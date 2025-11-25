import { SEO, organizationSchema, productSchema, faqSchema, breadcrumbSchema } from '@/components/SEO';
import { Navbar } from '@/components/Navbar';
import { Footer } from '@/components/Footer';
import { Button } from '@/components/ui/button';
import { Check, Palette, Shirt, Sparkles, Truck, Shield, Clock, DollarSign, Package, Award } from 'lucide-react';
import { Link } from 'react-router-dom';
import { CertificationBadges } from '@/components/CertificationBadges';

export default function CustomTShirtManufacturer() {
  const faqs = [
    {
      question: "What's your minimum order quantity for custom t-shirts?",
      answer: "Our MOQ is just 50 pieces per design per color. This low minimum is perfect for startups, influencers, small businesses, and entrepreneurs testing new designs. Unlike Chinese factories requiring 500-1,000 pieces, we support small-batch production."
    },
    {
      question: "What custom printing methods do you offer?",
      answer: "We offer Screen Printing (best for bulk, 200+ pieces), DTG (Direct-to-Garment for full-color designs, small batches), DTF (Direct-to-Film for high-quality transfers), Embroidery (premium branding), Heat Transfer, and Sublimation (for polyester activewear). We'll recommend the best method for your design and quantity."
    },
    {
      question: "Can you manufacture custom t-shirts with my own designs and labels?",
      answer: "Absolutely! We specialize in fully private label custom t-shirts. We'll manufacture shirts with your custom artwork, add woven/printed neck labels, hang tags, custom poly bags, and even custom packaging. You get a completely branded product ready for retail or e-commerce."
    },
    {
      question: "What fabric options are available for custom t-shirts?",
      answer: "We offer 100% Cotton (Combed, Ring-spun, Organic), Cotton Blends (50/50, 60/40, 80/20 poly-cotton for wrinkle resistance), Tri-Blends (Cotton/Poly/Rayon for softness), Performance fabrics (Moisture-wicking polyester for activewear), and Premium options (Supima cotton, Pima cotton, Bamboo blends). Fabric weight ranges from 120 GSM to 240 GSM."
    },
    {
      question: "How much do custom t-shirts cost per piece?",
      answer: "Pricing depends on fabric, printing method, and quantity. Blank t-shirts: $2.50-$4.00/pc (50-100 units), Screen Printed: $3.50-$6.00/pc (200+ units, 1-3 colors), DTG Full-Color: $5.00-$8.00/pc (50-200 units), Embroidered: $6.00-$10.00/pc (logo placement). All prices FOB Chittagong include fabric, labor, and printing. Add $0.50-$1.00 for custom labels/tags."
    },
    {
      question: "What's the production timeline for custom t-shirts?",
      answer: "Sample production: 5-7 days including shipping. Bulk production: 15-20 days for 50-500 pieces, 20-25 days for 500-2,000 pieces, 25-30 days for 2,000+ pieces. Rush production available (add 20-30% cost). Shipping: Air freight 7-10 days, Sea freight 18-25 days to USA ports."
    },
    {
      question: "Do you handle Amazon FBA prep for custom t-shirts?",
      answer: "Yes! We're experienced with Amazon FBA requirements. We provide poly bagging, FNSKU barcode labeling, carton labeling, prep center shipping, and Amazon compliance documentation. FBA prep costs $0.50-$1.00 per unit. We can ship directly to Amazon fulfillment centers."
    },
    {
      question: "Can you create custom t-shirt designs if I only have an idea?",
      answer: "Yes! Our design team can help. If you have rough sketches, reference images, or just a concept, we'll create professional mockups and tech packs. Design service costs $50-$150 per design depending on complexity. You'll receive detailed spec sheets and realistic 3D mockups before production."
    },
    {
      question: "What's the best t-shirt style for my brand?",
      answer: "Depends on your target market! Streetwear brands: Oversized fit, heavyweight 200-220 GSM, dropped shoulders. Premium basics: Regular fit, soft ring-spun cotton 180-200 GSM. Activewear: Moisture-wicking poly-blends 140-160 GSM. Fashion brands: Slim fit, Tri-blend 150-170 GSM. We'll recommend the best style based on your brand positioning."
    },
    {
      question: "Do you offer eco-friendly and sustainable t-shirt options?",
      answer: "Absolutely! We offer GOTS Organic Cotton (certified organic), Recycled Polyester (from plastic bottles), Bamboo Cotton Blends (naturally antimicrobial), Low-impact dyes (OEKO-TEX certified), and Water-based printing (no harmful chemicals). All eco options are certified and comply with EU/USA environmental standards."
    }
  ];

  const schemas = [
    organizationSchema,
    productSchema({
      name: "Custom T-Shirt Manufacturing Service",
      description: "Custom t-shirt manufacturing in Bangladesh with 50-piece MOQ. Screen printing, DTG, embroidery, private label. OEKO-TEX certified. Perfect for brands, startups, influencers.",
      minPrice: "3.50",
      maxPrice: "10.00"
    }),
    faqSchema(faqs),
    breadcrumbSchema([
      { name: "Home", url: "https://sleekapparels.com" },
      { name: "Custom T-Shirt Manufacturer", url: "https://sleekapparels.com/custom-tshirt-manufacturer-bangladesh" }
    ])
  ];

  return (
    <>
      <SEO
        title="Custom T-Shirt Manufacturer Bangladesh | Private Label | MOQ 50"
        description="Custom t-shirt manufacturer in Bangladesh with 50-piece MOQ. Screen printing, DTG, embroidery, private label. OEKO-TEX certified. Fast 15-20 day production for brands, startups & Amazon FBA sellers."
        canonical="https://sleekapparels.com/custom-tshirt-manufacturer-bangladesh"
        keywords="custom t-shirt manufacturer Bangladesh, private label t-shirts, custom tee shirts, screen printing Bangladesh, DTG printing, low MOQ t-shirts, branded t-shirts manufacturer"
        schema={schemas}
        ogImage="https://sleekapparels.com/images/custom-tshirt-production.jpg"
      />

      <div className="min-h-screen bg-white">
        <Navbar />
        
        {/* Hero Section */}
        <section className="bg-gradient-to-br from-primary to-secondary text-white py-20">
          <div className="container mx-auto px-4">
            <div className="max-w-4xl">
              {/* Breadcrumb */}
              <nav className="text-sm mb-4 opacity-90">
                <Link to="/" className="hover:underline">Home</Link>
                <span className="mx-2">/</span>
                <span>Custom T-Shirt Manufacturer Bangladesh</span>
              </nav>
              
              <h1 className="text-4xl md:text-5xl font-bold mb-6 leading-tight">
                Custom T-Shirt Manufacturer Bangladesh: Your Brand, Your Design, Our Expertise
              </h1>
              
              <p className="text-xl mb-8 opacity-95 leading-relaxed">
                <strong>50-piece minimum order.</strong> Screen printing, DTG, embroidery, private label, custom packaging. 
                OEKO-TEX certified. 15-20 day production. Perfect for fashion brands, influencers, startups & Amazon FBA sellers.
              </p>
              
              <div className="flex flex-wrap gap-4 mb-8">
                <div className="flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-2 rounded-lg">
                  <Package className="h-5 w-5" />
                  <span className="font-semibold">MOQ: 50 Pieces</span>
                </div>
                <div className="flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-2 rounded-lg">
                  <Clock className="h-5 w-5" />
                  <span className="font-semibold">15-20 Days Production</span>
                </div>
                <div className="flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-2 rounded-lg">
                  <Shield className="h-5 w-5" />
                  <span className="font-semibold">OEKO-TEX Certified</span>
                </div>
              </div>
              
              <div className="flex flex-wrap gap-4">
                <Button size="lg" variant="secondary" asChild>
                  <Link to="/contact">Get Free Quote</Link>
                </Button>
                <Button size="lg" variant="outline" className="bg-white/10 border-white text-white hover:bg-white/20" asChild>
                  <Link to="/samples">Order Samples ($25-50)</Link>
                </Button>
              </div>
            </div>
          </div>
        </section>

        {/* Key Benefits */}
        <section className="py-16 bg-gray-50">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">Why Choose Our Custom T-Shirt Manufacturing?</h2>
            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
              {[
                { icon: Package, title: "True Low MOQ", desc: "Just 50 pieces per design. Test your market without massive inventory risk." },
                { icon: Palette, title: "Any Printing Method", desc: "Screen print, DTG, DTF, embroidery, heat transfer, sublimation - we do it all." },
                { icon: Shirt, title: "Premium Fabrics", desc: "Organic cotton, tri-blends, performance fabrics. 120-240 GSM weight options." },
                { icon: Award, title: "OEKO-TEX Certified", desc: "All fabrics certified safe. BSCI ethical production. USA/EU compliant." }
              ].map((benefit, i) => (
                <div key={i} className="bg-white p-6 rounded-xl shadow-sm hover:shadow-md transition">
                  <benefit.icon className="h-10 w-10 text-primary mb-4" />
                  <h3 className="font-bold text-lg mb-2">{benefit.title}</h3>
                  <p className="text-gray-600 text-sm">{benefit.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Printing Methods */}
        <section className="py-16">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">Custom T-Shirt Printing Methods We Offer</h2>
            <div className="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
              {[
                {
                  title: "Screen Printing",
                  desc: "Best for: 200+ pieces, 1-6 colors",
                  price: "$3.50-$6.00/pc",
                  features: ["Vibrant colors", "Durable & long-lasting", "Cost-effective for bulk", "Pantone color matching"]
                },
                {
                  title: "DTG (Direct-to-Garment)",
                  desc: "Best for: 50-200 pieces, full-color",
                  price: "$5.00-$8.00/pc",
                  features: ["Unlimited colors", "Photorealistic prints", "No setup costs", "Perfect for small batches"]
                },
                {
                  title: "Embroidery",
                  desc: "Best for: Premium branding",
                  price: "$6.00-$10.00/pc",
                  features: ["Professional look", "Extremely durable", "Raised 3D effect", "Perfect for logos"]
                }
              ].map((method, i) => (
                <div key={i} className="border-2 border-gray-200 rounded-xl p-6 hover:border-primary transition">
                  <h3 className="text-xl font-bold mb-2">{method.title}</h3>
                  <p className="text-gray-600 mb-2">{method.desc}</p>
                  <p className="text-2xl font-bold text-primary mb-4">{method.price}</p>
                  <ul className="space-y-2">
                    {method.features.map((feature, j) => (
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

        {/* Fabric Options */}
        <section className="py-16 bg-gray-50">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-4">Custom T-Shirt Fabric Options</h2>
            <p className="text-center text-gray-600 mb-12 max-w-2xl mx-auto">
              Choose from premium fabrics to match your brand positioning and customer expectations
            </p>
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 max-w-6xl mx-auto">
              {[
                { name: "100% Combed Cotton", weight: "160-200 GSM", use: "Classic basics, premium feel", price: "$2.50-$4.00/pc" },
                { name: "50/50 Cotton-Poly Blend", weight: "150-180 GSM", use: "Wrinkle-resistant, retail brands", price: "$2.80-$4.50/pc" },
                { name: "Tri-Blend (Cotton/Poly/Rayon)", weight: "145-165 GSM", use: "Ultra-soft, fashion brands", price: "$3.50-$5.50/pc" },
                { name: "Organic Cotton (GOTS)", weight: "180-210 GSM", use: "Eco-conscious brands", price: "$4.00-$6.00/pc" },
                { name: "Performance Polyester", weight: "120-150 GSM", use: "Activewear, gym apparel", price: "$3.00-$5.00/pc" },
                { name: "Heavyweight (220-240 GSM)", weight: "220-240 GSM", use: "Streetwear, premium quality", price: "$4.50-$7.00/pc" }
              ].map((fabric, i) => (
                <div key={i} className="bg-white p-6 rounded-lg shadow-sm hover:shadow-md transition">
                  <h3 className="font-bold text-lg mb-2">{fabric.name}</h3>
                  <p className="text-sm text-gray-600 mb-1"><strong>Weight:</strong> {fabric.weight}</p>
                  <p className="text-sm text-gray-600 mb-3"><strong>Best for:</strong> {fabric.use}</p>
                  <p className="text-primary font-bold">{fabric.price}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Private Label Process */}
        <section className="py-16">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">Complete Private Label T-Shirt Solution</h2>
            <div className="grid md:grid-cols-2 gap-8 max-w-5xl mx-auto">
              <div className="space-y-6">
                <h3 className="text-2xl font-bold mb-4">What's Included:</h3>
                {[
                  "Your custom t-shirt designs printed/embroidered",
                  "Custom woven or printed neck labels",
                  "Hang tags with your branding",
                  "Custom poly bags with logo",
                  "Branded packaging boxes (optional)",
                  "Care label with your brand info",
                  "Size labels in your language",
                  "Amazon FBA prep available"
                ].map((item, i) => (
                  <div key={i} className="flex items-start gap-3">
                    <Check className="h-6 w-6 text-green-600 mt-0.5 flex-shrink-0" />
                    <span className="text-lg">{item}</span>
                  </div>
                ))}
              </div>
              <div className="bg-gradient-to-br from-primary/5 to-secondary/5 p-8 rounded-xl">
                <h3 className="text-2xl font-bold mb-4">Pricing Breakdown</h3>
                <div className="space-y-4">
                  <div className="flex justify-between items-center border-b pb-2">
                    <span>Base T-Shirt + Printing</span>
                    <span className="font-bold">$3.50-$6.00</span>
                  </div>
                  <div className="flex justify-between items-center border-b pb-2">
                    <span>Custom Neck Label</span>
                    <span className="font-bold">$0.30-$0.50</span>
                  </div>
                  <div className="flex justify-between items-center border-b pb-2">
                    <span>Hang Tag</span>
                    <span className="font-bold">$0.15-$0.30</span>
                  </div>
                  <div className="flex justify-between items-center border-b pb-2">
                    <span>Poly Bag</span>
                    <span className="font-bold">$0.10-$0.20</span>
                  </div>
                  <div className="flex justify-between items-center pt-2">
                    <span className="font-bold text-lg">Total per Piece</span>
                    <span className="font-bold text-2xl text-primary">$4.05-$7.00</span>
                  </div>
                  <p className="text-sm text-gray-600 mt-4">Based on 100-200 pieces. FOB Chittagong, Bangladesh.</p>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Production Process */}
        <section className="py-16 bg-gray-50">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">How Custom T-Shirt Production Works</h2>
            <div className="max-w-4xl mx-auto">
              <div className="space-y-6">
                {[
                  { step: "1", title: "Send Your Design", desc: "Share your artwork, ideas, or sketches. We accept AI, PSD, PDF, PNG, JPG. No tech pack? We'll create one for $50-150." },
                  { step: "2", title: "Choose Fabric & Printing", desc: "Select fabric type, weight, color. Choose printing method (screen, DTG, embroidery). We'll recommend the best option." },
                  { step: "3", title: "Sample Production (5-7 days)", desc: "We produce 1-3 samples with your exact design, fabric, and printing. Cost: $25-50 per sample including shipping." },
                  { step: "4", title: "Approve or Revise", desc: "Review physical samples. Request changes if needed. We make revisions until you're 100% satisfied." },
                  { step: "5", title: "Bulk Production (15-20 days)", desc: "Once approved, we start bulk manufacturing. 50-500 pieces take 15-20 days. Real-time production updates via WhatsApp." },
                  { step: "6", title: "Quality Control & Shipping", desc: "100% inspection before shipping. We handle air freight (7-10 days) or sea freight (18-25 days) to your door or Amazon FBA." }
                ].map((process, i) => (
                  <div key={i} className="flex gap-4">
                    <div className="flex-shrink-0 w-12 h-12 bg-primary text-white rounded-full flex items-center justify-center font-bold text-xl">
                      {process.step}
                    </div>
                    <div>
                      <h3 className="font-bold text-xl mb-2">{process.title}</h3>
                      <p className="text-gray-600">{process.desc}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* CTA Section */}
        <section className="py-16 bg-gradient-to-br from-primary to-secondary text-white">
          <div className="container mx-auto px-4 text-center">
            <h2 className="text-3xl md:text-4xl font-bold mb-6">Ready to Launch Your Custom T-Shirt Line?</h2>
            <p className="text-xl mb-8 opacity-95 max-w-2xl mx-auto">
              Join 500+ fashion brands, influencers, and startups who trust us with their custom t-shirt manufacturing. 
              Get a free quote in 24 hours.
            </p>
            <div className="flex flex-wrap gap-4 justify-center">
              <Button size="lg" variant="secondary" asChild>
                <Link to="/contact">Get Free Quote Now</Link>
              </Button>
              <Button size="lg" variant="outline" className="bg-white/10 border-white text-white hover:bg-white/20" asChild>
                <Link to="/samples">Order Sample Pack</Link>
              </Button>
            </div>
          </div>
        </section>

        {/* FAQs */}
        <section className="py-16">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">Frequently Asked Questions</h2>
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
