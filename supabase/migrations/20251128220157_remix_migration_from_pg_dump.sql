CREATE EXTENSION IF NOT EXISTS "pg_graphql";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "plpgsql";
CREATE EXTENSION IF NOT EXISTS "supabase_vault";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
--
-- PostgreSQL database dump
--


-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--



--
-- Name: app_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.app_role AS ENUM (
    'retailer',
    'wholesaler',
    'educational',
    'corporate',
    'sports_team',
    'factory',
    'admin',
    'supplier'
);


--
-- Name: order_workflow_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.order_workflow_status AS ENUM (
    'quote_requested',
    'quote_sent',
    'admin_review',
    'awaiting_payment',
    'payment_received',
    'assigned_to_supplier',
    'sample_requested',
    'sample_submitted',
    'sample_approved',
    'bulk_production',
    'qc_inspection',
    'ready_to_ship',
    'shipped',
    'delivered',
    'completed',
    'cancelled',
    'on_hold'
);


--
-- Name: product_interaction_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.product_interaction_type AS ENUM (
    'hover',
    'quick_view_click',
    'wishlist_click',
    'color_swatch_click',
    'design_click',
    'quote_click',
    'add_to_cart',
    'view_details'
);


--
-- Name: production_stage; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.production_stage AS ENUM (
    'yarn_received',
    'knitting',
    'linking',
    'washing_finishing',
    'final_qc',
    'packing',
    'ready_to_ship'
);


--
-- Name: supplier_tier; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.supplier_tier AS ENUM (
    'bronze',
    'silver',
    'gold'
);


--
-- Name: verification_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.verification_status AS ENUM (
    'pending',
    'verified',
    'rejected',
    'suspended'
);


--
-- Name: assign_admin_role(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.assign_admin_role(target_user_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  -- Only existing admins can assign admin role
  IF NOT public.has_role(auth.uid(), 'admin') THEN
    RAISE EXCEPTION 'Unauthorized: Only admins can assign admin role';
  END IF;
  
  -- Verify target user exists
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = target_user_id) THEN
    RAISE EXCEPTION 'User not found';
  END IF;
  
  -- Insert admin role
  INSERT INTO public.user_roles (user_id, role)
  VALUES (target_user_id, 'admin'::public.app_role)
  ON CONFLICT (user_id, role) DO NOTHING;
END;
$$;


--
-- Name: assign_user_role(uuid, public.app_role); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.assign_user_role(target_user_id uuid, target_role public.app_role) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  -- Only admins can assign roles
  IF NOT public.has_role(auth.uid(), 'admin') THEN
    RAISE EXCEPTION 'Unauthorized: Only admins can assign roles';
  END IF;
  
  -- Prevent assigning admin role through this function (use assign_admin_role instead)
  IF target_role = 'admin' THEN
    RAISE EXCEPTION 'Use assign_admin_role() function to assign admin role';
  END IF;
  
  -- Verify target user exists
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = target_user_id) THEN
    RAISE EXCEPTION 'User not found';
  END IF;
  
  -- Insert role
  INSERT INTO public.user_roles (user_id, role)
  VALUES (target_user_id, target_role)
  ON CONFLICT (user_id, role) DO NOTHING;
END;
$$;


--
-- Name: calculate_factory_match_score(uuid, integer, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_factory_match_score(p_supplier_id uuid, p_quantity integer, p_target_date date) RETURNS numeric
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_score NUMERIC := 0;
  v_capacity_score NUMERIC := 0;
  v_quality_score NUMERIC := 0;
  v_speed_score NUMERIC := 0;
  v_available INTEGER;
  v_total INTEGER;
BEGIN
  -- Get factory capacity
  SELECT available_capacity, total_capacity
  INTO v_available, v_total
  FROM public.factory_capacity
  WHERE supplier_id = p_supplier_id
  AND date = COALESCE(p_target_date, CURRENT_DATE);
  
  -- If no capacity data, use default
  IF v_total IS NULL OR v_total = 0 THEN
    v_total := 1000;
    v_available := 500;
  END IF;
  
  -- Capacity score (higher available % = higher score)
  v_capacity_score := (v_available::NUMERIC / NULLIF(v_total, 0)) * 100;
  
  -- Quality score (performance_score from suppliers table)
  SELECT performance_score INTO v_quality_score
  FROM public.suppliers
  WHERE id = p_supplier_id;
  
  v_quality_score := COALESCE(v_quality_score, 50);
  
  -- Speed score (inverse of lead_time_days)
  SELECT (1.0 / NULLIF(lead_time_days, 0)) * 100 INTO v_speed_score
  FROM public.suppliers
  WHERE id = p_supplier_id;
  
  v_speed_score := COALESCE(v_speed_score, 50);
  
  -- Final score: weighted average
  v_score := (v_capacity_score * 0.5) + (v_quality_score * 0.3) + (v_speed_score * 0.2);
  
  RETURN ROUND(v_score, 2);
END;
$$;


--
-- Name: check_otp_rate_limit(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_otp_rate_limit(p_identifier text, p_identifier_type text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_attempt_count INTEGER;
  v_time_window INTERVAL := '1 hour';
  v_max_attempts INTEGER := 3;
BEGIN
  -- Count attempts in the last hour
  SELECT COUNT(*)
  INTO v_attempt_count
  FROM public.otp_verification_attempts
  WHERE identifier = p_identifier
    AND identifier_type = p_identifier_type
    AND attempt_time > (now() - v_time_window);
  
  -- Return rate limit info
  RETURN jsonb_build_object(
    'allowed', v_attempt_count < v_max_attempts,
    'attempts_used', v_attempt_count,
    'max_attempts', v_max_attempts,
    'attempts_remaining', GREATEST(0, v_max_attempts - v_attempt_count)
  );
END;
$$;


--
-- Name: create_update_notification(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_update_notification() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  -- Notify the buyer
  INSERT INTO public.notifications (user_id, title, message, type, link)
  SELECT 
    orders.buyer_id,
    'Production Update: Order #' || orders.order_number,
    'New update at stage: ' || NEW.stage,
    'order_update',
    '/orders/' || NEW.order_id
  FROM public.orders
  WHERE orders.id = NEW.order_id;
  
  RETURN NEW;
END;
$$;


--
-- Name: generate_invoice_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_invoice_number() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  next_number INTEGER;
  invoice_num TEXT;
BEGIN
  -- Get the count of existing invoices + 1
  SELECT COALESCE(MAX(CAST(SUBSTRING(invoice_number FROM 9) AS INTEGER)), 0) + 1
  INTO next_number
  FROM invoices
  WHERE invoice_number LIKE 'INV-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-%';
  
  -- Format: INV-YYYY-XXXX
  invoice_num := 'INV-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(next_number::TEXT, 4, '0');
  
  RETURN invoice_num;
END;
$$;


--
-- Name: generate_work_order_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_work_order_number() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  next_number INTEGER;
  wo_number TEXT;
BEGIN
  SELECT COALESCE(MAX(CAST(SUBSTRING(work_order_number FROM 8) AS INTEGER)), 0) + 1
  INTO next_number
  FROM public.work_orders
  WHERE work_order_number LIKE 'WO-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-%';
  
  wo_number := 'WO-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(next_number::TEXT, 4, '0');
  
  RETURN wo_number;
END;
$$;


SET default_table_access_method = heap;

--
-- Name: product_interactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_interactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    session_id text NOT NULL,
    product_id uuid NOT NULL,
    interaction_type public.product_interaction_type NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL,
    additional_data jsonb DEFAULT '{}'::jsonb,
    ip_address text,
    user_agent text,
    referrer text
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    category text NOT NULL,
    gauge text,
    yarn text,
    colors text[],
    image_url text NOT NULL,
    description text,
    featured boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    ai_generated_image boolean DEFAULT false,
    image_generation_prompt text,
    image_generation_date timestamp with time zone,
    image_approved_by_admin boolean DEFAULT false,
    price numeric(10,2),
    compare_at_price numeric(10,2),
    materials text[],
    popularity_score integer DEFAULT 0,
    lead_time_days integer DEFAULT 30,
    moq integer DEFAULT 50,
    search_vector tsvector
);


--
-- Name: product_engagement_metrics; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.product_engagement_metrics AS
 SELECT p.id AS product_id,
    p.title AS product_name,
    p.category,
    count(DISTINCT pi.session_id) AS unique_sessions,
    count(*) FILTER (WHERE (pi.interaction_type = 'hover'::public.product_interaction_type)) AS hover_count,
    count(*) FILTER (WHERE (pi.interaction_type = 'quick_view_click'::public.product_interaction_type)) AS quick_view_count,
    count(*) FILTER (WHERE (pi.interaction_type = 'wishlist_click'::public.product_interaction_type)) AS wishlist_count,
    count(*) FILTER (WHERE (pi.interaction_type = 'color_swatch_click'::public.product_interaction_type)) AS color_swatch_count,
    count(*) FILTER (WHERE (pi.interaction_type = 'design_click'::public.product_interaction_type)) AS design_click_count,
    count(*) FILTER (WHERE (pi.interaction_type = 'quote_click'::public.product_interaction_type)) AS quote_click_count,
    count(*) FILTER (WHERE (pi.interaction_type = 'view_details'::public.product_interaction_type)) AS view_details_count,
    max(pi."timestamp") AS last_interaction,
    count(*) AS total_interactions
   FROM (public.products p
     LEFT JOIN public.product_interactions pi ON ((p.id = pi.product_id)))
  WHERE ((pi."timestamp" > (now() - '30 days'::interval)) OR (pi."timestamp" IS NULL))
  GROUP BY p.id, p.title, p.category
  WITH NO DATA;


--
-- Name: get_product_engagement_metrics(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_product_engagement_metrics() RETURNS SETOF public.product_engagement_metrics
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  -- Only allow admins to access this data
  SELECT *
  FROM public.product_engagement_metrics
  WHERE public.has_role(auth.uid(), 'admin'::app_role);
$$;


--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  -- Insert profile data
  INSERT INTO public.profiles (id, full_name, company_name, phone)
  VALUES (
    new.id,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'company_name',
    new.raw_user_meta_data->>'phone'
  );
  
  -- SECURITY FIX: Always default to 'retailer', ignore client-supplied role
  -- Admin roles must be assigned through secure admin-only function
  INSERT INTO public.user_roles (user_id, role)
  VALUES (new.id, 'retailer'::public.app_role);
  
  RETURN new;
END;
$$;


--
-- Name: handle_new_user_role(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_user_role() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  -- Extract role from signup metadata and insert into user_roles
  IF NEW.raw_user_meta_data ? 'role' THEN
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, (NEW.raw_user_meta_data->>'role')::app_role)
    ON CONFLICT (user_id, role) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: has_any_role(uuid, public.app_role[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_any_role(_user_id uuid, _roles public.app_role[]) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1 
    FROM public.user_roles
    WHERE user_id = _user_id 
      AND role = ANY(_roles)
  )
$$;


--
-- Name: has_role(uuid, public.app_role); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_role(_user_id uuid, _role public.app_role) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = _role
  )
$$;


--
-- Name: increment_blog_post_shares(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.increment_blog_post_shares(post_id_param uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  UPDATE public.blog_posts
  SET shares_count = shares_count + 1
  WHERE id = post_id_param;
END;
$$;


--
-- Name: increment_blog_post_views(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.increment_blog_post_views(post_id_param uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  UPDATE public.blog_posts
  SET views_count = views_count + 1
  WHERE id = post_id_param;
END;
$$;


--
-- Name: link_quote_requests_to_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.link_quote_requests_to_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  -- Link any quote requests with matching email to the new user
  UPDATE public.quote_requests
  SET user_id = NEW.id
  WHERE email = NEW.email AND user_id IS NULL;
  
  RETURN NEW;
END;
$$;


--
-- Name: log_admin_action(text, text, uuid, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.log_admin_action(p_action text, p_resource_type text, p_resource_id uuid DEFAULT NULL::uuid, p_details jsonb DEFAULT '{}'::jsonb) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_log_id uuid;
BEGIN
  INSERT INTO public.admin_audit_logs (
    admin_id,
    action,
    resource_type,
    resource_id,
    details,
    created_at
  ) VALUES (
    auth.uid(),
    p_action,
    p_resource_type,
    p_resource_id,
    p_details,
    now()
  )
  RETURNING id INTO v_log_id;
  
  RETURN v_log_id;
END;
$$;


--
-- Name: log_otp_attempt(text, text, boolean, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.log_otp_attempt(p_identifier text, p_identifier_type text, p_success boolean, p_ip_address text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_attempt_id UUID;
BEGIN
  INSERT INTO public.otp_verification_attempts (
    identifier,
    identifier_type,
    success,
    ip_address
  ) VALUES (
    p_identifier,
    p_identifier_type,
    p_success,
    p_ip_address
  )
  RETURNING id INTO v_attempt_id;
  
  RETURN v_attempt_id;
END;
$$;


--
-- Name: products_search_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.products_search_trigger() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  NEW.search_vector := 
    setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(NEW.category, '')), 'C');
  RETURN NEW;
END;
$$;


--
-- Name: refresh_product_engagement_metrics(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.refresh_product_engagement_metrics() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY public.product_engagement_metrics;
END;
$$;


--
-- Name: remove_user_role(uuid, public.app_role); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.remove_user_role(target_user_id uuid, target_role public.app_role) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  -- Only admins can remove roles
  IF NOT public.has_role(auth.uid(), 'admin') THEN
    RAISE EXCEPTION 'Unauthorized: Only admins can remove roles';
  END IF;
  
  -- Delete the role
  DELETE FROM public.user_roles
  WHERE user_id = target_user_id AND role = target_role;
END;
$$;


--
-- Name: sanitize_public_orders(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sanitize_public_orders() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  -- If order is marked for public display, clear sensitive pricing
  IF NEW.display_publicly = true THEN
    NEW.buyer_price := NULL;
    NEW.supplier_price := NULL;
    NEW.admin_margin := NULL;
    NEW.anonymized_client_name := COALESCE(NEW.anonymized_client_name, 'Anonymous Client');
  END IF;
  
  RETURN NEW;
END;
$$;


--
-- Name: trigger_invoice_generation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_invoice_generation() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  IF NEW.workflow_status = 'completed' AND NEW.deposit_paid_at IS NOT NULL 
     AND (OLD.workflow_status IS NULL OR OLD.workflow_status != 'completed') THEN
    
    IF NOT EXISTS (
      SELECT 1 FROM public.invoices 
      WHERE order_id = NEW.id AND payment_type = 'full'
    ) THEN
      PERFORM pg_notify('invoice_generation', json_build_object('order_id', NEW.id)::text);
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;


--
-- Name: update_blog_post_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_blog_post_updated_at() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


--
-- Name: update_cms_content_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_cms_content_updated_at() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


--
-- Name: update_factory_capacity_on_order(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_factory_capacity_on_order() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  -- When a supplier order is created, update capacity utilization
  IF TG_OP = 'INSERT' AND NEW.supplier_id IS NOT NULL THEN
    INSERT INTO public.factory_capacity (supplier_id, date, current_utilization)
    VALUES (NEW.supplier_id, COALESCE(NEW.target_date, CURRENT_DATE), NEW.quantity)
    ON CONFLICT (supplier_id, date)
    DO UPDATE SET 
      current_utilization = factory_capacity.current_utilization + NEW.quantity,
      updated_at = now();
  END IF;
  
  -- When status changes to completed, log it
  IF TG_OP = 'UPDATE' AND OLD.status != 'completed' AND NEW.status = 'completed' THEN
    INSERT INTO public.capacity_utilization_logs (supplier_id, date, utilization_percentage, orders_count, revenue_generated)
    SELECT 
      NEW.supplier_id,
      CURRENT_DATE,
      (fc.current_utilization::NUMERIC / NULLIF(fc.total_capacity, 0)) * 100,
      1,
      NEW.supplier_price
    FROM public.factory_capacity fc
    WHERE fc.supplier_id = NEW.supplier_id 
    AND fc.date = CURRENT_DATE;
  END IF;
  
  RETURN NEW;
END;
$$;


--
-- Name: update_invoice_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_invoice_updated_at() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


--
-- Name: update_marketplace_products_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_marketplace_products_updated_at() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


--
-- Name: update_order_status(uuid, public.order_workflow_status, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_order_status(p_order_id uuid, p_new_status public.order_workflow_status, p_notes text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_old_status order_workflow_status;
BEGIN
  -- Get current status
  SELECT workflow_status INTO v_old_status
  FROM orders WHERE id = p_order_id;
  
  -- Update order status
  UPDATE orders
  SET workflow_status = p_new_status,
      updated_at = now()
  WHERE id = p_order_id;
  
  -- Log status change
  INSERT INTO order_status_history (order_id, old_status, new_status, changed_by, notes)
  VALUES (p_order_id, v_old_status, p_new_status, auth.uid(), p_notes);
END;
$$;


--
-- Name: update_production_batches_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_production_batches_updated_at() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


--
-- Name: update_production_stage_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_production_stage_status() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  NEW.updated_at = now();
  
  -- Auto-set started_at when first update
  IF OLD.completion_percentage = 0 AND NEW.completion_percentage > 0 AND NEW.started_at IS NULL THEN
    NEW.started_at = now();
    NEW.status = 'in_progress';
  END IF;
  
  -- Auto-set completed_at when 100%
  IF NEW.completion_percentage = 100 AND NEW.completed_at IS NULL THEN
    NEW.completed_at = now();
    NEW.status = 'completed';
  END IF;
  
  RETURN NEW;
END;
$$;


--
-- Name: update_supplier_orders_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_supplier_orders_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


--
-- Name: update_supplier_performance_metrics(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_supplier_performance_metrics() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_supplier_id UUID;
  v_total_orders INTEGER;
  v_on_time_count INTEGER;
  v_avg_quality NUMERIC;
  v_avg_communication NUMERIC;
BEGIN
  -- Get supplier_id from the order
  SELECT supplier_id INTO v_supplier_id
  FROM public.supplier_orders
  WHERE id = NEW.supplier_order_id;
  
  -- Calculate metrics
  SELECT 
    COUNT(*),
    COUNT(*) FILTER (WHERE on_time = true),
    AVG(quality_score),
    AVG(communication_score)
  INTO v_total_orders, v_on_time_count, v_avg_quality, v_avg_communication
  FROM public.supplier_performance
  WHERE supplier_id = v_supplier_id;
  
  -- Update supplier table
  UPDATE public.suppliers
  SET 
    total_orders_completed = v_total_orders,
    on_time_delivery_rate = CASE WHEN v_total_orders > 0 THEN (v_on_time_count::NUMERIC / v_total_orders) * 100 ELSE 0 END,
    performance_score = (v_avg_quality + v_avg_communication) * 10
  WHERE id = v_supplier_id;
  
  RETURN NEW;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


--
-- Name: update_work_orders_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_work_orders_updated_at() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


--
-- Name: validate_message_recipient(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_message_recipient() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  -- Check if recipient exists in profiles table (not auth.users)
  IF NOT EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = NEW.recipient_id
  ) THEN
    RAISE EXCEPTION 'Invalid recipient';
  END IF;
  
  RETURN NEW;
END;
$$;


--
-- Name: admin_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_actions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    admin_id uuid,
    action_type text NOT NULL,
    entity_type text NOT NULL,
    entity_id uuid,
    details jsonb,
    ip_address text,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: admin_audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_audit_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    admin_id uuid,
    action text NOT NULL,
    resource_type text NOT NULL,
    resource_id uuid,
    details jsonb DEFAULT '{}'::jsonb,
    ip_address text,
    user_agent text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ai_cost_tracking; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_cost_tracking (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    function_name text NOT NULL,
    model text NOT NULL,
    request_tokens integer,
    response_tokens integer,
    estimated_cost numeric(10,6),
    session_id text,
    user_id uuid,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: ai_hourly_costs; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ai_hourly_costs WITH (security_invoker='true') AS
 SELECT date_trunc('hour'::text, created_at) AS hour,
    function_name,
    model,
    count(*) AS request_count,
    sum(request_tokens) AS total_request_tokens,
    sum(response_tokens) AS total_response_tokens,
    sum(estimated_cost) AS total_cost
   FROM public.ai_cost_tracking
  GROUP BY (date_trunc('hour'::text, created_at)), function_name, model;


--
-- Name: ai_quote_rate_limits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_quote_rate_limits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    identifier text NOT NULL,
    identifier_type text NOT NULL,
    request_count integer DEFAULT 1,
    window_start timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT ai_quote_rate_limits_identifier_type_check CHECK ((identifier_type = ANY (ARRAY['session'::text, 'user'::text, 'ip'::text])))
);


--
-- Name: ai_quotes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_quotes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    customer_email text,
    customer_name text,
    product_type text NOT NULL,
    quantity integer NOT NULL,
    complexity_level text,
    fabric_type text,
    additional_requirements text,
    quote_data jsonb NOT NULL,
    total_price numeric(10,2) NOT NULL,
    estimated_delivery_days integer NOT NULL,
    ai_suggestions text,
    alternative_options jsonb,
    status text DEFAULT 'draft'::text,
    converted_to_order_id uuid,
    session_id text,
    phone_number text,
    country text,
    lead_status text DEFAULT 'new'::text,
    lead_notes text,
    specialty_sourcing_required boolean DEFAULT false,
    production_route text,
    specialty_notes text,
    bangladesh_cost numeric(10,2),
    specialty_cost numeric(10,2),
    admin_markup numeric(10,2),
    user_id uuid,
    market_research_id uuid,
    confidence_score numeric,
    research_sources jsonb DEFAULT '[]'::jsonb,
    price_justification text,
    comparable_products jsonb DEFAULT '[]'::jsonb,
    conversation_history jsonb DEFAULT '[]'::jsonb,
    refinement_count integer DEFAULT 0,
    ip_address text,
    CONSTRAINT ai_quotes_confidence_score_check CHECK (((confidence_score >= (0)::numeric) AND (confidence_score <= (100)::numeric))),
    CONSTRAINT ai_quotes_lead_status_check CHECK ((lead_status = ANY (ARRAY['new'::text, 'contacted'::text, 'hot'::text, 'warm'::text, 'cold'::text, 'lost'::text]))),
    CONSTRAINT ai_quotes_production_route_check CHECK ((production_route = ANY (ARRAY['bangladesh_only'::text, 'hybrid'::text, 'specialty_only'::text])))
);


--
-- Name: ai_usage_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_usage_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id text,
    user_id uuid,
    function_name text NOT NULL,
    estimated_cost numeric(10,4),
    request_data jsonb,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: automation_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_rules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    rule_name text NOT NULL,
    rule_type text NOT NULL,
    conditions jsonb NOT NULL,
    actions jsonb NOT NULL,
    active boolean DEFAULT true,
    priority integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT automation_rules_rule_type_check CHECK ((rule_type = ANY (ARRAY['order_assignment'::text, 'email_trigger'::text, 'invoice_generation'::text, 'notification'::text])))
);


--
-- Name: batch_contributions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.batch_contributions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    batch_id uuid,
    order_id uuid,
    quantity integer NOT NULL,
    style_details jsonb NOT NULL,
    buyer_price_per_unit numeric(10,2) NOT NULL,
    contribution_margin numeric(10,2),
    committed_at timestamp without time zone DEFAULT now()
);


--
-- Name: blog_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blog_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    description text,
    color text DEFAULT '#10b981'::text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: blog_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blog_comments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    post_id uuid NOT NULL,
    user_id uuid,
    author_name text NOT NULL,
    author_email text NOT NULL,
    content text NOT NULL,
    approved boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: blog_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blog_posts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    slug text NOT NULL,
    excerpt text NOT NULL,
    content text NOT NULL,
    category text NOT NULL,
    author_id uuid,
    featured_image_url text NOT NULL,
    thumbnail_url text,
    meta_title text,
    meta_description text,
    meta_keywords text,
    published boolean DEFAULT false,
    published_at timestamp with time zone,
    views_count integer DEFAULT 0,
    shares_count integer DEFAULT 0,
    tags jsonb DEFAULT '[]'::jsonb,
    seo_data jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: bootstrap_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bootstrap_attempts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ip_address text NOT NULL,
    success boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: capacity_utilization_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.capacity_utilization_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    supplier_id uuid NOT NULL,
    date date NOT NULL,
    utilization_percentage numeric(5,2) NOT NULL,
    orders_count integer DEFAULT 0,
    revenue_generated numeric(10,2) DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: case_studies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.case_studies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    client_name text NOT NULL,
    industry text NOT NULL,
    product_type text NOT NULL,
    quantity integer NOT NULL,
    challenge text NOT NULL,
    solution text NOT NULL,
    results text NOT NULL,
    testimonial text NOT NULL,
    testimonial_author text NOT NULL,
    hero_image_url text,
    process_images jsonb DEFAULT '[]'::jsonb,
    metrics jsonb DEFAULT '{}'::jsonb,
    featured boolean DEFAULT false,
    published boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: certifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    icon_name text NOT NULL,
    color_class text NOT NULL,
    bg_color_class text NOT NULL,
    status text NOT NULL,
    certificate_number text,
    issuing_body text,
    issue_date date,
    expiry_date date,
    certificate_url text,
    display_order integer DEFAULT 0,
    active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT certifications_status_check CHECK ((status = ANY (ARRAY['certified'::text, 'in_progress'::text, 'aspirational'::text])))
);


--
-- Name: cms_content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cms_content (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    section text NOT NULL,
    content_type text NOT NULL,
    content jsonb NOT NULL,
    active boolean DEFAULT true,
    display_order integer DEFAULT 0,
    updated_by uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: company_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.company_info (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type text NOT NULL,
    legal_name text NOT NULL,
    registration_number text,
    tax_id text,
    address text NOT NULL,
    city text,
    state text,
    country text NOT NULL,
    zip_code text,
    display_order integer DEFAULT 0,
    active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT company_info_entity_type_check CHECK ((entity_type = ANY (ARRAY['us_llc'::text, 'bangladesh'::text])))
);


--
-- Name: conversation_analytics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversation_analytics (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    date date DEFAULT CURRENT_DATE NOT NULL,
    total_conversations integer DEFAULT 0,
    buyer_conversations integer DEFAULT 0,
    supplier_conversations integer DEFAULT 0,
    completed_conversations integer DEFAULT 0,
    quotes_generated integer DEFAULT 0,
    avg_messages_per_conversation numeric(10,2),
    common_questions jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: conversation_context; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversation_context (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id text NOT NULL,
    user_id uuid,
    email text,
    phone text,
    intent text,
    status text DEFAULT 'active'::text,
    transcript jsonb DEFAULT '[]'::jsonb,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    stage text DEFAULT 'greeting'::text,
    extracted_data jsonb DEFAULT '{}'::jsonb,
    style_preference text,
    budget_range text,
    timeline_urgency text,
    design_readiness text,
    lead_score integer DEFAULT 0,
    conversation_path text,
    target_market text,
    decision_stage text,
    CONSTRAINT voice_conversations_intent_check CHECK ((intent = ANY (ARRAY['buyer'::text, 'supplier'::text, 'unknown'::text]))),
    CONSTRAINT voice_conversations_status_check CHECK ((status = ANY (ARRAY['active'::text, 'completed'::text, 'abandoned'::text])))
);


--
-- Name: conversation_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversation_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    conversation_id uuid NOT NULL,
    role text NOT NULL,
    content text NOT NULL,
    audio_url text,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    sentiment text,
    topics text[],
    quick_replies jsonb,
    CONSTRAINT conversation_messages_role_check CHECK ((role = ANY (ARRAY['user'::text, 'assistant'::text, 'system'::text])))
);


--
-- Name: conversation_rate_limits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversation_rate_limits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    identifier text NOT NULL,
    request_count integer DEFAULT 1 NOT NULL,
    window_start timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: security_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.security_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_type text NOT NULL,
    severity text NOT NULL,
    source text NOT NULL,
    user_id uuid,
    session_id text,
    ip_address text,
    user_agent text,
    details jsonb,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT security_events_event_type_check CHECK ((event_type = ANY (ARRAY['captcha_failure'::text, 'rate_limit_violation'::text, 'suspicious_pattern'::text, 'cost_alert'::text]))),
    CONSTRAINT security_events_severity_check CHECK ((severity = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'critical'::text])))
);


--
-- Name: daily_security_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.daily_security_summary WITH (security_invoker='true') AS
 SELECT date_trunc('day'::text, created_at) AS day,
    event_type,
    severity,
    count(*) AS event_count,
    count(DISTINCT ip_address) AS unique_ips,
    count(DISTINCT session_id) AS unique_sessions
   FROM public.security_events
  GROUP BY (date_trunc('day'::text, created_at)), event_type, severity;


--
-- Name: defects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.defects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    qc_check_id uuid NOT NULL,
    defect_type text NOT NULL,
    severity text NOT NULL,
    quantity integer NOT NULL,
    description text,
    photo_url text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT defects_severity_check CHECK ((severity = ANY (ARRAY['minor'::text, 'major'::text, 'critical'::text])))
);


--
-- Name: email_verification_otps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_verification_otps (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    otp text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    verified boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    ip_address text,
    session_id text,
    attempt_count integer DEFAULT 0,
    resend_email_id text,
    email_sent_at timestamp with time zone,
    delivery_status text DEFAULT 'pending'::text,
    delivery_error text,
    user_id uuid,
    CONSTRAINT email_verification_otps_delivery_status_check CHECK ((delivery_status = ANY (ARRAY['pending'::text, 'sent'::text, 'failed'::text, 'bounced'::text, 'delivered'::text])))
);

ALTER TABLE ONLY public.email_verification_otps FORCE ROW LEVEL SECURITY;


--
-- Name: exchange_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exchange_rates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    base_currency text DEFAULT 'USD'::text NOT NULL,
    target_currency text NOT NULL,
    rate numeric(10,6) NOT NULL,
    fetched_at timestamp with time zone DEFAULT now() NOT NULL,
    valid_until timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: exit_intent_sample_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exit_intent_sample_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    source text DEFAULT 'exit_intent_popup'::text NOT NULL,
    notes text,
    ip_address text,
    user_agent text,
    CONSTRAINT exit_intent_sample_requests_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'sent'::text, 'fulfilled'::text]))),
    CONSTRAINT valid_email_format CHECK ((email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text))
);


--
-- Name: factory_capacity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.factory_capacity (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    supplier_id uuid NOT NULL,
    date date DEFAULT CURRENT_DATE NOT NULL,
    total_capacity integer DEFAULT 0 NOT NULL,
    current_utilization integer DEFAULT 0 NOT NULL,
    available_capacity integer GENERATED ALWAYS AS ((total_capacity - current_utilization)) STORED,
    machines_count integer DEFAULT 0,
    workers_count integer DEFAULT 0,
    shift_hours integer DEFAULT 8,
    updated_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: industry_knowledge; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.industry_knowledge (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    category text NOT NULL,
    subcategory text,
    title text NOT NULL,
    content text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb,
    version integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid,
    invoice_number text NOT NULL,
    amount numeric NOT NULL,
    payment_type text NOT NULL,
    status text DEFAULT 'pending'::text,
    due_date date,
    paid_at timestamp with time zone,
    pdf_url text,
    stripe_invoice_id text,
    stripe_payment_intent_id text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT invoices_payment_type_check CHECK ((payment_type = ANY (ARRAY['deposit'::text, 'balance'::text, 'full'::text]))),
    CONSTRAINT invoices_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'paid'::text, 'cancelled'::text, 'refunded'::text])))
);


--
-- Name: market_research_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.market_research_cache (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_category text NOT NULL,
    quantity_range text NOT NULL,
    research_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    sources text[] DEFAULT ARRAY[]::text[],
    confidence_score numeric,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT market_research_cache_confidence_score_check CHECK (((confidence_score >= (0)::numeric) AND (confidence_score <= (100)::numeric)))
);


--
-- Name: marketplace_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marketplace_products (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    supplier_id uuid NOT NULL,
    product_type text NOT NULL,
    title text NOT NULL,
    description text,
    category text NOT NULL,
    subcategory text,
    base_price numeric NOT NULL,
    available_quantity integer DEFAULT 0 NOT NULL,
    moq integer DEFAULT 1 NOT NULL,
    unit text DEFAULT 'pieces'::text NOT NULL,
    sizes text[] DEFAULT ARRAY[]::text[],
    colors text[] DEFAULT ARRAY[]::text[],
    material text,
    gsm integer,
    fabric_composition text,
    lead_time_days integer DEFAULT 0 NOT NULL,
    shipping_from text,
    status text DEFAULT 'pending'::text NOT NULL,
    quality_score integer DEFAULT 0,
    is_featured boolean DEFAULT false,
    views integer DEFAULT 0,
    sales integer DEFAULT 0,
    rating numeric DEFAULT 0,
    image_urls text[] DEFAULT ARRAY[]::text[],
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sender_id uuid,
    recipient_id uuid,
    order_id uuid,
    subject text,
    message text NOT NULL,
    attachments text[],
    read boolean DEFAULT false,
    read_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: notification_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_preferences (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    email_orders boolean DEFAULT true NOT NULL,
    email_messages boolean DEFAULT true NOT NULL,
    email_production boolean DEFAULT true NOT NULL,
    email_payments boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    title text NOT NULL,
    message text NOT NULL,
    type text NOT NULL,
    read boolean DEFAULT false,
    link text,
    created_at timestamp with time zone DEFAULT now(),
    notification_type text,
    metadata jsonb,
    read_at timestamp with time zone,
    action_url text,
    CONSTRAINT notifications_type_check CHECK ((type = ANY (ARRAY['order_update'::text, 'qc_alert'::text, 'system'::text, 'shipment'::text])))
);


--
-- Name: order_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid NOT NULL,
    file_name text NOT NULL,
    file_url text NOT NULL,
    file_type text NOT NULL,
    uploaded_by uuid NOT NULL,
    uploaded_at timestamp with time zone DEFAULT now() NOT NULL,
    document_type text DEFAULT 'general'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: order_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    sender_role text NOT NULL,
    message text NOT NULL,
    attachments text[],
    translated_message text,
    read_by uuid[],
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: order_status_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_status_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid,
    old_status public.order_workflow_status,
    new_status public.order_workflow_status NOT NULL,
    changed_by uuid,
    notes text,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: order_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_updates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid NOT NULL,
    stage public.production_stage NOT NULL,
    message text,
    photos text[],
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    completion_percentage integer DEFAULT 0,
    CONSTRAINT order_updates_completion_percentage_check CHECK (((completion_percentage >= 0) AND (completion_percentage <= 100)))
);

ALTER TABLE ONLY public.order_updates REPLICA IDENTITY FULL;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_number text NOT NULL,
    buyer_id uuid NOT NULL,
    factory_id uuid,
    product_type text NOT NULL,
    quantity integer NOT NULL,
    status text DEFAULT 'pending'::text,
    target_date date,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    current_stage public.production_stage DEFAULT 'yarn_received'::public.production_stage,
    stage_progress jsonb DEFAULT '{"linking": 0, "packing": 0, "final_qc": 0, "knitting": 0, "ready_to_ship": 0, "yarn_received": 0, "washing_finishing": 0}'::jsonb,
    supplier_id uuid,
    quote_id uuid,
    production_status text DEFAULT 'pending'::text,
    milestone_tracker jsonb DEFAULT '{"production": {"status": "pending", "completion_date": null}, "packing_shipping": {"status": "pending", "completion_date": null}, "quality_inspection": {"status": "pending", "completion_date": null}, "cutting_preparation": {"status": "pending", "completion_date": null}, "material_procurement": {"status": "pending", "completion_date": null}}'::jsonb,
    expected_delivery_date date,
    actual_delivery_date date,
    tracking_token text,
    payment_status text DEFAULT 'pending'::text,
    deposit_amount numeric,
    balance_amount numeric,
    deposit_paid_at timestamp with time zone,
    balance_paid_at timestamp with time zone,
    stripe_payment_intent_id text,
    stripe_customer_id text,
    workflow_status public.order_workflow_status DEFAULT 'quote_requested'::public.order_workflow_status,
    admin_notes text,
    buyer_price numeric,
    supplier_price numeric,
    admin_margin numeric,
    margin_percentage numeric,
    assigned_by uuid,
    assigned_at timestamp with time zone,
    is_demo_order boolean DEFAULT false,
    display_publicly boolean DEFAULT false,
    anonymized_client_name text,
    CONSTRAINT orders_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT orders_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'confirmed'::text, 'in_production'::text, 'quality_check'::text, 'shipped'::text, 'delivered'::text, 'cancelled'::text])))
);


--
-- Name: otp_rate_limits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.otp_rate_limits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    identifier text NOT NULL,
    identifier_type text NOT NULL,
    request_count integer DEFAULT 1,
    window_start timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: otp_verification_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.otp_verification_attempts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    identifier text NOT NULL,
    identifier_type text NOT NULL,
    attempt_time timestamp with time zone DEFAULT now() NOT NULL,
    success boolean DEFAULT false NOT NULL,
    ip_address text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: payment_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid,
    invoice_id uuid,
    amount numeric NOT NULL,
    payment_type text NOT NULL,
    payment_method text,
    transaction_id text,
    status text NOT NULL,
    paid_by uuid,
    paid_to uuid,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT payment_history_payment_type_check CHECK ((payment_type = ANY (ARRAY['deposit'::text, 'balance'::text, 'full'::text, 'supplier_payment'::text]))),
    CONSTRAINT payment_history_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'completed'::text, 'failed'::text, 'refunded'::text])))
);


--
-- Name: phone_verification_otps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.phone_verification_otps (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    phone text NOT NULL,
    otp text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    verified boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    attempt_count integer DEFAULT 0,
    ip_address text,
    session_id text
);

ALTER TABLE ONLY public.phone_verification_otps FORCE ROW LEVEL SECURITY;


--
-- Name: product_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    description text,
    image_url text,
    display_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: production_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.production_batches (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_category text NOT NULL,
    product_variant_base text NOT NULL,
    target_quantity integer DEFAULT 200 NOT NULL,
    current_quantity integer DEFAULT 0,
    current_style_count integer DEFAULT 0,
    max_styles integer DEFAULT 4,
    supplier_id uuid,
    batch_status text DEFAULT 'filling'::text,
    unit_price_base numeric(10,2) NOT NULL,
    complexity_multiplier numeric(3,2) DEFAULT 1.0,
    estimated_start_date date,
    actual_start_date date,
    window_closes_at timestamp without time zone DEFAULT (now() + '7 days'::interval),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT production_batches_batch_status_check CHECK ((batch_status = ANY (ARRAY['filling'::text, 'confirmed'::text, 'in_production'::text, 'completed'::text, 'cancelled'::text])))
);


--
-- Name: production_stage_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.production_stage_templates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_category text NOT NULL,
    stage_name text NOT NULL,
    stage_number integer NOT NULL,
    description text,
    estimated_days integer,
    active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: production_stages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.production_stages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    supplier_order_id uuid NOT NULL,
    stage_number integer NOT NULL,
    stage_name text NOT NULL,
    description text,
    target_date date,
    completion_percentage integer DEFAULT 0,
    status text DEFAULT 'pending'::text NOT NULL,
    photos text[],
    notes text,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    updated_by uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT production_stages_completion_percentage_check CHECK (((completion_percentage >= 0) AND (completion_percentage <= 100)))
);

ALTER TABLE ONLY public.production_stages REPLICA IDENTITY FULL;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    full_name text,
    company_name text,
    phone text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    address text,
    bio text,
    email text,
    phone_verified boolean DEFAULT false,
    phone_verified_at timestamp with time zone,
    role text DEFAULT 'user'::text,
    CONSTRAINT profiles_role_check CHECK ((role = ANY (ARRAY['user'::text, 'admin'::text, 'super_admin'::text])))
);


--
-- Name: qc_checks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.qc_checks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid NOT NULL,
    inspector_id uuid NOT NULL,
    check_date timestamp with time zone DEFAULT now() NOT NULL,
    stage public.production_stage NOT NULL,
    total_pieces_checked integer NOT NULL,
    passed_pieces integer NOT NULL,
    failed_pieces integer NOT NULL,
    notes text,
    photos text[],
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: quote_approvals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quote_approvals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    quote_id uuid,
    admin_id uuid,
    status text NOT NULL,
    adjusted_price numeric,
    adjusted_delivery_days integer,
    admin_notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT quote_approvals_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text, 'adjusted'::text, 'rejected'::text])))
);


--
-- Name: quote_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quote_configurations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    product_category text NOT NULL,
    base_price_per_unit numeric(10,2) NOT NULL,
    moq_min integer NOT NULL,
    moq_max integer NOT NULL,
    complexity_multiplier jsonb DEFAULT '{"medium": 1.3, "simple": 1.0, "complex": 1.6}'::jsonb,
    sampling_days integer DEFAULT 7,
    production_days_per_100_units integer DEFAULT 5,
    base_lead_time_days integer DEFAULT 30,
    material_cost_multipliers jsonb DEFAULT '{}'::jsonb,
    is_active boolean DEFAULT true
);


--
-- Name: quote_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quote_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    company text,
    whatsapp text,
    product_type text NOT NULL,
    quantity integer NOT NULL,
    gauge text,
    target_date date,
    notes text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    session_id text,
    user_id uuid,
    CONSTRAINT valid_email CHECK ((email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text)),
    CONSTRAINT valid_quantity CHECK (((quantity > 0) AND (quantity <= 10000000)))
);


--
-- Name: quote_usage_tracking; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quote_usage_tracking (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    ip_address text,
    session_id text,
    quote_count integer DEFAULT 1,
    window_start timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: quotes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quotes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    buyer_id uuid,
    session_id text,
    product_type text NOT NULL,
    quantity integer NOT NULL,
    target_moq integer,
    complexity_level text,
    fabric_type text,
    customization_details text,
    additional_requirements text,
    tech_pack_urls text[],
    reference_image_urls text[],
    target_price_per_unit numeric,
    target_delivery_date date,
    matched_supplier_ids uuid[],
    status text DEFAULT 'draft'::text NOT NULL,
    ai_estimation jsonb,
    customer_name text,
    customer_email text,
    customer_phone text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: resource_downloads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_downloads (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    full_name text,
    company_name text,
    resource_type text NOT NULL,
    source text DEFAULT 'homepage'::text,
    ip_address text,
    user_agent text,
    email_sent boolean DEFAULT false,
    email_sent_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT resource_downloads_resource_type_check CHECK ((resource_type = ANY (ARRAY['buyers_guide'::text, 'material_chart'::text])))
);


--
-- Name: sample_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sample_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid NOT NULL,
    requested_by uuid,
    requested_at timestamp with time zone DEFAULT now(),
    approved_at timestamp with time zone,
    rejected_at timestamp with time zone,
    sample_type text NOT NULL,
    specifications jsonb,
    status text DEFAULT 'pending'::text,
    notes text,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: sample_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sample_submissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sample_request_id uuid NOT NULL,
    submitted_by uuid,
    submitted_at timestamp with time zone DEFAULT now(),
    photos text[],
    measurements jsonb,
    supplier_notes text,
    feedback text,
    approved boolean,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: shipping_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipping_info (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid NOT NULL,
    tracking_number text,
    carrier text,
    status text DEFAULT 'preparing'::text NOT NULL,
    shipped_date timestamp with time zone,
    estimated_delivery date,
    actual_delivery date,
    current_location text,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: social_shares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.social_shares (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    post_id uuid NOT NULL,
    platform text NOT NULL,
    shared_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id uuid,
    session_id text,
    ip_address text
);


--
-- Name: supplier_capabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier_capabilities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    supplier_id uuid NOT NULL,
    product_category text NOT NULL,
    materials text[] DEFAULT '{}'::text[] NOT NULL,
    techniques text[] DEFAULT '{}'::text[] NOT NULL,
    gauge_range text,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: supplier_certifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier_certifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    supplier_id uuid NOT NULL,
    certification_name text NOT NULL,
    certification_body text,
    issue_date date,
    expiry_date date,
    document_url text,
    verified boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: supplier_media; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier_media (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    supplier_id uuid NOT NULL,
    media_type text NOT NULL,
    url text NOT NULL,
    caption text,
    display_order integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: supplier_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    supplier_order_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    message text NOT NULL,
    attachments text[],
    read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: supplier_mou_terms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier_mou_terms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    supplier_id uuid,
    tier text DEFAULT 'standard'::text,
    moq_per_batch integer DEFAULT 200,
    max_styles_allowed integer DEFAULT 4,
    base_price numeric(10,2) NOT NULL,
    complexity_premium_percent numeric(4,2) DEFAULT 5.0,
    lead_time_days integer DEFAULT 14,
    extra_style_lead_time integer DEFAULT 2,
    monthly_batch_minimum integer DEFAULT 3,
    signed_at timestamp without time zone,
    mou_document_url text,
    status text DEFAULT 'pending'::text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT supplier_mou_terms_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'active'::text, 'suspended'::text, 'terminated'::text]))),
    CONSTRAINT supplier_mou_terms_tier_check CHECK ((tier = ANY (ARRAY['standard'::text, 'premium'::text, 'specialty'::text])))
);


--
-- Name: supplier_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier_orders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_number text NOT NULL,
    supplier_id uuid,
    buyer_order_id uuid,
    product_type text NOT NULL,
    quantity integer NOT NULL,
    buyer_price numeric,
    supplier_price numeric,
    margin numeric GENERATED ALWAYS AS ((buyer_price - supplier_price)) STORED,
    target_date date,
    status text DEFAULT 'pending'::text NOT NULL,
    tech_pack_urls text[],
    reference_images text[],
    special_instructions text,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    acceptance_status text DEFAULT 'pending'::text,
    accepted_at timestamp with time zone,
    rejected_at timestamp with time zone,
    rejection_reason text,
    counter_offer_price numeric,
    counter_offer_notes text,
    CONSTRAINT supplier_orders_acceptance_status_check CHECK ((acceptance_status = ANY (ARRAY['pending'::text, 'accepted'::text, 'rejected'::text, 'counter_offered'::text])))
);


--
-- Name: supplier_payables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier_payables (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    supplier_id uuid,
    order_id uuid,
    amount_due numeric NOT NULL,
    amount_paid numeric DEFAULT 0,
    due_date date,
    status text NOT NULL,
    payment_terms text,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT supplier_payables_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'partial'::text, 'paid'::text, 'overdue'::text])))
);


--
-- Name: supplier_performance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier_performance (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    supplier_id uuid NOT NULL,
    supplier_order_id uuid NOT NULL,
    committed_delivery_date date NOT NULL,
    actual_delivery_date date,
    on_time boolean,
    quality_score integer,
    communication_score integer,
    overall_score numeric GENERATED ALWAYS AS ((((quality_score + communication_score))::numeric / 2.0)) STORED,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT supplier_performance_communication_score_check CHECK (((communication_score >= 1) AND (communication_score <= 5))),
    CONSTRAINT supplier_performance_quality_score_check CHECK (((quality_score >= 1) AND (quality_score <= 5)))
);


--
-- Name: supplier_quotes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier_quotes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    quote_id uuid NOT NULL,
    supplier_id uuid NOT NULL,
    unit_price numeric NOT NULL,
    total_price numeric NOT NULL,
    lead_time_days integer NOT NULL,
    moq_offered integer NOT NULL,
    pricing_breakdown jsonb,
    materials_description text,
    terms_conditions text,
    valid_until date,
    notes text,
    status text DEFAULT 'pending'::text NOT NULL,
    submitted_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: supplier_ratings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier_ratings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    supplier_id uuid NOT NULL,
    order_id uuid,
    buyer_id uuid NOT NULL,
    quality_score integer,
    communication_score integer,
    delivery_score integer,
    overall_score numeric GENERATED ALWAYS AS (((((quality_score + communication_score) + delivery_score))::numeric / 3.0)) STORED,
    review_text text,
    on_time_delivery boolean,
    would_recommend boolean,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT supplier_ratings_communication_score_check CHECK (((communication_score >= 1) AND (communication_score <= 5))),
    CONSTRAINT supplier_ratings_delivery_score_check CHECK (((delivery_score >= 1) AND (delivery_score <= 5))),
    CONSTRAINT supplier_ratings_quality_score_check CHECK (((quality_score >= 1) AND (quality_score <= 5)))
);


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suppliers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    company_name text NOT NULL,
    factory_location text NOT NULL,
    address text,
    workforce_size integer,
    moq_minimum integer DEFAULT 50 NOT NULL,
    moq_maximum integer,
    lead_time_days integer DEFAULT 45 NOT NULL,
    verification_status public.verification_status DEFAULT 'pending'::public.verification_status NOT NULL,
    tier public.supplier_tier DEFAULT 'bronze'::public.supplier_tier NOT NULL,
    about text,
    specializations text[],
    website_url text,
    contact_person text,
    contact_phone text,
    contact_email text,
    business_registration_number text,
    year_established integer,
    total_capacity_monthly integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    managed_by_sleek boolean DEFAULT true,
    performance_score numeric DEFAULT 0,
    total_orders_completed integer DEFAULT 0,
    on_time_delivery_rate numeric DEFAULT 0,
    avg_capacity_utilization numeric(5,2) DEFAULT 0,
    capacity_update_frequency text DEFAULT 'daily'::text,
    auto_accept_orders boolean DEFAULT false
);


--
-- Name: suppliers_public; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.suppliers_public WITH (security_invoker='on') AS
 SELECT id,
    company_name,
    factory_location,
    address,
    specializations,
    lead_time_days,
    website_url,
    created_at,
    updated_at,
    verification_status,
    tier,
    about,
    moq_minimum,
    moq_maximum
   FROM public.suppliers
  WHERE (verification_status = 'verified'::public.verification_status);


--
-- Name: timeline_predictions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.timeline_predictions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    quote_id uuid,
    order_id uuid,
    stages jsonb NOT NULL,
    total_days integer NOT NULL,
    estimated_completion_date date NOT NULL,
    confidence_score numeric(3,2),
    actual_completion_date date,
    accuracy_score numeric(3,2)
);


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    role public.app_role DEFAULT 'retailer'::public.app_role NOT NULL
);


--
-- Name: wishlist_rate_limits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wishlist_rate_limits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    action_count integer DEFAULT 1,
    window_start timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: wishlists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wishlists (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    product_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    notes text
);


--
-- Name: work_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_orders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid,
    supplier_id uuid,
    work_order_number text NOT NULL,
    pdf_url text,
    status text NOT NULL,
    rejection_reason text,
    sent_at timestamp with time zone,
    accepted_at timestamp with time zone,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT work_orders_status_check CHECK ((status = ANY (ARRAY['sent'::text, 'accepted'::text, 'rejected'::text, 'in_progress'::text, 'completed'::text])))
);


--
-- Name: admin_actions admin_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_actions
    ADD CONSTRAINT admin_actions_pkey PRIMARY KEY (id);


--
-- Name: admin_audit_logs admin_audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_audit_logs
    ADD CONSTRAINT admin_audit_logs_pkey PRIMARY KEY (id);


--
-- Name: ai_cost_tracking ai_cost_tracking_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_cost_tracking
    ADD CONSTRAINT ai_cost_tracking_pkey PRIMARY KEY (id);


--
-- Name: ai_quote_rate_limits ai_quote_rate_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_quote_rate_limits
    ADD CONSTRAINT ai_quote_rate_limits_pkey PRIMARY KEY (id);


--
-- Name: ai_quotes ai_quotes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_quotes
    ADD CONSTRAINT ai_quotes_pkey PRIMARY KEY (id);


--
-- Name: ai_usage_logs ai_usage_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_usage_logs
    ADD CONSTRAINT ai_usage_logs_pkey PRIMARY KEY (id);


--
-- Name: automation_rules automation_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_rules
    ADD CONSTRAINT automation_rules_pkey PRIMARY KEY (id);


--
-- Name: batch_contributions batch_contributions_batch_id_order_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.batch_contributions
    ADD CONSTRAINT batch_contributions_batch_id_order_id_key UNIQUE (batch_id, order_id);


--
-- Name: batch_contributions batch_contributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.batch_contributions
    ADD CONSTRAINT batch_contributions_pkey PRIMARY KEY (id);


--
-- Name: blog_categories blog_categories_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_categories
    ADD CONSTRAINT blog_categories_name_key UNIQUE (name);


--
-- Name: blog_categories blog_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_categories
    ADD CONSTRAINT blog_categories_pkey PRIMARY KEY (id);


--
-- Name: blog_categories blog_categories_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_categories
    ADD CONSTRAINT blog_categories_slug_key UNIQUE (slug);


--
-- Name: blog_comments blog_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_comments
    ADD CONSTRAINT blog_comments_pkey PRIMARY KEY (id);


--
-- Name: blog_posts blog_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_pkey PRIMARY KEY (id);


--
-- Name: blog_posts blog_posts_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_slug_key UNIQUE (slug);


--
-- Name: bootstrap_attempts bootstrap_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bootstrap_attempts
    ADD CONSTRAINT bootstrap_attempts_pkey PRIMARY KEY (id);


--
-- Name: capacity_utilization_logs capacity_utilization_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.capacity_utilization_logs
    ADD CONSTRAINT capacity_utilization_logs_pkey PRIMARY KEY (id);


--
-- Name: case_studies case_studies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_studies
    ADD CONSTRAINT case_studies_pkey PRIMARY KEY (id);


--
-- Name: certifications certifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certifications
    ADD CONSTRAINT certifications_pkey PRIMARY KEY (id);


--
-- Name: cms_content cms_content_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_content
    ADD CONSTRAINT cms_content_pkey PRIMARY KEY (id);


--
-- Name: company_info company_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_info
    ADD CONSTRAINT company_info_pkey PRIMARY KEY (id);


--
-- Name: conversation_analytics conversation_analytics_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_analytics
    ADD CONSTRAINT conversation_analytics_date_key UNIQUE (date);


--
-- Name: conversation_analytics conversation_analytics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_analytics
    ADD CONSTRAINT conversation_analytics_pkey PRIMARY KEY (id);


--
-- Name: conversation_messages conversation_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_messages
    ADD CONSTRAINT conversation_messages_pkey PRIMARY KEY (id);


--
-- Name: conversation_rate_limits conversation_rate_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_rate_limits
    ADD CONSTRAINT conversation_rate_limits_pkey PRIMARY KEY (id);


--
-- Name: defects defects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.defects
    ADD CONSTRAINT defects_pkey PRIMARY KEY (id);


--
-- Name: email_verification_otps email_verification_otps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_verification_otps
    ADD CONSTRAINT email_verification_otps_pkey PRIMARY KEY (id);


--
-- Name: exchange_rates exchange_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rates
    ADD CONSTRAINT exchange_rates_pkey PRIMARY KEY (id);


--
-- Name: exit_intent_sample_requests exit_intent_sample_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exit_intent_sample_requests
    ADD CONSTRAINT exit_intent_sample_requests_pkey PRIMARY KEY (id);


--
-- Name: factory_capacity factory_capacity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.factory_capacity
    ADD CONSTRAINT factory_capacity_pkey PRIMARY KEY (id);


--
-- Name: factory_capacity factory_capacity_supplier_id_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.factory_capacity
    ADD CONSTRAINT factory_capacity_supplier_id_date_key UNIQUE (supplier_id, date);


--
-- Name: industry_knowledge industry_knowledge_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.industry_knowledge
    ADD CONSTRAINT industry_knowledge_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key UNIQUE (invoice_number);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: market_research_cache market_research_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.market_research_cache
    ADD CONSTRAINT market_research_cache_pkey PRIMARY KEY (id);


--
-- Name: marketplace_products marketplace_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketplace_products
    ADD CONSTRAINT marketplace_products_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: notification_preferences notification_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_preferences
    ADD CONSTRAINT notification_preferences_pkey PRIMARY KEY (id);


--
-- Name: notification_preferences notification_preferences_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_preferences
    ADD CONSTRAINT notification_preferences_user_id_key UNIQUE (user_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: order_documents order_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_documents
    ADD CONSTRAINT order_documents_pkey PRIMARY KEY (id);


--
-- Name: order_messages order_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_messages
    ADD CONSTRAINT order_messages_pkey PRIMARY KEY (id);


--
-- Name: order_status_history order_status_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_status_history
    ADD CONSTRAINT order_status_history_pkey PRIMARY KEY (id);


--
-- Name: order_updates order_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_updates
    ADD CONSTRAINT order_updates_pkey PRIMARY KEY (id);


--
-- Name: orders orders_order_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_order_number_key UNIQUE (order_number);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: orders orders_tracking_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_tracking_token_key UNIQUE (tracking_token);


--
-- Name: otp_rate_limits otp_rate_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.otp_rate_limits
    ADD CONSTRAINT otp_rate_limits_pkey PRIMARY KEY (id);


--
-- Name: otp_verification_attempts otp_verification_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.otp_verification_attempts
    ADD CONSTRAINT otp_verification_attempts_pkey PRIMARY KEY (id);


--
-- Name: payment_history payment_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_history
    ADD CONSTRAINT payment_history_pkey PRIMARY KEY (id);


--
-- Name: phone_verification_otps phone_verification_otps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phone_verification_otps
    ADD CONSTRAINT phone_verification_otps_pkey PRIMARY KEY (id);


--
-- Name: product_categories product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (id);


--
-- Name: product_categories product_categories_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_slug_key UNIQUE (slug);


--
-- Name: product_interactions product_interactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_interactions
    ADD CONSTRAINT product_interactions_pkey PRIMARY KEY (id);


--
-- Name: production_batches production_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.production_batches
    ADD CONSTRAINT production_batches_pkey PRIMARY KEY (id);


--
-- Name: production_stage_templates production_stage_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.production_stage_templates
    ADD CONSTRAINT production_stage_templates_pkey PRIMARY KEY (id);


--
-- Name: production_stages production_stages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.production_stages
    ADD CONSTRAINT production_stages_pkey PRIMARY KEY (id);


--
-- Name: production_stages production_stages_supplier_order_id_stage_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.production_stages
    ADD CONSTRAINT production_stages_supplier_order_id_stage_number_key UNIQUE (supplier_order_id, stage_number);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: qc_checks qc_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_checks
    ADD CONSTRAINT qc_checks_pkey PRIMARY KEY (id);


--
-- Name: quote_approvals quote_approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_approvals
    ADD CONSTRAINT quote_approvals_pkey PRIMARY KEY (id);


--
-- Name: quote_configurations quote_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_configurations
    ADD CONSTRAINT quote_configurations_pkey PRIMARY KEY (id);


--
-- Name: quote_requests quote_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_requests
    ADD CONSTRAINT quote_requests_pkey PRIMARY KEY (id);


--
-- Name: quote_usage_tracking quote_usage_tracking_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_usage_tracking
    ADD CONSTRAINT quote_usage_tracking_pkey PRIMARY KEY (id);


--
-- Name: quotes quotes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotes
    ADD CONSTRAINT quotes_pkey PRIMARY KEY (id);


--
-- Name: resource_downloads resource_downloads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_downloads
    ADD CONSTRAINT resource_downloads_pkey PRIMARY KEY (id);


--
-- Name: sample_requests sample_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_requests
    ADD CONSTRAINT sample_requests_pkey PRIMARY KEY (id);


--
-- Name: sample_submissions sample_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_submissions
    ADD CONSTRAINT sample_submissions_pkey PRIMARY KEY (id);


--
-- Name: security_events security_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_events
    ADD CONSTRAINT security_events_pkey PRIMARY KEY (id);


--
-- Name: shipping_info shipping_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_info
    ADD CONSTRAINT shipping_info_pkey PRIMARY KEY (id);


--
-- Name: social_shares social_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.social_shares
    ADD CONSTRAINT social_shares_pkey PRIMARY KEY (id);


--
-- Name: supplier_capabilities supplier_capabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_capabilities
    ADD CONSTRAINT supplier_capabilities_pkey PRIMARY KEY (id);


--
-- Name: supplier_certifications supplier_certifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_certifications
    ADD CONSTRAINT supplier_certifications_pkey PRIMARY KEY (id);


--
-- Name: supplier_media supplier_media_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_media
    ADD CONSTRAINT supplier_media_pkey PRIMARY KEY (id);


--
-- Name: supplier_messages supplier_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_messages
    ADD CONSTRAINT supplier_messages_pkey PRIMARY KEY (id);


--
-- Name: supplier_mou_terms supplier_mou_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_mou_terms
    ADD CONSTRAINT supplier_mou_terms_pkey PRIMARY KEY (id);


--
-- Name: supplier_mou_terms supplier_mou_terms_supplier_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_mou_terms
    ADD CONSTRAINT supplier_mou_terms_supplier_id_key UNIQUE (supplier_id);


--
-- Name: supplier_orders supplier_orders_order_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_orders
    ADD CONSTRAINT supplier_orders_order_number_key UNIQUE (order_number);


--
-- Name: supplier_orders supplier_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_orders
    ADD CONSTRAINT supplier_orders_pkey PRIMARY KEY (id);


--
-- Name: supplier_payables supplier_payables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_payables
    ADD CONSTRAINT supplier_payables_pkey PRIMARY KEY (id);


--
-- Name: supplier_performance supplier_performance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_performance
    ADD CONSTRAINT supplier_performance_pkey PRIMARY KEY (id);


--
-- Name: supplier_performance supplier_performance_supplier_order_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_performance
    ADD CONSTRAINT supplier_performance_supplier_order_id_key UNIQUE (supplier_order_id);


--
-- Name: supplier_quotes supplier_quotes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_quotes
    ADD CONSTRAINT supplier_quotes_pkey PRIMARY KEY (id);


--
-- Name: supplier_ratings supplier_ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_ratings
    ADD CONSTRAINT supplier_ratings_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: timeline_predictions timeline_predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timeline_predictions
    ADD CONSTRAINT timeline_predictions_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_user_id_role_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_role_key UNIQUE (user_id, role);


--
-- Name: conversation_context voice_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_context
    ADD CONSTRAINT voice_conversations_pkey PRIMARY KEY (id);


--
-- Name: conversation_context voice_conversations_session_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_context
    ADD CONSTRAINT voice_conversations_session_id_key UNIQUE (session_id);


--
-- Name: wishlist_rate_limits wishlist_rate_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlist_rate_limits
    ADD CONSTRAINT wishlist_rate_limits_pkey PRIMARY KEY (id);


--
-- Name: wishlist_rate_limits wishlist_rate_limits_user_id_window_start_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlist_rate_limits
    ADD CONSTRAINT wishlist_rate_limits_user_id_window_start_key UNIQUE (user_id, window_start);


--
-- Name: wishlists wishlists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_pkey PRIMARY KEY (id);


--
-- Name: wishlists wishlists_user_id_product_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_user_id_product_id_key UNIQUE (user_id, product_id);


--
-- Name: work_orders work_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_pkey PRIMARY KEY (id);


--
-- Name: work_orders work_orders_work_order_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_work_order_number_key UNIQUE (work_order_number);


--
-- Name: idx_admin_actions_admin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_actions_admin_id ON public.admin_actions USING btree (admin_id);


--
-- Name: idx_admin_actions_entity_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_actions_entity_type ON public.admin_actions USING btree (entity_type);


--
-- Name: idx_admin_audit_logs_admin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_audit_logs_admin_id ON public.admin_audit_logs USING btree (admin_id);


--
-- Name: idx_admin_audit_logs_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_audit_logs_created_at ON public.admin_audit_logs USING btree (created_at DESC);


--
-- Name: idx_admin_audit_logs_resource; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_audit_logs_resource ON public.admin_audit_logs USING btree (resource_type, resource_id);


--
-- Name: idx_ai_cost_function_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_cost_function_date ON public.ai_cost_tracking USING btree (function_name, created_at DESC);


--
-- Name: idx_ai_cost_model; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_cost_model ON public.ai_cost_tracking USING btree (model, created_at DESC);


--
-- Name: idx_ai_cost_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_cost_user ON public.ai_cost_tracking USING btree (user_id, created_at DESC) WHERE (user_id IS NOT NULL);


--
-- Name: idx_ai_quotes_ip_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_quotes_ip_session ON public.ai_quotes USING btree (ip_address, session_id, created_at);


--
-- Name: idx_ai_quotes_lead_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_quotes_lead_status ON public.ai_quotes USING btree (lead_status);


--
-- Name: idx_ai_quotes_market_research; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_quotes_market_research ON public.ai_quotes USING btree (market_research_id);


--
-- Name: idx_ai_quotes_session_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_quotes_session_created ON public.ai_quotes USING btree (session_id, created_at) WHERE (session_id IS NOT NULL);


--
-- Name: idx_ai_quotes_specialty_sourcing; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_quotes_specialty_sourcing ON public.ai_quotes USING btree (specialty_sourcing_required) WHERE (specialty_sourcing_required = true);


--
-- Name: idx_ai_quotes_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_quotes_status ON public.ai_quotes USING btree (status);


--
-- Name: idx_automation_rules_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_automation_rules_active ON public.automation_rules USING btree (active);


--
-- Name: idx_batch_contributions_batch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_batch_contributions_batch ON public.batch_contributions USING btree (batch_id);


--
-- Name: idx_batch_contributions_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_batch_contributions_order ON public.batch_contributions USING btree (order_id);


--
-- Name: idx_bootstrap_attempts_ip_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bootstrap_attempts_ip_time ON public.bootstrap_attempts USING btree (ip_address, created_at DESC);


--
-- Name: idx_capacity_logs_supplier_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_capacity_logs_supplier_date ON public.capacity_utilization_logs USING btree (supplier_id, date);


--
-- Name: idx_categories_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_categories_active ON public.product_categories USING btree (is_active);


--
-- Name: idx_categories_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_categories_order ON public.product_categories USING btree (display_order);


--
-- Name: idx_cms_content_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cms_content_active ON public.cms_content USING btree (active);


--
-- Name: idx_cms_content_section; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cms_content_section ON public.cms_content USING btree (section);


--
-- Name: idx_conversation_context_decision_stage; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conversation_context_decision_stage ON public.conversation_context USING btree (decision_stage);


--
-- Name: idx_conversation_context_intent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conversation_context_intent ON public.conversation_context USING btree (intent);


--
-- Name: idx_conversation_context_lead_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conversation_context_lead_score ON public.conversation_context USING btree (lead_score DESC);


--
-- Name: idx_conversation_context_stage; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conversation_context_stage ON public.conversation_context USING btree (stage);


--
-- Name: idx_conversation_messages_conversation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conversation_messages_conversation_id ON public.conversation_messages USING btree (conversation_id);


--
-- Name: idx_conversation_messages_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conversation_messages_created_at ON public.conversation_messages USING btree (created_at);


--
-- Name: idx_conversation_rate_limits_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conversation_rate_limits_identifier ON public.conversation_rate_limits USING btree (identifier);


--
-- Name: idx_conversation_rate_limits_window; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conversation_rate_limits_window ON public.conversation_rate_limits USING btree (window_start);


--
-- Name: idx_defects_qc_check_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_defects_qc_check_id ON public.defects USING btree (qc_check_id);


--
-- Name: idx_email_verification_delivery_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_email_verification_delivery_status ON public.email_verification_otps USING btree (delivery_status, created_at);


--
-- Name: idx_email_verification_otps_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_email_verification_otps_email ON public.email_verification_otps USING btree (email);


--
-- Name: idx_email_verification_otps_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_email_verification_otps_expires_at ON public.email_verification_otps USING btree (expires_at);


--
-- Name: idx_email_verification_otps_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_email_verification_otps_user_id ON public.email_verification_otps USING btree (user_id);


--
-- Name: idx_email_verification_resend_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_email_verification_resend_id ON public.email_verification_otps USING btree (resend_email_id) WHERE (resend_email_id IS NOT NULL);


--
-- Name: idx_exchange_rates_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exchange_rates_lookup ON public.exchange_rates USING btree (base_currency, target_currency, valid_until);


--
-- Name: idx_exit_intent_sample_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exit_intent_sample_created ON public.exit_intent_sample_requests USING btree (created_at);


--
-- Name: idx_exit_intent_sample_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exit_intent_sample_email ON public.exit_intent_sample_requests USING btree (email);


--
-- Name: idx_factory_capacity_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_factory_capacity_date ON public.factory_capacity USING btree (date);


--
-- Name: idx_factory_capacity_supplier_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_factory_capacity_supplier_date ON public.factory_capacity USING btree (supplier_id, date);


--
-- Name: idx_industry_knowledge_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_industry_knowledge_category ON public.industry_knowledge USING btree (category);


--
-- Name: idx_industry_knowledge_subcategory; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_industry_knowledge_subcategory ON public.industry_knowledge USING btree (subcategory);


--
-- Name: idx_market_research_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_market_research_category ON public.market_research_cache USING btree (product_category, quantity_range);


--
-- Name: idx_market_research_expires; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_market_research_expires ON public.market_research_cache USING btree (expires_at);


--
-- Name: idx_marketplace_products_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_marketplace_products_category ON public.marketplace_products USING btree (category);


--
-- Name: idx_marketplace_products_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_marketplace_products_status ON public.marketplace_products USING btree (status);


--
-- Name: idx_marketplace_products_supplier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_marketplace_products_supplier ON public.marketplace_products USING btree (supplier_id);


--
-- Name: idx_messages_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_messages_order_id ON public.messages USING btree (order_id);


--
-- Name: idx_messages_read; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_messages_read ON public.messages USING btree (read);


--
-- Name: idx_messages_recipient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_messages_recipient_id ON public.messages USING btree (recipient_id);


--
-- Name: idx_messages_sender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_messages_sender_id ON public.messages USING btree (sender_id);


--
-- Name: idx_notification_preferences_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_preferences_user_id ON public.notification_preferences USING btree (user_id);


--
-- Name: idx_notifications_read; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_read ON public.notifications USING btree (read);


--
-- Name: idx_notifications_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_user_id ON public.notifications USING btree (user_id);


--
-- Name: idx_order_documents_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_documents_order_id ON public.order_documents USING btree (order_id);


--
-- Name: idx_order_messages_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_messages_order_id ON public.order_messages USING btree (order_id);


--
-- Name: idx_orders_quote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_quote_id ON public.orders USING btree (quote_id);


--
-- Name: idx_orders_supplier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_supplier_id ON public.orders USING btree (supplier_id);


--
-- Name: idx_orders_tracking_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_tracking_token ON public.orders USING btree (tracking_token);


--
-- Name: idx_otp_attempts_identifier_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_otp_attempts_identifier_time ON public.otp_verification_attempts USING btree (identifier, attempt_time DESC);


--
-- Name: idx_otp_rate_limits_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_otp_rate_limits_identifier ON public.otp_rate_limits USING btree (identifier);


--
-- Name: idx_payment_history_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_history_order_id ON public.payment_history USING btree (order_id);


--
-- Name: idx_payment_history_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_history_status ON public.payment_history USING btree (status);


--
-- Name: idx_phone_verification_otps_expires; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_phone_verification_otps_expires ON public.phone_verification_otps USING btree (expires_at);


--
-- Name: idx_phone_verification_otps_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_phone_verification_otps_phone ON public.phone_verification_otps USING btree (phone);


--
-- Name: idx_product_engagement_metrics_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_product_engagement_metrics_product_id ON public.product_engagement_metrics USING btree (product_id);


--
-- Name: idx_product_interactions_composite; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_product_interactions_composite ON public.product_interactions USING btree (product_id, interaction_type, "timestamp" DESC);


--
-- Name: idx_product_interactions_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_product_interactions_product_id ON public.product_interactions USING btree (product_id);


--
-- Name: idx_product_interactions_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_product_interactions_session_id ON public.product_interactions USING btree (session_id);


--
-- Name: idx_product_interactions_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_product_interactions_timestamp ON public.product_interactions USING btree ("timestamp" DESC);


--
-- Name: idx_product_interactions_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_product_interactions_type ON public.product_interactions USING btree (interaction_type);


--
-- Name: idx_product_interactions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_product_interactions_user_id ON public.product_interactions USING btree (user_id) WHERE (user_id IS NOT NULL);


--
-- Name: idx_production_batches_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_production_batches_category ON public.production_batches USING btree (product_category);


--
-- Name: idx_production_batches_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_production_batches_status ON public.production_batches USING btree (batch_status);


--
-- Name: idx_production_batches_supplier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_production_batches_supplier ON public.production_batches USING btree (supplier_id);


--
-- Name: idx_production_stage_templates_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_production_stage_templates_category ON public.production_stage_templates USING btree (product_category);


--
-- Name: idx_production_stages_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_production_stages_order_id ON public.production_stages USING btree (supplier_order_id);


--
-- Name: idx_production_stages_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_production_stages_status ON public.production_stages USING btree (status);


--
-- Name: idx_products_ai_generated; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_ai_generated ON public.products USING btree (ai_generated_image);


--
-- Name: idx_products_approved; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_approved ON public.products USING btree (image_approved_by_admin);


--
-- Name: idx_products_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_category ON public.products USING btree (category);


--
-- Name: idx_products_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_created_at ON public.products USING btree (created_at);


--
-- Name: idx_products_featured; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_featured ON public.products USING btree (featured);


--
-- Name: idx_products_price; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_price ON public.products USING btree (price);


--
-- Name: idx_profiles_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_profiles_role ON public.profiles USING btree (role);


--
-- Name: idx_qc_checks_inspector_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qc_checks_inspector_id ON public.qc_checks USING btree (inspector_id);


--
-- Name: idx_qc_checks_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qc_checks_order_id ON public.qc_checks USING btree (order_id);


--
-- Name: idx_quote_approvals_quote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quote_approvals_quote_id ON public.quote_approvals USING btree (quote_id);


--
-- Name: idx_quote_approvals_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quote_approvals_status ON public.quote_approvals USING btree (status);


--
-- Name: idx_quote_requests_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quote_requests_created_at ON public.quote_requests USING btree (created_at DESC);


--
-- Name: idx_quote_requests_session_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quote_requests_session_created ON public.quote_requests USING btree (session_id, created_at) WHERE (session_id IS NOT NULL);


--
-- Name: idx_quote_requests_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quote_requests_status ON public.quote_requests USING btree (status);


--
-- Name: idx_quote_usage_tracking_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quote_usage_tracking_email ON public.quote_usage_tracking USING btree (email);


--
-- Name: idx_quote_usage_tracking_window; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quote_usage_tracking_window ON public.quote_usage_tracking USING btree (window_start);


--
-- Name: idx_quotes_buyer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quotes_buyer_id ON public.quotes USING btree (buyer_id);


--
-- Name: idx_quotes_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quotes_status ON public.quotes USING btree (status);


--
-- Name: idx_rate_limits_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rate_limits_identifier ON public.ai_quote_rate_limits USING btree (identifier, window_start);


--
-- Name: idx_resource_downloads_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_resource_downloads_created_at ON public.resource_downloads USING btree (created_at DESC);


--
-- Name: idx_resource_downloads_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_resource_downloads_email ON public.resource_downloads USING btree (email);


--
-- Name: idx_resource_downloads_resource_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_resource_downloads_resource_type ON public.resource_downloads USING btree (resource_type);


--
-- Name: idx_security_events_ip; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_security_events_ip ON public.security_events USING btree (ip_address, created_at DESC);


--
-- Name: idx_security_events_severity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_security_events_severity ON public.security_events USING btree (severity, created_at DESC);


--
-- Name: idx_security_events_type_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_security_events_type_date ON public.security_events USING btree (event_type, created_at DESC);


--
-- Name: idx_shipping_info_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_shipping_info_order_id ON public.shipping_info USING btree (order_id);


--
-- Name: idx_supplier_capabilities_supplier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_supplier_capabilities_supplier_id ON public.supplier_capabilities USING btree (supplier_id);


--
-- Name: idx_supplier_messages_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_supplier_messages_order_id ON public.supplier_messages USING btree (supplier_order_id);


--
-- Name: idx_supplier_messages_read; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_supplier_messages_read ON public.supplier_messages USING btree (read);


--
-- Name: idx_supplier_mou_supplier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_supplier_mou_supplier ON public.supplier_mou_terms USING btree (supplier_id);


--
-- Name: idx_supplier_orders_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_supplier_orders_status ON public.supplier_orders USING btree (status);


--
-- Name: idx_supplier_orders_supplier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_supplier_orders_supplier_id ON public.supplier_orders USING btree (supplier_id);


--
-- Name: idx_supplier_payables_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_supplier_payables_status ON public.supplier_payables USING btree (status);


--
-- Name: idx_supplier_payables_supplier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_supplier_payables_supplier_id ON public.supplier_payables USING btree (supplier_id);


--
-- Name: idx_supplier_performance_supplier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_supplier_performance_supplier_id ON public.supplier_performance USING btree (supplier_id);


--
-- Name: idx_supplier_quotes_quote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_supplier_quotes_quote_id ON public.supplier_quotes USING btree (quote_id);


--
-- Name: idx_supplier_quotes_supplier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_supplier_quotes_supplier_id ON public.supplier_quotes USING btree (supplier_id);


--
-- Name: idx_suppliers_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_suppliers_user_id ON public.suppliers USING btree (user_id);


--
-- Name: idx_suppliers_verification_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_suppliers_verification_status ON public.suppliers USING btree (verification_status);


--
-- Name: idx_usage_logs_function_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usage_logs_function_date ON public.ai_usage_logs USING btree (function_name, created_at);


--
-- Name: idx_usage_logs_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usage_logs_session ON public.ai_usage_logs USING btree (session_id);


--
-- Name: idx_voice_conversations_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_voice_conversations_email ON public.conversation_context USING btree (email);


--
-- Name: idx_voice_conversations_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_voice_conversations_session_id ON public.conversation_context USING btree (session_id);


--
-- Name: idx_voice_conversations_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_voice_conversations_status ON public.conversation_context USING btree (status);


--
-- Name: idx_wishlist_rate_limits_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wishlist_rate_limits_user ON public.wishlist_rate_limits USING btree (user_id, window_start);


--
-- Name: idx_wishlists_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wishlists_created_at ON public.wishlists USING btree (created_at DESC);


--
-- Name: idx_wishlists_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wishlists_product_id ON public.wishlists USING btree (product_id);


--
-- Name: idx_wishlists_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wishlists_user_id ON public.wishlists USING btree (user_id);


--
-- Name: idx_work_orders_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_work_orders_order_id ON public.work_orders USING btree (order_id);


--
-- Name: idx_work_orders_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_work_orders_status ON public.work_orders USING btree (status);


--
-- Name: idx_work_orders_supplier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_work_orders_supplier_id ON public.work_orders USING btree (supplier_id);


--
-- Name: products_search_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_search_idx ON public.products USING gin (search_vector);


--
-- Name: marketplace_products marketplace_products_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER marketplace_products_updated_at BEFORE UPDATE ON public.marketplace_products FOR EACH ROW EXECUTE FUNCTION public.update_marketplace_products_updated_at();


--
-- Name: order_updates on_order_update_created; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_order_update_created AFTER INSERT ON public.order_updates FOR EACH ROW EXECUTE FUNCTION public.create_update_notification();


--
-- Name: products products_search_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER products_search_update BEFORE INSERT OR UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.products_search_trigger();


--
-- Name: orders sanitize_public_orders_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sanitize_public_orders_trigger BEFORE INSERT OR UPDATE ON public.orders FOR EACH ROW WHEN ((new.display_publicly = true)) EXECUTE FUNCTION public.sanitize_public_orders();


--
-- Name: orders trigger_generate_invoice_on_completion; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_generate_invoice_on_completion AFTER UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.trigger_invoice_generation();


--
-- Name: supplier_orders trigger_update_capacity; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_capacity AFTER INSERT OR UPDATE ON public.supplier_orders FOR EACH ROW EXECUTE FUNCTION public.update_factory_capacity_on_order();


--
-- Name: cms_content trigger_update_cms_content_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_cms_content_updated_at BEFORE UPDATE ON public.cms_content FOR EACH ROW EXECUTE FUNCTION public.update_cms_content_updated_at();


--
-- Name: work_orders trigger_update_work_orders_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_work_orders_updated_at BEFORE UPDATE ON public.work_orders FOR EACH ROW EXECUTE FUNCTION public.update_work_orders_updated_at();


--
-- Name: blog_posts update_blog_posts_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_blog_posts_updated_at BEFORE UPDATE ON public.blog_posts FOR EACH ROW EXECUTE FUNCTION public.update_blog_post_updated_at();


--
-- Name: invoices update_invoices_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON public.invoices FOR EACH ROW EXECUTE FUNCTION public.update_invoice_updated_at();


--
-- Name: orders update_orders_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: production_batches update_production_batches_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_production_batches_updated_at BEFORE UPDATE ON public.production_batches FOR EACH ROW EXECUTE FUNCTION public.update_production_batches_updated_at();


--
-- Name: production_stages update_production_stage_status; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_production_stage_status BEFORE UPDATE ON public.production_stages FOR EACH ROW EXECUTE FUNCTION public.update_production_stage_status();


--
-- Name: products update_products_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: profiles update_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: quote_configurations update_quote_configurations_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_quote_configurations_updated_at BEFORE UPDATE ON public.quote_configurations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: quotes update_quotes_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_quotes_updated_at BEFORE UPDATE ON public.quotes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: supplier_performance update_supplier_metrics; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_supplier_metrics AFTER INSERT OR UPDATE ON public.supplier_performance FOR EACH ROW EXECUTE FUNCTION public.update_supplier_performance_metrics();


--
-- Name: supplier_mou_terms update_supplier_mou_terms_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_supplier_mou_terms_updated_at BEFORE UPDATE ON public.supplier_mou_terms FOR EACH ROW EXECUTE FUNCTION public.update_production_batches_updated_at();


--
-- Name: supplier_orders update_supplier_orders_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_supplier_orders_updated_at BEFORE UPDATE ON public.supplier_orders FOR EACH ROW EXECUTE FUNCTION public.update_supplier_orders_updated_at();


--
-- Name: supplier_payables update_supplier_payables_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_supplier_payables_updated_at BEFORE UPDATE ON public.supplier_payables FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: supplier_quotes update_supplier_quotes_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_supplier_quotes_updated_at BEFORE UPDATE ON public.supplier_quotes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: suppliers update_suppliers_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_suppliers_updated_at BEFORE UPDATE ON public.suppliers FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: conversation_context update_voice_conversations_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_voice_conversations_updated_at BEFORE UPDATE ON public.conversation_context FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: messages validate_message_recipient_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER validate_message_recipient_trigger BEFORE INSERT ON public.messages FOR EACH ROW EXECUTE FUNCTION public.validate_message_recipient();


--
-- Name: admin_actions admin_actions_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_actions
    ADD CONSTRAINT admin_actions_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES auth.users(id);


--
-- Name: admin_audit_logs admin_audit_logs_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_audit_logs
    ADD CONSTRAINT admin_audit_logs_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: ai_quotes ai_quotes_converted_to_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_quotes
    ADD CONSTRAINT ai_quotes_converted_to_order_id_fkey FOREIGN KEY (converted_to_order_id) REFERENCES public.orders(id);


--
-- Name: ai_quotes ai_quotes_market_research_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_quotes
    ADD CONSTRAINT ai_quotes_market_research_id_fkey FOREIGN KEY (market_research_id) REFERENCES public.market_research_cache(id);


--
-- Name: ai_quotes ai_quotes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_quotes
    ADD CONSTRAINT ai_quotes_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: batch_contributions batch_contributions_batch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.batch_contributions
    ADD CONSTRAINT batch_contributions_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.production_batches(id) ON DELETE CASCADE;


--
-- Name: batch_contributions batch_contributions_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.batch_contributions
    ADD CONSTRAINT batch_contributions_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: blog_comments blog_comments_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_comments
    ADD CONSTRAINT blog_comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.blog_posts(id) ON DELETE CASCADE;


--
-- Name: blog_comments blog_comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_comments
    ADD CONSTRAINT blog_comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: blog_posts blog_posts_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES auth.users(id);


--
-- Name: capacity_utilization_logs capacity_utilization_logs_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.capacity_utilization_logs
    ADD CONSTRAINT capacity_utilization_logs_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE CASCADE;


--
-- Name: cms_content cms_content_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_content
    ADD CONSTRAINT cms_content_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
-- Name: conversation_messages conversation_messages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_messages
    ADD CONSTRAINT conversation_messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversation_context(id) ON DELETE CASCADE;


--
-- Name: defects defects_qc_check_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.defects
    ADD CONSTRAINT defects_qc_check_id_fkey FOREIGN KEY (qc_check_id) REFERENCES public.qc_checks(id) ON DELETE CASCADE;


--
-- Name: factory_capacity factory_capacity_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.factory_capacity
    ADD CONSTRAINT factory_capacity_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE CASCADE;


--
-- Name: product_interactions fk_product; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_interactions
    ADD CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: invoices invoices_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: marketplace_products marketplace_products_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketplace_products
    ADD CONSTRAINT marketplace_products_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE CASCADE;


--
-- Name: messages messages_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE SET NULL;


--
-- Name: messages messages_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: order_messages order_messages_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_messages
    ADD CONSTRAINT order_messages_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_messages order_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_messages
    ADD CONSTRAINT order_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: order_status_history order_status_history_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_status_history
    ADD CONSTRAINT order_status_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES auth.users(id);


--
-- Name: order_status_history order_status_history_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_status_history
    ADD CONSTRAINT order_status_history_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_updates order_updates_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_updates
    ADD CONSTRAINT order_updates_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: order_updates order_updates_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_updates
    ADD CONSTRAINT order_updates_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: orders orders_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES auth.users(id);


--
-- Name: orders orders_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES auth.users(id);


--
-- Name: orders orders_factory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_factory_id_fkey FOREIGN KEY (factory_id) REFERENCES auth.users(id);


--
-- Name: orders orders_quote_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_quote_id_fkey FOREIGN KEY (quote_id) REFERENCES public.quotes(id) ON DELETE SET NULL;


--
-- Name: orders orders_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE SET NULL;


--
-- Name: payment_history payment_history_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_history
    ADD CONSTRAINT payment_history_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE SET NULL;


--
-- Name: payment_history payment_history_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_history
    ADD CONSTRAINT payment_history_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: payment_history payment_history_paid_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_history
    ADD CONSTRAINT payment_history_paid_by_fkey FOREIGN KEY (paid_by) REFERENCES auth.users(id);


--
-- Name: payment_history payment_history_paid_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_history
    ADD CONSTRAINT payment_history_paid_to_fkey FOREIGN KEY (paid_to) REFERENCES auth.users(id);


--
-- Name: production_batches production_batches_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.production_batches
    ADD CONSTRAINT production_batches_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id);


--
-- Name: production_stages production_stages_supplier_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.production_stages
    ADD CONSTRAINT production_stages_supplier_order_id_fkey FOREIGN KEY (supplier_order_id) REFERENCES public.supplier_orders(id) ON DELETE CASCADE;


--
-- Name: production_stages production_stages_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.production_stages
    ADD CONSTRAINT production_stages_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: qc_checks qc_checks_inspector_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_checks
    ADD CONSTRAINT qc_checks_inspector_id_fkey FOREIGN KEY (inspector_id) REFERENCES auth.users(id);


--
-- Name: qc_checks qc_checks_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_checks
    ADD CONSTRAINT qc_checks_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: quote_approvals quote_approvals_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_approvals
    ADD CONSTRAINT quote_approvals_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES auth.users(id);


--
-- Name: quote_approvals quote_approvals_quote_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_approvals
    ADD CONSTRAINT quote_approvals_quote_id_fkey FOREIGN KEY (quote_id) REFERENCES public.ai_quotes(id) ON DELETE CASCADE;


--
-- Name: quote_requests quote_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_requests
    ADD CONSTRAINT quote_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: quotes quotes_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotes
    ADD CONSTRAINT quotes_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: social_shares social_shares_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.social_shares
    ADD CONSTRAINT social_shares_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.blog_posts(id) ON DELETE CASCADE;


--
-- Name: social_shares social_shares_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.social_shares
    ADD CONSTRAINT social_shares_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: supplier_capabilities supplier_capabilities_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_capabilities
    ADD CONSTRAINT supplier_capabilities_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE CASCADE;


--
-- Name: supplier_certifications supplier_certifications_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_certifications
    ADD CONSTRAINT supplier_certifications_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE CASCADE;


--
-- Name: supplier_media supplier_media_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_media
    ADD CONSTRAINT supplier_media_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE CASCADE;


--
-- Name: supplier_messages supplier_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_messages
    ADD CONSTRAINT supplier_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES auth.users(id);


--
-- Name: supplier_messages supplier_messages_supplier_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_messages
    ADD CONSTRAINT supplier_messages_supplier_order_id_fkey FOREIGN KEY (supplier_order_id) REFERENCES public.supplier_orders(id) ON DELETE CASCADE;


--
-- Name: supplier_mou_terms supplier_mou_terms_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_mou_terms
    ADD CONSTRAINT supplier_mou_terms_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id);


--
-- Name: supplier_orders supplier_orders_buyer_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_orders
    ADD CONSTRAINT supplier_orders_buyer_order_id_fkey FOREIGN KEY (buyer_order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: supplier_orders supplier_orders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_orders
    ADD CONSTRAINT supplier_orders_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: supplier_orders supplier_orders_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_orders
    ADD CONSTRAINT supplier_orders_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE SET NULL;


--
-- Name: supplier_payables supplier_payables_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_payables
    ADD CONSTRAINT supplier_payables_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: supplier_payables supplier_payables_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_payables
    ADD CONSTRAINT supplier_payables_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE CASCADE;


--
-- Name: supplier_performance supplier_performance_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_performance
    ADD CONSTRAINT supplier_performance_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE CASCADE;


--
-- Name: supplier_performance supplier_performance_supplier_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_performance
    ADD CONSTRAINT supplier_performance_supplier_order_id_fkey FOREIGN KEY (supplier_order_id) REFERENCES public.supplier_orders(id) ON DELETE CASCADE;


--
-- Name: supplier_quotes supplier_quotes_quote_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_quotes
    ADD CONSTRAINT supplier_quotes_quote_id_fkey FOREIGN KEY (quote_id) REFERENCES public.quotes(id) ON DELETE CASCADE;


--
-- Name: supplier_quotes supplier_quotes_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_quotes
    ADD CONSTRAINT supplier_quotes_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE CASCADE;


--
-- Name: supplier_ratings supplier_ratings_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_ratings
    ADD CONSTRAINT supplier_ratings_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: supplier_ratings supplier_ratings_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_ratings
    ADD CONSTRAINT supplier_ratings_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE SET NULL;


--
-- Name: supplier_ratings supplier_ratings_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_ratings
    ADD CONSTRAINT supplier_ratings_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE CASCADE;


--
-- Name: suppliers suppliers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: timeline_predictions timeline_predictions_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timeline_predictions
    ADD CONSTRAINT timeline_predictions_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: timeline_predictions timeline_predictions_quote_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timeline_predictions
    ADD CONSTRAINT timeline_predictions_quote_id_fkey FOREIGN KEY (quote_id) REFERENCES public.ai_quotes(id);


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: conversation_context voice_conversations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_context
    ADD CONSTRAINT voice_conversations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: wishlists wishlists_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: wishlists wishlists_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: work_orders work_orders_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: work_orders work_orders_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id);


--
-- Name: order_status_history Admins and suppliers can insert status changes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins and suppliers can insert status changes" ON public.order_status_history FOR INSERT WITH CHECK (public.has_any_role(auth.uid(), ARRAY['admin'::public.app_role, 'factory'::public.app_role, 'supplier'::public.app_role]));


--
-- Name: user_roles Admins can assign roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can assign roles" ON public.user_roles FOR INSERT TO authenticated WITH CHECK ((public.has_role(auth.uid(), 'admin'::public.app_role) AND (role <> 'admin'::public.app_role)));


--
-- Name: production_stages Admins can delete production stages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can delete production stages" ON public.production_stages FOR DELETE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: cms_content Admins can manage CMS content; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage CMS content" ON public.cms_content USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: supplier_mou_terms Admins can manage MOUs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage MOUs" ON public.supplier_mou_terms USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: factory_capacity Admins can manage all capacity; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all capacity" ON public.factory_capacity USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: invoices Admins can manage all invoices; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all invoices" ON public.invoices USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: marketplace_products Admins can manage all marketplace products; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all marketplace products" ON public.marketplace_products USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: supplier_performance Admins can manage all performance records; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all performance records" ON public.supplier_performance TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: production_stages Admins can manage all production stages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all production stages" ON public.production_stages TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: supplier_orders Admins can manage all supplier orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all supplier orders" ON public.supplier_orders TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: automation_rules Admins can manage automation rules; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage automation rules" ON public.automation_rules USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: production_batches Admins can manage batches; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage batches" ON public.production_batches USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: blog_categories Admins can manage blog categories; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage blog categories" ON public.blog_categories USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: blog_posts Admins can manage blog posts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage blog posts" ON public.blog_posts TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: case_studies Admins can manage case studies; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage case studies" ON public.case_studies USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: certifications Admins can manage certifications; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage certifications" ON public.certifications USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: blog_comments Admins can manage comments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage comments" ON public.blog_comments USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: company_info Admins can manage company info; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage company info" ON public.company_info USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: batch_contributions Admins can manage contributions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage contributions" ON public.batch_contributions USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: products Admins can manage products; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage products" ON public.products USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: quote_approvals Admins can manage quote approvals; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage quote approvals" ON public.quote_approvals USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: production_stage_templates Admins can manage stage templates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage stage templates" ON public.production_stage_templates USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: supplier_payables Admins can manage supplier payables; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage supplier payables" ON public.supplier_payables USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: work_orders Admins can manage work orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage work orders" ON public.work_orders USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: user_roles Admins can revoke roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can revoke roles" ON public.user_roles FOR DELETE TO authenticated USING ((public.has_role(auth.uid(), 'admin'::public.app_role) AND (NOT ((user_id = auth.uid()) AND (role = 'admin'::public.app_role)))));


--
-- Name: orders Admins can update all orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can update all orders" ON public.orders FOR UPDATE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: production_stages Admins can update all production stages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can update all production stages" ON public.production_stages FOR UPDATE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: profiles Admins can update all profiles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can update all profiles" ON public.profiles FOR UPDATE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: quote_requests Admins can update quote requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can update quote requests" ON public.quote_requests FOR UPDATE USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: user_roles Admins can update roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can update roles" ON public.user_roles FOR UPDATE TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: suppliers Admins can update supplier verification; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can update supplier verification" ON public.suppliers FOR UPDATE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: otp_rate_limits Admins can view OTP rate limits; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view OTP rate limits" ON public.otp_rate_limits FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: admin_actions Admins can view admin actions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view admin actions" ON public.admin_actions FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: qc_checks Admins can view all QC checks; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all QC checks" ON public.qc_checks FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: production_batches Admins can view all batches; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all batches" ON public.production_batches FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: defects Admins can view all defects; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all defects" ON public.defects FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: product_interactions Admins can view all interactions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all interactions" ON public.product_interactions FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: capacity_utilization_logs Admins can view all logs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all logs" ON public.capacity_utilization_logs FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: orders Admins can view all orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all orders" ON public.orders FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: supplier_payables Admins can view all payables; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all payables" ON public.supplier_payables FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: payment_history Admins can view all payments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all payments" ON public.payment_history FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: production_stages Admins can view all production stages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all production stages" ON public.production_stages FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: profiles Admins can view all profiles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all profiles" ON public.profiles FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: quote_requests Admins can view all quote requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all quote requests" ON public.quote_requests FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: ai_quotes Admins can view all quotes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all quotes" ON public.ai_quotes FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: quotes Admins can view all quotes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all quotes" ON public.quotes FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: resource_downloads Admins can view all resource downloads; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all resource downloads" ON public.resource_downloads FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: user_roles Admins can view all roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all roles" ON public.user_roles FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: shipping_info Admins can view all shipping; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all shipping" ON public.shipping_info FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: supplier_quotes Admins can view all supplier quotes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all supplier quotes" ON public.supplier_quotes FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: suppliers Admins can view all suppliers; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all suppliers" ON public.suppliers FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: conversation_analytics Admins can view analytics; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view analytics" ON public.conversation_analytics FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: admin_audit_logs Admins can view audit logs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view audit logs" ON public.admin_audit_logs FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: conversation_rate_limits Admins can view conversation rate limits; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view conversation rate limits" ON public.conversation_rate_limits FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: timeline_predictions Admins can view predictions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view predictions" ON public.timeline_predictions FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: market_research_cache Admins can view research cache; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view research cache" ON public.market_research_cache FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: exit_intent_sample_requests Admins can view sample requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view sample requests" ON public.exit_intent_sample_requests FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: social_shares Admins can view shares; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view shares" ON public.social_shares FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: wishlist_rate_limits Admins can view wishlist rate limits; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view wishlist rate limits" ON public.wishlist_rate_limits FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: conversation_context Admins manage all conversations; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins manage all conversations" ON public.conversation_context USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: conversation_messages Admins manage all messages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins manage all messages" ON public.conversation_messages USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: admin_audit_logs Admins view audit logs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins view audit logs" ON public.admin_audit_logs FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: product_interactions Admins view product interactions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins view product interactions" ON public.product_interactions FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: exit_intent_sample_requests Admins view sample requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins view sample requests" ON public.exit_intent_sample_requests FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: cms_content Anyone can view active CMS content; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view active CMS content" ON public.cms_content FOR SELECT USING ((active = true));


--
-- Name: certifications Anyone can view active certifications; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view active certifications" ON public.certifications FOR SELECT USING ((active = true));


--
-- Name: company_info Anyone can view active company info; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view active company info" ON public.company_info FOR SELECT USING ((active = true));


--
-- Name: quote_configurations Anyone can view active quote configurations; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view active quote configurations" ON public.quote_configurations FOR SELECT USING ((is_active = true));


--
-- Name: production_stage_templates Anyone can view active stage templates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view active stage templates" ON public.production_stage_templates FOR SELECT USING ((active = true));


--
-- Name: blog_comments Anyone can view approved comments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view approved comments" ON public.blog_comments FOR SELECT USING ((approved = true));


--
-- Name: marketplace_products Anyone can view approved marketplace products; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view approved marketplace products" ON public.marketplace_products FOR SELECT USING ((status = 'approved'::text));


--
-- Name: supplier_capabilities Anyone can view capabilities of verified suppliers; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view capabilities of verified suppliers" ON public.supplier_capabilities FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.suppliers
  WHERE ((suppliers.id = supplier_capabilities.supplier_id) AND (suppliers.verification_status = 'verified'::public.verification_status)))));


--
-- Name: blog_categories Anyone can view categories; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view categories" ON public.blog_categories FOR SELECT USING (true);


--
-- Name: supplier_certifications Anyone can view certifications of verified suppliers; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view certifications of verified suppliers" ON public.supplier_certifications FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.suppliers
  WHERE ((suppliers.id = supplier_certifications.supplier_id) AND (suppliers.verification_status = 'verified'::public.verification_status)))));


--
-- Name: industry_knowledge Anyone can view industry knowledge; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view industry knowledge" ON public.industry_knowledge FOR SELECT USING (true);


--
-- Name: supplier_media Anyone can view media of verified suppliers; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view media of verified suppliers" ON public.supplier_media FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.suppliers
  WHERE ((suppliers.id = supplier_media.supplier_id) AND (suppliers.verification_status = 'verified'::public.verification_status)))));


--
-- Name: blog_posts Anyone can view published blog posts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view published blog posts" ON public.blog_posts FOR SELECT USING ((published = true));


--
-- Name: case_studies Anyone can view published case studies; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view published case studies" ON public.case_studies FOR SELECT USING ((published = true));


--
-- Name: social_shares Anyone can view social shares; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view social shares" ON public.social_shares FOR SELECT USING (true);


--
-- Name: factory_capacity Anyone can view verified supplier capacity; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view verified supplier capacity" ON public.factory_capacity FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.suppliers
  WHERE ((suppliers.id = factory_capacity.supplier_id) AND (suppliers.verification_status = 'verified'::public.verification_status)))));


--
-- Name: suppliers Anyone can view verified suppliers; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can view verified suppliers" ON public.suppliers FOR SELECT USING ((verification_status = 'verified'::public.verification_status));


--
-- Name: social_shares Anyone views share counts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone views share counts" ON public.social_shares FOR SELECT USING (true);


--
-- Name: quote_requests Authenticated users can create quote requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Authenticated users can create quote requests" ON public.quote_requests FOR INSERT WITH CHECK (((auth.uid() IS NOT NULL) OR (auth.role() = 'service_role'::text)));


--
-- Name: ai_quotes Authenticated users can create quotes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Authenticated users can create quotes" ON public.ai_quotes FOR INSERT TO authenticated WITH CHECK (((auth.uid() IS NOT NULL) AND ((user_id = auth.uid()) OR (user_id IS NULL))));


--
-- Name: suppliers Authenticated users can create supplier profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Authenticated users can create supplier profile" ON public.suppliers FOR INSERT TO authenticated WITH CHECK (((user_id = auth.uid()) AND (NOT (EXISTS ( SELECT 1
   FROM public.suppliers suppliers_1
  WHERE (suppliers_1.user_id = auth.uid()))))));


--
-- Name: order_documents Authenticated users can upload documents; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Authenticated users can upload documents" ON public.order_documents FOR INSERT WITH CHECK ((auth.uid() = uploaded_by));


--
-- Name: supplier_ratings Authenticated users can view ratings; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Authenticated users can view ratings" ON public.supplier_ratings FOR SELECT USING ((auth.uid() IS NOT NULL));


--
-- Name: email_verification_otps Authenticated users cannot access email OTPs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Authenticated users cannot access email OTPs" ON public.email_verification_otps TO authenticated USING (false);


--
-- Name: phone_verification_otps Authenticated users cannot access phone OTPs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Authenticated users cannot access phone OTPs" ON public.phone_verification_otps TO authenticated USING (false);


--
-- Name: blog_comments Authenticated users create comments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Authenticated users create comments" ON public.blog_comments FOR INSERT TO authenticated WITH CHECK ((auth.uid() = user_id));


--
-- Name: suppliers Authenticated users view verified suppliers; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Authenticated users view verified suppliers" ON public.suppliers FOR SELECT TO authenticated USING (((verification_status = 'verified'::public.verification_status) OR (auth.uid() = user_id) OR public.has_role(auth.uid(), 'admin'::public.app_role)));


--
-- Name: supplier_ratings Buyers can create ratings for their completed orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Buyers can create ratings for their completed orders" ON public.supplier_ratings FOR INSERT WITH CHECK (((buyer_id = auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = supplier_ratings.order_id) AND (orders.buyer_id = auth.uid()) AND (orders.status = 'completed'::text))))));


--
-- Name: orders Buyers can create their own orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Buyers can create their own orders" ON public.orders FOR INSERT TO authenticated WITH CHECK ((buyer_id = auth.uid()));


--
-- Name: orders Buyers can update their own orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Buyers can update their own orders" ON public.orders FOR UPDATE TO authenticated USING ((buyer_id = auth.uid()));


--
-- Name: qc_checks Buyers can view QC checks for their orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Buyers can view QC checks for their orders" ON public.qc_checks FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = qc_checks.order_id) AND (orders.buyer_id = auth.uid())))));


--
-- Name: production_batches Buyers can view batches with their orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Buyers can view batches with their orders" ON public.production_batches FOR SELECT USING ((EXISTS ( SELECT 1
   FROM (public.batch_contributions bc
     JOIN public.orders o ON ((o.id = bc.order_id)))
  WHERE ((bc.batch_id = production_batches.id) AND (o.buyer_id = auth.uid())))));


--
-- Name: defects Buyers can view defects for their orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Buyers can view defects for their orders" ON public.defects FOR SELECT USING ((EXISTS ( SELECT 1
   FROM (public.qc_checks
     JOIN public.orders ON ((orders.id = qc_checks.order_id)))
  WHERE ((qc_checks.id = defects.qc_check_id) AND (orders.buyer_id = auth.uid())))));


--
-- Name: production_stages Buyers can view stages for their orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Buyers can view stages for their orders" ON public.production_stages FOR SELECT USING ((supplier_order_id IN ( SELECT so.id
   FROM public.supplier_orders so
  WHERE (so.buyer_order_id IN ( SELECT orders.id
           FROM public.orders
          WHERE (orders.buyer_id = auth.uid()))))));


--
-- Name: invoices Buyers can view their invoices; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Buyers can view their invoices" ON public.invoices FOR SELECT USING ((order_id IN ( SELECT orders.id
   FROM public.orders
  WHERE (orders.buyer_id = auth.uid()))));


--
-- Name: shipping_info Buyers can view their order shipping; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Buyers can view their order shipping" ON public.shipping_info FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = shipping_info.order_id) AND (orders.buyer_id = auth.uid())))));


--
-- Name: orders Buyers can view their own orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Buyers can view their own orders" ON public.orders FOR SELECT TO authenticated USING ((buyer_id = auth.uid()));


--
-- Name: sample_requests Buyers manage sample requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Buyers manage sample requests" ON public.sample_requests TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = sample_requests.order_id) AND (orders.buyer_id = auth.uid())))));


--
-- Name: shipping_info Buyers manage shipping; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Buyers manage shipping" ON public.shipping_info TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = shipping_info.order_id) AND (orders.buyer_id = auth.uid())))));


--
-- Name: timeline_predictions Buyers view their order predictions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Buyers view their order predictions" ON public.timeline_predictions FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.orders o
  WHERE ((o.id = timeline_predictions.order_id) AND (o.buyer_id = auth.uid())))));


--
-- Name: exchange_rates Exchange rates are publicly readable; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Exchange rates are publicly readable" ON public.exchange_rates FOR SELECT USING (true);


--
-- Name: orders Factories can update assigned orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Factories can update assigned orders" ON public.orders FOR UPDATE TO authenticated USING ((factory_id = auth.uid()));


--
-- Name: qc_checks Factories can update their QC checks; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Factories can update their QC checks" ON public.qc_checks FOR UPDATE USING ((inspector_id = auth.uid()));


--
-- Name: shipping_info Factories can view assigned order shipping; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Factories can view assigned order shipping" ON public.shipping_info FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = shipping_info.order_id) AND (orders.factory_id = auth.uid())))));


--
-- Name: orders Factories can view assigned orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Factories can view assigned orders" ON public.orders FOR SELECT TO authenticated USING ((factory_id = auth.uid()));


--
-- Name: defects Factories can view defects for their QC checks; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Factories can view defects for their QC checks" ON public.defects FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.qc_checks
  WHERE ((qc_checks.id = defects.qc_check_id) AND (qc_checks.inspector_id = auth.uid())))));


--
-- Name: qc_checks Factories can view their QC checks; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Factories can view their QC checks" ON public.qc_checks FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = qc_checks.order_id) AND (orders.factory_id = auth.uid())))));


--
-- Name: qc_checks Factory users can create QC checks for their orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Factory users can create QC checks for their orders" ON public.qc_checks FOR INSERT TO authenticated WITH CHECK (((inspector_id = auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = qc_checks.order_id) AND (orders.factory_id = auth.uid()))))));


--
-- Name: defects Factory users can create defects; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Factory users can create defects" ON public.defects FOR INSERT TO authenticated WITH CHECK ((EXISTS ( SELECT 1
   FROM public.qc_checks
  WHERE ((qc_checks.id = defects.qc_check_id) AND (qc_checks.inspector_id = auth.uid())))));


--
-- Name: order_updates Factory users can create updates for their orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Factory users can create updates for their orders" ON public.order_updates FOR INSERT TO authenticated WITH CHECK (((created_by = auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = order_updates.order_id) AND (orders.factory_id = auth.uid()))))));


--
-- Name: invoices No one can delete invoices; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "No one can delete invoices" ON public.invoices FOR DELETE TO authenticated USING (false);


--
-- Name: payment_history No one can delete payment records; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "No one can delete payment records" ON public.payment_history FOR DELETE TO authenticated USING (false);


--
-- Name: orders Only admins can delete orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Only admins can delete orders" ON public.orders FOR DELETE TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: industry_knowledge Only admins can manage industry knowledge; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Only admins can manage industry knowledge" ON public.industry_knowledge USING (false);


--
-- Name: supplier_payables Only service role can insert payables; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Only service role can insert payables" ON public.supplier_payables FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: order_documents Order participants can view documents; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Order participants can view documents" ON public.order_documents FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = order_documents.order_id) AND ((orders.buyer_id = auth.uid()) OR (orders.supplier_id IN ( SELECT suppliers.id
           FROM public.suppliers
          WHERE (suppliers.user_id = auth.uid()))))))));


--
-- Name: order_documents Order participants upload documents; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Order participants upload documents" ON public.order_documents FOR INSERT TO authenticated WITH CHECK (((EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = order_documents.order_id) AND ((orders.buyer_id = auth.uid()) OR (orders.supplier_id = auth.uid()))))) AND (uploaded_by = auth.uid())));


--
-- Name: order_documents Order participants view documents; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Order participants view documents" ON public.order_documents FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = order_documents.order_id) AND ((orders.buyer_id = auth.uid()) OR (orders.supplier_id = auth.uid()))))));


--
-- Name: production_stages Order participants view production stages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Order participants view production stages" ON public.production_stages FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM (public.supplier_orders so
     JOIN public.orders o ON ((so.buyer_order_id = o.id)))
  WHERE ((so.id = production_stages.supplier_order_id) AND ((o.supplier_id = auth.uid()) OR (o.buyer_id = auth.uid()))))));


--
-- Name: sample_requests Order participants view sample requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Order participants view sample requests" ON public.sample_requests FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = sample_requests.order_id) AND ((orders.buyer_id = auth.uid()) OR (orders.supplier_id = auth.uid()))))));


--
-- Name: sample_submissions Order participants view sample submissions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Order participants view sample submissions" ON public.sample_submissions FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM (public.sample_requests sr
     JOIN public.orders o ON ((sr.order_id = o.id)))
  WHERE ((sr.id = sample_submissions.sample_request_id) AND ((o.buyer_id = auth.uid()) OR (o.supplier_id = auth.uid()))))));


--
-- Name: shipping_info Order participants view shipping; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Order participants view shipping" ON public.shipping_info FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = shipping_info.order_id) AND ((orders.buyer_id = auth.uid()) OR (orders.supplier_id = auth.uid()))))));


--
-- Name: products Products are viewable by everyone; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Products are viewable by everyone" ON public.products FOR SELECT USING (true);


--
-- Name: product_categories Public categories are viewable by everyone; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public categories are viewable by everyone" ON public.product_categories FOR SELECT USING (true);


--
-- Name: products Public products are viewable by everyone; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public products are viewable by everyone" ON public.products FOR SELECT USING (true);


--
-- Name: suppliers Public view supplier basics (no contact info); Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public view supplier basics (no contact info)" ON public.suppliers FOR SELECT USING (((verification_status = 'verified'::public.verification_status) AND ((auth.uid() IS NOT NULL) OR (auth.uid() IS NULL))));


--
-- Name: batch_contributions Service role can create contributions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can create contributions" ON public.batch_contributions FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: conversation_context Service role can create conversations; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can create conversations" ON public.conversation_context FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: conversation_messages Service role can create messages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can create messages" ON public.conversation_messages FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: notifications Service role can create notifications; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can create notifications" ON public.notifications FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: payment_history Service role can create payments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can create payments" ON public.payment_history FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: timeline_predictions Service role can create predictions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can create predictions" ON public.timeline_predictions FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: ai_quotes Service role can create quotes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can create quotes" ON public.ai_quotes FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: quotes Service role can create quotes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can create quotes" ON public.quotes FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: ai_usage_logs Service role can create usage logs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can create usage logs" ON public.ai_usage_logs FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: capacity_utilization_logs Service role can insert capacity logs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can insert capacity logs" ON public.capacity_utilization_logs FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: blog_comments Service role can insert comments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can insert comments" ON public.blog_comments FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: production_stages Service role can insert production stages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can insert production stages" ON public.production_stages FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: quote_requests Service role can insert quote requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can insert quote requests" ON public.quote_requests FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: resource_downloads Service role can insert resource downloads; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can insert resource downloads" ON public.resource_downloads FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: social_shares Service role can insert social shares; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can insert social shares" ON public.social_shares FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: admin_actions Service role can log actions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can log actions" ON public.admin_actions FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: user_roles Service role can manage all roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can manage all roles" ON public.user_roles USING ((auth.role() = 'service_role'::text));


--
-- Name: ai_cost_tracking Service role can manage cost tracking; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can manage cost tracking" ON public.ai_cost_tracking USING ((auth.role() = 'service_role'::text));


--
-- Name: exchange_rates Service role can manage exchange rates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can manage exchange rates" ON public.exchange_rates USING ((auth.role() = 'service_role'::text));


--
-- Name: ai_quote_rate_limits Service role can manage rate limits; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can manage rate limits" ON public.ai_quote_rate_limits USING ((auth.role() = 'service_role'::text)) WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: market_research_cache Service role can manage research cache; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can manage research cache" ON public.market_research_cache USING ((auth.role() = 'service_role'::text));


--
-- Name: security_events Service role can manage security events; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can manage security events" ON public.security_events USING ((auth.role() = 'service_role'::text));


--
-- Name: social_shares Service role can track shares; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can track shares" ON public.social_shares FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: production_stages Service role full access to production stages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role full access to production stages" ON public.production_stages USING ((auth.role() = 'service_role'::text));


--
-- Name: admin_audit_logs Service role inserts audit logs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role inserts audit logs" ON public.admin_audit_logs FOR INSERT TO service_role WITH CHECK (true);


--
-- Name: product_interactions Service role inserts product interactions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role inserts product interactions" ON public.product_interactions FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: exit_intent_sample_requests Service role inserts sample requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role inserts sample requests" ON public.exit_intent_sample_requests FOR INSERT WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: otp_verification_attempts Service role manages OTP attempts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role manages OTP attempts" ON public.otp_verification_attempts TO service_role USING (true) WITH CHECK (true);


--
-- Name: otp_rate_limits Service role manages OTP rate limits; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role manages OTP rate limits" ON public.otp_rate_limits TO service_role USING (true) WITH CHECK (true);


--
-- Name: conversation_analytics Service role manages analytics; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role manages analytics" ON public.conversation_analytics TO service_role USING (true) WITH CHECK (true);


--
-- Name: bootstrap_attempts Service role manages bootstrap attempts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role manages bootstrap attempts" ON public.bootstrap_attempts USING ((auth.role() = 'service_role'::text)) WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: conversation_rate_limits Service role manages conversation rate limits; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role manages conversation rate limits" ON public.conversation_rate_limits TO service_role USING (true) WITH CHECK (true);


--
-- Name: email_verification_otps Service role manages email OTPs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role manages email OTPs" ON public.email_verification_otps TO service_role USING (true) WITH CHECK (true);


--
-- Name: phone_verification_otps Service role manages phone OTPs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role manages phone OTPs" ON public.phone_verification_otps TO service_role USING (true) WITH CHECK (true);


--
-- Name: timeline_predictions Service role manages predictions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role manages predictions" ON public.timeline_predictions TO service_role USING (true) WITH CHECK (true);


--
-- Name: quote_usage_tracking Service role manages quote usage; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role manages quote usage" ON public.quote_usage_tracking TO service_role USING (true) WITH CHECK (true);


--
-- Name: wishlist_rate_limits Service role manages wishlist rate limits; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role manages wishlist rate limits" ON public.wishlist_rate_limits TO service_role USING (true) WITH CHECK (true);


--
-- Name: supplier_quotes Suppliers can create their quotes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can create their quotes" ON public.supplier_quotes FOR INSERT WITH CHECK ((supplier_id IN ( SELECT s.id
   FROM public.suppliers s
  WHERE (s.user_id = auth.uid()))));


--
-- Name: supplier_capabilities Suppliers can manage their capabilities; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can manage their capabilities" ON public.supplier_capabilities USING ((EXISTS ( SELECT 1
   FROM public.suppliers
  WHERE ((suppliers.id = supplier_capabilities.supplier_id) AND (suppliers.user_id = auth.uid())))));


--
-- Name: factory_capacity Suppliers can manage their capacity; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can manage their capacity" ON public.factory_capacity USING ((EXISTS ( SELECT 1
   FROM public.suppliers
  WHERE ((suppliers.id = factory_capacity.supplier_id) AND (suppliers.user_id = auth.uid())))));


--
-- Name: supplier_certifications Suppliers can manage their certifications; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can manage their certifications" ON public.supplier_certifications USING ((EXISTS ( SELECT 1
   FROM public.suppliers
  WHERE ((suppliers.id = supplier_certifications.supplier_id) AND (suppliers.user_id = auth.uid())))));


--
-- Name: supplier_media Suppliers can manage their media; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can manage their media" ON public.supplier_media USING ((EXISTS ( SELECT 1
   FROM public.suppliers
  WHERE ((suppliers.id = supplier_media.supplier_id) AND (suppliers.user_id = auth.uid())))));


--
-- Name: marketplace_products Suppliers can manage their own products; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can manage their own products" ON public.marketplace_products USING ((supplier_id IN ( SELECT suppliers.id
   FROM public.suppliers
  WHERE (suppliers.user_id = auth.uid()))));


--
-- Name: production_stages Suppliers can update stages for their orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can update stages for their orders" ON public.production_stages FOR UPDATE TO authenticated USING ((supplier_order_id IN ( SELECT so.id
   FROM public.supplier_orders so
  WHERE (so.supplier_id IN ( SELECT suppliers.id
           FROM public.suppliers
          WHERE (suppliers.user_id = auth.uid()))))));


--
-- Name: production_stages Suppliers can update their assigned order stages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can update their assigned order stages" ON public.production_stages FOR UPDATE USING ((supplier_order_id IN ( SELECT supplier_orders.id
   FROM public.supplier_orders
  WHERE (supplier_orders.supplier_id IN ( SELECT suppliers.id
           FROM public.suppliers
          WHERE (suppliers.user_id = auth.uid()))))));


--
-- Name: supplier_orders Suppliers can update their assigned orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can update their assigned orders" ON public.supplier_orders FOR UPDATE TO authenticated USING ((supplier_id IN ( SELECT suppliers.id
   FROM public.suppliers
  WHERE (suppliers.user_id = auth.uid()))));


--
-- Name: suppliers Suppliers can update their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can update their own profile" ON public.suppliers FOR UPDATE USING ((user_id = auth.uid()));


--
-- Name: supplier_quotes Suppliers can update their quotes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can update their quotes" ON public.supplier_quotes FOR UPDATE USING ((supplier_id IN ( SELECT s.id
   FROM public.suppliers s
  WHERE (s.user_id = auth.uid()))));


--
-- Name: work_orders Suppliers can update their work orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can update their work orders" ON public.work_orders FOR UPDATE USING ((supplier_id IN ( SELECT suppliers.id
   FROM public.suppliers
  WHERE (suppliers.user_id = auth.uid()))));


--
-- Name: work_orders Suppliers can view and update their work orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can view and update their work orders" ON public.work_orders FOR SELECT USING ((supplier_id IN ( SELECT suppliers.id
   FROM public.suppliers
  WHERE (suppliers.user_id = auth.uid()))));


--
-- Name: shipping_info Suppliers can view assigned order shipping; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can view assigned order shipping" ON public.shipping_info FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = shipping_info.order_id) AND (orders.supplier_id IN ( SELECT suppliers.id
           FROM public.suppliers
          WHERE (suppliers.user_id = auth.uid())))))));


--
-- Name: supplier_quotes Suppliers can view quotes where they are matched; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can view quotes where they are matched" ON public.supplier_quotes FOR SELECT USING (((supplier_id IN ( SELECT s.id
   FROM public.suppliers s
  WHERE (s.user_id = auth.uid()))) OR (EXISTS ( SELECT 1
   FROM public.quotes q
  WHERE ((q.id = supplier_quotes.quote_id) AND (q.buyer_id = auth.uid()))))));


--
-- Name: production_stages Suppliers can view stages for their orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can view stages for their orders" ON public.production_stages FOR SELECT TO authenticated USING ((supplier_order_id IN ( SELECT so.id
   FROM public.supplier_orders so
  WHERE (so.supplier_id IN ( SELECT suppliers.id
           FROM public.suppliers
          WHERE (suppliers.user_id = auth.uid()))))));


--
-- Name: supplier_mou_terms Suppliers can view their MOU; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can view their MOU" ON public.supplier_mou_terms FOR SELECT USING (((supplier_id IN ( SELECT suppliers.id
   FROM public.suppliers
  WHERE (suppliers.user_id = auth.uid()))) OR public.has_role(auth.uid(), 'admin'::public.app_role)));


--
-- Name: production_batches Suppliers can view their assigned batches; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can view their assigned batches" ON public.production_batches FOR SELECT USING ((supplier_id IN ( SELECT suppliers.id
   FROM public.suppliers
  WHERE (suppliers.user_id = auth.uid()))));


--
-- Name: production_stages Suppliers can view their assigned order stages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can view their assigned order stages" ON public.production_stages FOR SELECT USING ((supplier_order_id IN ( SELECT supplier_orders.id
   FROM public.supplier_orders
  WHERE (supplier_orders.supplier_id IN ( SELECT suppliers.id
           FROM public.suppliers
          WHERE (suppliers.user_id = auth.uid()))))));


--
-- Name: supplier_orders Suppliers can view their assigned orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can view their assigned orders" ON public.supplier_orders FOR SELECT TO authenticated USING ((supplier_id IN ( SELECT suppliers.id
   FROM public.suppliers
  WHERE (suppliers.user_id = auth.uid()))));


--
-- Name: capacity_utilization_logs Suppliers can view their logs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can view their logs" ON public.capacity_utilization_logs FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.suppliers
  WHERE ((suppliers.id = capacity_utilization_logs.supplier_id) AND (suppliers.user_id = auth.uid())))));


--
-- Name: supplier_payables Suppliers can view their own payables; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can view their own payables" ON public.supplier_payables FOR SELECT USING ((supplier_id IN ( SELECT suppliers.id
   FROM public.suppliers
  WHERE (suppliers.user_id = auth.uid()))));


--
-- Name: supplier_performance Suppliers can view their own performance; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can view their own performance" ON public.supplier_performance FOR SELECT TO authenticated USING ((supplier_id IN ( SELECT suppliers.id
   FROM public.suppliers
  WHERE (suppliers.user_id = auth.uid()))));


--
-- Name: suppliers Suppliers can view their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can view their own profile" ON public.suppliers FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: supplier_payables Suppliers can view their payables; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers can view their payables" ON public.supplier_payables FOR SELECT USING ((supplier_id IN ( SELECT suppliers.id
   FROM public.suppliers
  WHERE (suppliers.user_id = auth.uid()))));


--
-- Name: sample_submissions Suppliers create sample submissions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers create sample submissions" ON public.sample_submissions FOR INSERT TO authenticated WITH CHECK ((EXISTS ( SELECT 1
   FROM (public.sample_requests sr
     JOIN public.orders o ON ((sr.order_id = o.id)))
  WHERE ((sr.id = sample_submissions.sample_request_id) AND (o.supplier_id = auth.uid())))));


--
-- Name: production_stages Suppliers manage production stages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers manage production stages" ON public.production_stages TO authenticated USING ((EXISTS ( SELECT 1
   FROM (public.supplier_orders so
     JOIN public.orders o ON ((so.buyer_order_id = o.id)))
  WHERE ((so.id = production_stages.supplier_order_id) AND (o.supplier_id = auth.uid())))));


--
-- Name: sample_submissions Suppliers update sample submissions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers update sample submissions" ON public.sample_submissions FOR UPDATE TO authenticated USING ((EXISTS ( SELECT 1
   FROM (public.sample_requests sr
     JOIN public.orders o ON ((sr.order_id = o.id)))
  WHERE ((sr.id = sample_submissions.sample_request_id) AND (o.supplier_id = auth.uid())))));


--
-- Name: timeline_predictions Suppliers view assigned order predictions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Suppliers view assigned order predictions" ON public.timeline_predictions FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.orders o
  WHERE ((o.id = timeline_predictions.order_id) AND (o.supplier_id IN ( SELECT suppliers.id
           FROM public.suppliers
          WHERE (suppliers.user_id = auth.uid())))))));


--
-- Name: order_messages Users can create messages for their orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can create messages for their orders" ON public.order_messages FOR INSERT WITH CHECK (((sender_id = auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.orders o
  WHERE ((o.id = order_messages.order_id) AND ((o.buyer_id = auth.uid()) OR (o.supplier_id IN ( SELECT s.id
           FROM public.suppliers s
          WHERE (s.user_id = auth.uid())))))))));


--
-- Name: wishlists Users can delete own wishlist; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can delete own wishlist" ON public.wishlists FOR DELETE USING ((auth.uid() = user_id));


--
-- Name: order_documents Users can delete their own documents; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can delete their own documents" ON public.order_documents FOR DELETE USING ((auth.uid() = uploaded_by));


--
-- Name: notifications Users can delete their own notifications; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can delete their own notifications" ON public.notifications FOR DELETE USING ((user_id = auth.uid()));


--
-- Name: profiles Users can insert own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK ((auth.uid() = id));


--
-- Name: wishlists Users can insert own wishlist; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert own wishlist" ON public.wishlists FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: profiles Users can insert their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT TO authenticated WITH CHECK ((id = auth.uid()));


--
-- Name: messages Users can send messages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can send messages" ON public.messages FOR INSERT WITH CHECK ((sender_id = auth.uid()));


--
-- Name: supplier_messages Users can send messages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can send messages" ON public.supplier_messages FOR INSERT TO authenticated WITH CHECK (((sender_id = auth.uid()) AND (public.has_role(auth.uid(), 'admin'::public.app_role) OR (supplier_order_id IN ( SELECT so.id
   FROM public.supplier_orders so
  WHERE (so.supplier_id IN ( SELECT suppliers.id
           FROM public.suppliers
          WHERE (suppliers.user_id = auth.uid()))))))));


--
-- Name: profiles Users can update own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING ((auth.uid() = id));


--
-- Name: wishlists Users can update own wishlist; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update own wishlist" ON public.wishlists FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: notifications Users can update their notifications; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their notifications" ON public.notifications FOR UPDATE USING ((user_id = auth.uid()));


--
-- Name: conversation_context Users can update their own conversations; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their own conversations" ON public.conversation_context FOR UPDATE USING (((auth.uid() = user_id) OR (email = (( SELECT users.email
   FROM auth.users
  WHERE (users.id = auth.uid())))::text)));


--
-- Name: notifications Users can update their own notifications; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their own notifications" ON public.notifications FOR UPDATE TO authenticated USING ((user_id = auth.uid()));


--
-- Name: notification_preferences Users can update their own preferences; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their own preferences" ON public.notification_preferences USING ((auth.uid() = user_id));


--
-- Name: profiles Users can update their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE TO authenticated USING ((id = auth.uid()));


--
-- Name: ai_quotes Users can update their own quotes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their own quotes" ON public.ai_quotes FOR UPDATE TO authenticated USING (((user_id = auth.uid()) OR ((user_id IS NULL) AND (customer_email = (( SELECT users.email
   FROM auth.users
  WHERE (users.id = auth.uid())))::text))));


--
-- Name: quotes Users can update their own quotes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their own quotes" ON public.quotes FOR UPDATE USING (((buyer_id = auth.uid()) OR (session_id = ((current_setting('request.jwt.claims'::text, true))::json ->> 'session_id'::text))));


--
-- Name: messages Users can update their received messages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their received messages" ON public.messages FOR UPDATE USING ((recipient_id = auth.uid()));


--
-- Name: quote_approvals Users can view approvals for their quotes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view approvals for their quotes" ON public.quote_approvals FOR SELECT USING ((quote_id IN ( SELECT ai_quotes.id
   FROM public.ai_quotes
  WHERE (ai_quotes.customer_email = (( SELECT users.email
           FROM auth.users
          WHERE (users.id = auth.uid())))::text))));


--
-- Name: order_messages Users can view messages for their orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view messages for their orders" ON public.order_messages FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.orders o
  WHERE ((o.id = order_messages.order_id) AND ((o.buyer_id = auth.uid()) OR (o.supplier_id IN ( SELECT s.id
           FROM public.suppliers s
          WHERE (s.user_id = auth.uid()))))))));


--
-- Name: supplier_messages Users can view messages for their orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view messages for their orders" ON public.supplier_messages FOR SELECT TO authenticated USING ((public.has_role(auth.uid(), 'admin'::public.app_role) OR (supplier_order_id IN ( SELECT so.id
   FROM public.supplier_orders so
  WHERE (so.supplier_id IN ( SELECT suppliers.id
           FROM public.suppliers
          WHERE (suppliers.user_id = auth.uid())))))));


--
-- Name: order_status_history Users can view order history for their orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view order history for their orders" ON public.order_status_history FOR SELECT USING (((order_id IN ( SELECT orders.id
   FROM public.orders
  WHERE ((orders.buyer_id = auth.uid()) OR (orders.supplier_id IN ( SELECT suppliers.id
           FROM public.suppliers
          WHERE (suppliers.user_id = auth.uid())))))) OR (EXISTS ( SELECT 1
   FROM public.user_roles
  WHERE ((user_roles.user_id = auth.uid()) AND (user_roles.role = 'admin'::public.app_role))))));


--
-- Name: profiles Users can view own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING ((auth.uid() = id));


--
-- Name: profiles Users can view own profile only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view own profile only" ON public.profiles FOR SELECT TO authenticated USING (((id = auth.uid()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));


--
-- Name: wishlists Users can view own wishlist; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view own wishlist" ON public.wishlists FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: batch_contributions Users can view their contributions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their contributions" ON public.batch_contributions FOR SELECT USING (((EXISTS ( SELECT 1
   FROM public.orders o
  WHERE ((o.id = batch_contributions.order_id) AND (o.buyer_id = auth.uid())))) OR public.has_role(auth.uid(), 'admin'::public.app_role)));


--
-- Name: messages Users can view their messages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their messages" ON public.messages FOR SELECT USING (((sender_id = auth.uid()) OR (recipient_id = auth.uid())));


--
-- Name: notifications Users can view their notifications; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their notifications" ON public.notifications FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: product_interactions Users can view their own interactions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own interactions" ON public.product_interactions FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: notifications Users can view their own notifications; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own notifications" ON public.notifications FOR SELECT TO authenticated USING ((user_id = auth.uid()));


--
-- Name: payment_history Users can view their own payments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own payments" ON public.payment_history FOR SELECT USING (((paid_by = auth.uid()) OR (paid_to = auth.uid())));


--
-- Name: notification_preferences Users can view their own preferences; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own preferences" ON public.notification_preferences FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: profiles Users can view their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own profile" ON public.profiles FOR SELECT TO authenticated USING ((id = auth.uid()));


--
-- Name: quote_requests Users can view their own quote requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own quote requests" ON public.quote_requests FOR SELECT USING (((auth.uid() = user_id) OR (email = (( SELECT users.email
   FROM auth.users
  WHERE (users.id = auth.uid())))::text)));


--
-- Name: ai_quotes Users can view their own quotes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own quotes" ON public.ai_quotes FOR SELECT TO authenticated USING (((user_id = auth.uid()) OR ((user_id IS NULL) AND (customer_email = (( SELECT users.email
   FROM auth.users
  WHERE (users.id = auth.uid())))::text))));


--
-- Name: quotes Users can view their own quotes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own quotes" ON public.quotes FOR SELECT USING (((buyer_id = auth.uid()) OR (session_id = ((current_setting('request.jwt.claims'::text, true))::json ->> 'session_id'::text))));


--
-- Name: user_roles Users can view their own roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own roles" ON public.user_roles FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: timeline_predictions Users can view timelines for their quotes and orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view timelines for their quotes and orders" ON public.timeline_predictions FOR SELECT USING ((((quote_id IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public.quotes
  WHERE ((quotes.id = timeline_predictions.quote_id) AND ((quotes.buyer_id = auth.uid()) OR (quotes.session_id = ((current_setting('request.jwt.claims'::text, true))::json ->> 'session_id'::text))))))) OR ((order_id IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = timeline_predictions.order_id) AND ((orders.buyer_id = auth.uid()) OR (orders.factory_id = auth.uid())))))) OR public.has_role(auth.uid(), 'admin'::public.app_role)));


--
-- Name: order_updates Users can view updates for their orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view updates for their orders" ON public.order_updates FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = order_updates.order_id) AND ((orders.buyer_id = auth.uid()) OR (orders.factory_id = auth.uid()))))));


--
-- Name: profiles Users update own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users update own profile" ON public.profiles FOR UPDATE TO authenticated USING ((auth.uid() = id)) WITH CHECK ((auth.uid() = id));


--
-- Name: blog_comments Users view approved comments or own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users view approved comments or own" ON public.blog_comments FOR SELECT USING (((approved = true) OR (auth.uid() = user_id) OR public.has_role(auth.uid(), 'admin'::public.app_role)));


--
-- Name: conversation_messages Users view conversation messages (5 min window); Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users view conversation messages (5 min window)" ON public.conversation_messages FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.conversation_context cc
  WHERE ((cc.id = conversation_messages.conversation_id) AND (((auth.uid() IS NOT NULL) AND ((cc.user_id = auth.uid()) OR (cc.email = (( SELECT users.email
           FROM auth.users
          WHERE (users.id = auth.uid())))::text))) OR ((auth.uid() IS NULL) AND (cc.session_id IS NOT NULL) AND (cc.created_at > (now() - '00:05:00'::interval))) OR public.has_role(auth.uid(), 'admin'::public.app_role))))));


--
-- Name: conversation_context Users view conversations (5 min window); Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users view conversations (5 min window)" ON public.conversation_context FOR SELECT USING ((((auth.uid() IS NOT NULL) AND ((user_id = auth.uid()) OR (email = (( SELECT users.email
   FROM auth.users
  WHERE (users.id = auth.uid())))::text))) OR ((auth.uid() IS NULL) AND (session_id IS NOT NULL) AND (created_at > (now() - '00:05:00'::interval))) OR public.has_role(auth.uid(), 'admin'::public.app_role)));


--
-- Name: conversation_context Users view own conversations or recent session (5 min); Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users view own conversations or recent session (5 min)" ON public.conversation_context FOR SELECT USING (((auth.uid() = user_id) OR public.has_role(auth.uid(), 'admin'::public.app_role) OR ((session_id IS NOT NULL) AND (created_at > (now() - '00:05:00'::interval)))));


--
-- Name: profiles Users view own profile or admins view all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users view own profile or admins view all" ON public.profiles FOR SELECT TO authenticated USING (((auth.uid() = id) OR public.has_role(auth.uid(), 'admin'::public.app_role)));


--
-- Name: quote_requests Users view own quote requests; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users view own quote requests" ON public.quote_requests FOR SELECT TO authenticated USING ((email = (( SELECT users.email
   FROM auth.users
  WHERE (users.id = auth.uid())))::text));


--
-- Name: quote_requests Users view own quote requests via user_id; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users view own quote requests via user_id" ON public.quote_requests FOR SELECT TO authenticated USING (((auth.uid() = user_id) OR public.has_role(auth.uid(), 'admin'::public.app_role)));


--
-- Name: quotes Users view own quotes only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users view own quotes only" ON public.quotes FOR SELECT USING (((auth.uid() = buyer_id) OR public.has_role(auth.uid(), 'admin'::public.app_role)));


--
-- Name: ai_quotes Users view quotes with IP-bound session (5 min); Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users view quotes with IP-bound session (5 min)" ON public.ai_quotes FOR SELECT USING (((auth.uid() = user_id) OR public.has_role(auth.uid(), 'admin'::public.app_role) OR ((session_id IS NOT NULL) AND (created_at > (now() - '00:05:00'::interval)) AND ((ip_address IS NULL) OR (ip_address = ((current_setting('request.headers'::text, true))::json ->> 'x-forwarded-for'::text))))));


--
-- Name: admin_actions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.admin_actions ENABLE ROW LEVEL SECURITY;

--
-- Name: admin_audit_logs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.admin_audit_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: ai_cost_tracking; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.ai_cost_tracking ENABLE ROW LEVEL SECURITY;

--
-- Name: ai_quote_rate_limits; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.ai_quote_rate_limits ENABLE ROW LEVEL SECURITY;

--
-- Name: ai_quotes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.ai_quotes ENABLE ROW LEVEL SECURITY;

--
-- Name: ai_usage_logs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.ai_usage_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: automation_rules; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.automation_rules ENABLE ROW LEVEL SECURITY;

--
-- Name: batch_contributions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.batch_contributions ENABLE ROW LEVEL SECURITY;

--
-- Name: blog_categories; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.blog_categories ENABLE ROW LEVEL SECURITY;

--
-- Name: blog_comments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.blog_comments ENABLE ROW LEVEL SECURITY;

--
-- Name: blog_posts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.blog_posts ENABLE ROW LEVEL SECURITY;

--
-- Name: bootstrap_attempts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.bootstrap_attempts ENABLE ROW LEVEL SECURITY;

--
-- Name: capacity_utilization_logs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.capacity_utilization_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: case_studies; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.case_studies ENABLE ROW LEVEL SECURITY;

--
-- Name: certifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.certifications ENABLE ROW LEVEL SECURITY;

--
-- Name: cms_content; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.cms_content ENABLE ROW LEVEL SECURITY;

--
-- Name: company_info; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.company_info ENABLE ROW LEVEL SECURITY;

--
-- Name: conversation_analytics; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.conversation_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: conversation_context; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.conversation_context ENABLE ROW LEVEL SECURITY;

--
-- Name: conversation_messages; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.conversation_messages ENABLE ROW LEVEL SECURITY;

--
-- Name: conversation_rate_limits; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.conversation_rate_limits ENABLE ROW LEVEL SECURITY;

--
-- Name: defects; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.defects ENABLE ROW LEVEL SECURITY;

--
-- Name: email_verification_otps; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.email_verification_otps ENABLE ROW LEVEL SECURITY;

--
-- Name: exchange_rates; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.exchange_rates ENABLE ROW LEVEL SECURITY;

--
-- Name: exit_intent_sample_requests; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.exit_intent_sample_requests ENABLE ROW LEVEL SECURITY;

--
-- Name: factory_capacity; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.factory_capacity ENABLE ROW LEVEL SECURITY;

--
-- Name: industry_knowledge; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.industry_knowledge ENABLE ROW LEVEL SECURITY;

--
-- Name: invoices; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;

--
-- Name: market_research_cache; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.market_research_cache ENABLE ROW LEVEL SECURITY;

--
-- Name: marketplace_products; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.marketplace_products ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: notification_preferences; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

--
-- Name: order_documents; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.order_documents ENABLE ROW LEVEL SECURITY;

--
-- Name: order_messages; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.order_messages ENABLE ROW LEVEL SECURITY;

--
-- Name: order_status_history; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;

--
-- Name: order_updates; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.order_updates ENABLE ROW LEVEL SECURITY;

--
-- Name: orders; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

--
-- Name: otp_rate_limits; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.otp_rate_limits ENABLE ROW LEVEL SECURITY;

--
-- Name: otp_verification_attempts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.otp_verification_attempts ENABLE ROW LEVEL SECURITY;

--
-- Name: payment_history; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.payment_history ENABLE ROW LEVEL SECURITY;

--
-- Name: phone_verification_otps; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.phone_verification_otps ENABLE ROW LEVEL SECURITY;

--
-- Name: product_categories; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.product_categories ENABLE ROW LEVEL SECURITY;

--
-- Name: product_interactions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.product_interactions ENABLE ROW LEVEL SECURITY;

--
-- Name: production_batches; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.production_batches ENABLE ROW LEVEL SECURITY;

--
-- Name: production_stage_templates; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.production_stage_templates ENABLE ROW LEVEL SECURITY;

--
-- Name: production_stages; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.production_stages ENABLE ROW LEVEL SECURITY;

--
-- Name: products; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: qc_checks; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.qc_checks ENABLE ROW LEVEL SECURITY;

--
-- Name: quote_approvals; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.quote_approvals ENABLE ROW LEVEL SECURITY;

--
-- Name: quote_configurations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.quote_configurations ENABLE ROW LEVEL SECURITY;

--
-- Name: quote_requests; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.quote_requests ENABLE ROW LEVEL SECURITY;

--
-- Name: quote_usage_tracking; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.quote_usage_tracking ENABLE ROW LEVEL SECURITY;

--
-- Name: quotes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.quotes ENABLE ROW LEVEL SECURITY;

--
-- Name: resource_downloads; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.resource_downloads ENABLE ROW LEVEL SECURITY;

--
-- Name: sample_requests; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.sample_requests ENABLE ROW LEVEL SECURITY;

--
-- Name: sample_submissions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.sample_submissions ENABLE ROW LEVEL SECURITY;

--
-- Name: security_events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.security_events ENABLE ROW LEVEL SECURITY;

--
-- Name: shipping_info; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.shipping_info ENABLE ROW LEVEL SECURITY;

--
-- Name: social_shares; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.social_shares ENABLE ROW LEVEL SECURITY;

--
-- Name: supplier_capabilities; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.supplier_capabilities ENABLE ROW LEVEL SECURITY;

--
-- Name: supplier_certifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.supplier_certifications ENABLE ROW LEVEL SECURITY;

--
-- Name: supplier_media; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.supplier_media ENABLE ROW LEVEL SECURITY;

--
-- Name: supplier_messages; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.supplier_messages ENABLE ROW LEVEL SECURITY;

--
-- Name: supplier_mou_terms; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.supplier_mou_terms ENABLE ROW LEVEL SECURITY;

--
-- Name: supplier_orders; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.supplier_orders ENABLE ROW LEVEL SECURITY;

--
-- Name: supplier_payables; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.supplier_payables ENABLE ROW LEVEL SECURITY;

--
-- Name: supplier_performance; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.supplier_performance ENABLE ROW LEVEL SECURITY;

--
-- Name: supplier_quotes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.supplier_quotes ENABLE ROW LEVEL SECURITY;

--
-- Name: supplier_ratings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.supplier_ratings ENABLE ROW LEVEL SECURITY;

--
-- Name: suppliers; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;

--
-- Name: timeline_predictions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.timeline_predictions ENABLE ROW LEVEL SECURITY;

--
-- Name: user_roles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

--
-- Name: wishlist_rate_limits; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.wishlist_rate_limits ENABLE ROW LEVEL SECURITY;

--
-- Name: wishlists; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.wishlists ENABLE ROW LEVEL SECURITY;

--
-- Name: work_orders; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.work_orders ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--


