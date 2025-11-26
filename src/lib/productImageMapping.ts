/**
 * Product Image Mapping System
 * Direct ID-based mapping for accurate product-to-image associations
 * This replaces the fuzzy keyword matching system
 */

// Import existing portfolio images as placeholders until real product images are uploaded
import poloNavy from "@/assets/portfolio/white/polo-navy.webp";
import poloBlack from "@/assets/portfolio/white/polo-black.webp";
import poloWhite from "@/assets/portfolio/white/polo-white.webp";
import sweaterCamel from "@/assets/portfolio/white/sweater-camel.webp";
import sweaterGrey from "@/assets/portfolio/white/sweater-grey.webp";
import cardiganRed from "@/assets/portfolio/white/cardigan-red.webp";
import cardiganNavy from "@/assets/portfolio/white/cardigan-navy.webp";
import vestGreen from "@/assets/portfolio/white/vest-green.webp";
import vestCream from "@/assets/portfolio/white/vest-cream.webp";
import shirtOxfordBlue from "@/assets/portfolio/white/shirt-oxford-blue.webp";
import hoodieTech from "@/assets/portfolio/white/hoodie-tech.webp";
import schoolUniformPolo from "@/assets/portfolio/white/school-uniform-polo.webp";
import schoolUniformSet from "@/assets/portfolio/white/school-uniform-set.webp";
import sportsJerseyBasketball from "@/assets/portfolio/white/sports-jersey-basketball.webp";
import sportsJerseySoccer from "@/assets/portfolio/white/sports-jersey-soccer.webp";
import beanieBlack from "@/assets/portfolio/white/beanie-black.webp";

/**
 * Direct product ID to image URL mapping
 * Keys are exact product IDs from the database
 * Values are imported image paths (local assets)
 */
export const productImageMap: Record<string, string> = {
  // T-Shirts
  'classic-crew-neck-tshirt': poloWhite, // Placeholder - awaiting upload
  'premium-vneck-tshirt': poloWhite,
  'long-sleeve-tshirt': poloNavy,
  'organic-cotton-tshirt': poloWhite,
  'performance-athletic-tshirt': poloBlack,
  'pocket-tshirt': poloWhite,
  
  // Hoodies & Sweatshirts
  'classic-pullover-hoodie': hoodieTech,
  'zip-up-hoodie': hoodieTech,
  'crewneck-sweatshirt': sweaterGrey,
  'oversized-hoodie': hoodieTech,
  'cropped-hoodie': hoodieTech,
  'raglan-sleeve-hoodie': sweaterCamel,
  'sherpa-lined-hoodie': sweaterCamel,
  
  // Polo Shirts
  'classic-pique-polo': poloNavy,
  'performance-polo': poloBlack,
  'long-sleeve-polo': poloNavy,
  'ladies-fit-polo': poloWhite,
  
  // Activewear
  'french-terry-joggers': vestGreen, // Placeholder - awaiting upload
  'athletic-track-pants': vestCream,
  'performance-shorts': vestGreen,
  'high-waist-leggings': vestCream,
  'sports-bra': vestCream,
  
  // Uniforms
  'corporate-polo-uniform': schoolUniformPolo,
  'school-tshirt-uniform': schoolUniformSet,
  'sports-team-jersey': sportsJerseyBasketball,
  
  // Legacy/Generic fallbacks
  'tshirt-navy-crew': poloNavy,
  'hoodie-black-pullover': hoodieTech,
  'polo-white': poloWhite,
  'polo-navy': poloNavy,
  'polo-black': poloBlack,
};

/**
 * Category-based fallback images
 */
const categoryFallbacks: Record<string, string> = {
  'tshirts': poloWhite,
  't-shirts': poloWhite,
  'hoodies': hoodieTech,
  'sweatshirts': sweaterGrey,
  'polos': poloNavy,
  'polo-shirts': poloNavy,
  'activewear': vestGreen,
  'joggers': vestGreen,
  'uniforms': schoolUniformPolo,
  'accessories': beanieBlack,
};

/**
 * Get product image by exact ID match
 * Falls back to category-based image if ID not found
 * Returns placeholder if nothing matches
 */
export function getProductImage(productId: string, category?: string): string {
  // Direct ID match (highest priority)
  if (productImageMap[productId]) {
    return productImageMap[productId];
  }
  
  // Category fallback (medium priority)
  if (category) {
    const normalizedCategory = category.toLowerCase().trim();
    if (categoryFallbacks[normalizedCategory]) {
      return categoryFallbacks[normalizedCategory];
    }
  }
  
  // Default fallback (lowest priority)
  return poloWhite;
}

/**
 * Get multiple product images for gallery/showcase
 * Returns diverse set of images from different categories
 */
export function getShowcaseImages(count: number = 12): Array<{ url: string; alt: string; category: string }> {
  return [
    { url: poloNavy, alt: 'Navy Blue Polo Shirt', category: 'polos' },
    { url: hoodieTech, alt: 'Technical Pullover Hoodie', category: 'hoodies' },
    { url: poloWhite, alt: 'White Classic T-Shirt', category: 'tshirts' },
    { url: sweaterGrey, alt: 'Grey Crewneck Sweatshirt', category: 'sweatshirts' },
    { url: poloBlack, alt: 'Black Performance Polo', category: 'polos' },
    { url: cardiganRed, alt: 'Red Cardigan', category: 'knitwear' },
    { url: vestGreen, alt: 'Green Athletic Vest', category: 'activewear' },
    { url: schoolUniformPolo, alt: 'School Uniform Polo', category: 'uniforms' },
    { url: sweaterCamel, alt: 'Camel Brown Sweater', category: 'knitwear' },
    { url: shirtOxfordBlue, alt: 'Blue Oxford Shirt', category: 'shirts' },
    { url: sportsJerseyBasketball, alt: 'Basketball Team Jersey', category: 'uniforms' },
    { url: beanieBlack, alt: 'Black Knit Beanie', category: 'accessories' },
  ].slice(0, count);
}

/**
 * Portfolio gallery images (for homepage showcase)
 */
export function getPortfolioGalleryImages(): Array<{ url: string; alt: string }> {
  return getShowcaseImages(12).map(img => ({ url: img.url, alt: img.alt }));
}
