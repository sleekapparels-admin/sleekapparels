import { Metadata } from 'next';
import Link from 'next/link';
import JsonLd from '@/components/JsonLd';
import { generateMetadata } from '@/lib/metadata';
import { generateBreadcrumbSchema, generateProductSchema, generateFAQSchema, generateOrganizationSchema, defaultOrganization } from '@/lib/schema';

export const metadata: Metadata = generateMetadata({
  title: 'Amazon FBA Apparel Supplier Bangladesh | Private Label | MOQ 50 | Sleek Apparels',
  description: 'Amazon FBA ready apparel supplier in Bangladesh. MOQ 50 pieces, FBA-compliant packaging, FNSKU labeling, direct warehouse shipping. Start your Amazon clothing brand today.',
  keywords: [
    'amazon fba apparel supplier bangladesh',
    'amazon fba clothing manufacturer',
    'private label amazon fba bangladesh',
    'amazon seller clothing supplier',
    'fba ready apparel bangladesh',
    'amazon fashion supplier bangladesh',
    'low moq amazon fba clothing',
    'amazon fba starter bangladesh',
  ],
  canonical: 'https://sleekapparels.com/amazon-fba-apparel-supplier-bangladesh',
});

interface FAQItem {
  question: string;
  answer: string;
}

export default function AmazonFBASupplierPage() {
  const faqs: FAQItem[] = [
    {
      question: "What is your minimum order quantity (MOQ) for Amazon FBA sellers?",
      answer: "Our MOQ for Amazon FBA sellers is just 50 pieces per style/color - perfect for testing new designs without massive inventory risk. This breaks down to approximately 10 pieces per size (S, M, L, XL, XXL), ideal for initial market validation. Many successful Amazon sellers start with 2-3 designs at 50 pieces each (150 total), test market response for 30-60 days, then reorder bestsellers in larger quantities (100-300 pieces) with better pricing. Our low MOQ is specifically designed for Amazon Private Label sellers who need to: Test multiple designs quickly, validate demand before scaling, manage cash flow efficiently, avoid dead inventory risk. After your first successful order, reorder MOQ drops to just 30 pieces per style, giving you even more flexibility as you scale."
    },
    {
      question: "Do you provide FBA-compliant packaging and labeling?",
      answer: "Yes, we're experts in Amazon FBA requirements and provide complete FBA-ready preparation. Our FBA compliance service includes: FNSKU Labels (barcode labels applied to every unit, scannable and durable, correct size and placement per Amazon standards), Box Labels (shipping labels on master cartons, includes FNSKU, quantity, destination FBA center), Suffocation Warnings (required poly bag warnings in 14pt font, compliance with Amazon safety requirements), Proper Packaging (poly bags with 1.5\" opening or vent holes, bubble wrap for delicate items, sturdy cartons meeting weight limits), Carton Specifications (maximum 50lbs per box, dimensions not exceeding 25\" girth, proper cushioning and protection), Packing Slips (item manifest inside each carton, matches shipment plan exactly). We've shipped to every major FBA center and know the requirements cold. Your inventory arrives FBA-ready—Amazon scans and shelves immediately with zero prep delays."
    },
    {
      question: "Can you ship directly to multiple Amazon FBA warehouses?",
      answer: "Absolutely—we handle split shipments to multiple FBA centers routinely. Here's how it works: You create your shipment plan in Amazon Seller Central, Amazon assigns destination warehouses (typically 2-4 locations), you provide us the shipment IDs and box labels, we split your inventory according to Amazon's allocation, we ship directly to each FBA center with proper documentation, you track each shipment through your Seller Central account. We regularly ship to these major FBA centers: West Coast (ONT8, LAS1, PHX6 in CA/NV/AZ), Central (DFW7 Texas, IND4 Indiana, MDW6 Illinois), East Coast (EWR4/LGA9 NJ/NY, RIC2 Virginia, AVP1 Pennsylvania). Split shipment logistics: We charge $50 per additional destination (very reasonable), each location receives proper box labels and packing lists, you receive tracking for all shipments, typical delivery: 7-10 days air freight, 20-25 days sea freight. Pro tip: For first orders, request single-destination fulfillment in Seller Central to simplify logistics. As you scale, multi-warehouse distribution improves delivery speed to customers."
    },
    {
      question: "What's the complete cost breakdown for an Amazon FBA clothing order?",
      answer: "Here's a transparent breakdown for a typical first Amazon FBA order (100 t-shirts): Manufacturing: Unit cost $4.50-$6.50 per t-shirt depending on fabric/print = $450-$650 total. Branding & Packaging: Woven labels (100 pcs) $0.30 each = $30, Poly bags with suffocation warning $0.12 each = $12, Hang tags $0.25 each = $25, FNSKU labels (we apply) $0.10 each = $10. Shipping to USA FBA: Air freight (15kg shipment) ~$90-$120, Customs clearance and duties ~$50-$80, or Sea freight (larger orders) ~$150-$200 all-in. Total First Order Cost: Low end: $657 ($6.57/unit landed), High end: $927 ($9.27/unit landed). Your Amazon Selling Price: If selling at $19.99 (common price point): Amazon fees (referral 15% + FBA $4-5) = ~$7-8 per unit, Your profit per unit = $19.99 - $9.27 (cost) - $7.50 (Amazon fees) = $3.22, Total profit on 100 units = $322 (49% margin). As you scale to 300-500 piece orders: Unit costs drop 10-15%, shipping per unit decreases, profit margins improve to 55-65%. This is why Amazon Private Label works—you control the brand and margins."
    },
    {
      question: "How long does it take from order to Amazon FBA warehouse delivery?",
      answer: "Complete timeline for Amazon FBA orders: Week 1: Design finalization, fabric/trim selection, tech pack creation. Week 2: Sample production and approval (shipped via DHL, 5-7 days to you). Week 3: Production deposit paid, cutting and sewing begins. Weeks 4-6: Bulk production (printing, assembly, quality control). Week 7: FBA preparation (FNSKU labeling, poly bagging, carton packing). Week 8: Shipping to FBA warehouse (Air: 7-10 days, Sea: 20-25 days). Total Timeline: Air Freight Path: 8-9 weeks order to FBA shelves, Sea Freight Path: 10-11 weeks order to FBA shelves. Rush Service Available: For urgent restocks, we offer 5-week total timeline: 3 weeks production + 1 week prep + 1 week air freight, additional 20% rush fee applies. Pro Tips for Amazon Sellers: Order your next batch when current inventory hits 50% to avoid stockouts, use air freight for initial test orders (speed over cost), switch to sea freight for proven bestsellers (cost over speed), plan for Q4 (order by August 1 for October FBA delivery)."
    },
    {
      question: "What product categories work best for Amazon Private Label from Bangladesh?",
      answer: "Based on our 300+ successful Amazon seller clients, these categories perform exceptionally well: T-Shirts & Basics (60% of our Amazon orders): Graphic tees with niche designs, minimalist basics in trending colors, oversized/longline trendy fits, retail price $16.99-$24.99, profit margin 50-65%. Hoodies & Sweatshirts (25% of orders): Pullover hoodies (bestseller), zip-up hoodies, crewneck sweatshirts, retail price $29.99-$49.99, profit margin 45-60%, higher AOV boosts rankings. Activewear & Leggings (10% of orders): High-waist leggings, sports bras, yoga tops, retail price $24.99-$39.99, profit margin 50-60%, technical fabrics available. Loungewear Sets (5% of orders): Matching sets (huge trend), pajama sets, jogger sets, retail price $34.99-$59.99, profit margin 55-65%, bundle advantage. What Doesn't Work Well: Fast fashion trendy items (trends change before production completes), Complex technical outerwear (requires high MOQs), Denim jeans (sizing complexity, high return rates), Formal wear (fit-critical, high returns). Best Strategy: Start with 2-3 basic t-shirt designs in trending niches (fitness, gaming, mental health, etc.), validate sales for 60 days, expand to hoodies for higher AOV and profit, add complementary products (hats, tote bags) to increase cart value."
    },
    {
      question: "Do you help with Amazon product listings, photos, and branding?",
      answer: "While we focus on manufacturing, we provide essential assets to support your Amazon listing success: What We Provide: High-resolution product photos (flat lay, hanger shots, detail shots), size chart with measurements in inches, product description technical details (fabric, weight, care), dimension and weight data for Amazon listing. What We DON'T Provide (but can recommend partners): Lifestyle/model photography, Amazon listing copywriting, keyword research and SEO, A+ Content creation, product video production. However, we can connect you with trusted service providers: Photography: We work with Bangladesh-based lifestyle photographers ($200-$400 per product shoot), can arrange model shoots at our facility or outdoor locations, faster turnaround than shipping samples to USA photographers. Listing Optimization: We partner with Amazon listing specialists (USA-based) who understand apparel, typical cost $300-$500 per listing, includes keyword research, copywriting, and A+ Content. Many successful Amazon sellers follow this workflow: Receive samples from us (2-3 pieces), photograph samples themselves or hire local photographer, write initial listing copy and launch, reinvest first profits into professional photography and A+ Content, scale advertising once listing is optimized. Budget $500-$1,000 for listing assets if you're serious about Amazon success."
    },
    {
      question: "What Amazon compliance issues should I be aware of?",
      answer: "Amazon has strict compliance requirements for apparel—we help you navigate them all: Mandatory Compliance: Product Safety: All apparel must meet CPSIA standards (children's products require third-party testing), flammability requirements under 16 CFR 1610, proper fiber content labeling. Textile Labeling: Care labels required (washing instructions, fiber content, country of origin), must be permanently attached and legible, we provide compliant care labels with every order. Country of Origin: 'Made in Bangladesh' label required, cannot be removed or obscured, we ensure proper labeling on all products. Category-Specific Requirements: Children's Apparel (under 12): CPSIA testing required (lead, phthalates), tracking labels mandatory, age grading must be clear, we arrange testing through Intertek/SGS ($300-$500 per product). Sleepwear: Additional flammability testing required, specific fabric requirements, we advise on compliant fabrics. Performance Claims: If advertising 'moisture-wicking' or 'UV protection', testing documentation required, we can arrange performance testing. Intellectual Property: Never copy branded designs or trademarks, Amazon's Brand Registry detects infringement aggressively, we help you create truly original designs. Our Compliance Support: We provide certificates of compliance with every order, can arrange third-party testing when required, ensure all labeling meets Amazon and FTC standards, keep you out of compliance trouble that could suspend your account."
    },
    {
      question: "Can you help me create a complete Amazon Private Label brand from scratch?",
      answer: "Yes—many of our clients start with zero apparel experience and we guide them through the complete process. Our Amazon Startup Package includes: Brand Development Consultation (FREE): 30-minute video call to discuss your niche and target audience, product recommendations based on Amazon bestsellers, pricing strategy to ensure profitability. Design Support (FREE): Tech pack creation from your rough ideas/sketches, fabric and color recommendations, sizing guidance for US market, competitor analysis of similar Amazon products. Sampling ($75-$125 per sample): 2-3 physical samples for you to inspect, photographs for your Amazon listing, size samples for fit verification. Brand Assets (Cost varies): Custom woven labels with your brand name/logo ($30-$60 for 100 labels), hang tags with branding ($25-$50 for 100 tags), custom packaging (poly bags, tissue paper, stickers), logo design referral if needed ($200-$500 through our partner designers). Manufacturing (MOQ 50 pieces): First production run at standard pricing, full FBA preparation included, direct shipping to Amazon FBA warehouse. Launch Support: Checklists for Amazon Seller Central setup, recommended listing optimization partners, ongoing support for reorders and scaling. Total Investment to Launch: Ultra-budget: $1,500-$2,000 (samples + 50 pieces + basic branding), recommended: $2,500-$3,500 (samples + 100 pieces + professional branding), optimal: $4,000-$5,000 (samples + 150-200 pieces + pro photos and listings). Many Amazon sellers achieve profitability on their very first 100-unit order, then reinvest profits to expand product line and inventory. Success Timeline: Month 1-2: Planning, sampling, production, Month 3: Launch on Amazon, initial ads, Month 4-6: Optimization, reorders of bestsellers, Month 7-12: Scale to $10K-$50K/month with 5-10 products. We're not just a manufacturer—we're your partner in building a successful Amazon apparel brand."
    },
    {
      question: "What are the biggest mistakes new Amazon FBA clothing sellers make?",
      answer: "After working with 300+ Amazon sellers, we've seen these costly mistakes repeatedly: Ordering Too Much Too Soon: Mistake: Ordering 500-1,000 pieces for first launch, Reality: Most first products don't sell well, Solution: Start with 50-100 pieces, test and validate, then scale. Poor Product-Market Fit: Mistake: Choosing products based on personal preference, Reality: Amazon success requires data-driven decisions, Solution: Research bestsellers, identify underserved niches, follow trends. Ignoring Sizing: Mistake: Using Asian sizing specs, Reality: US customers expect US sizing, Solution: We default to US sizing to prevent this issue. Cutting Corners on Quality: Mistake: Choosing cheapest manufacturer, ignoring quality, Reality: Bad reviews destroy Amazon rankings permanently, Solution: Invest in quality from day one (we're mid-priced, high-quality). Not Budgeting for Marketing: Mistake: Expecting organic sales immediately, Reality: Amazon requires PPC advertising to launch, Solution: Budget $500-$1,000 for launch PPC campaigns. Weak Product Photography: Mistake: Using supplier photos or amateur photos, Reality: Amazon is visual—bad photos kill conversions, Solution: Invest $200-$400 in professional product photography. No Brand Building: Mistake: Treating Amazon as one-off transaction, Reality: Successful sellers build recognizable brands, Solution: Invest in consistent branding across products. Inventory Mismanagement: Mistake: Running out of stock during momentum, Reality: Stockouts kill rankings and waste ad spend, Solution: Reorder when inventory hits 50%, use our 30-piece reorder MOQ. Not Testing Multiple Designs: Mistake: Betting everything on one design, Reality: Impossible to predict winners without testing, Solution: Test 2-3 designs at 50 pieces each. Ignoring Compliance: Mistake: Skipping certifications and testing, Reality: Amazon suspends non-compliant accounts, Solution: We handle compliance from day one. Our Success Formula: Start with 2-3 tested designs (50-100 pieces each), invest in quality manufacturing and photography, launch with Amazon PPC advertising budget, double down on winners, cut losers quickly, scale proven bestsellers to 300-500 pieces, expand product line with profits, build a brand, not just products. This approach has helped our clients build $10K-$100K+/month Amazon businesses."
    }
  ];

  const breadcrumbSchema = generateBreadcrumbSchema([
    { name: 'Home', url: 'https://sleekapparels.com' },
    { name: 'Services', url: 'https://sleekapparels.com/services' },
    { name: 'Amazon FBA Supplier', url: 'https://sleekapparels.com/amazon-fba-apparel-supplier-bangladesh' }
  ]);

  const productSchema = generateProductSchema({
    name: 'Amazon FBA Apparel Supplier Service - Bangladesh',
    description: 'Complete Amazon FBA clothing supplier service from Bangladesh. MOQ 50 pieces, FBA-compliant packaging, FNSKU labeling, direct FBA warehouse shipping. Launch your Amazon brand.',
    brand: 'Sleek Apparels Limited',
    offers: {
      price: '3.50-18.00',
      priceCurrency: 'USD',
      availability: 'https://schema.org/InStock',
    }
  });

  const faqSchema = generateFAQSchema(faqs);
  const organizationSchema = generateOrganizationSchema(defaultOrganization);

  return (
    <>
      <JsonLd data={organizationSchema} />
      <JsonLd data={breadcrumbSchema} />
      <JsonLd data={productSchema} />
      <JsonLd data={faqSchema} />

      <main className="min-h-screen bg-gradient-to-b from-gray-50 to-white">
        {/* Hero Section */}
        <section className="relative overflow-hidden bg-gradient-to-br from-orange-600 via-red-600 to-pink-700 text-white">
          <div className="absolute inset-0 bg-black/10"></div>
          <div className="container mx-auto px-4 py-16 md:py-24 relative z-10">
            <div className="max-w-4xl mx-auto text-center">
              <div className="inline-block mb-6 px-4 py-2 bg-white/20 backdrop-blur-sm rounded-full text-sm font-semibold">
                📦 Amazon FBA Specialist
              </div>
              <h1 className="text-4xl md:text-6xl font-bold mb-6 leading-tight">
                Amazon FBA Apparel Supplier Bangladesh - Start Your Brand
              </h1>
              <p className="text-xl md:text-2xl mb-4 text-orange-100 leading-relaxed">
                <span className="font-bold text-white">MOQ 50 Pieces</span> • FBA-Ready Packaging • 
                FNSKU Labeling • Direct Warehouse Shipping
              </p>
              <p className="text-lg mb-8 text-orange-200">
                Private Label • Custom Branding • Complete Compliance • 8-9 Week Delivery
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Link 
                  href="/contact" 
                  className="inline-block bg-white text-orange-700 px-8 py-4 rounded-lg font-bold text-lg hover:bg-orange-50 transition-all shadow-xl hover:shadow-2xl hover:scale-105"
                >
                  Start Amazon Brand
                </Link>
                <Link 
                  href="/quote" 
                  className="inline-block bg-orange-800/50 backdrop-blur-sm border-2 border-white text-white px-8 py-4 rounded-lg font-bold text-lg hover:bg-orange-700/50 transition-all"
                >
                  Get FBA Quote
                </Link>
              </div>
              <p className="mt-6 text-sm text-orange-200">
                ✓ 300+ Successful Amazon Sellers • ✓ FBA-Compliant Guaranteed • ✓ Complete Startup Support
              </p>
            </div>
          </div>
        </section>

        {/* FAQs - Core content for this streamlined version */}
        <section className="py-16 md:py-24">
          <div className="container mx-auto px-4">
            <div className="max-w-3xl mx-auto text-center mb-16">
              <h2 className="text-3xl md:text-5xl font-bold mb-6 text-gray-900">
                Amazon FBA Seller Questions Answered
              </h2>
              <p className="text-xl text-gray-600">
                Everything you need to know to launch and scale your Amazon clothing brand.
              </p>
            </div>

            <div className="max-w-4xl mx-auto space-y-6">
              {faqs.map((faq, index) => (
                <details 
                  key={index}
                  className="group bg-white rounded-xl shadow-lg overflow-hidden border border-gray-200 hover:border-orange-600 transition-all"
                >
                  <summary className="flex justify-between items-center cursor-pointer p-6 font-semibold text-lg text-gray-900 hover:text-orange-600 transition-colors">
                    <span className="pr-8">{faq.question}</span>
                    <span className="flex-shrink-0 text-orange-600 group-open:rotate-180 transition-transform">
                      <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                      </svg>
                    </span>
                  </summary>
                  <div className="px-6 pb-6 text-gray-600 leading-relaxed border-t border-gray-100 pt-4">
                    {faq.answer}
                  </div>
                </details>
              ))}
            </div>
          </div>
        </section>

        {/* Final CTA */}
        <section className="py-16 md:py-24 bg-gradient-to-br from-orange-600 via-red-600 to-pink-700 text-white">
          <div className="container mx-auto px-4">
            <div className="max-w-4xl mx-auto text-center">
              <h2 className="text-4xl md:text-6xl font-bold mb-6">
                Launch Your Amazon Apparel Brand Today
              </h2>
              <p className="text-xl md:text-2xl mb-8 text-orange-100">
                MOQ 50 pieces • FBA-ready • Complete support • 8-9 week delivery
              </p>
              <Link 
                href="/contact" 
                className="inline-block bg-white text-orange-700 px-10 py-5 rounded-lg font-bold text-xl hover:bg-orange-50 transition-all shadow-2xl hover:scale-105"
              >
                Get Your Amazon FBA Quote
              </Link>
              <p className="mt-6 text-sm text-orange-200">
                ✓ 300+ Sellers Launched • ✓ $10K-$100K/Month Potential • ✓ Full Compliance Guaranteed
              </p>
            </div>
          </div>
        </section>
      </main>
    </>
  );
}
