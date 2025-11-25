import { Metadata } from 'next';
import Link from 'next/link';
import JsonLd from '@/components/JsonLd';
import { generateMetadata } from '@/lib/metadata';
import { generateBreadcrumbSchema, generateProductSchema, generateFAQSchema, generateOrganizationSchema, defaultOrganization } from '@/lib/schema';

export const metadata: Metadata = generateMetadata({
  title: 'Custom T-Shirt Manufacturer Bangladesh | 50 Piece MOQ | Sleek Apparels',
  description: 'Premium custom t-shirt manufacturer in Bangladesh with 50-piece MOQ. 100% cotton, organic, tri-blend options. OEKO-TEX certified. Screen print, DTG, embroidery available.',
  keywords: [
    'custom tshirt manufacturer bangladesh',
    'custom t-shirt manufacturer bangladesh',
    'bangladesh tshirt factory',
    'wholesale tshirt manufacturer bangladesh',
    'bulk t-shirt supplier bangladesh',
    'organic cotton tshirt bangladesh',
    'custom printed tshirts bangladesh',
    'low moq tshirt manufacturer',
    'bangladesh apparel manufacturer tshirts',
    'custom clothing bangladesh tshirts',
    'screen printing tshirts bangladesh',
    'embroidered tshirts bangladesh',
  ],
  canonical: 'https://sleekapparels.com/custom-tshirt-manufacturer-bangladesh',
});

interface FAQItem {
  question: string;
  answer: string;
}

export default function CustomTShirtManufacturerPage() {
  const faqs: FAQItem[] = [
    {
      question: "What is the minimum order quantity (MOQ) for custom t-shirts at Sleek Apparels?",
      answer: "Our minimum order quantity for custom t-shirts is just 50 pieces per style/color combination. This is significantly lower than most Bangladesh manufacturers who require 500-1,000 pieces. You can mix sizes within the 50-piece order (for example: 10 Small, 15 Medium, 15 Large, 10 XL). If you need multiple colors of the same design, each color requires a separate 50-piece minimum. This low MOQ makes us ideal for startups, small brands, event merchandise, corporate orders, and testing new designs before committing to large inventory."
    },
    {
      question: "What t-shirt fabric options do you offer?",
      answer: "We offer extensive fabric choices to match your quality and price point: 100% Cotton (ringspun or combed cotton, 150gsm-220gsm, soft and breathable, most popular for everyday tees), Cotton-Polyester Blends (50/50 or 60/40 cotton-poly, 160gsm-180gsm, more affordable, wrinkle-resistant, faster drying), Tri-Blend (50% polyester, 25% cotton, 25% rayon, 145gsm-160gsm, ultra-soft vintage feel, excellent drape), Organic Cotton (GOTS-certified 100% organic, 180gsm-200gsm, eco-friendly, premium positioning), Pima/Supima Cotton (long-staple premium cotton, 180gsm-200gsm, luxurious feel, higher durability), Performance Fabrics (moisture-wicking polyester or poly-cotton, 140gsm-160gsm, athletic/activewear applications). All fabrics are OEKO-TEX Standard 100 certified, ensuring they're free from harmful chemicals and safe for direct skin contact."
    },
    {
      question: "Can you print custom designs on t-shirts, and what methods do you use?",
      answer: "Yes, we offer multiple customization methods depending on your design complexity, quantity, and budget: Screen Printing (plastisol or water-based inks, ideal for large quantities and simple designs, up to 8 colors, durable and cost-effective at $0.50-$2.00 per print location), Direct-to-Garment (DTG) Printing (full-color digital printing, perfect for complex designs and small batches, photo-quality prints, higher cost at $2.50-$5.00 per print but no color limits), Embroidery (thread-based logo/text application, premium look and feel, extremely durable, best for corporate/promotional tees, $3.00-$6.00 depending on stitch count), Heat Transfer (vinyl or full-color transfers, good for names/numbers and small runs, $1.50-$3.00 per location), All-Over Printing (sublimation or specialty techniques, edge-to-edge custom prints, higher minimums usually required, $6.00-$10.00 per piece). We can combine methods too—for example, screen-printed front with embroidered sleeve logo."
    },
    {
      question: "How long does it take to produce custom t-shirts from order to delivery?",
      answer: "Standard custom t-shirt production timeline is 6-8 weeks total: Week 1: Design finalization, fabric selection, tech pack creation, Week 2: Sample production and approval (we ship samples via DHL, 5-7 days delivery), Week 3: Bulk fabric procurement and cutting begins, Weeks 4-5: Printing/embroidery and sewing, Week 6: Quality control, washing (if required), finishing, labeling, packing, Weeks 7-8: International shipping (air freight 5-7 days, sea freight 3-4 weeks). Rush production is available for an additional 15% fee, reducing total time to 4-5 weeks. We send progress photos every 3-4 days so you always know where your order stands. Many clients use the production time to build pre-launch hype on social media and lock in pre-orders."
    },
    {
      question: "What are your t-shirt pricing ranges, and what affects the cost?",
      answer: "T-shirt unit pricing ranges from $3.50 to $9.00 per piece depending on several factors: Fabric Type (100% cotton basics: $3.50-$5.50, Organic cotton: $5.00-$7.00, Tri-blend premium: $6.00-$8.00, Pima/Supima cotton: $7.00-$9.00), Fabric Weight (lighter 150gsm: lower cost, heavier 200-220gsm: 10-15% higher), Customization (plain stock tees: baseline pricing, 1-color screen print: add $0.50-$1.00, full-color DTG print: add $2.50-$5.00, embroidery: add $3.00-$6.00), Order Quantity (50-100 pieces: standard pricing, 100-300 pieces: 5-8% discount, 300-500 pieces: 8-12% discount, 500+ pieces: 12-18% discount), Construction Details (basic crew neck: baseline, custom neck labels: add $0.25-$0.40, side seams vs tubular: slight cost difference, reinforced shoulders: add $0.15-$0.30). We provide detailed cost breakdowns upfront with zero hidden fees."
    },
    {
      question: "Can you add custom labels, tags, and packaging to our t-shirts?",
      answer: "Absolutely—we offer complete turnkey branding services: Neck Labels (woven labels sewn into neck: $0.25-$0.60 each for 100+ pieces, printed heat-transfer labels: $0.15-$0.35 each, tear-away labels for comfort: available, custom sizes and colors to match your brand), Care Labels (fabric care instruction labels: $0.10-$0.20 each, required for retail sales in most countries, we provide standard templates or custom designs), Hang Tags (custom cardstock or kraft paper tags: $0.20-$0.50 each depending on complexity, can include barcode, size info, branding, metal or plastic fasteners included), Packaging (clear or frosted poly bags: $0.08-$0.15 each, custom printed poly bags with logo: $0.25-$0.40 each, tissue paper with logo: $0.25-$0.40 per sheet, premium gift boxes for special editions: $0.80-$2.00 each). We handle all sourcing, attachment during production, and quality control. Your t-shirts arrive 100% retail-ready."
    },
    {
      question: "Do you offer organic cotton and sustainable t-shirt options?",
      answer: "Yes, sustainability is increasingly important to our clients, and we offer comprehensive eco-friendly options: Organic Cotton (GOTS-certified 100% organic cotton from India or Turkey, grown without synthetic pesticides or fertilizers, 180gsm-200gsm premium weight, softer and more breathable than conventional cotton, 15-20% price premium over standard cotton but worth it for eco-conscious brands), Recycled Polyester Blends (made from recycled plastic bottles, 50/50 cotton-recycled poly or 100% recycled poly, performance characteristics with environmental benefits), Low-Impact Dyes (GOTS-approved natural and low-impact synthetic dyes, reduced water usage and chemical runoff, vibrant color options without environmental harm), Ethical Manufacturing (WRAP and SA8000 certified facilities, fair wages and safe working conditions, no child labor, transparent supply chain), Carbon-Neutral Shipping (we can offset shipping emissions for eco-conscious clients). We provide certification documents with every organic/sustainable order for your marketing claims and retail compliance."
    },
    {
      question: "Can you manufacture oversized, cropped, or custom-fit t-shirts?",
      answer: "Yes, we specialize in custom fits beyond standard sizing: Oversized/Boxy Fit (dropped shoulders, wider body, shorter length for streetwear aesthetic, popular with Gen Z and streetwear brands, same MOQ applies), Slim/Fitted Cut (tapered sides, closer-fitting sleeves, longer body length, preferred by fashion-forward and athletic brands), Cropped Styles (shortened body length hitting at waist or above, raw hem or finished hem options, trending in women's fashion and festival wear), Longline/Extended Length (extra length extending past hips, curved or straight hem options, popular in urban/streetwear), Custom Pattern Development (if you have specific measurements/fit requirements, we can develop custom patterns, one-time pattern fee of $100-$200, then standard per-piece pricing applies). We provide grading across all standard sizes (XS-3XL) for any custom fit. Samples are critical for fit approval before bulk production, and we encourage ordering 2-3 samples in different sizes."
    },
    {
      question: "What quality control measures do you have for t-shirt production?",
      answer: "Quality is non-negotiable at Sleek Apparels. Our 6-point inspection process for every t-shirt: 1) Fabric Inspection (checking for defects, holes, inconsistent dyeing, correct weight/hand feel before cutting), 2) Cutting Accuracy (ensuring pattern pieces match specifications within 2-3mm tolerance, consistent sizing across all pieces), 3) Sewing Quality (checking stitch integrity, seam strength, consistent stitch count, no loose threads or skipped stitches), 4) Print/Embroidery Quality (verifying placement accuracy within 5mm, color matching to approved samples, durability testing for washing/stretching, no cracking, peeling, or fading), 5) Measurements Verification (spot-checking 10% of finished garments against spec sheet, chest width, body length, sleeve length, neck opening), 6) Final Inspection & Packing (checking for stains, loose buttons/trims, proper labeling and tagging, correct poly bag/packaging). Any garments failing inspection are remade at no cost to you. We maintain a defect rate below 0.5% (industry standard is 2-4%). You receive pre-shipment photos and videos showing final products."
    },
    {
      question: "Can you handle t-shirt orders for events, corporate clients, and promotional campaigns?",
      answer: "Absolutely—we're experienced with time-sensitive event and corporate orders: Corporate Apparel (employee uniforms and team tees, consistent sizing and quality across large organizations, company logo embroidery or screen printing, reorder programs for ongoing needs), Event Merchandise (concert/festival tees, charity run/walk shirts, conference and trade show giveaways, sporting event apparel), Promotional Campaigns (product launch giveaways, influencer seeding and PR packages, social media contest prizes, brand awareness campaigns), Fast Turnaround Options (rush production available for urgent deadlines, 4-5 weeks total with 15% fee, air shipping for faster delivery), Flexible Ordering (order now, deliver later for scheduled events, warehousing available at our facility for staged rollouts, split shipments to multiple locations possible). We've produced t-shirts for Fortune 500 companies, major music festivals, and international NGOs. Our account managers understand deadline pressure and communicate proactively."
    }
  ];

  const breadcrumbSchema = generateBreadcrumbSchema([
    { name: 'Home', url: 'https://sleekapparels.com' },
    { name: 'Products', url: 'https://sleekapparels.com/products' },
    { name: 'Custom T-Shirt Manufacturing', url: 'https://sleekapparels.com/custom-tshirt-manufacturer-bangladesh' }
  ]);

  const productSchema = generateProductSchema({
    name: 'Custom T-Shirt Manufacturing Service - Bangladesh',
    description: 'Premium custom t-shirt manufacturing in Bangladesh with 50-piece MOQ. 100% cotton, organic, tri-blend options. Screen print, DTG, embroidery. OEKO-TEX certified fabrics.',
    brand: 'Sleek Apparels Limited',
    offers: {
      price: '3.50-9.00',
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
        <section className="relative overflow-hidden bg-gradient-to-br from-green-600 via-teal-600 to-blue-700 text-white">
          <div className="absolute inset-0 bg-black/10"></div>
          <div className="container mx-auto px-4 py-16 md:py-24 relative z-10">
            <div className="max-w-4xl mx-auto text-center">
              <div className="inline-block mb-6 px-4 py-2 bg-white/20 backdrop-blur-sm rounded-full text-sm font-semibold">
                👕 Premium T-Shirt Manufacturing
              </div>
              <h1 className="text-4xl md:text-6xl font-bold mb-6 leading-tight">
                Custom T-Shirt Manufacturer Bangladesh with 50-Piece MOQ
              </h1>
              <p className="text-xl md:text-2xl mb-4 text-green-100 leading-relaxed">
                Premium Quality • <span className="font-bold text-white">OEKO-TEX Certified</span> • 
                100% Cotton, Organic & Tri-Blend Options
              </p>
              <p className="text-lg mb-8 text-green-200">
                Screen Print • DTG • Embroidery • Custom Labels • 6-8 Week Turnaround
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Link 
                  href="/contact" 
                  className="inline-block bg-white text-green-700 px-8 py-4 rounded-lg font-bold text-lg hover:bg-green-50 transition-all shadow-xl hover:shadow-2xl hover:scale-105"
                >
                  Get T-Shirt Quote
                </Link>
                <Link 
                  href="/products/t-shirts" 
                  className="inline-block bg-green-800/50 backdrop-blur-sm border-2 border-white text-white px-8 py-4 rounded-lg font-bold text-lg hover:bg-green-700/50 transition-all"
                >
                  View T-Shirt Styles
                </Link>
              </div>
              <p className="mt-6 text-sm text-green-200">
                ✓ 50-Piece Minimum Order • ✓ All Fabric Types • ✓ Multiple Printing Methods
              </p>
            </div>
          </div>
          <div className="absolute bottom-0 left-0 right-0 h-16 bg-gradient-to-t from-white to-transparent"></div>
        </section>

        {/* Trust Bar */}
        <section className="bg-gray-50 border-y border-gray-200 py-6">
          <div className="container mx-auto px-4">
            <div className="flex flex-wrap justify-center items-center gap-8 text-center">
              <div className="flex items-center gap-2">
                <span className="text-2xl">📦</span>
                <div>
                  <div className="font-bold text-gray-900">50 Pieces</div>
                  <div className="text-sm text-gray-600">Minimum Order</div>
                </div>
              </div>
              <div className="hidden md:block w-px h-12 bg-gray-300"></div>
              <div className="flex items-center gap-2">
                <span className="text-2xl">✅</span>
                <div>
                  <div className="font-bold text-gray-900">OEKO-TEX</div>
                  <div className="text-sm text-gray-600">Certified Fabrics</div>
                </div>
              </div>
              <div className="hidden md:block w-px h-12 bg-gray-300"></div>
              <div className="flex items-center gap-2">
                <span className="text-2xl">🎨</span>
                <div>
                  <div className="font-bold text-gray-900">6+ Fabrics</div>
                  <div className="text-sm text-gray-600">Cotton, Organic, Blends</div>
                </div>
              </div>
              <div className="hidden md:block w-px h-12 bg-gray-300"></div>
              <div className="flex items-center gap-2">
                <span className="text-2xl">⚡</span>
                <div>
                  <div className="font-bold text-gray-900">6-8 Weeks</div>
                  <div className="text-sm text-gray-600">Production Time</div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Why Choose Our T-Shirt Manufacturing */}
        <section className="py-16 md:py-24">
          <div className="container mx-auto px-4">
            <div className="max-w-3xl mx-auto text-center mb-16">
              <h2 className="text-3xl md:text-5xl font-bold mb-6 text-gray-900">
                Why Brands Choose Sleek Apparels for Custom T-Shirts
              </h2>
              <p className="text-xl text-gray-600">
                From fabric selection to final packaging, we deliver retail-quality custom t-shirts 
                that represent your brand with pride.
              </p>
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8 max-w-7xl mx-auto">
              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-4xl mb-4">🏭</div>
                <h3 className="text-xl font-bold mb-3 text-gray-900">50-Piece Low MOQ</h3>
                <p className="text-gray-600 mb-4">
                  Industry-low 50-piece minimum per style/color. Test designs, launch startups, 
                  or run promotional campaigns without massive inventory risk.
                </p>
                <div className="text-sm text-green-600 font-semibold">
                  ✓ 10x lower than competitors
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-4xl mb-4">🧵</div>
                <h3 className="text-xl font-bold mb-3 text-gray-900">Premium Fabric Selection</h3>
                <p className="text-gray-600 mb-4">
                  Choose from 100% cotton, organic cotton, tri-blend, Pima/Supima, or performance 
                  fabrics. All OEKO-TEX certified and sourced from trusted mills.
                </p>
                <div className="text-sm text-green-600 font-semibold">
                  ✓ 6+ fabric options available
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-4xl mb-4">🎨</div>
                <h3 className="text-xl font-bold mb-3 text-gray-900">Multiple Customization Methods</h3>
                <p className="text-gray-600 mb-4">
                  Screen printing, DTG digital printing, embroidery, heat transfer, or all-over prints. 
                  We match the right method to your design and budget.
                </p>
                <div className="text-sm text-green-600 font-semibold">
                  ✓ 5 printing techniques available
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-4xl mb-4">💰</div>
                <h3 className="text-xl font-bold mb-3 text-gray-900">Transparent Pricing</h3>
                <p className="text-gray-600 mb-4">
                  $3.50-$9.00 per t-shirt depending on fabric and customization. Detailed quotes 
                  with zero hidden fees. Volume discounts available.
                </p>
                <div className="text-sm text-green-600 font-semibold">
                  ✓ No surprise charges
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-4xl mb-4">✅</div>
                <h3 className="text-xl font-bold mb-3 text-gray-900">6-Point Quality Control</h3>
                <p className="text-gray-600 mb-4">
                  Every t-shirt undergoes rigorous inspection: fabric, cutting, sewing, printing, 
                  measurements, and final QC. Defect rate below 0.5%.
                </p>
                <div className="text-sm text-green-600 font-semibold">
                  ✓ Industry-leading quality
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-4xl mb-4">🌱</div>
                <h3 className="text-xl font-bold mb-3 text-gray-900">Sustainable Options</h3>
                <p className="text-gray-600 mb-4">
                  GOTS-certified organic cotton, recycled polyester blends, low-impact dyes, and 
                  ethical manufacturing (WRAP/SA8000 certified).
                </p>
                <div className="text-sm text-green-600 font-semibold">
                  ✓ Eco-friendly choices
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-4xl mb-4">📦</div>
                <h3 className="text-xl font-bold mb-3 text-gray-900">Complete Branding Services</h3>
                <p className="text-gray-600 mb-4">
                  Custom woven labels, hang tags, care labels, poly bags, tissue paper, and gift boxes. 
                  Your t-shirts arrive 100% retail-ready.
                </p>
                <div className="text-sm text-green-600 font-semibold">
                  ✓ Turnkey packaging solutions
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-4xl mb-4">⚡</div>
                <h3 className="text-xl font-bold mb-3 text-gray-900">Fast Turnaround</h3>
                <p className="text-gray-600 mb-4">
                  Standard 6-8 weeks from order to delivery. Rush production available in 4-5 weeks 
                  for urgent deadlines (events, seasonal launches).
                </p>
                <div className="text-sm text-green-600 font-semibold">
                  ✓ Rush options available
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* T-Shirt Fabric Options */}
        <section className="py-16 md:py-24 bg-gray-50">
          <div className="container mx-auto px-4">
            <div className="max-w-3xl mx-auto text-center mb-16">
              <h2 className="text-3xl md:text-5xl font-bold mb-6 text-gray-900">
                Premium T-Shirt Fabrics
              </h2>
              <p className="text-xl text-gray-600">
                Choose the perfect fabric for your brand's quality positioning and target market. 
                All fabrics are OEKO-TEX Standard 100 certified.
              </p>
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8 max-w-6xl mx-auto">
              <div className="bg-white rounded-xl overflow-hidden shadow-lg hover:shadow-2xl transition-all">
                <div className="bg-gradient-to-br from-blue-500 to-blue-600 p-6 text-white">
                  <div className="text-3xl mb-2">🧵</div>
                  <h3 className="text-2xl font-bold">100% Cotton</h3>
                  <div className="text-sm text-blue-100 mt-1">Most Popular</div>
                </div>
                <div className="p-6">
                  <p className="text-gray-600 mb-4">
                    Soft, breathable, and comfortable. Perfect for everyday wear. Available in 
                    ringspun or combed cotton for premium softness.
                  </p>
                  <div className="space-y-2 mb-4">
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Weight: 150gsm - 220gsm</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Feel: Soft & breathable</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Best for: Everyday casual wear</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Shrinkage: Pre-shrunk available</span>
                    </div>
                  </div>
                  <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                    <span className="text-sm text-gray-500">Price Range</span>
                    <span className="text-xl font-bold text-blue-600">$3.50 - $5.50</span>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl overflow-hidden shadow-lg hover:shadow-2xl transition-all border-2 border-green-500">
                <div className="absolute top-4 right-4 bg-green-500 text-white px-3 py-1 rounded-full text-xs font-bold">
                  ECO-FRIENDLY
                </div>
                <div className="bg-gradient-to-br from-green-500 to-green-600 p-6 text-white">
                  <div className="text-3xl mb-2">🌱</div>
                  <h3 className="text-2xl font-bold">Organic Cotton</h3>
                  <div className="text-sm text-green-100 mt-1">GOTS Certified</div>
                </div>
                <div className="p-6">
                  <p className="text-gray-600 mb-4">
                    Sustainably grown without synthetic pesticides or fertilizers. GOTS-certified 
                    for eco-conscious brands and premium positioning.
                  </p>
                  <div className="space-y-2 mb-4">
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Weight: 180gsm - 200gsm</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Feel: Premium soft & natural</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Best for: Eco-brands, premium</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Certification: GOTS included</span>
                    </div>
                  </div>
                  <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                    <span className="text-sm text-gray-500">Price Range</span>
                    <span className="text-xl font-bold text-green-600">$5.00 - $7.00</span>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl overflow-hidden shadow-lg hover:shadow-2xl transition-all">
                <div className="bg-gradient-to-br from-purple-500 to-purple-600 p-6 text-white">
                  <div className="text-3xl mb-2">✨</div>
                  <h3 className="text-2xl font-bold">Tri-Blend</h3>
                  <div className="text-sm text-purple-100 mt-1">Ultra Soft</div>
                </div>
                <div className="p-6">
                  <p className="text-gray-600 mb-4">
                    50% polyester, 25% cotton, 25% rayon blend. Ultra-soft vintage feel with 
                    excellent drape. Perfect for premium streetwear brands.
                  </p>
                  <div className="space-y-2 mb-4">
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Weight: 145gsm - 160gsm</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Feel: Luxurious & drapey</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Best for: Fashion, streetwear</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Wrinkle: Naturally resistant</span>
                    </div>
                  </div>
                  <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                    <span className="text-sm text-gray-500">Price Range</span>
                    <span className="text-xl font-bold text-purple-600">$6.00 - $8.00</span>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl overflow-hidden shadow-lg hover:shadow-2xl transition-all">
                <div className="bg-gradient-to-br from-gray-700 to-gray-800 p-6 text-white">
                  <div className="text-3xl mb-2">🎯</div>
                  <h3 className="text-2xl font-bold">Cotton-Poly Blend</h3>
                  <div className="text-sm text-gray-300 mt-1">Best Value</div>
                </div>
                <div className="p-6">
                  <p className="text-gray-600 mb-4">
                    50/50 or 60/40 cotton-polyester blend. More affordable than 100% cotton, 
                    wrinkle-resistant, faster drying. Great for corporate/promotional.
                  </p>
                  <div className="space-y-2 mb-4">
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Weight: 160gsm - 180gsm</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Feel: Durable & practical</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Best for: Corporate, workwear</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Maintenance: Easy care</span>
                    </div>
                  </div>
                  <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                    <span className="text-sm text-gray-500">Price Range</span>
                    <span className="text-xl font-bold text-gray-700">$3.50 - $4.50</span>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl overflow-hidden shadow-lg hover:shadow-2xl transition-all">
                <div className="bg-gradient-to-br from-indigo-500 to-indigo-600 p-6 text-white">
                  <div className="text-3xl mb-2">👑</div>
                  <h3 className="text-2xl font-bold">Pima/Supima Cotton</h3>
                  <div className="text-sm text-indigo-100 mt-1">Luxury Grade</div>
                </div>
                <div className="p-6">
                  <p className="text-gray-600 mb-4">
                    Long-staple premium cotton from Peru or USA. Exceptionally soft, durable, 
                    and luxurious. Perfect for high-end brands and premium positioning.
                  </p>
                  <div className="space-y-2 mb-4">
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Weight: 180gsm - 200gsm</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Feel: Silky & luxurious</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Best for: Luxury, designer</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Durability: 50% longer lasting</span>
                    </div>
                  </div>
                  <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                    <span className="text-sm text-gray-500">Price Range</span>
                    <span className="text-xl font-bold text-indigo-600">$7.00 - $9.00</span>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl overflow-hidden shadow-lg hover:shadow-2xl transition-all">
                <div className="bg-gradient-to-br from-orange-500 to-orange-600 p-6 text-white">
                  <div className="text-3xl mb-2">🏃</div>
                  <h3 className="text-2xl font-bold">Performance Fabric</h3>
                  <div className="text-sm text-orange-100 mt-1">Athletic</div>
                </div>
                <div className="p-6">
                  <p className="text-gray-600 mb-4">
                    Moisture-wicking polyester or poly-cotton blends. Quick-drying, breathable, 
                    anti-odor. Ideal for activewear and athletic brands.
                  </p>
                  <div className="space-y-2 mb-4">
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Weight: 140gsm - 160gsm</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Feel: Technical & lightweight</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Best for: Fitness, sports</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Features: Moisture-wicking</span>
                    </div>
                  </div>
                  <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                    <span className="text-sm text-gray-500">Price Range</span>
                    <span className="text-xl font-bold text-orange-600">$4.50 - $6.50</span>
                  </div>
                </div>
              </div>
            </div>

            <div className="mt-12 text-center max-w-3xl mx-auto">
              <div className="bg-blue-50 border-l-4 border-blue-600 p-6 rounded-lg">
                <p className="text-gray-700 mb-2">
                  <strong className="text-blue-900">💡 Not sure which fabric to choose?</strong> 
                  Our team will recommend the best option based on your brand positioning, target 
                  market, and budget. We can also send fabric swatches before you commit to production.
                </p>
              </div>
            </div>
          </div>
        </section>

        {/* Customization Methods */}
        <section className="py-16 md:py-24">
          <div className="container mx-auto px-4">
            <div className="max-w-3xl mx-auto text-center mb-16">
              <h2 className="text-3xl md:text-5xl font-bold mb-6 text-gray-900">
                Custom T-Shirt Printing & Decoration Methods
              </h2>
              <p className="text-xl text-gray-600">
                We match the right customization technique to your design complexity, quantity, 
                and budget requirements.
              </p>
            </div>

            <div className="grid md:grid-cols-2 gap-8 max-w-5xl mx-auto">
              <div className="bg-white p-8 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-200">
                <div className="flex items-center gap-4 mb-4">
                  <div className="text-4xl">🖨️</div>
                  <div>
                    <h3 className="text-2xl font-bold text-gray-900">Screen Printing</h3>
                    <div className="text-sm text-gray-500">Most Popular for Large Runs</div>
                  </div>
                </div>
                <p className="text-gray-600 mb-4">
                  Traditional plastisol or water-based inks applied through mesh screens. Best for 
                  simple designs with 1-8 colors. Extremely durable and cost-effective for quantities.
                </p>
                <div className="space-y-2 mb-4">
                  <div className="flex items-center text-sm text-gray-700">
                    <span className="text-green-600 mr-2">✓</span>
                    <span>Best for: 50+ pieces, simple designs</span>
                  </div>
                  <div className="flex items-center text-sm text-gray-700">
                    <span className="text-green-600 mr-2">✓</span>
                    <span>Colors: Up to 8 spot colors</span>
                  </div>
                  <div className="flex items-center text-sm text-gray-700">
                    <span className="text-green-600 mr-2">✓</span>
                    <span>Durability: Excellent (50+ washes)</span>
                  </div>
                  <div className="flex items-center text-sm text-gray-700">
                    <span className="text-green-600 mr-2">✓</span>
                    <span>Feel: Smooth or slight texture</span>
                  </div>
                </div>
                <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                  <span className="text-sm text-gray-500">Cost per Print</span>
                  <span className="text-xl font-bold text-green-600">$0.50 - $2.00</span>
                </div>
              </div>

              <div className="bg-white p-8 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-200">
                <div className="flex items-center gap-4 mb-4">
                  <div className="text-4xl">🎨</div>
                  <div>
                    <h3 className="text-2xl font-bold text-gray-900">Direct-to-Garment (DTG)</h3>
                    <div className="text-sm text-gray-500">Full-Color Digital Printing</div>
                  </div>
                </div>
                <p className="text-gray-600 mb-4">
                  Digital inkjet printing directly onto fabric. Perfect for complex designs, photographs, 
                  and full-color artwork. No color limits, ideal for small batches.
                </p>
                <div className="space-y-2 mb-4">
                  <div className="flex items-center text-sm text-gray-700">
                    <span className="text-green-600 mr-2">✓</span>
                    <span>Best for: 50-200 pieces, complex art</span>
                  </div>
                  <div className="flex items-center text-sm text-gray-700">
                    <span className="text-green-600 mr-2">✓</span>
                    <span>Colors: Unlimited full-color</span>
                  </div>
                  <div className="flex items-center text-sm text-gray-700">
                    <span className="text-green-600 mr-2">✓</span>
                    <span>Durability: Good (30-40 washes)</span>
                  </div>
                  <div className="flex items-center text-sm text-gray-700">
                    <span className="text-green-600 mr-2">✓</span>
                    <span>Feel: Soft, no texture</span>
                  </div>
                </div>
                <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                  <span className="text-sm text-gray-500">Cost per Print</span>
                  <span className="text-xl font-bold text-green-600">$2.50 - $5.00</span>
                </div>
              </div>

              <div className="bg-white p-8 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-200">
                <div className="flex items-center gap-4 mb-4">
                  <div className="text-4xl">🧵</div>
                  <div>
                    <h3 className="text-2xl font-bold text-gray-900">Embroidery</h3>
                    <div className="text-sm text-gray-500">Premium Thread Application</div>
                  </div>
                </div>
                <p className="text-gray-600 mb-4">
                  Thread-based logo or text stitched directly into fabric. Premium look and feel, 
                  extremely durable. Perfect for corporate, polos, and high-end branding.
                </p>
                <div className="space-y-2 mb-4">
                  <div className="flex items-center text-sm text-gray-700">
                    <span className="text-green-600 mr-2">✓</span>
                    <span>Best for: Logos, text, small designs</span>
                  </div>
                  <div className="flex items-center text-sm text-gray-700">
                    <span className="text-green-600 mr-2">✓</span>
                    <span>Colors: Up to 15 thread colors</span>
                  </div>
                  <div className="flex items-center text-sm text-gray-700">
                    <span className="text-green-600 mr-2">✓</span>
                    <span>Durability: Excellent (100+ washes)</span>
                  </div>
                  <div className="flex items-center text-sm text-gray-700">
                    <span className="text-green-600 mr-2">✓</span>
                    <span>Feel: Raised 3D texture</span>
                  </div>
                </div>
                <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                  <span className="text-sm text-gray-500">Cost per Location</span>
                  <span className="text-xl font-bold text-green-600">$3.00 - $6.00</span>
                </div>
              </div>

              <div className="bg-white p-8 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-200">
                <div className="flex items-center gap-4 mb-4">
                  <div className="text-4xl">🔥</div>
                  <div>
                    <h3 className="text-2xl font-bold text-gray-900">Heat Transfer</h3>
                    <div className="text-sm text-gray-500">Vinyl & Digital Transfers</div>
                  </div>
                </div>
                <p className="text-gray-600 mb-4">
                  Vinyl or printed transfers heat-pressed onto fabric. Great for names, numbers, 
                  and small-batch custom orders. Quick turnaround and flexible.
                </p>
                <div className="space-y-2 mb-4">
                  <div className="flex items-center text-sm text-gray-700">
                    <span className="text-green-600 mr-2">✓</span>
                    <span>Best for: Names, numbers, small runs</span>
                  </div>
                  <div className="flex items-center text-sm text-gray-700">
                    <span className="text-green-600 mr-2">✓</span>
                    <span>Colors: Vinyl (limited), Digital (full)</span>
                  </div>
                  <div className="flex items-center text-sm text-gray-700">
                    <span className="text-green-600 mr-2">✓</span>
                    <span>Durability: Moderate (20-30 washes)</span>
                  </div>
                  <div className="flex items-center text-sm text-gray-700">
                    <span className="text-green-600 mr-2">✓</span>
                    <span>Feel: Slight texture or smooth</span>
                  </div>
                </div>
                <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                  <span className="text-sm text-gray-500">Cost per Print</span>
                  <span className="text-xl font-bold text-green-600">$1.50 - $3.00</span>
                </div>
              </div>

              <div className="bg-white p-8 rounded-xl shadow-lg hover:shadow-2xl transition-all border-2 border-purple-500 col-span-2">
                <div className="flex items-center gap-4 mb-4">
                  <div className="text-4xl">🌈</div>
                  <div>
                    <h3 className="text-2xl font-bold text-gray-900">All-Over Printing</h3>
                    <div className="text-sm text-gray-500">Edge-to-Edge Custom Prints</div>
                  </div>
                </div>
                <div className="grid md:grid-cols-2 gap-6">
                  <div>
                    <p className="text-gray-600 mb-4">
                      Sublimation or specialty printing techniques that cover the entire garment 
                      surface. Perfect for bold artistic designs, patterns, and statement pieces.
                    </p>
                    <div className="space-y-2">
                      <div className="flex items-center text-sm text-gray-700">
                        <span className="text-green-600 mr-2">✓</span>
                        <span>Best for: Artistic brands, unique designs</span>
                      </div>
                      <div className="flex items-center text-sm text-gray-700">
                        <span className="text-green-600 mr-2">✓</span>
                        <span>Colors: Unlimited full-color</span>
                      </div>
                      <div className="flex items-center text-sm text-gray-700">
                        <span className="text-green-600 mr-2">✓</span>
                        <span>Durability: Excellent (permanent)</span>
                      </div>
                      <div className="flex items-center text-sm text-gray-700">
                        <span className="text-green-600 mr-2">✓</span>
                        <span>Feel: Soft, part of fabric</span>
                      </div>
                    </div>
                  </div>
                  <div>
                    <div className="bg-purple-50 border-l-4 border-purple-600 p-4 rounded">
                      <p className="text-sm text-gray-700 mb-2">
                        <strong className="text-purple-900">Note:</strong> All-over printing typically 
                        requires slightly higher MOQs (100-150 pieces) due to specialized setup.
                      </p>
                      <div className="flex items-center justify-between pt-3 border-t border-purple-200 mt-3">
                        <span className="text-sm text-gray-600">Cost per Piece</span>
                        <span className="text-lg font-bold text-purple-600">$6.00 - $10.00</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="mt-12 text-center max-w-4xl mx-auto">
              <div className="bg-green-50 border border-green-200 p-6 rounded-xl">
                <h4 className="font-bold text-lg text-gray-900 mb-3">Can't Decide? We Can Combine Methods!</h4>
                <p className="text-gray-700 mb-4">
                  Many successful brands use multiple decoration techniques on the same t-shirt for 
                  unique effects. For example: Screen-printed front design + embroidered sleeve logo, 
                  or DTG chest print + heat-transfer back name/number.
                </p>
                <Link 
                  href="/contact" 
                  className="inline-block bg-green-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-green-700 transition-colors"
                >
                  Discuss Your Custom Design
                </Link>
              </div>
            </div>
          </div>
        </section>

        {/* Comparison Table */}
        <section className="py-16 md:py-24 bg-gray-50">
          <div className="container mx-auto px-4">
            <div className="max-w-3xl mx-auto text-center mb-16">
              <h2 className="text-3xl md:text-5xl font-bold mb-6 text-gray-900">
                Sleek Apparels vs. Other Bangladesh T-Shirt Manufacturers
              </h2>
              <p className="text-xl text-gray-600">
                See why hundreds of brands choose us for custom t-shirt manufacturing.
              </p>
            </div>

            <div className="max-w-5xl mx-auto overflow-x-auto">
              <table className="w-full bg-white shadow-xl rounded-xl overflow-hidden">
                <thead>
                  <tr className="bg-gradient-to-r from-green-600 to-teal-600 text-white">
                    <th className="px-6 py-4 text-left font-bold">Feature</th>
                    <th className="px-6 py-4 text-center font-bold">Sleek Apparels</th>
                    <th className="px-6 py-4 text-center font-bold">Typical Manufacturers</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Minimum Order Quantity</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold text-lg">50 pieces</span>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold text-lg">500-1,000 pieces</span>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Fabric Options</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold">6+ Options</span>
                      <div className="text-sm text-gray-500">Cotton, Organic, Tri-Blend, etc.</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold">2-3 Options</span>
                      <div className="text-sm text-gray-500">Limited selection</div>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Printing Methods</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold">5 Methods</span>
                      <div className="text-sm text-gray-500">Screen, DTG, Embroidery, etc.</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold">1-2 Methods</span>
                      <div className="text-sm text-gray-500">Usually just screen print</div>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">OEKO-TEX Certification</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold">✓ Included FREE</span>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold">✗ Not Available</span>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Custom Labels & Tags</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold">✓ Turnkey Service</span>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold">✗ Your Responsibility</span>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Production Timeline</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold">6-8 weeks</span>
                      <div className="text-sm text-gray-500">Rush: 4-5 weeks</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold">10-14 weeks</span>
                      <div className="text-sm text-gray-500">No rush option</div>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Communication</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold">Direct 12-24h</span>
                      <div className="text-sm text-gray-500">WhatsApp/Email</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold">3-7 days</span>
                      <div className="text-sm text-gray-500">Through agents</div>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Quality Control</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold">6-Point Inspection</span>
                      <div className="text-sm text-gray-500">&lt;0.5% defect rate</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold">Basic Inspection</span>
                      <div className="text-sm text-gray-500">2-4% defect rate</div>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50 bg-green-50">
                    <td className="px-6 py-4 font-bold text-gray-900">Unit Price Range</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold text-xl">$3.50 - $9.00</span>
                      <div className="text-sm text-gray-600">Competitive with quality</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold text-xl">$3.00 - $8.00</span>
                      <div className="text-sm text-gray-600">But limited options</div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div className="mt-12 text-center">
              <Link 
                href="/quote" 
                className="inline-block bg-green-600 text-white px-8 py-4 rounded-lg font-bold text-lg hover:bg-green-700 transition-colors shadow-lg"
              >
                Get Your T-Shirt Quote Now
              </Link>
            </div>
          </div>
        </section>

        {/* T-Shirt Styles & Fits */}
        <section className="py-16 md:py-24">
          <div className="container mx-auto px-4">
            <div className="max-w-3xl mx-auto text-center mb-16">
              <h2 className="text-3xl md:text-5xl font-bold mb-6 text-gray-900">
                Custom T-Shirt Styles & Fits We Manufacture
              </h2>
              <p className="text-xl text-gray-600">
                From classic crew necks to trendy oversized styles, we manufacture every t-shirt 
                style your brand needs.
              </p>
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 max-w-7xl mx-auto">
              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-3xl mb-3 text-center">👕</div>
                <h3 className="text-xl font-bold mb-2 text-gray-900 text-center">Crew Neck</h3>
                <p className="text-gray-600 text-sm text-center mb-3">
                  Classic round neckline. The most versatile and popular t-shirt style for all brands.
                </p>
                <div className="text-center text-sm text-green-600 font-semibold">
                  50-piece MOQ
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-3xl mb-3 text-center">🔻</div>
                <h3 className="text-xl font-bold mb-2 text-gray-900 text-center">V-Neck</h3>
                <p className="text-gray-600 text-sm text-center mb-3">
                  V-shaped neckline. Popular for fashion-forward and women's styles. Flattering fit.
                </p>
                <div className="text-center text-sm text-green-600 font-semibold">
                  50-piece MOQ
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-3xl mb-3 text-center">🎽</div>
                <h3 className="text-xl font-bold mb-2 text-gray-900 text-center">Scoop Neck</h3>
                <p className="text-gray-600 text-sm text-center mb-3">
                  Wider, deeper neckline. Feminine and casual. Great for women's basics and layering.
                </p>
                <div className="text-center text-sm text-green-600 font-semibold">
                  50-piece MOQ
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-3xl mb-3 text-center">📏</div>
                <h3 className="text-xl font-bold mb-2 text-gray-900 text-center">Longline</h3>
                <p className="text-gray-600 text-sm text-center mb-3">
                  Extended length past hips. Modern urban/streetwear aesthetic. Popular with Gen Z.
                </p>
                <div className="text-center text-sm text-green-600 font-semibold">
                  50-piece MOQ
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-3xl mb-3 text-center">📦</div>
                <h3 className="text-xl font-bold mb-2 text-gray-900 text-center">Oversized/Boxy</h3>
                <p className="text-gray-600 text-sm text-center mb-3">
                  Dropped shoulders, wider body. Trending streetwear and comfort-focused brands.
                </p>
                <div className="text-center text-sm text-green-600 font-semibold">
                  50-piece MOQ
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-3xl mb-3 text-center">✂️</div>
                <h3 className="text-xl font-bold mb-2 text-gray-900 text-center">Cropped</h3>
                <p className="text-gray-600 text-sm text-center mb-3">
                  Shortened length hitting at waist. Trending in women's fashion and festival wear.
                </p>
                <div className="text-center text-sm text-green-600 font-semibold">
                  50-piece MOQ
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-3xl mb-3 text-center">👔</div>
                <h3 className="text-xl font-bold mb-2 text-gray-900 text-center">Henley</h3>
                <p className="text-gray-600 text-sm text-center mb-3">
                  Collarless with button placket. Casual-smart aesthetic. Popular for menswear brands.
                </p>
                <div className="text-center text-sm text-green-600 font-semibold">
                  50-piece MOQ
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-3xl mb-3 text-center">🎯</div>
                <h3 className="text-xl font-bold mb-2 text-gray-900 text-center">Pocket Tee</h3>
                <p className="text-gray-600 text-sm text-center mb-3">
                  Chest pocket detail. Classic American workwear aesthetic. Versatile branding spot.
                </p>
                <div className="text-center text-sm text-green-600 font-semibold">
                  50-piece MOQ
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* FAQs */}
        <section className="py-16 md:py-24 bg-gray-50">
          <div className="container mx-auto px-4">
            <div className="max-w-3xl mx-auto text-center mb-16">
              <h2 className="text-3xl md:text-5xl font-bold mb-6 text-gray-900">
                Frequently Asked Questions About Custom T-Shirt Manufacturing
              </h2>
              <p className="text-xl text-gray-600">
                Everything you need to know about ordering custom t-shirts from Bangladesh.
              </p>
            </div>

            <div className="max-w-4xl mx-auto space-y-6">
              {faqs.map((faq, index) => (
                <details 
                  key={index}
                  className="group bg-white rounded-xl shadow-lg overflow-hidden border border-gray-200 hover:border-green-600 transition-all"
                >
                  <summary className="flex justify-between items-center cursor-pointer p-6 font-semibold text-lg text-gray-900 hover:text-green-600 transition-colors">
                    <span className="pr-8">{faq.question}</span>
                    <span className="flex-shrink-0 text-green-600 group-open:rotate-180 transition-transform">
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

            <div className="mt-12 text-center">
              <p className="text-gray-600 mb-4">More questions about custom t-shirt manufacturing?</p>
              <Link 
                href="/contact" 
                className="inline-block bg-green-600 text-white px-8 py-3 rounded-lg font-semibold hover:bg-green-700 transition-colors"
              >
                Contact Our T-Shirt Specialists
              </Link>
            </div>
          </div>
        </section>

        {/* Final CTA */}
        <section className="py-16 md:py-24 bg-gradient-to-br from-green-600 via-teal-600 to-blue-700 text-white">
          <div className="container mx-auto px-4">
            <div className="max-w-4xl mx-auto text-center">
              <h2 className="text-4xl md:text-6xl font-bold mb-6">
                Start Your Custom T-Shirt Order Today
              </h2>
              <p className="text-xl md:text-2xl mb-4 text-green-100 leading-relaxed">
                Premium quality • 50-piece MOQ • OEKO-TEX certified fabrics • 6-8 week turnaround
              </p>
              <p className="text-lg mb-8 text-green-200">
                Screen print, DTG, embroidery available • Custom labels & packaging • Free design support
              </p>
              
              <div className="flex flex-col sm:flex-row gap-4 justify-center mb-8">
                <Link 
                  href="/quote" 
                  className="inline-block bg-white text-green-700 px-10 py-5 rounded-lg font-bold text-xl hover:bg-green-50 transition-all shadow-2xl hover:shadow-3xl hover:scale-105"
                >
                  Get T-Shirt Quote
                </Link>
                <Link 
                  href="/contact" 
                  className="inline-block bg-green-800/50 backdrop-blur-sm border-2 border-white text-white px-10 py-5 rounded-lg font-bold text-xl hover:bg-green-700/50 transition-all"
                >
                  Schedule Consultation
                </Link>
              </div>

              <div className="grid md:grid-cols-4 gap-6 text-center">
                <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4">
                  <div className="text-2xl font-bold mb-1">50 Pieces</div>
                  <div className="text-green-200 text-sm">Minimum Order</div>
                </div>
                <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4">
                  <div className="text-2xl font-bold mb-1">6+ Fabrics</div>
                  <div className="text-green-200 text-sm">Cotton to Premium</div>
                </div>
                <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4">
                  <div className="text-2xl font-bold mb-1">5 Methods</div>
                  <div className="text-green-200 text-sm">Print & Embroidery</div>
                </div>
                <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4">
                  <div className="text-2xl font-bold mb-1">6-8 Weeks</div>
                  <div className="text-green-200 text-sm">Production Time</div>
                </div>
              </div>

              <p className="mt-8 text-sm text-green-200">
                ✓ OEKO-TEX Certified • ✓ WRAP Ethical Manufacturing • ✓ 6-Point Quality Control • ✓ 0.5% Defect Rate
              </p>
            </div>
          </div>
        </section>
      </main>
    </>
  );
}
