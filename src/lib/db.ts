import fs from "fs";
import path from "path";
import { UserProfile, UserMeasurements, ProductItem, SavedStyle } from "@/types";

const DB_DIR = path.join(process.cwd(), "data");
const DB_FILE = path.join(DB_DIR, "app-database.json");

export interface DatabaseSchema {
  profile: UserProfile;
  measurements: UserMeasurements;
  products: ProductItem[];
  savedStyles: SavedStyle[];
  todayOutfit: {
    title: string;
    dateText: string;
    imageUrl: string;
    items: { icon: string; name: string }[];
    recommendedPlace: {
      name: string;
      badge: string;
      description: string;
      imageUrl: string;
    };
  };
}

const DEFAULT_DATA: DatabaseSchema = {
  profile: {
    id: "user_001",
    name: "สมชาย ใจดี",
    email: "somchai@email.com",
    phone: "081-234-5678",
    birthdate: "15 มีนาคม 2538",
    isPremium: true,
    avatarUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80",
  },
  measurements: {
    height: 175,
    weight: 68,
    waist: 32,
    chest: 38,
    hips: 36,
    updatedAt: new Date().toISOString(),
  },
  products: [
    {
      id: "prod_01",
      name: "เสื้อคลุมยีนส์ Oversized",
      category: "เสื้อ",
      price: 1290,
      imageUrl: "https://images.unsplash.com/photo-1576995853123-5a10305d93c0?auto=format&fit=crop&w=600&q=80",
      description: "เสื้อยีนส์ฟอกนุ่ม ทรงหลวม Oversized แมทช์ง่าย เหมาะกับลุคสตรีทและ Urban Casual",
      sizes: ["S", "M", "L", "XL"],
      recommendedSize: "L",
    },
    {
      id: "prod_02",
      name: "Chinos สีกากี Slim Fit",
      category: "กางเกง",
      price: 990,
      imageUrl: "https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=600&q=80",
      description: "กางเกงชิโน่ผ้าคอตตอนยืดหยุ่น ทรงเข้ารูปพอดีตัว สวมใส่สบายตลอดทั้งวัน",
      sizes: ["30", "32", "34", "36"],
      recommendedSize: "32",
    },
    {
      id: "prod_03",
      name: "รองเท้า Loafer หนัง",
      category: "รองเท้า",
      price: 2590,
      imageUrl: "https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?auto=format&fit=crop&w=600&q=80",
      description: "รองเท้าโลฟเฟอร์หนังแท้เกรดพรีเมียม สไตล์ Penny Loafer ใส่ได้ทั้งลุคทำงานและลำลอง",
      sizes: ["40", "41", "42", "43"],
      recommendedSize: "42",
    },
    {
      id: "prod_04",
      name: "เสื้อ Linen ครีม",
      category: "เสื้อ",
      price: 890,
      imageUrl: "https://images.unsplash.com/photo-1598033129183-c4f50c736f10?auto=format&fit=crop&w=600&q=80",
      description: "เสื้อเชิ้ตลินินธรรมชาติ ระบายอากาศได้ดีเยี่ยม สัมผัสนุ่ม สีครีมมินิมอลสบายตา",
      sizes: ["M", "L", "XL"],
      recommendedSize: "L",
    },
    {
      id: "prod_05",
      name: "กระเป๋าสะพายหนัง GG Classic",
      category: "กระเป๋า",
      price: 4990,
      imageUrl: "https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=600&q=80",
      description: "กระเป๋าสะพายข้างหนังควิลท์สีดำ อะไหล่ทองหรูหรา แมทช์ได้ทุกลุค",
      sizes: ["Free Size"],
      recommendedSize: "Free Size",
    },
    {
      id: "prod_06",
      name: "เสื้อไหมพรม Knit คอกลม",
      category: "เสื้อ",
      price: 1190,
      imageUrl: "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?auto=format&fit=crop&w=600&q=80",
      description: "เสื้อสเวตเตอร์ไหมพรมเนื้อนุ่ม ทรง Relaxed สไตล์เกาหลี เรียบหรู",
      sizes: ["M", "L", "XL"],
      recommendedSize: "L",
    },
    {
      id: "prod_07",
      name: "กางเกงผ้า Wide Leg",
      category: "กางเกง",
      price: 1350,
      imageUrl: "https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=600&q=80",
      description: "กางเกงขากว้างสไตล์ Minimalist ทิ้งตัวสวย ใส่แล้วดูสูงโปร่ง",
      sizes: ["S", "M", "L"],
      recommendedSize: "M",
    },
    {
      id: "prod_08",
      name: "รองเท้า Mule หนังกลับ",
      category: "รองเท้า",
      price: 1890,
      imageUrl: "https://images.unsplash.com/photo-1560769629-975ec94e6a86?auto=format&fit=crop&w=600&q=80",
      description: "รองเท้าเปิดส้นหนังกลับ สวมใส่ง่าย เข้ากับวันสบายๆ วันหยุดสุดสัปดาห์",
      sizes: ["41", "42", "43"],
      recommendedSize: "42",
    },
  ],
  savedStyles: [
    {
      id: "style_01",
      title: "ลุค Urban Casual",
      tags: ["Casual", "Office"],
      imageUrl: "https://images.unsplash.com/photo-1516257984-b1b4d707412e?auto=format&fit=crop&w=800&q=80",
      isStarred: true,
      items: [
        { icon: "shirt", name: "เสื้อคลุมยีนส์", category: "เสื้อ" },
        { icon: "trousers", name: "Chinos สีกากี", category: "กางเกง" },
        { icon: "footprints", name: "รองเท้า Loafer", category: "รองเท้า" },
      ],
      recommendedPlace: {
        name: "คาเฟ่ 'The Glasshouse'",
        description: "เหมาะกับชุด Urban Casual ของคุณในวันนี้",
        imageUrl: "https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80",
      },
    },
    {
      id: "style_02",
      title: "ลุค Soft Beige",
      tags: ["Minimal", "Weekend"],
      imageUrl: "https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?auto=format&fit=crop&w=800&q=80",
      isStarred: true,
      items: [
        { icon: "shirt", name: "เสื้อ Linen ครีม", category: "เสื้อ" },
        { icon: "trousers", name: "กางเกงผ้า Wide Leg", category: "กางเกง" },
        { icon: "footprints", name: "รองเท้า Mule", category: "รองเท้า" },
      ],
      recommendedPlace: {
        name: "Art Gallery & Specialty Coffee",
        description: "สไตล์มินิมอลสบายตา เหมาะกับวันเสพงานศิลป์และดื่มกาแฟชิลๆ",
        imageUrl: "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80",
      },
    },
  ],
  todayOutfit: {
    title: "แนะนำชุดวันนี้",
    dateText: "วันพฤหัสบดี, 24 กันยายน 2569",
    imageUrl: "https://images.unsplash.com/photo-1516257984-b1b4d707412e?auto=format&fit=crop&w=800&q=80",
    items: [
      { icon: "shirt", name: "เสื้อคลุมยีนส์/แจ็คเก็ต" },
      { icon: "trousers", name: "Chinos สีกากี" },
      { icon: "footprints", name: "รองเท้า Loafer" },
    ],
    recommendedPlace: {
      name: "คาเฟ่ 'The Glasshouse'",
      badge: "The Glasshouse",
      description: "เหมาะกับชุด Urban Casual ของคุณในวันนี้",
      imageUrl: "https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80",
    },
  },
};

// Helper to ensure database file exists
function readDb(): DatabaseSchema {
  try {
    if (!fs.existsSync(DB_DIR)) {
      fs.mkdirSync(DB_DIR, { recursive: true });
    }
    if (!fs.existsSync(DB_FILE)) {
      fs.writeFileSync(DB_FILE, JSON.stringify(DEFAULT_DATA, null, 2), "utf-8");
      return DEFAULT_DATA;
    }
    const content = fs.readFileSync(DB_FILE, "utf-8");
    return JSON.parse(content);
  } catch (err) {
    console.error("Error reading database:", err);
    return DEFAULT_DATA;
  }
}

function writeDb(data: DatabaseSchema): boolean {
  try {
    if (!fs.existsSync(DB_DIR)) {
      fs.mkdirSync(DB_DIR, { recursive: true });
    }
    fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2), "utf-8");
    return true;
  } catch (err) {
    console.error("Error writing database:", err);
    return false;
  }
}

export const db = {
  getProfile: (): UserProfile => {
    return readDb().profile;
  },
  updateProfile: (profile: Partial<UserProfile>): UserProfile => {
    const data = readDb();
    data.profile = { ...data.profile, ...profile };
    writeDb(data);
    return data.profile;
  },

  getMeasurements: (): UserMeasurements => {
    return readDb().measurements;
  },
  updateMeasurements: (measurements: Partial<UserMeasurements>): UserMeasurements => {
    const data = readDb();
    data.measurements = {
      ...data.measurements,
      ...measurements,
      updatedAt: new Date().toISOString(),
    };
    writeDb(data);
    return data.measurements;
  },

  getProducts: (category?: string, query?: string): ProductItem[] => {
    let list = readDb().products;
    if (category && category !== "ทั้งหมด") {
      list = list.filter((p) => p.category === category);
    }
    if (query && query.trim() !== "") {
      const q = query.toLowerCase();
      list = list.filter((p) => p.name.toLowerCase().includes(q) || p.description.toLowerCase().includes(q));
    }
    return list;
  },

  getSavedStyles: (): SavedStyle[] => {
    return readDb().savedStyles;
  },
  toggleStarStyle: (id: string): SavedStyle[] => {
    const data = readDb();
    data.savedStyles = data.savedStyles.map((s) => {
      if (s.id === id) {
        return { ...s, isStarred: !s.isStarred };
      }
      return s;
    });
    writeDb(data);
    return data.savedStyles;
  },
  addSavedStyle: (style: Omit<SavedStyle, "id">): SavedStyle => {
    const data = readDb();
    const newStyle: SavedStyle = {
      ...style,
      id: `style_${Date.now()}`,
    };
    data.savedStyles.unshift(newStyle);
    writeDb(data);
    return newStyle;
  },

  getTodayOutfit: () => {
    return readDb().todayOutfit;
  },
  updateTodayOutfit: (outfit: DatabaseSchema["todayOutfit"]) => {
    const data = readDb();
    data.todayOutfit = outfit;
    writeDb(data);
    return data.todayOutfit;
  },

};
