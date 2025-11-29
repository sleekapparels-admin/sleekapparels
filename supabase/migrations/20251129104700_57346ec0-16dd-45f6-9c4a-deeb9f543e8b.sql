-- Convert materialized view to regular view for security compliance
-- Step 1: Drop dependent functions
DROP FUNCTION IF EXISTS public.refresh_product_engagement_metrics();
DROP FUNCTION IF EXISTS public.get_product_engagement_metrics();

-- Step 2: Drop the materialized view
DROP MATERIALIZED VIEW IF EXISTS public.product_engagement_metrics;

-- Step 3: Recreate as a regular view for always-current data
CREATE OR REPLACE VIEW public.product_engagement_metrics AS
SELECT 
    p.id AS product_id,
    p.title AS product_name,
    p.category,
    count(DISTINCT pi.session_id) AS unique_sessions,
    count(*) FILTER (WHERE pi.interaction_type = 'hover'::product_interaction_type) AS hover_count,
    count(*) FILTER (WHERE pi.interaction_type = 'quick_view_click'::product_interaction_type) AS quick_view_count,
    count(*) FILTER (WHERE pi.interaction_type = 'wishlist_click'::product_interaction_type) AS wishlist_count,
    count(*) FILTER (WHERE pi.interaction_type = 'color_swatch_click'::product_interaction_type) AS color_swatch_count,
    count(*) FILTER (WHERE pi.interaction_type = 'design_click'::product_interaction_type) AS design_click_count,
    count(*) FILTER (WHERE pi.interaction_type = 'quote_click'::product_interaction_type) AS quote_click_count,
    count(*) FILTER (WHERE pi.interaction_type = 'view_details'::product_interaction_type) AS view_details_count,
    max(pi.timestamp) AS last_interaction,
    count(*) AS total_interactions
FROM products p
LEFT JOIN product_interactions pi ON p.id = pi.product_id
WHERE pi.timestamp > (now() - interval '30 days') OR pi.timestamp IS NULL
GROUP BY p.id, p.title, p.category;

-- Step 4: Recreate the access function (no longer need refresh function)
CREATE OR REPLACE FUNCTION public.get_product_engagement_metrics()
RETURNS SETOF product_engagement_metrics
LANGUAGE sql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
  -- Only allow admins to access this data
  SELECT *
  FROM public.product_engagement_metrics
  WHERE public.has_role(auth.uid(), 'admin'::app_role);
$$;

-- Step 5: Revoke direct access to the view (access only through the function)
REVOKE ALL ON public.product_engagement_metrics FROM authenticated;
REVOKE ALL ON public.product_engagement_metrics FROM anon;
REVOKE ALL ON public.product_engagement_metrics FROM public;

-- Grant execute permission on the access function to authenticated users
GRANT EXECUTE ON FUNCTION public.get_product_engagement_metrics() TO authenticated;