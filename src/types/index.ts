export interface UserProfile {
  id: string;
  name: string;
  email: string;
  phone: string;
  birthdate: string;
  isPremium: boolean;
  avatarUrl?: string;
}

export interface UserMeasurements {
  height: number; // cm
  weight: number; // kg
  waist: number;  // inches
  chest: number;  // inches
  hips: number;   // inches
  updatedAt: string;
}

export type ProductCategory = "ทั้งหมด" | "เสื้อ" | "กางเกง" | "รองเท้า" | "กระเป๋า";

export interface ProductItem {
  id: string;
  name: string;
  category: "เสื้อ" | "กางเกง" | "รองเท้า" | "กระเป๋า";
  price: number;
  imageUrl: string;
  badge?: string;
  description: string;
  sizes: string[];
  recommendedSize?: string;
}

export interface SavedStyle {
  id: string;
  title: string;
  tags: string[];
  imageUrl: string;
  isStarred: boolean;
  items: {
    icon: string;
    name: string;
    category: string;
  }[];
  recommendedPlace: {
    name: string;
    description: string;
    imageUrl: string;
  };
}
