import { SEO, organizationSchema, productSchema, faqSchema, breadcrumbSchema } from '@/components/SEO';
import { Navbar } from '@/components/Navbar';
import { Footer } from '@/components/Footer';
import { Button } from '@/components/ui/button';
import { Check, Package, DollarSign, Truck, BarChart, Shield, Zap, Box, Tag, FileCheck } from 'lucide-react';
import { Link } from 'react-router-dom';
import { CertificationBadges } from '@/components/CertificationBadges';

export default function AmazonFBASupplier() {
  const faqs = [
    {
      question: "What's your minimum order quantity for Amazon FBA sellers?",
      answer: "Our MOQ is just 50 pieces per design per color - one of the lowest for Amazon FBA-focused manufacturers. This lets you test products without tying up $10K+ in inventory. For reorders, we offer 30-piece minimums for proven bestsellers."
    },
    {
      question: "Do you handle Amazon FBA prep and labeling?",
      answer: "Yes! We're FBA experts. We provide poly bagging (per Amazon SOP), FNSKU barcode labeling (scannable at 100%), carton labeling with shipment IDs, product inspection reports, and compliance with Amazon packaging requirements. FBA prep costs $0.50-$1.00 per unit - cheaper than USA prep centers."
    },
    {
      question: "Can you ship directly to multiple Amazon FBA warehouses?",
      answer: "Absolutely! We ship to all Amazon fulfillment centers: PHX6, PHX7, ONT8, OAK4, RNO4 (West), DFW6, HOU7, IND2 (Central), EWR9, MDT1, ABE2, PHL7 (East). We handle split shipments and provide separate tracking for each warehouse location at no extra cost."
    },
    {
      question: "How much does a typical Amazon FBA inventory order cost?",
      answer: "Example: 200 t-shirts at $4.50/pc = $900, FBA prep $100, Air shipping $400, Labels/tags $100 = $1,500 total ($7.50 landed cost). Sell at $25-30/unit = $5,000-6,000 revenue. Net profit after Amazon fees (15%) = $2,750-3,600 per batch. Great ROI for FBA sellers!"
    },
    {
      question: "What's the production and shipping timeline for FBA orders?",
      answer: "Production: 15-20 days for 50-500 units. Air freight: 7-10 days to Amazon warehouses (best for FBA). Sea freight: 20-25 days (for larger reorders 1,000+ units). Total time: 22-30 days from order to Amazon receiving. We prioritize FBA orders for fast turnaround."
    },
    {
      question: "Do you provide product photos and listing content for Amazon?",
      answer: "Yes! We offer professional product photography on white background (Amazon-compliant), lifestyle shots with models, 360-degree spin images, infographic design for A+ Content, and bullet point/description copywriting assistance. Photography package: $150-300 per product line."
    },
    {
      question: "What certifications do I need for selling on Amazon USA?",
      answer: "We provide all required documentation: OEKO-TEX Standard 100 (textile safety for Amazon registry), CPSC compliance (Consumer Product Safety), Test reports for flammability (16 CFR 1610), Prop 65 compliance (California), and Country of Origin labels. Your products will pass Amazon's compliance checks."
    },
    {
      question: "Can you manufacture private label products with my Amazon brand?",
      answer: "Absolutely! We specialize in Amazon private label. We'll add your brand name, logo, woven/printed labels, custom hang tags, poly bags with branding, UPC barcodes, and Amazon-compliant packaging. Complete white-label service ready for FBA."
    },
    {
      question: "Do you offer packaging that stands out for Amazon unboxing?",
      answer: "Yes! We create premium packaging: Custom printed mailers ($0.50-1.00/pc), Branded tissue paper ($0.20/pc), Thank-you cards ($0.15/pc), Stickers/inserts ($0.10/pc), Custom boxes for gift-ready presentation ($1.50-3.00/pc). Great for review generation and brand building."
    },
    {
      question: "What's the best product category for Amazon FBA beginners?",
      answer: "Based on 100+ FBA clients: T-shirts (lowest entry cost, fast-moving), Hoodies (higher perceived value, $30-50 retail), Activewear leggings (high demand, recurring buyers), Blank apparel for niche markets (gym, yoga, outdoor), Baby/toddler clothing (impulse purchases, gift market). We'll recommend based on your budget."
    }
  ];

  const schemas = [
    organizationSchema,
    productSchema({
      name: "Amazon FBA Apparel Supplier from Bangladesh",
      description: "Amazon FBA-ready clothing supplier in Bangladesh. 50-piece MOQ, FBA prep, labeling, direct shipping to fulfillment centers. OEKO-TEX certified. Perfect for Amazon private label sellers.",
      minPrice: "4.50",
      maxPrice: "18.00"
    }),
    faqSchema(faqs),
    breadcrumbSchema([
      { name: "Home", url: "https://sleekapparels.com" },
      { name: "Amazon FBA Apparel Supplier", url: "https://sleekapparels.com/amazon-fba-apparel-supplier-bangladesh" }
    ])
  ];

  return (
    <>
      <SEO
        title="Amazon FBA Apparel Supplier Bangladesh | Private Label | FBA Prep"
        description="Amazon FBA clothing supplier in Bangladesh with 50-piece MOQ. FBA prep, FNSKU labeling, direct shipping to fulfillment centers. OEKO-TEX certified. Perfect for Amazon private label sellers."
        canonical="https://sleekapparels.com/amazon-fba-apparel-supplier-bangladesh"
        keywords="Amazon FBA apparel supplier, Amazon FBA clothing manufacturer, private label Amazon FBA, Bangladesh FBA supplier, FBA prep service, Amazon private label clothing"
        schema={schemas}
        ogImage="https://sleekapparels.com/images/amazon-fba-ready.jpg"
      />

      <div className="min-h-screen bg-white">
        <Navbar />
        
        {/* Hero Section */}
        <section className="bg-gradient-to-br from-primary to-secondary text-white py-20">
          <div className="container mx-auto px-4">
            <div className="max-w-4xl">
              <nav className="text-sm mb-4 opacity-90">
                <Link to="/" className="hover:underline">Home</Link>
                <span className="mx-2">/</span>
                <span>Amazon FBA Apparel Supplier</span>
              </nav>
              
              <h1 className="text-4xl md:text-5xl font-bold mb-6 leading-tight">
                Amazon FBA Apparel Supplier Bangladesh: Launch Your Private Label Brand with 50 Pieces
              </h1>
              
              <p className="text-xl mb-8 opacity-95 leading-relaxed">
                <strong>The only Bangladesh supplier built for Amazon FBA sellers.</strong> 50-piece MOQ, FBA prep & labeling, 
                direct shipping to fulfillment centers, Amazon-compliant packaging. OEKO-TEX certified. Start your FBA brand for $1,500-2,500.
              </p>
              
              <div className="flex flex-wrap gap-4 mb-8">
                <div className="flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-2 rounded-lg">
                  <Package className="h-5 w-5" />
                  <span className="font-semibold">MOQ: 50 Pieces</span>
                </div>
                <div className="flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-2 rounded-lg">
                  <Tag className="h-5 w-5" />
                  <span className="font-semibold">FBA Prep Included</span>
                </div>
                <div className="flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-2 rounded-lg">
                  <Truck className="h-5 w-5" />
                  <span className="font-semibold">Direct to FBA Warehouses</span>
                </div>
              </div>
              
              <div className="flex flex-wrap gap-4">
                <Button size="lg" variant="secondary" asChild>
                  <Link to="/contact">Start Your FBA Brand</Link>
                </Button>
                <Button size="lg" variant="outline" className="bg-white/10 border-white text-white hover:bg-white/20" asChild>
                  <Link to="/samples">Get FBA Sample Pack</Link>
                </Button>
              </div>
            </div>
          </div>
        </section>

        {/* FBA Benefits */}
        <section className="py-16 bg-gray-50">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">Why Amazon FBA Sellers Choose Sleek Apparels</h2>
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 max-w-6xl mx-auto">
              {[
                { icon: Package, title: "True Low MOQ (50 pcs)", desc: "Test products without $10K inventory. Perfect for validating demand before scaling." },
                { icon: Tag, title: "Complete FBA Prep", desc: "Poly bagging, FNSKU labeling, carton prep - Amazon-compliant at $0.50-1.00/unit." },
                { icon: Truck, title: "Direct FBA Shipping", desc: "We ship directly to all Amazon fulfillment centers. Split shipments handled seamlessly." },
                { icon: Shield, title: "Amazon-Compliant Certs", desc: "OEKO-TEX, CPSC, Prop 65 - all required documentation for Amazon registry." },
                { icon: DollarSign, title: "Maximize Profit Margins", desc: "Save 25-40% vs USA suppliers. Higher margins = more aggressive PPC bidding power." },
                { icon: BarChart, title: "Proven FBA Success", desc: "We've helped 200+ FBA sellers launch and scale. We understand Amazon's requirements inside-out." }
              ].map((benefit, i) => (
                <div key={i} className="bg-white p-6 rounded-xl shadow-sm hover:shadow-md transition">
                  <benefit.icon className="h-10 w-10 text-primary mb-4" />
                  <h3 className="font-bold text-lg mb-2">{benefit.title}</h3>
                  <p className="text-gray-600 text-sm leading-relaxed">{benefit.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* FBA Launch Cost Calculator */}
        <section className="py-16">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-4">Launch Your Amazon FBA Apparel Brand</h2>
            <p className="text-center text-gray-600 mb-12 max-w-2xl mx-auto">
              Real budget breakdown for launching an FBA private label clothing brand
            </p>
            <div className="max-w-4xl mx-auto grid md:grid-cols-2 gap-8">
              {/* Starter FBA Launch */}
              <div className="border-2 border-gray-200 rounded-xl p-8 hover:border-primary transition">
                <h3 className="text-2xl font-bold mb-2">FBA Starter Launch</h3>
                <p className="text-3xl font-bold text-primary mb-6">$1,800</p>
                <div className="space-y-3">
                  <div className="flex justify-between pb-2 border-b">
                    <span>100 T-Shirts ($4.50/pc)</span>
                    <span className="font-semibold">$450</span>
                  </div>
                  <div className="flex justify-between pb-2 border-b">
                    <span>50 Hoodies ($15/pc)</span>
                    <span className="font-semibold">$750</span>
                  </div>
                  <div className="flex justify-between pb-2 border-b">
                    <span>FBA Prep (150 units x $0.75)</span>
                    <span className="font-semibold">$112</span>
                  </div>
                  <div className="flex justify-between pb-2 border-b">
                    <span>Air Shipping DDP</span>
                    <span className="font-semibold">$350</span>
                  </div>
                  <div className="flex justify-between pb-2 border-b">
                    <span>Private Label (labels/tags)</span>
                    <span className="font-semibold">$138</span>
                  </div>
                </div>
                <div className="bg-green-50 p-4 rounded-lg mt-6">
                  <p className="font-bold text-green-800 mb-2">Profit Potential:</p>
                  <p className="text-sm text-green-700">Sell 150 units at $28 avg = $4,200 revenue</p>
                  <p className="text-sm text-green-700">After Amazon fees (15%) = $3,570</p>
                  <p className="text-sm text-green-700">Net Profit: <strong>$1,770 (98% ROI)</strong></p>
                </div>
              </div>

              {/* Scale FBA Launch */}
              <div className="border-2 border-primary rounded-xl p-8 bg-primary/5">
                <h3 className="text-2xl font-bold mb-2">FBA Scale Launch</h3>
                <p className="text-3xl font-bold text-primary mb-6">$3,500</p>
                <div className="space-y-3">
                  <div className="flex justify-between pb-2 border-b">
                    <span>200 T-Shirts ($4.00/pc)</span>
                    <span className="font-semibold">$800</span>
                  </div>
                  <div className="flex justify-between pb-2 border-b">
                    <span>100 Hoodies ($14/pc)</span>
                    <span className="font-semibold">$1,400</span>
                  </div>
                  <div className="flex justify-between pb-2 border-b">
                    <span>100 Sweatpants ($12/pc)</span>
                    <span className="font-semibold">$1,200</span>
                  </div>
                  <div className="flex justify-between pb-2 border-b">
                    <span>FBA Prep (400 units x $0.70)</span>
                    <span className="font-semibold">$280</span>
                  </div>
                  <div className="flex justify-between pb-2 border-b">
                    <span>Premium packaging</span>
                    <span className="font-semibold">$320</span>
                  </div>
                  <div className="flex justify-between pb-2 border-b">
                    <span>Air Shipping DDP</span>
                    <span className="font-semibold">$500</span>
                  </div>
                </div>
                <div className="bg-green-50 p-4 rounded-lg mt-6">
                  <p className="font-bold text-green-800 mb-2">Profit Potential:</p>
                  <p className="text-sm text-green-700">Sell 400 units at $32 avg = $12,800 revenue</p>
                  <p className="text-sm text-green-700">After Amazon fees (15%) = $10,880</p>
                  <p className="text-sm text-green-700">Net Profit: <strong>$7,380 (210% ROI)</strong></p>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* FBA Prep Services */}
        <section className="py-16 bg-gray-50">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">Complete Amazon FBA Prep Services</h2>
            <div className="max-w-5xl mx-auto">
              <div className="grid md:grid-cols-2 gap-6">
                {[
                  {
                    title: "FBA-Compliant Packaging",
                    items: [
                      "Poly bagging per Amazon SOP (suffocation warnings, 1.5 mil thickness)",
                      "Product barcodes scannable at 100%",
                      "Carton labeling with shipment ID",
                      "Weight/dimension compliance",
                      "Fragile/handling labels if needed"
                    ]
                  },
                  {
                    title: "FNSKU Labeling",
                    items: [
                      "FNSKU barcode generation & printing",
                      "Correct placement per product type",
                      "Scannable at Amazon receiving",
                      "Label size compliance (1\"x2\" minimum)",
                      "Cover existing barcodes properly"
                    ]
                  },
                  {
                    title: "Amazon Documentation",
                    items: [
                      "Commercial invoice with accurate HS codes",
                      "Packing list by SKU",
                      "BOL for each shipment",
                      "Compliance certificates (OEKO-TEX, CPSC)",
                      "Country of Origin documents"
                    ]
                  },
                  {
                    title: "Quality Control",
                    items: [
                      "100% inspection before FBA prep",
                      "Defect rate <0.5% (Amazon standard)",
                      "Size/color verification",
                      "Packaging integrity check",
                      "Photo reports for each batch"
                    ]
                  }
                ].map((service, i) => (
                  <div key={i} className="bg-white p-6 rounded-xl shadow-sm">
                    <h3 className="font-bold text-xl mb-4 text-primary">{service.title}</h3>
                    <ul className="space-y-2">
                      {service.items.map((item, j) => (
                        <li key={j} className="flex items-start gap-2">
                          <Check className="h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
                          <span className="text-sm">{item}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* Best Products for FBA */}
        <section className="py-16">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">Best-Selling Products for Amazon FBA</h2>
            <div className="grid md:grid-cols-3 gap-6 max-w-6xl mx-auto">
              {[
                {
                  product: "Basic T-Shirts",
                  why: "Fast-moving, low entry cost",
                  moq: "50 pcs",
                  cost: "$4.50/pc",
                  retail: "$19.99-24.99",
                  margin: "60-70%",
                  competition: "High but consistent sales"
                },
                {
                  product: "Premium Hoodies",
                  why: "High perceived value",
                  moq: "50 pcs",
                  cost: "$14.00/pc",
                  retail: "$39.99-49.99",
                  margin: "55-65%",
                  competition: "Medium, seasonal spikes"
                },
                {
                  product: "Activewear Leggings",
                  why: "Recurring customers, reviews",
                  moq: "50 pcs",
                  cost: "$9.00/pc",
                  retail: "$28.99-34.99",
                  margin: "60-70%",
                  competition: "High but differentiation possible"
                },
                {
                  product: "Sweatpants/Joggers",
                  why: "Complements hoodies",
                  moq: "50 pcs",
                  cost: "$12.00/pc",
                  retail: "$32.99-39.99",
                  margin: "55-65%",
                  competition: "Medium, growing demand"
                },
                {
                  product: "Baby/Toddler Sets",
                  why: "Gift market, impulse buys",
                  moq: "50 pcs",
                  cost: "$6.50/pc",
                  retail: "$24.99-29.99",
                  margin: "65-75%",
                  competition: "Low-medium, high reviews"
                },
                {
                  product: "Blank Apparel (Niche)",
                  why: "Wholesale + retail hybrid",
                  moq: "50 pcs",
                  cost: "$3.50/pc",
                  retail: "$16.99-21.99",
                  margin: "70-80%",
                  competition: "Low, niche targeting"
                }
              ].map((item, i) => (
                <div key={i} className="border-2 border-gray-200 rounded-xl p-6 hover:border-primary transition">
                  <h3 className="text-xl font-bold mb-2 text-primary">{item.product}</h3>
                  <p className="text-sm text-gray-600 mb-4"><strong>Why:</strong> {item.why}</p>
                  <div className="space-y-2 text-sm mb-4">
                    <div className="flex justify-between">
                      <span>MOQ:</span>
                      <span className="font-semibold">{item.moq}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Landed Cost:</span>
                      <span className="font-semibold">{item.cost}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Retail Price:</span>
                      <span className="font-semibold text-primary">{item.retail}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Gross Margin:</span>
                      <span className="font-semibold text-green-600">{item.margin}</span>
                    </div>
                  </div>
                  <p className="text-xs text-gray-500"><strong>Competition:</strong> {item.competition}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* FBA Timeline */}
        <section className="py-16 bg-gray-50">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">Amazon FBA Launch Timeline</h2>
            <div className="max-w-3xl mx-auto">
              <div className="space-y-4">
                {[
                  { step: "1", title: "Product Research & Selection (1-2 days)", desc: "Choose winning products using Jungle Scout, Helium 10. We'll recommend based on MOQs and margins." },
                  { step: "2", title: "Sample Order & Testing (7-10 days)", desc: "Order 1-3 samples ($30-75). Test quality, sizing, Amazon listing photos. Make revisions if needed." },
                  { step: "3", title: "Amazon Seller Account Setup (1-2 days)", desc: "Register for Professional Seller account ($39.99/mo). Set up FBA, get FNSKU barcodes ready." },
                  { step: "4", title: "Place Bulk Order (15-20 days production)", desc: "Order 50-200 units with FBA prep. Pay 50% deposit. We handle manufacturing with daily updates." },
                  { step: "5", title: "Shipping to Amazon (7-10 days air)", desc: "We ship directly to FBA warehouses with proper labeling and documentation. Track each shipment." },
                  { step: "6", title: "Create Amazon Listing (2-3 days)", desc: "While shipping, create optimized listing: photos, A+ content, keywords, PPC campaigns." },
                  { step: "7", title: "Launch & Monitor (ongoing)", desc: "Amazon receives inventory. Launch PPC at $20-50/day. Monitor reviews, rankings, reorder at 30% stock." }
                ].map((timeline, i) => (
                  <div key={i} className="flex gap-4 bg-white p-6 rounded-lg shadow-sm">
                    <div className="flex-shrink-0 w-10 h-10 bg-primary text-white rounded-full flex items-center justify-center font-bold">
                      {timeline.step}
                    </div>
                    <div>
                      <h3 className="font-bold text-lg mb-2">{timeline.title}</h3>
                      <p className="text-gray-600 text-sm">{timeline.desc}</p>
                    </div>
                  </div>
                ))}
              </div>
              <div className="mt-8 bg-primary/5 p-6 rounded-lg text-center">
                <p className="font-bold text-xl text-primary">Total Time to Live on Amazon: 32-45 Days</p>
                <p className="text-sm text-gray-600 mt-2">From initial order to first sale on Amazon FBA</p>
              </div>
            </div>
          </div>
        </section>

        {/* CTA */}
        <section className="py-16 bg-gradient-to-br from-primary to-secondary text-white">
          <div className="container mx-auto px-4 text-center">
            <h2 className="text-3xl md:text-4xl font-bold mb-6">Ready to Launch Your Amazon FBA Apparel Brand?</h2>
            <p className="text-xl mb-8 opacity-95 max-w-2xl mx-auto">
              Join 200+ successful Amazon FBA sellers who source from us. Get FBA-ready samples and complete launch guide.
            </p>
            <div className="flex flex-wrap gap-4 justify-center">
              <Button size="lg" variant="secondary" asChild>
                <Link to="/contact">Get FBA Starter Package</Link>
              </Button>
              <Button size="lg" variant="outline" className="bg-white/10 border-white text-white hover:bg-white/20" asChild>
                <Link to="/samples">Order FBA Sample Pack</Link>
              </Button>
            </div>
          </div>
        </section>

        {/* FAQs */}
        <section className="py-16">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">Amazon FBA Seller FAQs</h2>
            <div className="max-w-3xl mx-auto space-y-6">
              {faqs.map((faq, i) => (
                <div key={i} className="border border-gray-200 rounded-lg p-6 hover:shadow-md transition">
                  <h3 className="font-bold text-lg mb-3">{faq.question}</h3>
                  <p className="text-gray-600 leading-relaxed">{faq.answer}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section className="py-16 bg-gray-50">
          <div className="container mx-auto px-4">
            <CertificationBadges />
          </div>
        </section>

        <Footer />
      </div>
    </>
  );
}
