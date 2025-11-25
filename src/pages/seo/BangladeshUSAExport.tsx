import { SEO, organizationSchema, productSchema, faqSchema, breadcrumbSchema } from '@/components/SEO';
import { Navbar } from '@/components/Navbar';
import { Footer } from '@/components/Footer';
import { Button } from '@/components/ui/button';
import { Check, Ship, DollarSign, Shield, FileCheck, Plane, Package, Clock, Globe, Award } from 'lucide-react';
import { Link } from 'react-router-dom';
import { CertificationBadges } from '@/components/CertificationBadges';

export default function BangladeshUSAExport() {
  const faqs = [
    {
      question: "Do you handle USA customs clearance and import documentation?",
      answer: "Yes! We manage full export documentation including Commercial Invoice, Packing List, Bill of Lading, Certificate of Origin (Form A for duty-free benefits), OEKO-TEX certificates, and BSCI/WRAP compliance documents. We work with experienced USA customs brokers to ensure smooth clearance."
    },
    {
      question: "What are the import duties and taxes for Bangladesh clothing to USA?",
      answer: "Bangladesh enjoys duty-free access to USA under GSP (Generalized System of Preferences) for many apparel categories. This can save 15-32% compared to China imports. However, quotas apply to certain categories. We'll confirm exact duty rates based on your product's HS code before shipping."
    },
    {
      question: "How long does shipping take from Bangladesh to USA?",
      answer: "Air freight: 7-10 days door-to-door (best for urgent orders, samples, small batches). Sea freight: 18-25 days to East Coast ports (NY, Savannah, Miami), 25-30 days to West Coast (LA, Oakland). We use trusted forwarders like DHL, FedEx for air, and Maersk, MSC for sea freight."
    },
    {
      question: "Can you ship directly to Amazon FBA warehouses in USA?",
      answer: "Absolutely! We're FBA-experienced and ship directly to all Amazon fulfillment centers (PHX6, ONT8, RNO4, etc.). We handle poly bagging, FNSKU labeling, carton requirements, and Amazon's strict compliance standards. FBA prep costs $0.50-$1.00 per unit."
    },
    {
      question: "What certifications are required for selling clothing in USA?",
      answer: "We provide OEKO-TEX Standard 100 (textile safety), CPSC compliance (Consumer Product Safety Commission), California Prop 65 certificates (if applicable), Fiber content labels (FTC rules), and Country of Origin labels ('Made in Bangladesh'). All certifications are USA-compliant."
    },
    {
      question: "Do you offer DDP (Delivered Duty Paid) shipping to USA?",
      answer: "Yes! We offer both FOB (you arrange customs) and DDP (we handle everything including duties, taxes, delivery to your door). DDP pricing includes all costs except local taxes. Popular for small businesses who want hassle-free delivery."
    },
    {
      question: "How much can I save importing from Bangladesh vs China?",
      answer: "Bangladesh offers 15-32% duty savings under GSP (duty-free access). Labor costs are 20-30% lower than China. Overall savings: 25-40% on total landed costs. Example: A hoodie costing $18 from China costs $12-13 from Bangladesh (including shipping)."
    },
    {
      question: "What payment terms do you offer for USA buyers?",
      answer: "First order: 50% deposit via wire transfer, 50% before shipping. After 2-3 successful orders: 30% deposit, 70% net 30 days. We accept USD wire transfers to our USA correspondent bank for easy payments."
    },
    {
      question: "Do you comply with USA labor and ethical standards?",
      answer: "Yes! We're BSCI certified (ethical production), WRAP certified (workplace safety), and comply with USA import requirements for ethical sourcing. We provide full transparency on wages, working conditions, and factory audits."
    },
    {
      question: "Can you provide USA sizing and fit standards?",
      answer: "Absolutely! We understand USA sizing runs larger than Asian standards. We'll adjust patterns to match USA fit expectations (regular, slim, oversized). We provide detailed size charts in inches and offer fit samples before bulk production."
    }
  ];

  const schemas = [
    organizationSchema,
    productSchema({
      name: "Bangladesh to USA Clothing Export Service",
      description: "Direct clothing export from Bangladesh to USA. Duty-free GSP benefits, OEKO-TEX certified, Amazon FBA support, DDP shipping available. 15-32% cost savings vs China.",
      minPrice: "3.50",
      maxPrice: "18.00"
    }),
    faqSchema(faqs),
    breadcrumbSchema([
      { name: "Home", url: "https://sleekapparels.com" },
      { name: "Bangladesh USA Export", url: "https://sleekapparels.com/bangladesh-clothing-manufacturer-usa-export" }
    ])
  ];

  return (
    <>
      <SEO
        title="Bangladesh Clothing Manufacturer USA Export | Duty-Free GSP Benefits"
        description="Export clothing from Bangladesh to USA with duty-free GSP benefits. Save 25-40% vs China. OEKO-TEX certified, Amazon FBA support, DDP shipping. 50-piece MOQ. Get USA customs help."
        canonical="https://sleekapparels.com/bangladesh-clothing-manufacturer-usa-export"
        keywords="Bangladesh clothing manufacturer USA, Bangladesh apparel export, duty-free GSP, import from Bangladesh, USA clothing supplier, Bangladesh to USA shipping"
        schema={schemas}
        ogImage="https://sleekapparels.com/images/usa-export-shipping.jpg"
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
                <span>Bangladesh to USA Clothing Export</span>
              </nav>
              
              <h1 className="text-4xl md:text-5xl font-bold mb-6 leading-tight">
                Bangladesh Clothing Manufacturer for USA Export: Save 25-40% with Duty-Free GSP
              </h1>
              
              <p className="text-xl mb-8 opacity-95 leading-relaxed">
                <strong>Direct export from Bangladesh to USA with duty-free GSP benefits.</strong> OEKO-TEX certified, 
                Amazon FBA support, DDP shipping available. 50-piece MOQ. Save 15-32% on import duties vs China.
              </p>
              
              <div className="flex flex-wrap gap-4 mb-8">
                <div className="flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-2 rounded-lg">
                  <DollarSign className="h-5 w-5" />
                  <span className="font-semibold">Save 25-40% vs China</span>
                </div>
                <div className="flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-2 rounded-lg">
                  <Ship className="h-5 w-5" />
                  <span className="font-semibold">7-10 Days Air Freight</span>
                </div>
                <div className="flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-2 rounded-lg">
                  <FileCheck className="h-5 w-5" />
                  <span className="font-semibold">Full USA Compliance</span>
                </div>
              </div>
              
              <div className="flex flex-wrap gap-4">
                <Button size="lg" variant="secondary" asChild>
                  <Link to="/contact">Get USA Export Quote</Link>
                </Button>
                <Button size="lg" variant="outline" className="bg-white/10 border-white text-white hover:bg-white/20" asChild>
                  <Link to="/samples">Order USA-Sized Samples</Link>
                </Button>
              </div>
            </div>
          </div>
        </section>

        {/* GSP Benefits */}
        <section className="py-16 bg-gray-50">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-4">Why Import from Bangladesh vs China?</h2>
            <p className="text-center text-gray-600 mb-12 max-w-2xl mx-auto">
              Bangladesh offers significant cost advantages for USA importers
            </p>
            <div className="grid md:grid-cols-3 gap-6 max-w-5xl mx-auto">
              {[
                { 
                  title: "Duty-Free GSP Access", 
                  desc: "Save 15-32% on import duties under USA's Generalized System of Preferences. T-shirts that cost $5 duty from China = $0 duty from Bangladesh.",
                  icon: DollarSign 
                },
                { 
                  title: "Lower Labor Costs", 
                  desc: "Bangladesh labor costs are 20-30% lower than China. This translates to 15-25% lower product costs without compromising quality.",
                  icon: Globe 
                },
                { 
                  title: "USA Compliance Ready", 
                  desc: "OEKO-TEX, CPSC, Prop 65, FTC labeling - we handle all USA import requirements. Your products arrive ready for sale.",
                  icon: Shield 
                }
              ].map((benefit, i) => (
                <div key={i} className="bg-white p-6 rounded-xl shadow-sm hover:shadow-md transition">
                  <benefit.icon className="h-10 w-10 text-primary mb-4" />
                  <h3 className="font-bold text-lg mb-2">{benefit.title}</h3>
                  <p className="text-gray-600 leading-relaxed">{benefit.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Cost Comparison */}
        <section className="py-16">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">Bangladesh vs China: Landed Cost Comparison</h2>
            <div className="max-w-4xl mx-auto">
              <div className="grid md:grid-cols-2 gap-6">
                {/* China Costs */}
                <div className="border-2 border-gray-300 rounded-xl p-6">
                  <h3 className="text-2xl font-bold mb-6 text-center">Import from China</h3>
                  <div className="space-y-3">
                    <div className="flex justify-between pb-2 border-b">
                      <span>Product Cost (Hoodie)</span>
                      <span className="font-semibold">$15.00</span>
                    </div>
                    <div className="flex justify-between pb-2 border-b">
                      <span>Sea Freight (per unit)</span>
                      <span className="font-semibold">$1.50</span>
                    </div>
                    <div className="flex justify-between pb-2 border-b">
                      <span>USA Import Duty (16.5%)</span>
                      <span className="font-semibold text-red-600">$2.72</span>
                    </div>
                    <div className="flex justify-between pb-2 border-b">
                      <span>Customs Clearance</span>
                      <span className="font-semibold">$0.50</span>
                    </div>
                    <div className="flex justify-between pt-3 text-lg">
                      <span className="font-bold">Total Landed Cost</span>
                      <span className="font-bold text-2xl">$19.72</span>
                    </div>
                  </div>
                </div>

                {/* Bangladesh Costs */}
                <div className="border-2 border-primary rounded-xl p-6 bg-primary/5">
                  <h3 className="text-2xl font-bold mb-6 text-center text-primary">Import from Bangladesh</h3>
                  <div className="space-y-3">
                    <div className="flex justify-between pb-2 border-b">
                      <span>Product Cost (Hoodie)</span>
                      <span className="font-semibold">$12.00</span>
                    </div>
                    <div className="flex justify-between pb-2 border-b">
                      <span>Sea Freight (per unit)</span>
                      <span className="font-semibold">$1.80</span>
                    </div>
                    <div className="flex justify-between pb-2 border-b">
                      <span>USA Import Duty (GSP)</span>
                      <span className="font-semibold text-green-600">$0.00</span>
                    </div>
                    <div className="flex justify-between pb-2 border-b">
                      <span>Customs Clearance</span>
                      <span className="font-semibold">$0.50</span>
                    </div>
                    <div className="flex justify-between pt-3 text-lg">
                      <span className="font-bold">Total Landed Cost</span>
                      <span className="font-bold text-2xl text-primary">$14.30</span>
                    </div>
                  </div>
                  <div className="mt-6 bg-green-50 p-4 rounded-lg">
                    <p className="text-center font-bold text-green-800">YOU SAVE: $5.42/unit (27.5%)</p>
                    <p className="text-center text-sm text-green-700 mt-2">On 1,000 units = $5,420 savings!</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Shipping Options */}
        <section className="py-16 bg-gray-50">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">Bangladesh to USA Shipping Options</h2>
            <div className="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
              <div className="bg-white p-6 rounded-xl shadow-sm">
                <Plane className="h-12 w-12 text-primary mb-4" />
                <h3 className="text-2xl font-bold mb-4">Air Freight</h3>
                <p className="text-gray-600 mb-4">Best for urgent orders, samples, and small batches (50-500 pieces)</p>
                <ul className="space-y-3 mb-6">
                  <li className="flex items-start gap-2">
                    <Check className="h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
                    <span><strong>Transit:</strong> 7-10 days door-to-door</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <Check className="h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
                    <span><strong>Cost:</strong> $4.50-$6.00 per kg</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <Check className="h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
                    <span><strong>Carriers:</strong> DHL, FedEx, UPS</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <Check className="h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
                    <span><strong>Tracking:</strong> Real-time GPS tracking</span>
                  </li>
                </ul>
                <p className="text-primary font-bold">Example: 100 hoodies = $450-600 shipping</p>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-sm">
                <Ship className="h-12 w-12 text-primary mb-4" />
                <h3 className="text-2xl font-bold mb-4">Sea Freight</h3>
                <p className="text-gray-600 mb-4">Best for large orders (500+ pieces) and cost-conscious buyers</p>
                <ul className="space-y-3 mb-6">
                  <li className="flex items-start gap-2">
                    <Check className="h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
                    <span><strong>Transit:</strong> 18-25 days (East Coast), 25-30 days (West Coast)</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <Check className="h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
                    <span><strong>Cost:</strong> $1.20-$2.00 per kg (4x cheaper than air)</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <Check className="h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
                    <span><strong>Ports:</strong> NY, Savannah, Miami, LA, Oakland</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <Check className="h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
                    <span><strong>Carriers:</strong> Maersk, MSC, CMA CGM</span>
                  </li>
                </ul>
                <p className="text-primary font-bold">Example: 1,000 hoodies = $1,200-2,000 shipping</p>
              </div>
            </div>
          </div>
        </section>

        {/* USA Compliance */}
        <section className="py-16">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">Complete USA Import Compliance</h2>
            <div className="max-w-4xl mx-auto">
              <div className="grid md:grid-cols-2 gap-6">
                {[
                  { title: "Customs Documentation", items: ["Commercial Invoice", "Packing List with HS codes", "Bill of Lading / Airway Bill", "Certificate of Origin (Form A for GSP)", "Manufacturer's affidavit"] },
                  { title: "Safety Certifications", items: ["OEKO-TEX Standard 100 (textile safety)", "CPSC compliance (Consumer Product Safety)", "California Prop 65 (if applicable)", "Flammability testing (16 CFR 1610)", "Lead testing for children's wear"] },
                  { title: "Labeling Requirements", items: ["Fiber content labels (FTC rules)", "Country of Origin ('Made in Bangladesh')", "Care instruction labels", "RN number (if required)", "Size labels (USA sizing)"] },
                  { title: "Ethical Compliance", items: ["BSCI ethical production certificate", "WRAP workplace safety certificate", "Factory audit reports available", "No forced labor declaration", "Living wage compliance"] }
                ].map((section, i) => (
                  <div key={i} className="bg-gray-50 p-6 rounded-xl">
                    <h3 className="font-bold text-xl mb-4 text-primary">{section.title}</h3>
                    <ul className="space-y-2">
                      {section.items.map((item, j) => (
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

        {/* CTA */}
        <section className="py-16 bg-gradient-to-br from-primary to-secondary text-white">
          <div className="container mx-auto px-4 text-center">
            <h2 className="text-3xl md:text-4xl font-bold mb-6">Ready to Save 25-40% on USA Imports?</h2>
            <p className="text-xl mb-8 opacity-95 max-w-2xl mx-auto">
              Start importing directly from Bangladesh with duty-free GSP benefits. Get free landed cost analysis for your products.
            </p>
            <div className="flex flex-wrap gap-4 justify-center">
              <Button size="lg" variant="secondary" asChild>
                <Link to="/contact">Get Landed Cost Analysis</Link>
              </Button>
              <Button size="lg" variant="outline" className="bg-white/10 border-white text-white hover:bg-white/20" asChild>
                <Link to="/samples">Order USA-Compliant Samples</Link>
              </Button>
            </div>
          </div>
        </section>

        {/* FAQs */}
        <section className="py-16">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">USA Import FAQs</h2>
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
