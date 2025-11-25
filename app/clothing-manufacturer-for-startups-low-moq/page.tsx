import { Metadata } from 'next';
import Link from 'next/link';
import JsonLd from '@/components/JsonLd';
import { generateMetadata } from '@/lib/metadata';
import { generateBreadcrumbSchema, generateProductSchema, generateFAQSchema, generateOrganizationSchema, defaultOrganization } from '@/lib/schema';

export const metadata: Metadata = generateMetadata({
  title: 'Clothing Manufacturer for Startups Low MOQ | 50 Pieces Minimum | Sleek Apparels',
  description: 'Launch your clothing brand with startup-friendly 50-piece MOQ. Trusted Bangladesh manufacturer offering design support, sampling, and no hidden fees. Perfect for first-time founders.',
  keywords: [
    'clothing manufacturer for startups low moq',
    'startup clothing manufacturer',
    'low moq apparel manufacturer for new brands',
    'clothing manufacturer for small business',
    'startup friendly clothing factory',
    'new brand clothing manufacturer',
    'first order clothing manufacturer',
    'beginner friendly apparel manufacturer',
    'clothing manufacturer for entrepreneurs',
    'startup apparel production Bangladesh',
    'low moq Bangladesh manufacturer',
    '50 piece minimum clothing manufacturer',
  ],
  canonical: 'https://sleekapparels.com/clothing-manufacturer-for-startups-low-moq',
});

interface FAQItem {
  question: string;
  answer: string;
}

export default function StartupManufacturerPage() {
  const faqs: FAQItem[] = [
    {
      question: "What makes Sleek Apparels startup-friendly compared to other manufacturers?",
      answer: "We understand the challenges first-time founders face. Our 50-piece minimum order quantity is 10-20x lower than traditional manufacturers (500-1,000 pieces), meaning you can test your designs with $850-$900 instead of $8,500-$17,000. We offer free technical sketches, transparent pricing with no hidden fees, flexible payment terms (30% deposit instead of 50%), and dedicated startup support including design consultation, fabric recommendations, and sampling. Our team has helped over 300 startups launch successfully since 2015, and we speak your language—literally and figuratively."
    },
    {
      question: "How much capital do I need to start a clothing brand with Sleek Apparels?",
      answer: "You can realistically launch with $3,000-$5,000 total capital: $850-$900 for your first production run (50 pieces), $150-$250 for sampling (2-3 samples), $500-$800 for branding materials (labels, tags, packaging), $300-$500 for photography and content creation, $500-$1,000 for initial marketing (social media ads, influencer seeding), and $700-$1,550 buffer for unexpected costs. This is 60-75% less than traditional manufacturers requiring $10,000-$15,000 minimum. Many successful startup founders begin with just one product (t-shirts or hoodies) to minimize risk, then expand their line with profits from initial sales."
    },
    {
      question: "Can you help with design if I only have rough sketches or ideas?",
      answer: "Absolutely—this is where we excel with startup clients. Our in-house design team can transform your rough sketches, Pinterest inspiration boards, or even verbal descriptions into production-ready technical packs. We provide: Free design consultation (30-45 minute video call to understand your vision), complimentary technical sketches showing front, back, and detail views, fabric and trim recommendations based on your target price point and brand aesthetic, size grading consultation to ensure proper fit across all sizes, and color matching assistance using Pantone standards. We've worked with founders who started with Instagram screenshots and ended with retail-quality products. Our goal is to make the technical aspects easy so you can focus on building your brand."
    },
    {
      question: "What's the complete timeline from order to receiving my first inventory?",
      answer: "For startups, the typical timeline is 8-10 weeks total: Week 1: Design finalization and technical pack creation (free), Week 2: Sample development and shipping to you (air shipping 5-7 days), Week 3: Sample approval and any revisions needed, Week 4: Production deposit (30%) and cutting begins, Weeks 5-7: Sewing, quality control, finishing, Week 8: Final inspection and packing, Weeks 9-10: International shipping to your location. Rush production is available for an additional 15% fee, reducing total time to 5-6 weeks. We send photo updates every 3-4 days during production so you're never wondering about progress. Many startups use the 8-10 week production time to build their website, create content, and start building hype on social media."
    },
    {
      question: "Do you offer dropshipping or can I order as my brand grows?",
      answer: "We don't offer traditional dropshipping (single-piece fulfillment), but we do offer highly flexible reorder terms perfect for growing startups. After your initial 50-piece order, you can reorder in increments of just 30 pieces per style/color, giving you flexibility to test new designs or restock bestsellers without overcommitting inventory. We can hold your production specs and approved samples for 18 months, ensuring consistency across reorders. We offer warehousing services at our facility ($50/month for up to 500 pieces) so you can order larger quantities at better pricing and fulfill orders as they come in. Many successful startup clients start with 50 pieces, then move to 100-piece reorders once they validate demand, and eventually scale to 300-500 pieces with 8-12% better pricing. We grow with you, not against you."
    },
    {
      question: "What happens if my first products don't sell well—am I stuck with inventory?",
      answer: "This is a common startup fear, which is exactly why our 50-piece MOQ is so valuable. With just 50 pieces, you have multiple exit strategies: 1) Sell through discount promotions (20-30% off) to generate cash flow and customer feedback, 2) Use pieces for influencer gifting to build brand awareness and social proof, 3) Donate to charitable causes for tax deductions and goodwill, 4) Rebrand or modify pieces with new labels/tags if pivoting your brand identity. The financial risk is just $850-$900, not $8,500-$17,000. Many of our most successful startup clients 'failed' with their first design but used learnings to create a bestseller on their second attempt. One client (UrbanThreads LA, featured in our case studies) tested 3 different hoodie designs at 50 pieces each ($2,700 total investment) before finding their hero product that generated $250K in 8 months. Low MOQ equals low-risk experimentation."
    },
    {
      question: "Can I visit your factory, or can you send me photos/videos of production?",
      answer: "Yes to both! We welcome factory visits by appointment (email us 1-2 weeks in advance). We're located in Gazipur, Dhaka, Bangladesh, about 45 minutes from Hazrat Shahjalal International Airport (DAC). We'll arrange pickup if needed. For clients who can't visit in person (most startups), we offer comprehensive virtual transparency: pre-production video call showing your fabrics and trims before cutting begins, progress photos every 3-4 days via WhatsApp or email (cutting, sewing, quality checks), live video factory tour via Zoom/WhatsApp during your production run, final inspection video before shipping showing every piece, and customer references (we can connect you with 5-7 startup founders who've worked with us). We're certified WRAP (Worldwide Responsible Accredited Production) and SA8000 compliant, and we have nothing to hide. Transparency builds trust, especially with first-time founders."
    },
    {
      question: "What certifications do you have, and why should startups care?",
      answer: "We hold four key certifications that protect startups from costly compliance issues: OEKO-TEX Standard 100 (chemical safety—ensures your fabrics are free from harmful substances, critical if selling in EU or to parents/kids), GOTS (Global Organic Textile Standard—mandatory for marketing products as 'organic cotton'), WRAP (ethical labor practices—protects you from reputational risk and ensures fair working conditions), SA8000 (social accountability—shows we don't use child labor or unsafe conditions). Why this matters for startups: Many e-commerce platforms (Amazon, Shopify, Etsy) require proof of chemical compliance for children's products. European Union regulations (REACH) ban certain chemicals—OEKO-TEX ensures compliance. Major retailers (Urban Outfitters, Nordstrom) require supplier certifications before stocking indie brands. Consumer trust is everything for startups—certifications provide proof points for transparency. We include certification documents with every shipment at no extra cost. This alone saves you $500-$1,500 in testing fees."
    },
    {
      question: "Do you provide packaging, labels, and hang tags, or do I need to source those separately?",
      answer: "We offer complete turnkey packaging and branding services, which is critical for startups wanting a polished, professional look from day one: Woven labels (100 pieces minimum): $0.25-$0.60 each depending on complexity, Printed labels (fabric or satin): $0.15-$0.35 each, Custom hang tags (cardstock or kraft paper): $0.20-$0.50 each, Poly bags (clear or frosted): $0.08-$0.15 each, Custom tissue paper with logo: $0.25-$0.40 per sheet, Branded shipping mailers: $0.80-$1.50 each. We can source everything for you, handle attachment during production, and deliver finished, retail-ready products. This saves you 2-3 weeks of coordinating with multiple suppliers and ensures everything arrives together. Our most popular startup package includes woven neck labels, printed care labels, simple hang tags, and poly bags—total add-on cost $0.68-$1.60 per garment. We'll send you digital mockups before production so you can approve the final look."
    },
    {
      question: "What if I want to scale quickly—can you handle growing from 50 to 500+ pieces per order?",
      answer: "Absolutely, and this is our specialty. Our facility has capacity for 100,000+ pieces per month, but we intentionally work with startups at 50 pieces because we believe in sustainable growth. As you scale, here's what happens: 50-100 pieces: Same pricing, same service, same timelines—no changes. 100-300 pieces: 5-8% pricing reduction, priority production scheduling, quarterly business reviews with our team. 300-500 pieces: 8-12% pricing reduction, dedicated account manager, extended payment terms (NET 15-30), warehousing options. 500-1,000 pieces: 12-18% pricing reduction, co-development of new styles, expedited sampling (3-5 days instead of 7-10), potential consignment terms for proven bestsellers. 1,000+ pieces: Custom pricing based on volume, full design and merchandising support, white-glove service. We've scaled with dozens of brands from first-order startup to six-figure annual production. Recent example: 'FitLife Athleisure' started at 50 pieces in January 2023, grew to 300 pieces by June 2023, and placed an 800-piece order by December 2023. We grew with them every step."
    }
  ];

  const breadcrumbSchema = generateBreadcrumbSchema([
    { name: 'Home', url: 'https://sleekapparels.com' },
    { name: 'Services', url: 'https://sleekapparels.com/services' },
    { name: 'Clothing Manufacturer for Startups', url: 'https://sleekapparels.com/clothing-manufacturer-for-startups-low-moq' }
  ]);

  const productSchema = generateProductSchema({
    name: 'Startup Clothing Manufacturing Service - 50 Piece MOQ',
    description: 'Startup-friendly clothing manufacturing with 50-piece minimum order, free design support, transparent pricing, and flexible payment terms. Perfect for first-time clothing brand founders.',
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
        <section className="relative overflow-hidden bg-gradient-to-br from-blue-600 via-blue-700 to-indigo-800 text-white">
          <div className="absolute inset-0 bg-black/10"></div>
          <div className="container mx-auto px-4 py-16 md:py-24 relative z-10">
            <div className="max-w-4xl mx-auto text-center">
              <div className="inline-block mb-6 px-4 py-2 bg-white/20 backdrop-blur-sm rounded-full text-sm font-semibold">
                ⚡ Startup-Friendly Manufacturing
              </div>
              <h1 className="text-4xl md:text-6xl font-bold mb-6 leading-tight">
                Clothing Manufacturer Built for Startups & First-Time Founders
              </h1>
              <p className="text-xl md:text-2xl mb-4 text-blue-100 leading-relaxed">
                Launch Your Brand with <span className="font-bold text-white">50-Piece Minimum Order</span> – 
                10x Lower Than Traditional Manufacturers
              </p>
              <p className="text-lg mb-8 text-blue-200">
                Free Design Support • No Hidden Fees • Flexible Payment Terms • OEKO-TEX Certified
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Link 
                  href="/contact" 
                  className="inline-block bg-white text-blue-700 px-8 py-4 rounded-lg font-bold text-lg hover:bg-blue-50 transition-all shadow-xl hover:shadow-2xl hover:scale-105"
                >
                  Start Your Brand Today
                </Link>
                <Link 
                  href="/quote" 
                  className="inline-block bg-blue-800/50 backdrop-blur-sm border-2 border-white text-white px-8 py-4 rounded-lg font-bold text-lg hover:bg-blue-700/50 transition-all"
                >
                  Get Instant Quote
                </Link>
              </div>
              <p className="mt-6 text-sm text-blue-200">
                ✓ Over 300 Startups Launched Since 2015 • ✓ Average 4.8/5 Rating • ✓ 92% Reorder Rate
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
                <span className="text-2xl">🏭</span>
                <div>
                  <div className="font-bold text-gray-900">300+</div>
                  <div className="text-sm text-gray-600">Startups Launched</div>
                </div>
              </div>
              <div className="hidden md:block w-px h-12 bg-gray-300"></div>
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
                  <div className="text-sm text-gray-600">Certified Safe</div>
                </div>
              </div>
              <div className="hidden md:block w-px h-12 bg-gray-300"></div>
              <div className="flex items-center gap-2">
                <span className="text-2xl">⚡</span>
                <div>
                  <div className="font-bold text-gray-900">8-10 Weeks</div>
                  <div className="text-sm text-gray-600">Production Time</div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Why Startups Choose Sleek Apparels */}
        <section className="py-16 md:py-24">
          <div className="container mx-auto px-4">
            <div className="max-w-3xl mx-auto text-center mb-16">
              <h2 className="text-3xl md:text-5xl font-bold mb-6 text-gray-900">
                Why First-Time Founders Choose Sleek Apparels
              </h2>
              <p className="text-xl text-gray-600">
                We understand the unique challenges of launching a clothing brand from scratch. 
                Here's how we remove the barriers that stop most startups before they begin.
              </p>
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8 max-w-7xl mx-auto">
              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-4xl mb-4">💰</div>
                <h3 className="text-xl font-bold mb-3 text-gray-900">10x Lower MOQ Than Competitors</h3>
                <p className="text-gray-600 mb-4">
                  Start with just 50 pieces ($850-$900) instead of 500-1,000 pieces ($8,500-$17,000). 
                  Test your designs without risking your entire savings.
                </p>
                <div className="text-sm text-blue-600 font-semibold">
                  ✓ 60-75% less capital needed to start
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-4xl mb-4">🎨</div>
                <h3 className="text-xl font-bold mb-3 text-gray-900">Free Design & Technical Support</h3>
                <p className="text-gray-600 mb-4">
                  Don't have tech packs or professional sketches? No problem. Our in-house designers 
                  turn your rough ideas into production-ready specs—at no charge.
                </p>
                <div className="text-sm text-blue-600 font-semibold">
                  ✓ Save $500-$1,200 in design fees
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-4xl mb-4">📊</div>
                <h3 className="text-xl font-bold mb-3 text-gray-900">100% Transparent Pricing</h3>
                <p className="text-gray-600 mb-4">
                  No hidden fees, no surprise charges. You get a detailed cost breakdown upfront 
                  including fabric, labor, trims, and shipping. What you see is what you pay.
                </p>
                <div className="text-sm text-blue-600 font-semibold">
                  ✓ Zero financial surprises
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-4xl mb-4">🤝</div>
                <h3 className="text-xl font-bold mb-3 text-gray-900">Flexible Payment Terms</h3>
                <p className="text-gray-600 mb-4">
                  30% deposit to start production (not 50% like most manufacturers), with balance due 
                  before shipping. We work with your cash flow reality.
                </p>
                <div className="text-sm text-blue-600 font-semibold">
                  ✓ Keep more cash for marketing
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-4xl mb-4">🔍</div>
                <h3 className="text-xl font-bold mb-3 text-gray-900">Quality Without Compromise</h3>
                <p className="text-gray-600 mb-4">
                  OEKO-TEX Standard 100 certified fabrics, WRAP ethical manufacturing, and 6-point 
                  quality inspection on every garment. Your brand reputation is protected.
                </p>
                <div className="text-sm text-blue-600 font-semibold">
                  ✓ Retail-quality from day one
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-4xl mb-4">⚡</div>
                <h3 className="text-xl font-bold mb-3 text-gray-900">Fast Turnaround for Startups</h3>
                <p className="text-gray-600 mb-4">
                  8-10 weeks from order to delivery (5-6 weeks with rush service). We know speed 
                  matters when you're bootstrapping and building momentum.
                </p>
                <div className="text-sm text-blue-600 font-semibold">
                  ✓ Weekly progress photo updates
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-4xl mb-4">📱</div>
                <h3 className="text-xl font-bold mb-3 text-gray-900">Dedicated Startup Support</h3>
                <p className="text-gray-600 mb-4">
                  Direct WhatsApp/email access to your account manager (not an outsourced call center). 
                  Responses within 12-24 hours, not days or weeks.
                </p>
                <div className="text-sm text-blue-600 font-semibold">
                  ✓ Founder-friendly communication
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-all border border-gray-100">
                <div className="text-4xl mb-4">📈</div>
                <h3 className="text-xl font-bold mb-3 text-gray-900">Scale-Friendly Growth Path</h3>
                <p className="text-gray-600 mb-4">
                  Reorder in increments of 30 pieces after your first order. As you grow to 100-500 
                  pieces, unlock 5-18% better pricing. We grow with you, not against you.
                </p>
                <div className="text-sm text-blue-600 font-semibold">
                  ✓ Better economics at every stage
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Product Categories Startups Love */}
        <section className="py-16 md:py-24 bg-gray-50">
          <div className="container mx-auto px-4">
            <div className="max-w-3xl mx-auto text-center mb-16">
              <h2 className="text-3xl md:text-5xl font-bold mb-6 text-gray-900">
                Products We Manufacture for Startups
              </h2>
              <p className="text-xl text-gray-600">
                From t-shirts to hoodies, we specialize in the core products most clothing startups 
                launch with. All with 50-piece minimums and transparent pricing.
              </p>
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8 max-w-6xl mx-auto">
              <div className="bg-white rounded-xl overflow-hidden shadow-lg hover:shadow-2xl transition-all">
                <div className="bg-gradient-to-br from-blue-500 to-blue-600 p-6 text-white">
                  <div className="text-3xl mb-2">👕</div>
                  <h3 className="text-2xl font-bold">T-Shirts & Basics</h3>
                </div>
                <div className="p-6">
                  <p className="text-gray-600 mb-4">
                    The perfect starting point for most clothing brands. Choose from crew neck, V-neck, 
                    scoop neck, or longline styles. 100% cotton, cotton blends, or tri-blends.
                  </p>
                  <div className="space-y-2 mb-4">
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>MOQ: 50 pieces per style/color</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Weight: 150gsm - 220gsm</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Lead Time: 8-10 weeks</span>
                    </div>
                  </div>
                  <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                    <span className="text-sm text-gray-500">Price Range</span>
                    <span className="text-xl font-bold text-blue-600">$3.50 - $7.00</span>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl overflow-hidden shadow-lg hover:shadow-2xl transition-all">
                <div className="bg-gradient-to-br from-purple-500 to-purple-600 p-6 text-white">
                  <div className="text-3xl mb-2">🧥</div>
                  <h3 className="text-2xl font-bold">Hoodies & Sweatshirts</h3>
                </div>
                <div className="p-6">
                  <p className="text-gray-600 mb-4">
                    High-margin essentials popular with streetwear, athleisure, and lifestyle brands. 
                    Pullover or zip-up styles available.
                  </p>
                  <div className="space-y-2 mb-4">
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>MOQ: 50 pieces per style/color</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Weight: 280gsm - 400gsm</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Lead Time: 9-11 weeks</span>
                    </div>
                  </div>
                  <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                    <span className="text-sm text-gray-500">Price Range</span>
                    <span className="text-xl font-bold text-purple-600">$12.00 - $18.00</span>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl overflow-hidden shadow-lg hover:shadow-2xl transition-all">
                <div className="bg-gradient-to-br from-pink-500 to-pink-600 p-6 text-white">
                  <div className="text-3xl mb-2">👗</div>
                  <h3 className="text-2xl font-bold">Dresses & Tops</h3>
                </div>
                <div className="p-6">
                  <p className="text-gray-600 mb-4">
                    Perfect for women's fashion brands. From casual jersey dresses to elevated blouses 
                    and crop tops. Endless customization options.
                  </p>
                  <div className="space-y-2 mb-4">
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>MOQ: 50 pieces per style/color</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Styles: Mini, Midi, Maxi, Crop</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Lead Time: 9-12 weeks</span>
                    </div>
                  </div>
                  <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                    <span className="text-sm text-gray-500">Price Range</span>
                    <span className="text-xl font-bold text-pink-600">$8.00 - $16.00</span>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl overflow-hidden shadow-lg hover:shadow-2xl transition-all">
                <div className="bg-gradient-to-br from-green-500 to-green-600 p-6 text-white">
                  <div className="text-3xl mb-2">🩳</div>
                  <h3 className="text-2xl font-bold">Shorts & Pants</h3>
                </div>
                <div className="p-6">
                  <p className="text-gray-600 mb-4">
                    Joggers, sweatpants, athletic shorts, and casual bottoms. Great for athleisure 
                    and loungewear brands expanding beyond tops.
                  </p>
                  <div className="space-y-2 mb-4">
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>MOQ: 50 pieces per style/color</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Fabrics: French Terry, Fleece, Nylon</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Lead Time: 9-11 weeks</span>
                    </div>
                  </div>
                  <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                    <span className="text-sm text-gray-500">Price Range</span>
                    <span className="text-xl font-bold text-green-600">$9.00 - $15.00</span>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl overflow-hidden shadow-lg hover:shadow-2xl transition-all">
                <div className="bg-gradient-to-br from-orange-500 to-orange-600 p-6 text-white">
                  <div className="text-3xl mb-2">🏃</div>
                  <h3 className="text-2xl font-bold">Activewear & Leggings</h3>
                </div>
                <div className="p-6">
                  <p className="text-gray-600 mb-4">
                    Technical fabrics perfect for fitness brands. Moisture-wicking, 4-way stretch, 
                    and compression options available.
                  </p>
                  <div className="space-y-2 mb-4">
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>MOQ: 50 pieces per style/color</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Fabrics: Polyester, Spandex blends</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Lead Time: 10-12 weeks</span>
                    </div>
                  </div>
                  <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                    <span className="text-sm text-gray-500">Price Range</span>
                    <span className="text-xl font-bold text-orange-600">$10.00 - $16.00</span>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl overflow-hidden shadow-lg hover:shadow-2xl transition-all">
                <div className="bg-gradient-to-br from-indigo-500 to-indigo-600 p-6 text-white">
                  <div className="text-3xl mb-2">🧢</div>
                  <h3 className="text-2xl font-bold">Accessories & Headwear</h3>
                </div>
                <div className="p-6">
                  <p className="text-gray-600 mb-4">
                    Beanies, dad hats, tote bags, and other brand-building accessories. Perfect for 
                    rounding out your product line or testing new markets.
                  </p>
                  <div className="space-y-2 mb-4">
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>MOQ: 50 pieces per style/color</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Customization: Embroidery, patches</span>
                    </div>
                    <div className="flex items-center text-sm text-gray-700">
                      <span className="text-green-600 mr-2">✓</span>
                      <span>Lead Time: 7-9 weeks</span>
                    </div>
                  </div>
                  <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                    <span className="text-sm text-gray-500">Price Range</span>
                    <span className="text-xl font-bold text-indigo-600">$4.00 - $12.00</span>
                  </div>
                </div>
              </div>
            </div>

            <div className="mt-12 text-center">
              <p className="text-gray-600 mb-4">
                Don't see what you're looking for? We manufacture custom designs too.
              </p>
              <Link 
                href="/contact" 
                className="inline-block bg-blue-600 text-white px-8 py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors"
              >
                Discuss Your Custom Product
              </Link>
            </div>
          </div>
        </section>

        {/* Comparison Table: Sleek vs Traditional Manufacturers */}
        <section className="py-16 md:py-24">
          <div className="container mx-auto px-4">
            <div className="max-w-3xl mx-auto text-center mb-16">
              <h2 className="text-3xl md:text-5xl font-bold mb-6 text-gray-900">
                Sleek Apparels vs. Traditional Manufacturers
              </h2>
              <p className="text-xl text-gray-600">
                See the dramatic difference in startup-friendliness, cost, and support.
              </p>
            </div>

            <div className="max-w-5xl mx-auto overflow-x-auto">
              <table className="w-full bg-white shadow-xl rounded-xl overflow-hidden">
                <thead>
                  <tr className="bg-gradient-to-r from-blue-600 to-indigo-600 text-white">
                    <th className="px-6 py-4 text-left font-bold">Feature</th>
                    <th className="px-6 py-4 text-center font-bold">Sleek Apparels<br/><span className="text-sm font-normal">(Startup-Focused)</span></th>
                    <th className="px-6 py-4 text-center font-bold">Traditional Manufacturers<br/><span className="text-sm font-normal">(Big Brand Focus)</span></th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Minimum Order Quantity (MOQ)</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold text-lg">50 pieces</span>
                      <div className="text-sm text-gray-500">Per style/color</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold text-lg">500-1,000 pieces</span>
                      <div className="text-sm text-gray-500">10-20x higher</div>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Initial Capital Required</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold text-lg">$850 - $900</span>
                      <div className="text-sm text-gray-500">For 50-piece order</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold text-lg">$8,500 - $17,000</span>
                      <div className="text-sm text-gray-500">For 500-1,000 pieces</div>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Design Support</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold">✓ FREE</span>
                      <div className="text-sm text-gray-500">Tech packs, sketches included</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold">✗ Additional Cost</span>
                      <div className="text-sm text-gray-500">$500-$1,200 per design</div>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Production Deposit</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold">30%</span>
                      <div className="text-sm text-gray-500">$255-$270 to start</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold">50%</span>
                      <div className="text-sm text-gray-500">$4,250-$8,500 to start</div>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Sampling Cost</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold">$75-$125</span>
                      <div className="text-sm text-gray-500">Per sample (2-3 pieces)</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold">$150-$300</span>
                      <div className="text-sm text-gray-500">Per sample + setup fees</div>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Production Timeline</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold">8-10 weeks</span>
                      <div className="text-sm text-gray-500">5-6 weeks rush available</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold">12-16 weeks</span>
                      <div className="text-sm text-gray-500">Rush rarely available</div>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Communication Response Time</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold">12-24 hours</span>
                      <div className="text-sm text-gray-500">Direct WhatsApp/email access</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold">3-7 days</span>
                      <div className="text-sm text-gray-500">Through intermediaries</div>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Reorder Flexibility</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold">30 pieces minimum</span>
                      <div className="text-sm text-gray-500">After first order</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold">Same 500-1,000</span>
                      <div className="text-sm text-gray-500">No flexibility</div>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">OEKO-TEX Certification</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold">✓ Included FREE</span>
                      <div className="text-sm text-gray-500">Documents provided</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold">✗ Additional $500-$1,500</span>
                      <div className="text-sm text-gray-500">If available at all</div>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Packaging & Labels</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold">✓ Turnkey Service</span>
                      <div className="text-sm text-gray-500">We source everything for you</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold">✗ Your Responsibility</span>
                      <div className="text-sm text-gray-500">Must coordinate separately</div>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">Progress Updates</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold">✓ Every 3-4 Days</span>
                      <div className="text-sm text-gray-500">Photos + video via WhatsApp</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold">✗ Limited Updates</span>
                      <div className="text-sm text-gray-500">Only when you ask</div>
                    </td>
                  </tr>
                  <tr className="hover:bg-gray-50 bg-green-50">
                    <td className="px-6 py-4 font-bold text-gray-900">Total Cost Savings for Startups</td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-green-600 font-bold text-xl">60-75% Lower</span>
                      <div className="text-sm text-gray-600">$3,000-$5,000 vs $10,000-$15,000</div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-red-600 font-bold text-xl">Baseline</span>
                      <div className="text-sm text-gray-600">Prohibitive for most startups</div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div className="mt-12 max-w-3xl mx-auto text-center">
              <p className="text-lg text-gray-600 mb-6">
                The difference is clear: Sleek Apparels was built specifically for startups and first-time 
                founders who need low risk, high flexibility, and hands-on support.
              </p>
              <Link 
                href="/quote" 
                className="inline-block bg-blue-600 text-white px-8 py-4 rounded-lg font-bold text-lg hover:bg-blue-700 transition-colors shadow-lg"
              >
                Get Your Startup-Friendly Quote
              </Link>
            </div>
          </div>
        </section>

        {/* Perfect For These Startup Types */}
        <section className="py-16 md:py-24 bg-gradient-to-b from-gray-50 to-white">
          <div className="container mx-auto px-4">
            <div className="max-w-3xl mx-auto text-center mb-16">
              <h2 className="text-3xl md:text-5xl font-bold mb-6 text-gray-900">
                Perfect For These Types of Clothing Startups
              </h2>
              <p className="text-xl text-gray-600">
                Whether you're a solo entrepreneur or a small team, we've helped hundreds of 
                startups just like yours succeed.
              </p>
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 max-w-7xl mx-auto">
              <div className="bg-white p-6 rounded-xl shadow-lg border-l-4 border-blue-600 hover:shadow-2xl transition-all">
                <div className="text-3xl mb-3">🚀</div>
                <h3 className="font-bold text-lg mb-2 text-gray-900">First-Time Founders</h3>
                <p className="text-gray-600 text-sm">
                  You have a vision but zero manufacturing experience. We'll guide you through 
                  every step from design to delivery.
                </p>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg border-l-4 border-purple-600 hover:shadow-2xl transition-all">
                <div className="text-3xl mb-3">👨‍💻</div>
                <h3 className="font-bold text-lg mb-2 text-gray-900">Solopreneurs & Side Hustles</h3>
                <p className="text-gray-600 text-sm">
                  Bootstrapping while keeping your day job. Our low MOQs let you launch without 
                  risking your savings.
                </p>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg border-l-4 border-pink-600 hover:shadow-2xl transition-all">
                <div className="text-3xl mb-3">📱</div>
                <h3 className="font-bold text-lg mb-2 text-gray-900">Influencer Brands</h3>
                <p className="text-gray-600 text-sm">
                  You have an audience but want to test merchandise interest before committing 
                  to massive inventory.
                </p>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg border-l-4 border-green-600 hover:shadow-2xl transition-all">
                <div className="text-3xl mb-3">🎨</div>
                <h3 className="font-bold text-lg mb-2 text-gray-900">Artist & Designer Brands</h3>
                <p className="text-gray-600 text-sm">
                  You have amazing designs but need a manufacturer who can execute your creative 
                  vision without breaking the bank.
                </p>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg border-l-4 border-orange-600 hover:shadow-2xl transition-all">
                <div className="text-3xl mb-3">🛍️</div>
                <h3 className="font-bold text-lg mb-2 text-gray-900">E-commerce Startups</h3>
                <p className="text-gray-600 text-sm">
                  Launching on Shopify, Etsy, or Amazon FBA. You need quality products with fast 
                  turnarounds to test market fit.
                </p>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg border-l-4 border-indigo-600 hover:shadow-2xl transition-all">
                <div className="text-3xl mb-3">🏋️</div>
                <h3 className="font-bold text-lg mb-2 text-gray-900">Fitness & Wellness Brands</h3>
                <p className="text-gray-600 text-sm">
                  Launching activewear, yoga wear, or athleisure. We specialize in technical 
                  fabrics with low minimums.
                </p>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg border-l-4 border-red-600 hover:shadow-2xl transition-all">
                <div className="text-3xl mb-3">🎓</div>
                <h3 className="font-bold text-lg mb-2 text-gray-900">College Entrepreneurs</h3>
                <p className="text-gray-600 text-sm">
                  Starting a brand while in school. Our flexible payment terms and low MOQs make 
                  it possible with limited capital.
                </p>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-lg border-l-4 border-yellow-600 hover:shadow-2xl transition-all">
                <div className="text-3xl mb-3">🔄</div>
                <h3 className="font-bold text-lg mb-2 text-gray-900">Pivoting Entrepreneurs</h3>
                <p className="text-gray-600 text-sm">
                  Tested one niche but want to try another. Low MOQs let you experiment without 
                  getting stuck with dead inventory.
                </p>
              </div>
            </div>
          </div>
        </section>

        {/* Startup Manufacturing Process */}
        <section className="py-16 md:py-24">
          <div className="container mx-auto px-4">
            <div className="max-w-3xl mx-auto text-center mb-16">
              <h2 className="text-3xl md:text-5xl font-bold mb-6 text-gray-900">
                Your Startup-to-Shipment Journey
              </h2>
              <p className="text-xl text-gray-600">
                From idea to inventory in 8-10 weeks. Here's exactly how we make it happen.
              </p>
            </div>

            <div className="max-w-5xl mx-auto space-y-8">
              <div className="flex gap-6 items-start">
                <div className="flex-shrink-0 w-16 h-16 rounded-full bg-gradient-to-br from-blue-600 to-blue-700 text-white flex items-center justify-center text-2xl font-bold shadow-lg">
                  1
                </div>
                <div className="flex-1 bg-white p-6 rounded-xl shadow-lg">
                  <h3 className="text-2xl font-bold mb-3 text-gray-900">Initial Consultation (FREE)</h3>
                  <p className="text-gray-600 mb-4">
                    Schedule a 30-45 minute video call or WhatsApp chat with our startup specialist. 
                    Share your rough sketches, Pinterest boards, competitor examples, or even just describe 
                    your vision verbally. We'll ask questions about your target market, price point, 
                    and brand aesthetic.
                  </p>
                  <div className="bg-blue-50 border-l-4 border-blue-600 p-4 text-sm text-gray-700">
                    <strong>What You'll Receive:</strong> Preliminary product recommendations, rough pricing 
                    estimate, fabric suggestions, and next-step roadmap. No obligation, no pressure.
                  </div>
                </div>
              </div>

              <div className="flex gap-6 items-start">
                <div className="flex-shrink-0 w-16 h-16 rounded-full bg-gradient-to-br from-purple-600 to-purple-700 text-white flex items-center justify-center text-2xl font-bold shadow-lg">
                  2
                </div>
                <div className="flex-1 bg-white p-6 rounded-xl shadow-lg">
                  <h3 className="text-2xl font-bold mb-3 text-gray-900">Design Development (FREE)</h3>
                  <p className="text-gray-600 mb-4">
                    Our in-house design team creates professional technical sketches showing front, back, 
                    and detail views. We'll specify fabric type, weight, colors (Pantone matching), sizing, 
                    and construction details. You'll receive a complete tech pack ready for sampling—normally 
                    $500-$1,200 if outsourced, but free with us.
                  </p>
                  <div className="bg-purple-50 border-l-4 border-purple-600 p-4 text-sm text-gray-700">
                    <strong>Timeline:</strong> 3-5 business days for simple designs (t-shirts, basics), 
                    5-7 business days for complex designs (jackets, multi-panel activewear).
                  </div>
                </div>
              </div>

              <div className="flex gap-6 items-start">
                <div className="flex-shrink-0 w-16 h-16 rounded-full bg-gradient-to-br from-pink-600 to-pink-700 text-white flex items-center justify-center text-2xl font-bold shadow-lg">
                  3
                </div>
                <div className="flex-1 bg-white p-6 rounded-xl shadow-lg">
                  <h3 className="text-2xl font-bold mb-3 text-gray-900">Sample Production</h3>
                  <p className="text-gray-600 mb-4">
                    We produce 2-3 physical samples for you to review. Cost: $75-$125 per sample depending 
                    on complexity. Samples are shipped via DHL/FedEx (5-7 days to USA/Europe). Try them on, 
                    test the quality, show friends/potential customers, and provide feedback. We'll make one 
                    round of revisions free if needed.
                  </p>
                  <div className="bg-pink-50 border-l-4 border-pink-600 p-4 text-sm text-gray-700">
                    <strong>Pro Tip:</strong> Many startups create social media content with samples before 
                    production to gauge interest and pre-sell inventory.
                  </div>
                </div>
              </div>

              <div className="flex gap-6 items-start">
                <div className="flex-shrink-0 w-16 h-16 rounded-full bg-gradient-to-br from-green-600 to-green-700 text-white flex items-center justify-center text-2xl font-bold shadow-lg">
                  4
                </div>
                <div className="flex-1 bg-white p-6 rounded-xl shadow-lg">
                  <h3 className="text-2xl font-bold mb-3 text-gray-900">Order Confirmation & Deposit</h3>
                  <p className="text-gray-600 mb-4">
                    Once you approve the sample, we send a detailed production invoice showing: unit cost, 
                    quantity breakdown by size/color, shipping estimate, and payment terms. You pay just 30% 
                    deposit (not 50% like most manufacturers), keeping more cash available for marketing. 
                    Payment via bank transfer, PayPal, or Wise.
                  </p>
                  <div className="bg-green-50 border-l-4 border-green-600 p-4 text-sm text-gray-700">
                    <strong>Example:</strong> 50-piece t-shirt order at $5.50/piece = $275 total. 
                    Just $82.50 deposit to start production.
                  </div>
                </div>
              </div>

              <div className="flex gap-6 items-start">
                <div className="flex-shrink-0 w-16 h-16 rounded-full bg-gradient-to-br from-orange-600 to-orange-700 text-white flex items-center justify-center text-2xl font-bold shadow-lg">
                  5
                </div>
                <div className="flex-1 bg-white p-6 rounded-xl shadow-lg">
                  <h3 className="text-2xl font-bold mb-3 text-gray-900">Production (4-6 Weeks)</h3>
                  <p className="text-gray-600 mb-4">
                    Your order enters our production line. We send you progress photos every 3-4 days via 
                    WhatsApp showing: fabric cutting, sewing in progress, quality inspections, finishing 
                    (labeling, tagging, packing). You're never wondering "where is my order?"—we keep you 
                    in the loop constantly.
                  </p>
                  <div className="bg-orange-50 border-l-4 border-orange-600 p-4 text-sm text-gray-700">
                    <strong>Quality Control:</strong> Every garment undergoes 6-point inspection 
                    (stitching, measurements, fabric defects, color consistency, label placement, packing).
                  </div>
                </div>
              </div>

              <div className="flex gap-6 items-start">
                <div className="flex-shrink-0 w-16 h-16 rounded-full bg-gradient-to-br from-indigo-600 to-indigo-700 text-white flex items-center justify-center text-2xl font-bold shadow-lg">
                  6
                </div>
                <div className="flex-1 bg-white p-6 rounded-xl shadow-lg">
                  <h3 className="text-2xl font-bold mb-3 text-gray-900">Final Inspection & Balance Payment</h3>
                  <p className="text-gray-600 mb-4">
                    Once production is complete, we send you a comprehensive video walkthrough showing every 
                    piece laid out. You'll see the final quality, confirm everything looks perfect, and approve 
                    for shipping. At this point, the remaining 70% balance payment is due before we ship.
                  </p>
                  <div className="bg-indigo-50 border-l-4 border-indigo-600 p-4 text-sm text-gray-700">
                    <strong>Protection:</strong> If there are any quality issues (extremely rare), we'll 
                    remake affected pieces at no cost before shipping.
                  </div>
                </div>
              </div>

              <div className="flex gap-6 items-start">
                <div className="flex-shrink-0 w-16 h-16 rounded-full bg-gradient-to-br from-red-600 to-red-700 text-white flex items-center justify-center text-2xl font-bold shadow-lg">
                  7
                </div>
                <div className="flex-1 bg-white p-6 rounded-xl shadow-lg">
                  <h3 className="text-2xl font-bold mb-3 text-gray-900">Shipping & Delivery (1-2 Weeks)</h3>
                  <p className="text-gray-600 mb-4">
                    We pack your order in high-quality cartons with moisture protection and ship via DHL, 
                    FedEx, or sea freight depending on your preference and budget. Air shipping takes 5-7 days 
                    (recommended for small orders), sea freight takes 3-4 weeks (cost-effective for 200+ pieces). 
                    You receive tracking info and customs documents.
                  </p>
                  <div className="bg-red-50 border-l-4 border-red-600 p-4 text-sm text-gray-700">
                    <strong>Customs Support:</strong> We've shipped to 42 countries. We'll guide you through 
                    any customs/import requirements in your country.
                  </div>
                </div>
              </div>
            </div>

            <div className="mt-12 text-center">
              <div className="inline-block bg-gradient-to-r from-blue-600 to-indigo-600 text-white px-8 py-6 rounded-xl shadow-2xl">
                <div className="text-4xl font-bold mb-2">8-10 Weeks Total</div>
                <div className="text-lg mb-4">From consultation to products in your hands</div>
                <div className="text-sm text-blue-100">
                  Rush production available: 5-6 weeks (+15% fee)
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Pricing Transparency */}
        <section className="py-16 md:py-24 bg-gray-50">
          <div className="container mx-auto px-4">
            <div className="max-w-3xl mx-auto text-center mb-16">
              <h2 className="text-3xl md:text-5xl font-bold mb-6 text-gray-900">
                Transparent Startup Pricing
              </h2>
              <p className="text-xl text-gray-600">
                No hidden fees. No surprises. Here's exactly what it costs to launch your clothing 
                brand with Sleek Apparels.
              </p>
            </div>

            <div className="grid md:grid-cols-3 gap-8 max-w-6xl mx-auto mb-12">
              <div className="bg-white rounded-2xl shadow-xl overflow-hidden border-2 border-gray-200 hover:border-blue-600 transition-all">
                <div className="bg-gradient-to-br from-gray-100 to-gray-200 p-6 text-center">
                  <h3 className="text-2xl font-bold text-gray-900 mb-2">Essentials</h3>
                  <p className="text-gray-600 text-sm">Perfect for Testing</p>
                  <div className="mt-4">
                    <div className="text-4xl font-bold text-gray-900">$850</div>
                    <div className="text-sm text-gray-600">50 pieces (t-shirts)</div>
                  </div>
                </div>
                <div className="p-6">
                  <div className="space-y-3 mb-6">
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">50 custom t-shirts (150-180gsm cotton)</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">Free design & technical pack</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">Woven neck labels included</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">Poly bag packaging</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">OEKO-TEX certified fabrics</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">Progress photo updates</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">8-10 week production</span>
                    </div>
                  </div>
                  <div className="text-center">
                    <div className="text-sm text-gray-600 mb-2">Unit Cost</div>
                    <div className="text-2xl font-bold text-blue-600">$3.50 - $5.50</div>
                    <div className="text-xs text-gray-500">per piece</div>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-2xl shadow-xl overflow-hidden border-2 border-blue-600 relative">
                <div className="absolute -top-3 left-1/2 transform -translate-x-1/2 bg-blue-600 text-white px-4 py-1 rounded-full text-sm font-bold">
                  MOST POPULAR
                </div>
                <div className="bg-gradient-to-br from-blue-600 to-indigo-600 p-6 text-center text-white">
                  <h3 className="text-2xl font-bold mb-2">Growth</h3>
                  <p className="text-blue-100 text-sm">Ready to Scale</p>
                  <div className="mt-4">
                    <div className="text-4xl font-bold">$1,850</div>
                    <div className="text-sm text-blue-100">50 pieces (hoodies)</div>
                  </div>
                </div>
                <div className="p-6">
                  <div className="space-y-3 mb-6">
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">50 custom hoodies (300-350gsm fleece)</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">Free design & technical pack</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">Woven labels + custom hang tags</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">Premium poly bags or tissue paper</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">OEKO-TEX certified fabrics</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">Video + photo progress updates</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">9-11 week production</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700 font-semibold">Priority support</span>
                    </div>
                  </div>
                  <div className="text-center">
                    <div className="text-sm text-gray-600 mb-2">Unit Cost</div>
                    <div className="text-2xl font-bold text-blue-600">$12.00 - $15.00</div>
                    <div className="text-xs text-gray-500">per piece</div>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-2xl shadow-xl overflow-hidden border-2 border-gray-200 hover:border-purple-600 transition-all">
                <div className="bg-gradient-to-br from-purple-100 to-purple-200 p-6 text-center">
                  <h3 className="text-2xl font-bold text-gray-900 mb-2">Premium</h3>
                  <p className="text-gray-600 text-sm">Full Brand Launch</p>
                  <div className="mt-4">
                    <div className="text-4xl font-bold text-gray-900">$2,400</div>
                    <div className="text-sm text-gray-600">Mix: 25 tees + 25 hoodies</div>
                  </div>
                </div>
                <div className="p-6">
                  <div className="space-y-3 mb-6">
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">25 t-shirts + 25 hoodies (mixed order)</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">Free design for BOTH styles</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">Woven labels, hang tags, care labels</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">Custom tissue paper + stickers</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">OEKO-TEX + GOTS certifications</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">Weekly video call updates</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700">9-11 week production</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700 font-semibold">Dedicated account manager</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <span className="text-green-600 mt-1">✓</span>
                      <span className="text-sm text-gray-700 font-semibold">Rush production available</span>
                    </div>
                  </div>
                  <div className="text-center">
                    <div className="text-sm text-gray-600 mb-2">Blended Unit Cost</div>
                    <div className="text-2xl font-bold text-purple-600">$10.50 - $13.00</div>
                    <div className="text-xs text-gray-500">per piece (mixed)</div>
                  </div>
                </div>
              </div>
            </div>

            <div className="max-w-4xl mx-auto bg-white rounded-xl shadow-lg p-8">
              <h3 className="text-2xl font-bold mb-6 text-gray-900 text-center">Additional Costs & Add-Ons</h3>
              <div className="grid md:grid-cols-2 gap-6">
                <div>
                  <h4 className="font-bold text-gray-900 mb-3 flex items-center gap-2">
                    <span className="text-blue-600">📋</span> Pre-Production
                  </h4>
                  <div className="space-y-2 text-sm text-gray-700">
                    <div className="flex justify-between">
                      <span>Samples (2-3 pieces)</span>
                      <span className="font-semibold">$75-$125</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Sample Shipping (DHL/FedEx)</span>
                      <span className="font-semibold">$35-$50</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Design/Tech Pack</span>
                      <span className="font-semibold text-green-600">FREE</span>
                    </div>
                  </div>
                </div>

                <div>
                  <h4 className="font-bold text-gray-900 mb-3 flex items-center gap-2">
                    <span className="text-purple-600">📦</span> Packaging & Branding
                  </h4>
                  <div className="space-y-2 text-sm text-gray-700">
                    <div className="flex justify-between">
                      <span>Woven Labels (100 pcs)</span>
                      <span className="font-semibold">$25-$60</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Custom Hang Tags (100 pcs)</span>
                      <span className="font-semibold">$20-$50</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Poly Bags per piece</span>
                      <span className="font-semibold">$0.08-$0.15</span>
                    </div>
                  </div>
                </div>

                <div>
                  <h4 className="font-bold text-gray-900 mb-3 flex items-center gap-2">
                    <span className="text-pink-600">🚚</span> Shipping & Logistics
                  </h4>
                  <div className="space-y-2 text-sm text-gray-700">
                    <div className="flex justify-between">
                      <span>Air Freight (DHL/FedEx)</span>
                      <span className="font-semibold">$4.50-$6.50/kg</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Sea Freight (200+ pcs)</span>
                      <span className="font-semibold">$0.80-$1.50/kg</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Customs/Import Duties</span>
                      <span className="font-semibold text-gray-500">Varies by country</span>
                    </div>
                  </div>
                </div>

                <div>
                  <h4 className="font-bold text-gray-900 mb-3 flex items-center gap-2">
                    <span className="text-orange-600">⚡</span> Optional Services
                  </h4>
                  <div className="space-y-2 text-sm text-gray-700">
                    <div className="flex justify-between">
                      <span>Rush Production (5-6 weeks)</span>
                      <span className="font-semibold">+15%</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Custom Fabric Dyeing</span>
                      <span className="font-semibold">+$0.50-$1.00/pc</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Embroidery per piece</span>
                      <span className="font-semibold">$1.50-$4.00</span>
                    </div>
                  </div>
                </div>
              </div>

              <div className="mt-8 p-4 bg-blue-50 border-l-4 border-blue-600 rounded">
                <p className="text-sm text-gray-700">
                  <strong className="text-blue-900">💡 Pro Tip:</strong> Most startups spend 
                  $3,000-$5,000 total for their first production run including samples, production, 
                  branding, and shipping. This is 60-75% less than traditional manufacturers requiring 
                  $10,000-$15,000 minimum investment.
                </p>
              </div>
            </div>

            <div className="mt-12 text-center">
              <Link 
                href="/quote" 
                className="inline-block bg-blue-600 text-white px-8 py-4 rounded-lg font-bold text-lg hover:bg-blue-700 transition-colors shadow-lg"
              >
                Get Your Custom Startup Quote
              </Link>
              <p className="mt-4 text-sm text-gray-600">
                Instant estimate in 24 hours • No commitment required
              </p>
            </div>
          </div>
        </section>

        {/* Startup Success Story */}
        <section className="py-16 md:py-24 bg-gradient-to-br from-blue-600 to-indigo-700 text-white">
          <div className="container mx-auto px-4">
            <div className="max-w-5xl mx-auto">
              <div className="text-center mb-12">
                <div className="inline-block px-4 py-2 bg-white/20 backdrop-blur-sm rounded-full text-sm font-semibold mb-4">
                  ⭐ Featured Startup Success Story
                </div>
                <h2 className="text-3xl md:text-5xl font-bold mb-4">
                  "From Side Hustle to $250K in 8 Months"
                </h2>
                <p className="text-xl text-blue-100">
                  How UrbanThreads LA Used Our 50-Piece MOQ to Test, Learn, and Scale
                </p>
              </div>

              <div className="bg-white/10 backdrop-blur-md rounded-2xl p-8 md:p-12 shadow-2xl">
                <div className="grid md:grid-cols-3 gap-6 mb-8">
                  <div className="text-center">
                    <div className="text-4xl font-bold mb-2">$2,700</div>
                    <div className="text-blue-200 text-sm">Initial Investment</div>
                    <div className="text-xs text-blue-300 mt-1">3 test designs (50 pcs each)</div>
                  </div>
                  <div className="text-center">
                    <div className="text-4xl font-bold mb-2">8 Months</div>
                    <div className="text-blue-200 text-sm">To $250K Revenue</div>
                    <div className="text-xs text-blue-300 mt-1">From first order to six figures</div>
                  </div>
                  <div className="text-center">
                    <div className="text-4xl font-bold mb-2">9,200%</div>
                    <div className="text-blue-200 text-sm">ROI Achieved</div>
                    <div className="text-xs text-blue-300 mt-1">$2,700 → $250,000 revenue</div>
                  </div>
                </div>

                <div className="space-y-6 text-blue-50">
                  <div>
                    <h3 className="font-bold text-xl mb-2 text-white">The Challenge</h3>
                    <p>
                      Marcus Chen, a 26-year-old graphic designer from Los Angeles, wanted to launch a 
                      streetwear brand but had zero manufacturing experience and limited capital ($5,000 savings). 
                      Traditional manufacturers demanded 500-1,000 piece minimums, which would have consumed 
                      his entire budget with no room for experimentation.
                    </p>
                  </div>

                  <div>
                    <h3 className="font-bold text-xl mb-2 text-white">The Strategy</h3>
                    <p>
                      Marcus partnered with Sleek Apparels in January 2023. Instead of betting everything on 
                      one design, he tested THREE different hoodie designs at 50 pieces each ($900 per design = 
                      $2,700 total). This low-risk approach let him: test market demand with real products, 
                      gather customer feedback quickly, identify his bestseller without massive financial risk, 
                      and keep $2,300 in reserve for marketing and iterations.
                    </p>
                  </div>

                  <div>
                    <h3 className="font-bold text-xl mb-2 text-white">The Results</h3>
                    <ul className="space-y-2">
                      <li className="flex items-start gap-2">
                        <span className="text-green-400 mt-1">✓</span>
                        <span><strong>Month 1-2:</strong> Sold first 150 pieces through Instagram at $58/hoodie 
                        ($8,700 revenue, 222% ROI immediately)</span>
                      </li>
                      <li className="flex items-start gap-2">
                        <span className="text-green-400 mt-1">✓</span>
                        <span><strong>Month 3:</strong> Identified bestseller (black oversized hoodie with 
                        minimalist logo), reordered 100 pieces with improved sizing</span>
                      </li>
                      <li className="flex items-start gap-2">
                        <span className="text-green-400 mt-1">✓</span>
                        <span><strong>Month 4-5:</strong> Scaled to 300-piece orders, unlocked 8% better 
                        pricing, expanded to 4 colorways</span>
                      </li>
                      <li className="flex items-start gap-2">
                        <span className="text-green-400 mt-1">✓</span>
                        <span><strong>Month 6-8:</strong> Placed 800-piece order, secured wholesale accounts 
                        with 3 local boutiques, hit $250K total revenue</span>
                      </li>
                    </ul>
                  </div>

                  <div className="bg-white/10 p-6 rounded-xl border-l-4 border-white">
                    <p className="italic text-lg mb-2">
                      "Sleek Apparels' 50-piece MOQ literally saved my business before it even started. 
                      If I had to order 500 pieces of one design like other manufacturers wanted, I would 
                      have picked the WRONG design (my third design ended up being the bestseller) and 
                      been stuck with $8,000 worth of dead inventory. Instead, I tested three designs for 
                      $2,700, found my winner, and scaled intelligently. This is the only way to launch 
                      a clothing brand in 2024."
                    </p>
                    <div className="flex items-center gap-4 mt-4">
                      <div className="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center text-2xl">
                        👤
                      </div>
                      <div>
                        <div className="font-bold">Marcus Chen</div>
                        <div className="text-sm text-blue-200">Founder, UrbanThreads LA</div>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="mt-8 text-center">
                  <Link 
                    href="/case-studies" 
                    className="inline-block bg-white text-blue-700 px-6 py-3 rounded-lg font-semibold hover:bg-blue-50 transition-colors"
                  >
                    Read More Startup Success Stories
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* FAQs */}
        <section className="py-16 md:py-24">
          <div className="container mx-auto px-4">
            <div className="max-w-3xl mx-auto text-center mb-16">
              <h2 className="text-3xl md:text-5xl font-bold mb-6 text-gray-900">
                Frequently Asked Questions from Startups
              </h2>
              <p className="text-xl text-gray-600">
                Everything first-time founders ask us about manufacturing, costs, and timelines.
              </p>
            </div>

            <div className="max-w-4xl mx-auto space-y-6">
              {faqs.map((faq, index) => (
                <details 
                  key={index}
                  className="group bg-white rounded-xl shadow-lg overflow-hidden border border-gray-200 hover:border-blue-600 transition-all"
                >
                  <summary className="flex justify-between items-center cursor-pointer p-6 font-semibold text-lg text-gray-900 hover:text-blue-600 transition-colors">
                    <span className="pr-8">{faq.question}</span>
                    <span className="flex-shrink-0 text-blue-600 group-open:rotate-180 transition-transform">
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
              <p className="text-gray-600 mb-4">Still have questions about starting your clothing brand?</p>
              <Link 
                href="/contact" 
                className="inline-block bg-blue-600 text-white px-8 py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors"
              >
                Schedule Free Consultation
              </Link>
            </div>
          </div>
        </section>

        {/* Final CTA */}
        <section className="py-16 md:py-24 bg-gradient-to-br from-blue-600 via-indigo-600 to-purple-700 text-white">
          <div className="container mx-auto px-4">
            <div className="max-w-4xl mx-auto text-center">
              <h2 className="text-4xl md:text-6xl font-bold mb-6">
                Your Clothing Brand Starts Here
              </h2>
              <p className="text-xl md:text-2xl mb-4 text-blue-100 leading-relaxed">
                Join 300+ startups who launched successfully with our 50-piece MOQ and 
                startup-friendly manufacturing process.
              </p>
              <p className="text-lg mb-8 text-blue-200">
                No massive capital required • No manufacturing experience needed • No hidden fees or surprises
              </p>
              
              <div className="flex flex-col sm:flex-row gap-4 justify-center mb-8">
                <Link 
                  href="/contact" 
                  className="inline-block bg-white text-blue-700 px-10 py-5 rounded-lg font-bold text-xl hover:bg-blue-50 transition-all shadow-2xl hover:shadow-3xl hover:scale-105"
                >
                  Start Your Brand Today
                </Link>
                <Link 
                  href="/quote" 
                  className="inline-block bg-blue-800/50 backdrop-blur-sm border-2 border-white text-white px-10 py-5 rounded-lg font-bold text-xl hover:bg-blue-700/50 transition-all"
                >
                  Get Instant Quote
                </Link>
              </div>

              <div className="grid md:grid-cols-3 gap-6 text-center">
                <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
                  <div className="text-3xl font-bold mb-2">50 Pieces</div>
                  <div className="text-blue-200">Minimum Order</div>
                </div>
                <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
                  <div className="text-3xl font-bold mb-2">$850-$900</div>
                  <div className="text-blue-200">Starting Investment</div>
                </div>
                <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
                  <div className="text-3xl font-bold mb-2">8-10 Weeks</div>
                  <div className="text-blue-200">To Launch</div>
                </div>
              </div>

              <p className="mt-8 text-sm text-blue-200">
                ✓ OEKO-TEX Certified • ✓ WRAP Ethical Manufacturing • ✓ 92% Reorder Rate • ✓ 4.8/5 Average Rating
              </p>
            </div>
          </div>
        </section>
      </main>
    </>
  );
}
