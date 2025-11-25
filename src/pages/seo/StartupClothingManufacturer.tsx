import { SEO, organizationSchema, productSchema, faqSchema, breadcrumbSchema } from '@/components/SEO';
import { Navbar } from '@/components/Navbar';
import { Footer } from '@/components/Footer';
import { Button } from '@/components/ui/button';
import { Check, Rocket, TrendingUp, DollarSign, Clock, Shield, Users, Lightbulb, Package, Zap } from 'lucide-react';
import { Link } from 'react-router-dom';
import { CertificationBadges } from '@/components/CertificationBadges';

export default function StartupClothingManufacturer() {
  const faqs = [
    {
      question: "What's the absolute minimum order quantity for fashion startups?",
      answer: "Our MOQ is just 50 pieces per style per color - one of the lowest in Bangladesh. This allows fashion startups to test markets, validate designs, and launch MVP collections without massive upfront inventory investment. Most Chinese factories require 500-1,000 pieces minimum."
    },
    {
      question: "How much capital do I need to start a clothing brand with your factory?",
      answer: "You can launch with $3,000-$5,000 total investment. Example budget: 100 t-shirts at $4.50/pc = $450, 100 hoodies at $15/pc = $1,500, Samples ($100-200), Shipping ($300-500), Labels/Tags ($150-250), Working capital ($500-1,000). This covers 200 pieces (2 products) ready for launch."
    },
    {
      question: "Do you offer design support for startups without tech packs?",
      answer: "Yes! Many startups have great ideas but lack technical design skills. Our design team creates professional tech packs from sketches, reference images, or mood boards. Service costs $75-$200 per design. You'll receive detailed specifications, measurements, construction notes, and 3D mockups."
    },
    {
      question: "Can you manufacture different products in one small order?",
      answer: "Absolutely! We understand startups need variety. You can mix products: 50 t-shirts + 50 hoodies + 50 sweatpants = 150 total pieces (meets our combined minimum). This flexibility lets you test multiple products without massive per-item commitments."
    },
    {
      question: "What's included in your startup-friendly pricing?",
      answer: "Our all-inclusive pricing covers fabric, labor, printing/embroidery, standard packaging, quality control, and FOB Chittagong export. No hidden fees. Optional add-ons: Custom labels ($0.30-0.50/pc), Hang tags ($0.15-0.30/pc), Premium packaging ($0.50-1.50/pc), FBA prep ($0.50-1.00/pc)."
    },
    {
      question: "Do you provide samples before bulk production?",
      answer: "Yes, always! Samples cost $25-50 per piece including DHL shipping (5-7 days). This is critical for startups to validate quality before committing to bulk. Sample cost is refunded if you place a bulk order of 200+ pieces within 60 days."
    },
    {
      question: "How long does production take for startup orders?",
      answer: "Sample production: 5-7 days including shipping. Bulk production: 50-200 pieces take 15-20 days, 200-500 pieces take 20-25 days. Rush production available (add 20-30% cost). We prioritize startup orders to help you launch faster."
    },
    {
      question: "Can you ship directly to Amazon FBA for my startup?",
      answer: "Yes! We're FBA-experienced. We handle poly bagging, FNSKU labeling, carton labeling, Amazon compliance documentation, and direct shipping to fulfillment centers. FBA prep costs $0.50-$1.00 per unit. Perfect for e-commerce startups."
    },
    {
      question: "Do you offer payment terms for growing startups?",
      answer: "For first orders: 50% deposit, 50% before shipping. After 2-3 successful orders, we offer 30% deposit, 70% net 30 days payment terms. We understand startup cash flow challenges and work with serious brands building long-term relationships."
    },
    {
      question: "What certifications do you have for selling in USA/Europe?",
      answer: "We're OEKO-TEX Standard 100 certified (textile safety), BSCI certified (ethical production), WRAP certified (social compliance). All certifications current and verifiable. Your products will comply with USA CPSC, EU REACH, and UK regulations for legal import and sale."
    }
  ];

  const schemas = [
    organizationSchema,
    productSchema({
      name: "Clothing Manufacturing Service for Fashion Startups",
      description: "Low MOQ clothing manufacturer for fashion startups in Bangladesh. 50-piece minimum, design support, fast production, OEKO-TEX certified. Perfect for launching fashion brands.",
      minPrice: "4.50",
      maxPrice: "18.00"
    }),
    faqSchema(faqs),
    breadcrumbSchema([
      { name: "Home", url: "https://sleekapparels.com" },
      { name: "Clothing Manufacturer for Startups", url: "https://sleekapparels.com/clothing-manufacturer-for-startups-low-moq" }
    ])
  ];

  return (
    <>
      <SEO
        title="Clothing Manufacturer for Startups | Low MOQ 50 Pieces | Bangladesh"
        description="Fashion startup-friendly clothing manufacturer in Bangladesh. 50-piece MOQ, design support, fast 15-20 day production. OEKO-TEX certified. Perfect for launching your clothing brand with low risk."
        canonical="https://sleekapparels.com/clothing-manufacturer-for-startups-low-moq"
        keywords="clothing manufacturer for startups, fashion startup manufacturer, low MOQ clothing factory, startup apparel manufacturer, launch clothing brand, small batch clothing"
        schema={schemas}
        ogImage="https://sleekapparels.com/images/startup-fashion-launch.jpg"
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
                <span>Clothing Manufacturer for Startups</span>
              </nav>
              
              <h1 className="text-4xl md:text-5xl font-bold mb-6 leading-tight">
                Clothing Manufacturer for Fashion Startups: Launch Your Brand with 50 Pieces
              </h1>
              
              <p className="text-xl mb-8 opacity-95 leading-relaxed">
                <strong>The only clothing manufacturer you need to launch your fashion startup.</strong> 50-piece minimum order, 
                design support, tech pack creation, Amazon FBA prep. OEKO-TEX certified. Start your brand for $3,000-$5,000.
              </p>
              
              <div className="flex flex-wrap gap-4 mb-8">
                <div className="flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-2 rounded-lg">
                  <Package className="h-5 w-5" />
                  <span className="font-semibold">MOQ: Just 50 Pieces</span>
                </div>
                <div className="flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-2 rounded-lg">
                  <Lightbulb className="h-5 w-5" />
                  <span className="font-semibold">Free Design Consultation</span>
                </div>
                <div className="flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-2 rounded-lg">
                  <Clock className="h-5 w-5" />
                  <span className="font-semibold">15-20 Days Production</span>
                </div>
              </div>
              
              <div className="flex flex-wrap gap-4">
                <Button size="lg" variant="secondary" asChild>
                  <Link to="/contact">Start Your Brand Today</Link>
                </Button>
                <Button size="lg" variant="outline" className="bg-white/10 border-white text-white hover:bg-white/20" asChild>
                  <Link to="/samples">Order Startup Sample Pack</Link>
                </Button>
              </div>
            </div>
          </div>
        </section>

        {/* Why Startups Choose Us */}
        <section className="py-16 bg-gray-50">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">Why Fashion Startups Choose Sleek Apparels</h2>
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 max-w-6xl mx-auto">
              {[
                { 
                  icon: Rocket, 
                  title: "True Low MOQ (50 Pieces)", 
                  desc: "Unlike Chinese factories requiring 500-1,000 pieces, we genuinely accept 50-piece orders. Test your designs without massive inventory risk." 
                },
                { 
                  icon: DollarSign, 
                  title: "Launch for $3K-$5K", 
                  desc: "Start your clothing brand with minimal capital. Our transparent pricing helps you budget accurately and launch profitably." 
                },
                { 
                  icon: Lightbulb, 
                  title: "Free Design Consulting", 
                  desc: "Not a designer? No problem! We help refine ideas, create tech packs ($75-200), and recommend best fabrics for your brand vision." 
                },
                { 
                  icon: Clock, 
                  title: "Fast 15-20 Day Production", 
                  desc: "Speed matters for startups. We prioritize small orders and deliver faster than large factories focused on big brands." 
                },
                { 
                  icon: Users, 
                  title: "Dedicated Startup Support", 
                  desc: "Work directly with experienced team members who understand startup challenges. WhatsApp updates, video factory tours, honest advice." 
                },
                { 
                  icon: Shield, 
                  title: "OEKO-TEX Certified Quality", 
                  desc: "Your products will be safe, certified, and compliant for USA/EU markets. Build customer trust from day one." 
                }
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

        {/* Startup Budget Calculator */}
        <section className="py-16">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-4">Launch Your Fashion Brand: Budget Breakdown</h2>
            <p className="text-center text-gray-600 mb-12 max-w-2xl mx-auto">
              Real numbers from successful fashion startups we've helped launch
            </p>
            <div className="grid md:grid-cols-2 gap-8 max-w-5xl mx-auto">
              {/* Minimal Launch Budget */}
              <div className="border-2 border-gray-200 rounded-xl p-8 hover:border-primary transition">
                <div className="flex items-center justify-between mb-6">
                  <h3 className="text-2xl font-bold">Minimal Launch</h3>
                  <span className="text-3xl font-bold text-primary">$3,000</span>
                </div>
                <div className="space-y-4">
                  <div className="flex justify-between items-center pb-2 border-b">
                    <span>100 T-Shirts ($4.50/pc)</span>
                    <span className="font-semibold">$450</span>
                  </div>
                  <div className="flex justify-between items-center pb-2 border-b">
                    <span>50 Hoodies ($15/pc)</span>
                    <span className="font-semibold">$750</span>
                  </div>
                  <div className="flex justify-between items-center pb-2 border-b">
                    <span>Samples (3 pieces)</span>
                    <span className="font-semibold">$150</span>
                  </div>
                  <div className="flex justify-between items-center pb-2 border-b">
                    <span>Air Shipping (DDP)</span>
                    <span className="font-semibold">$400</span>
                  </div>
                  <div className="flex justify-between items-center pb-2 border-b">
                    <span>Labels & Tags</span>
                    <span className="font-semibold">$200</span>
                  </div>
                  <div className="flex justify-between items-center pb-2 border-b">
                    <span>Working Capital Reserve</span>
                    <span className="font-semibold">$1,050</span>
                  </div>
                  <div className="bg-green-50 p-4 rounded-lg mt-4">
                    <p className="text-sm text-green-800"><strong>Profit Potential:</strong> Sell 150 pieces at $35 average = $5,250 revenue. Gross profit: $2,250 (75% margin).</p>
                  </div>
                </div>
              </div>

              {/* Growth Launch Budget */}
              <div className="border-2 border-primary rounded-xl p-8 bg-primary/5">
                <div className="flex items-center justify-between mb-6">
                  <h3 className="text-2xl font-bold">Growth Launch</h3>
                  <span className="text-3xl font-bold text-primary">$5,000</span>
                </div>
                <div className="space-y-4">
                  <div className="flex justify-between items-center pb-2 border-b">
                    <span>200 T-Shirts ($4.00/pc)</span>
                    <span className="font-semibold">$800</span>
                  </div>
                  <div className="flex justify-between items-center pb-2 border-b">
                    <span>100 Hoodies ($14/pc)</span>
                    <span className="font-semibold">$1,400</span>
                  </div>
                  <div className="flex justify-between items-center pb-2 border-b">
                    <span>50 Sweatpants ($12/pc)</span>
                    <span className="font-semibold">$600</span>
                  </div>
                  <div className="flex justify-between items-center pb-2 border-b">
                    <span>Design & Samples</span>
                    <span className="font-semibold">$300</span>
                  </div>
                  <div className="flex justify-between items-center pb-2 border-b">
                    <span>Air Shipping (DDP)</span>
                    <span className="font-semibold">$600</span>
                  </div>
                  <div className="flex justify-between items-center pb-2 border-b">
                    <span>Premium Packaging</span>
                    <span className="font-semibold">$400</span>
                  </div>
                  <div className="flex justify-between items-center pb-2 border-b">
                    <span>Working Capital Reserve</span>
                    <span className="font-semibold">$900</span>
                  </div>
                  <div className="bg-green-50 p-4 rounded-lg mt-4">
                    <p className="text-sm text-green-800"><strong>Profit Potential:</strong> Sell 350 pieces at $38 average = $13,300 revenue. Gross profit: $8,300 (166% ROI).</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Startup Launch Process */}
        <section className="py-16 bg-gray-50">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">How to Launch Your Clothing Brand (Step-by-Step)</h2>
            <div className="max-w-4xl mx-auto">
              <div className="space-y-6">
                {[
                  { 
                    step: "1", 
                    title: "Discovery Call (30 min - Free)", 
                    desc: "Share your brand vision, target market, budget, and timeline. We'll discuss fabric options, printing methods, and realistic MOQs. No sales pressure - just honest advice." 
                  },
                  { 
                    step: "2", 
                    title: "Design Development ($75-200)", 
                    desc: "Send sketches, mood boards, or reference images. Our design team creates professional tech packs with measurements, construction details, and fabric specifications. You'll receive 3D mockups for visualization." 
                  },
                  { 
                    step: "3", 
                    title: "Sample Production (5-7 days)", 
                    desc: "We manufacture 1-3 physical samples with exact fabrics, trims, and printing. Samples cost $25-50/piece including DHL shipping. This validates quality before bulk commitment." 
                  },
                  { 
                    step: "4", 
                    title: "Sample Review & Revisions", 
                    desc: "Receive samples, test fit and quality. Request changes to fabric, sizing, printing, or construction. We make revisions until you're 100% satisfied. Most startups approve within 1-2 rounds." 
                  },
                  { 
                    step: "5", 
                    title: "Place Bulk Order (50% deposit)", 
                    desc: "Confirm final quantities, sizes, colors, and packaging. Pay 50% deposit to begin production. We send a detailed invoice with exact timeline and delivery date." 
                  },
                  { 
                    step: "6", 
                    title: "Production (15-20 days)", 
                    desc: "We manufacture your order with daily WhatsApp photo updates. You'll see cutting, sewing, printing, quality control, and packaging stages. Full transparency throughout." 
                  },
                  { 
                    step: "7", 
                    title: "Quality Control & Shipping", 
                    desc: "100% inspection before shipment. Pay remaining 50% balance. We arrange air freight (7-10 days) or sea freight (18-25 days) with DDP (door-to-door) or FBA direct shipping." 
                  },
                  { 
                    step: "8", 
                    title: "Launch & Reorder Support", 
                    desc: "Launch your brand! We provide reorder discounts (5-10% off) and faster production for repeat orders. After 2-3 successful orders, we offer net 30 payment terms to ease cash flow." 
                  }
                ].map((process, i) => (
                  <div key={i} className="flex gap-4">
                    <div className="flex-shrink-0 w-12 h-12 bg-primary text-white rounded-full flex items-center justify-center font-bold text-xl">
                      {process.step}
                    </div>
                    <div>
                      <h3 className="font-bold text-xl mb-2">{process.title}</h3>
                      <p className="text-gray-600 leading-relaxed">{process.desc}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* Product Options for Startups */}
        <section className="py-16">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">Popular Products for Fashion Startup Collections</h2>
            <div className="grid md:grid-cols-3 gap-6 max-w-6xl mx-auto">
              {[
                { 
                  product: "T-Shirts", 
                  moq: "50 pieces", 
                  price: "$3.50-$6.00/pc", 
                  timeline: "15-18 days",
                  features: ["Combed cotton, blends, tri-blends", "Screen print, DTG, embroidery", "160-220 GSM weight options", "Perfect for testing designs"]
                },
                { 
                  product: "Hoodies", 
                  moq: "50 pieces", 
                  price: "$12.00-$18.00/pc", 
                  timeline: "18-22 days",
                  features: ["Fleece, French Terry, heavyweight", "Pullover or zip-up styles", "Screen print, embroidery, patches", "High perceived value product"]
                },
                { 
                  product: "Sweatpants", 
                  moq: "50 pieces", 
                  price: "$10.00-$15.00/pc", 
                  timeline: "18-22 days",
                  features: ["Fleece, French Terry fabrics", "Jogger or classic fit", "Elastic or drawstring waist", "Complements hoodie collections"]
                },
                { 
                  product: "Activewear", 
                  moq: "50 pieces", 
                  price: "$8.00-$14.00/pc", 
                  timeline: "20-25 days",
                  features: ["Moisture-wicking polyester", "Leggings, shorts, tanks, sports bras", "Flatlock stitching, stretch fabric", "Growing market segment"]
                },
                { 
                  product: "Streetwear", 
                  moq: "50 pieces", 
                  price: "$15.00-$25.00/pc", 
                  timeline: "22-28 days",
                  features: ["Oversized fits, heavyweight fabrics", "Cargo pants, bomber jackets", "Premium construction & details", "High-margin premium products"]
                },
                { 
                  product: "Basics Collection", 
                  moq: "50 per style", 
                  price: "$4.00-$8.00/pc", 
                  timeline: "15-18 days",
                  features: ["Tees, tanks, long sleeves, crew necks", "Simple, versatile designs", "Core wardrobe staples", "Easy to brand and market"]
                }
              ].map((item, i) => (
                <div key={i} className="border-2 border-gray-200 rounded-xl p-6 hover:border-primary transition">
                  <h3 className="text-xl font-bold mb-2">{item.product}</h3>
                  <div className="flex justify-between mb-4">
                    <span className="text-sm text-gray-600"><strong>MOQ:</strong> {item.moq}</span>
                    <span className="text-sm text-gray-600"><strong>Timeline:</strong> {item.timeline}</span>
                  </div>
                  <p className="text-2xl font-bold text-primary mb-4">{item.price}</p>
                  <ul className="space-y-2">
                    {item.features.map((feature, j) => (
                      <li key={j} className="flex items-start gap-2 text-sm">
                        <Check className="h-4 w-4 text-green-600 mt-0.5 flex-shrink-0" />
                        <span>{feature}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Success Stories Teaser */}
        <section className="py-16 bg-gradient-to-br from-primary/5 to-secondary/5">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">Fashion Startups We've Helped Launch</h2>
            <div className="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
              {[
                {
                  brand: "Urban Thread Co.",
                  founder: "Alex M., Los Angeles",
                  story: "Launched with 150 pieces (t-shirts & hoodies). Now doing $50K/month in revenue. Started with our 50-piece MOQ to test Instagram market.",
                  products: "T-shirts, Hoodies, Sweatpants"
                },
                {
                  brand: "EcoWear Basics",
                  founder: "Sarah T., London",
                  story: "Sustainable fashion startup. Launched with 100 organic cotton tees. Sold out in 3 weeks. Now on 5th reorder with expanded collection.",
                  products: "Organic T-Shirts, Tote Bags"
                },
                {
                  brand: "Apex Athletics",
                  founder: "Mike R., Toronto",
                  story: "Activewear startup for gym enthusiasts. Started with 50-piece order. Grew to 500+ pieces/month. Amazon FBA sales generating $30K/month.",
                  products: "Activewear, Gym Shorts, Tanks"
                }
              ].map((story, i) => (
                <div key={i} className="bg-white p-6 rounded-xl shadow-sm">
                  <h3 className="font-bold text-xl mb-2 text-primary">{story.brand}</h3>
                  <p className="text-sm text-gray-500 mb-4">{story.founder}</p>
                  <p className="text-gray-700 mb-4 leading-relaxed">{story.story}</p>
                  <p className="text-sm text-gray-600"><strong>Products:</strong> {story.products}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* CTA Section */}
        <section className="py-16 bg-gradient-to-br from-primary to-secondary text-white">
          <div className="container mx-auto px-4 text-center">
            <h2 className="text-3xl md:text-4xl font-bold mb-6">Ready to Launch Your Fashion Startup?</h2>
            <p className="text-xl mb-8 opacity-95 max-w-2xl mx-auto">
              Join 200+ fashion startups who launched their brands with us. Get free design consultation and startup pricing package.
            </p>
            <div className="flex flex-wrap gap-4 justify-center">
              <Button size="lg" variant="secondary" asChild>
                <Link to="/contact">Get Startup Pricing Package</Link>
              </Button>
              <Button size="lg" variant="outline" className="bg-white/10 border-white text-white hover:bg-white/20" asChild>
                <Link to="/samples">Order Startup Sample Pack</Link>
              </Button>
            </div>
          </div>
        </section>

        {/* FAQs */}
        <section className="py-16">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">Startup FAQs</h2>
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

        {/* Certifications */}
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
