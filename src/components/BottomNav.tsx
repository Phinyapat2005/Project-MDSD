"use client";

import React from "react";
import { motion } from "framer-motion";
import { Home, Search, Shirt, User } from "lucide-react";

export type NavTab = "home" | "search" | "wardrobe" | "profile";

interface BottomNavProps {
  currentTab: NavTab;
  onTabChange: (tab: NavTab) => void;
}

export const BottomNav: React.FC<BottomNavProps> = ({ currentTab, onTabChange }) => {
  const tabs = [
    { id: "home" as NavTab, label: "หน้าแรก", icon: Home },
    { id: "search" as NavTab, label: "ค้นหา", icon: Search },
    { id: "wardrobe" as NavTab, label: "ตู้เสื้อผ้า", icon: Shirt },
    { id: "profile" as NavTab, label: "โปรไฟล์", icon: User },
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 max-w-[430px] mx-auto z-40 px-3 pb-3 pointer-events-none">
      <div className="bg-brand-cocoa text-white rounded-4xl px-3 py-2.5 shadow-nav flex items-center justify-around pointer-events-auto border border-[#443126]/40 backdrop-blur-md">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = currentTab === tab.id;

          return (
            <button
              key={tab.id}
              onClick={() => onTabChange(tab.id)}
              className="relative flex flex-col items-center justify-center py-1.5 px-4 rounded-2xl transition-all duration-300 focus:outline-none"
            >
              {isActive && (
                <motion.div
                  layoutId="activeTabBadge"
                  className="absolute inset-0 bg-[#422F24] rounded-2xl -z-10 shadow-inner"
                  transition={{ type: "spring", stiffness: 450, damping: 32 }}
                />
              )}
              <motion.div
                animate={{ scale: isActive ? 1.08 : 0.95 }}
                transition={{ type: "spring", stiffness: 500, damping: 25 }}
                className={isActive ? "text-[#EBDDCF]" : "text-[#9E8B80]"}
              >
                <Icon size={22} strokeWidth={isActive ? 2.3 : 1.8} />
              </motion.div>
              <span
                className={`text-[11px] mt-1 font-medium transition-colors duration-200 ${
                  isActive ? "text-[#F5EFE9] font-semibold" : "text-[#9E8B80]"
                }`}
              >
                {tab.label}
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
};
