"use client";

import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  MapPin,
  Star,
  Edit3,
  Shirt,
  ShoppingBag,
  ExternalLink,
  ChevronRight,
  Coffee,
} from "lucide-react";
import { UserProfile, UserMeasurements, SavedStyle } from "@/types";

interface HomeScreenProps {
  profile: UserProfile;
  measurements: UserMeasurements;
  onEditMeasurements: () => void;
  onNavigateTab: (tab: "search" | "wardrobe" | "profile") => void;
  onSaveStyle?: (style: any) => void;
}

export const HomeScreen: React.FC<HomeScreenProps> = ({
  profile,
  measurements,
  onEditMeasurements,
  onNavigateTab,
}) => {
  const [viewMode, setViewMode] = useState<"combined" | "pieces">("combined");
  const [isSaved, setIsSaved] = useState(false);
  const [showToast, setShowToast] = useState<string | null>(null);

  const triggerToast = (msg: string) => {
    setShowToast(msg);
    setTimeout(() => setShowToast(null), 2500);
  };

  const handleShopOutfit = () => {
    setIsSaved(true);
    triggerToast("✨ บันทึกชุด 'Urban Casual' ลงในตู้เสื้อผ้าแล้ว!");
  };

  return (
    <div className="pb-28 pt-2 px-4 space-y-4 max-w-[430px] mx-auto">
      {/* Toast Notification */}
      <AnimatePresence>
        {showToast && (
          <motion.div
            initial={{ opacity: 0, y: -20, scale: 0.9 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -20, scale: 0.9 }}
            className="fixed top-12 left-1/2 -translate-x-1/2 z-50 bg-brand-cocoa text-[#F7F2EC] px-4 py-2.5 rounded-2xl shadow-xl text-xs font-medium border border-brand-terracotta/40 flex items-center gap-2"
          >
            <span>{showToast}</span>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Header Greeting */}
      <motion.div
        initial={{ opacity: 0, y: -10 }}
        animate={{ opacity: 1, y: 0 }}
        className="pt-2 px-1"
      >
        <div className="flex items-center justify-between">
          <p className="text-xs text-[#847367] font-medium tracking-wide">
            วันพฤหัสบดี, 24 กันยายน 2569
          </p>
        </div>
        <h1 className="text-2xl font-bold text-brand-textDark mt-0.5 tracking-tight">
          สวัสดี, {profile.name}
        </h1>
      </motion.div>

      {/* Card 1: แนะนำชุดวันนี้ */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4 }}
        className="bg-white rounded-3xl p-4 shadow-card border border-brand-border/40"
      >
        {/* Card Header & Toggle */}
        <div className="flex items-center justify-between mb-3.5">
          <div className="flex items-center gap-1.5 text-brand-terracotta font-bold text-base">
            <MapPin size={18} className="fill-brand-terracotta/20 stroke-brand-terracotta" />
            <span>แนะนำชุดวันนี้</span>
          </div>

          {/* Toggle "รวม" / "ชิ้นส่วน" */}
          <div className="bg-brand-cream/80 p-0.5 rounded-xl flex items-center">
            <button
              onClick={() => setViewMode("combined")}
              className={`px-3 py-1 rounded-lg text-xs font-semibold transition-all ${
                viewMode === "combined"
                  ? "bg-brand-cocoa text-white shadow-sm"
                  : "text-brand-textMuted hover:text-brand-textDark"
              }`}
            >
              รวม
            </button>
            <button
              onClick={() => setViewMode("pieces")}
              className={`px-3 py-1 rounded-lg text-xs font-semibold transition-all ${
                viewMode === "pieces"
                  ? "bg-brand-cocoa text-white shadow-sm"
                  : "text-brand-textMuted hover:text-brand-textDark"
              }`}
            >
              ชิ้นส่วน
            </button>
          </div>
        </div>

        {/* Content based on view mode */}
        <AnimatePresence mode="wait">
          {viewMode === "combined" ? (
            <motion.div
              key="combined"
              initial={{ opacity: 0, scale: 0.98 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.98 }}
              transition={{ duration: 0.2 }}
            >
              <div className="grid grid-cols-2 gap-3 items-stretch">
                {/* Outfit Model Photo */}
                <div className="relative rounded-2xl overflow-hidden aspect-[3/4] bg-stone-100 shadow-inner">
                  <img
                    src="https://images.unsplash.com/photo-1516257984-b1b4d707412e?auto=format&fit=crop&w=600&q=80"
                    alt="Today's Recommended Outfit"
                    className="w-full h-full object-cover object-top hover:scale-105 transition-transform duration-500"
                  />
                  <div className="absolute top-2 left-2 px-2 py-0.5 bg-black/40 backdrop-blur-md rounded-md text-[10px] text-white font-medium">
                    Urban Casual
                  </div>
                </div>

                {/* Garment Items List */}
                <div className="flex flex-col justify-between py-1">
                  <div className="space-y-2">
                    {/* Item 1 */}
                    <div className="bg-[#FAF5EF] p-2.5 rounded-xl border border-brand-border/40 flex items-center gap-2">
                      <div className="text-brand-textDark text-sm">👕</div>
                      <span className="text-[11px] font-medium text-brand-textDark leading-tight">
                        เสื้อคลุมยีนส์/แจ็คเก็ต
                      </span>
                    </div>

                    {/* Item 2 */}
                    <div className="bg-[#FAF5EF] p-2.5 rounded-xl border border-brand-border/40 flex items-center gap-2">
                      <div className="text-brand-textDark text-sm">👖</div>
                      <span className="text-[11px] font-medium text-brand-textDark leading-tight">
                        Chinos สีกากี
                      </span>
                    </div>

                    {/* Item 3 */}
                    <div className="bg-[#FAF5EF] p-2.5 rounded-xl border border-brand-border/40 flex items-center gap-2">
                      <div className="text-brand-textDark text-sm">👞</div>
                      <span className="text-[11px] font-medium text-brand-textDark leading-tight">
                        รองเท้า Loafer
                      </span>
                    </div>
                  </div>

                  {/* CTA Button: ช้อปชุดนี้ */}
                  <div className="flex items-center gap-2 pt-2">
                    <button
                      onClick={() => setIsSaved(!isSaved)}
                      className="p-2.5 rounded-xl bg-brand-cream/60 hover:bg-brand-cream text-brand-terracotta transition-colors active:scale-95"
                    >
                      <Star
                        size={18}
                        className={isSaved ? "fill-brand-terracotta text-brand-terracotta" : ""}
                      />
                    </button>
                    <button
                      onClick={handleShopOutfit}
                      className="flex-1 py-2.5 px-3 bg-brand-terracotta hover:bg-brand-terracottaHover text-white font-bold text-xs rounded-xl shadow-sm transition-all active:scale-[0.98] flex items-center justify-center gap-1.5"
                    >
                      <span>ช้อปชุดนี้</span>
                    </button>
                  </div>
                </div>
              </div>
            </motion.div>
          ) : (
            <motion.div
              key="pieces"
              initial={{ opacity: 0, scale: 0.98 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.98 }}
              transition={{ duration: 0.2 }}
              className="space-y-2 pt-1"
            >
              {/* Piece 1 */}
              <div
                onClick={() => onNavigateTab("search")}
                className="flex items-center justify-between p-2.5 bg-brand-creamLight rounded-xl border border-brand-border/60 cursor-pointer hover:border-brand-terracotta/40 transition-colors"
              >
                <div className="flex items-center gap-3">
                  <img
                    src="https://images.unsplash.com/photo-1576995853123-5a10305d93c0?auto=format&fit=crop&w=200&q=80"
                    alt="Jacket"
                    className="w-12 h-12 rounded-lg object-cover"
                  />
                  <div>
                    <h4 className="text-xs font-bold text-brand-textDark">เสื้อคลุมยีนส์ Oversized</h4>
                    <p className="text-[11px] text-brand-terracotta font-semibold">฿1,290</p>
                  </div>
                </div>
                <ChevronRight size={16} className="text-brand-textMuted" />
              </div>

              {/* Piece 2 */}
              <div
                onClick={() => onNavigateTab("search")}
                className="flex items-center justify-between p-2.5 bg-brand-creamLight rounded-xl border border-brand-border/60 cursor-pointer hover:border-brand-terracotta/40 transition-colors"
              >
                <div className="flex items-center gap-3">
                  <img
                    src="https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=200&q=80"
                    alt="Chinos"
                    className="w-12 h-12 rounded-lg object-cover"
                  />
                  <div>
                    <h4 className="text-xs font-bold text-brand-textDark">Chinos สีกากี Slim Fit</h4>
                    <p className="text-[11px] text-brand-terracotta font-semibold">฿990</p>
                  </div>
                </div>
                <ChevronRight size={16} className="text-brand-textMuted" />
              </div>

              {/* Piece 3 */}
              <div
                onClick={() => onNavigateTab("search")}
                className="flex items-center justify-between p-2.5 bg-brand-creamLight rounded-xl border border-brand-border/60 cursor-pointer hover:border-brand-terracotta/40 transition-colors"
              >
                <div className="flex items-center gap-3">
                  <img
                    src="https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?auto=format&fit=crop&w=200&q=80"
                    alt="Loafers"
                    className="w-12 h-12 rounded-lg object-cover"
                  />
                  <div>
                    <h4 className="text-xs font-bold text-brand-textDark">รองเท้า Loafer หนังแท้</h4>
                    <p className="text-[11px] text-brand-terracotta font-semibold">฿2,590</p>
                  </div>
                </div>
                <ChevronRight size={16} className="text-brand-textMuted" />
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>

      {/* Card 2: สถานที่แนะนำวันนี้ */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4, delay: 0.1 }}
        className="bg-white rounded-3xl p-4 shadow-card border border-brand-border/40"
      >
        <div className="flex items-center gap-1.5 text-brand-terracotta font-bold text-base mb-3">
          <MapPin size={18} className="fill-brand-terracotta/20 stroke-brand-terracotta" />
          <span>สถานที่แนะนำวันนี้</span>
        </div>

        {/* Place Image Banner */}
        <div className="relative rounded-2xl overflow-hidden h-32 bg-stone-200 shadow-sm group cursor-pointer">
          <img
            src="https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80"
            alt="The Glasshouse Cafe"
            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent" />

          {/* Place Badge Tag */}
          <div className="absolute bottom-3 left-3 bg-black/60 backdrop-blur-md px-3 py-1.5 rounded-xl border border-white/20 flex items-center gap-1.5">
            <Coffee size={14} className="text-amber-300" />
            <span className="text-xs font-semibold text-white">คาเฟ่ 'The Glasshouse'</span>
          </div>
        </div>

        {/* Place Subtitle */}
        <p className="text-xs text-brand-textMuted mt-2.5 font-medium px-1">
          เหมาะกับชุด Urban Casual ของคุณในวันนี้
        </p>
      </motion.div>

      {/* Card 3: สัดส่วนของคุณ */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4, delay: 0.2 }}
        className="bg-white rounded-3xl p-4 shadow-card border border-brand-border/40"
      >
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <div className="text-brand-terracotta text-base">👤</div>
            <span className="font-bold text-base text-brand-textDark">สัดส่วนของคุณ</span>
          </div>

          <button
            onClick={onEditMeasurements}
            className="flex items-center gap-1 text-xs font-semibold text-brand-textMuted hover:text-brand-terracotta transition-colors active:scale-95"
          >
            <Edit3 size={14} />
            <span>แก้ไข</span>
          </button>
        </div>

        {/* 3 Metric Cards */}
        <div className="grid grid-cols-3 gap-2.5">
          {/* ส่วนสูง */}
          <div className="bg-[#FAF6F0] p-3 rounded-2xl text-center border border-brand-border/40">
            <span className="text-[11px] text-brand-textMuted font-medium block mb-0.5">ส่วนสูง</span>
            <div className="text-base font-bold text-brand-textDark">
              {measurements.height} <span className="text-xs font-medium text-brand-textMuted">ซม.</span>
            </div>
          </div>

          {/* รอบเอว */}
          <div className="bg-[#FAF6F0] p-3 rounded-2xl text-center border border-brand-border/40">
            <span className="text-[11px] text-brand-textMuted font-medium block mb-0.5">รอบเอว</span>
            <div className="text-base font-bold text-brand-textDark">
              {measurements.waist} <span className="text-xs font-medium text-brand-textMuted">นิ้ว</span>
            </div>
          </div>

          {/* น้ำหนัก */}
          <div className="bg-[#FAF6F0] p-3 rounded-2xl text-center border border-brand-border/40">
            <span className="text-[11px] text-brand-textMuted font-medium block mb-0.5">น้ำหนัก</span>
            <div className="text-base font-bold text-brand-textDark">
              {measurements.weight} <span className="text-xs font-medium text-brand-textMuted">กก.</span>
            </div>
          </div>
        </div>
      </motion.div>

      {/* Floating Header Peek for Search bar */}
      <motion.div
        onClick={() => onNavigateTab("search")}
        whileTap={{ scale: 0.98 }}
        className="bg-brand-cocoa text-white rounded-2xl p-3.5 flex items-center justify-between shadow-lg cursor-pointer hover:bg-[#3d2c22] transition-colors"
      >
        <div className="flex items-center gap-2.5">
          <div className="w-6 h-6 rounded-full bg-white/10 flex items-center justify-center">
            <ShoppingBag size={14} className="text-[#EBDDCF]" />
          </div>
          <span className="text-xs font-bold text-[#F5EFE9]">ค้นหาเสื้อผ้า & สไตล์</span>
        </div>
        <div className="flex items-center gap-1 text-[11px] text-[#A69488]">
          <span>สำรวจคอลเลกชัน</span>
          <ChevronRight size={14} />
        </div>
      </motion.div>
    </div>
  );
};
