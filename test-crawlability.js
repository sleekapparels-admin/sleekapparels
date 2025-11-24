// Googlebot Simulation Test
// This script tests if pages are fully rendered server-side without JavaScript

const fs = require('fs');
const path = require('path');

const testRoutes = [
  '/',
  '/services',
  '/products',
  '/products/t-shirts',
  '/contact',
  '/faq',
  '/certifications',
  '/portfolio',
  '/blog',
];

console.log('🤖 Googlebot Crawlability Test\n');
console.log('Testing static HTML generation (no JavaScript execution)...\n');

const outDir = path.join(__dirname, 'out');
let allPassed = true;

testRoutes.forEach(route => {
  const filePath = route === '/' 
    ? path.join(outDir, 'index.html')
    : path.join(outDir, route.substring(1), 'index.html');
  
  console.log(`Testing: ${route}`);
  
  try {
    const html = fs.readFileSync(filePath, 'utf-8');
    
    // Test 1: HTML file exists and has content
    if (html.length < 1000) {
      console.log(`  ❌ FAIL: HTML content too short (${html.length} bytes)`);
      allPassed = false;
      return;
    }
    console.log(`  ✓ HTML exists (${(html.length / 1024).toFixed(1)}KB)`);
    
    // Test 2: Contains actual content (not just skeleton)
    const hasMainContent = html.includes('Sleek Apparels');
    if (!hasMainContent) {
      console.log('  ❌ FAIL: Missing main content');
      allPassed = false;
      return;
    }
    console.log('  ✓ Main content present');
    
    // Test 3: Has structured data (JSON-LD)
    const hasStructuredData = html.includes('application/ld+json');
    if (!hasStructuredData) {
      console.log('  ❌ FAIL: Missing structured data');
      allPassed = false;
      return;
    }
    console.log('  ✓ Structured data (JSON-LD) present');
    
    // Test 4: Has meta tags
    const hasMetaTags = html.includes('<meta name="description"');
    if (!hasMetaTags) {
      console.log('  ❌ FAIL: Missing meta description');
      allPassed = false;
      return;
    }
    console.log('  ✓ Meta tags present');
    
    // Test 5: Has Open Graph tags
    const hasOgTags = html.includes('og:title');
    if (!hasOgTags) {
      console.log('  ❌ FAIL: Missing Open Graph tags');
      allPassed = false;
      return;
    }
    console.log('  ✓ Open Graph tags present');
    
    // Test 6: Content is in HTML (not loaded via JS)
    const contentPatterns = {
      '/': ['Low MOQ Clothing Manufacturer', 'Bangladesh', 'OEKO-TEX'],
      '/services': ['Manufacturing Services', 'Custom Design'],
      '/products': ['Custom T-Shirts', 'Hoodies', 'Activewear'],
      '/products/t-shirts': ['T-Shirt Manufacturer', 'MOQ 50', 'GSM'],
      '/contact': ['Contact Us', 'Get in Touch'],
      '/faq': ['Frequently Asked Questions', 'minimum order quantity'],
      '/certifications': ['OEKO-TEX', 'BSCI', 'WRAP'],
      '/portfolio': ['Portfolio', 'Past Projects'],
      '/blog': ['Blog', 'Manufacturing'],
    };
    
    const patterns = contentPatterns[route] || [];
    const missingPatterns = patterns.filter(p => !html.includes(p));
    
    if (missingPatterns.length > 0) {
      console.log(`  ❌ FAIL: Missing content patterns: ${missingPatterns.join(', ')}`);
      allPassed = false;
      return;
    }
    console.log(`  ✓ All content patterns found (${patterns.length} checked)`);
    
    console.log(`  ✅ PASS: ${route} is fully crawlable\n`);
    
  } catch (error) {
    console.log(`  ❌ FAIL: ${error.message}\n`);
    allPassed = false;
  }
});

console.log('═'.repeat(60));
if (allPassed) {
  console.log('✅ ALL TESTS PASSED');
  console.log('🎉 Website is fully crawlable by Googlebot without JavaScript');
  console.log('🔍 All content is server-side rendered in HTML');
  process.exit(0);
} else {
  console.log('❌ SOME TESTS FAILED');
  console.log('⚠️  Please review failures above');
  process.exit(1);
}
