"use client";

import React, { useState } from "react";
import { Smartphone, Monitor, Database, Wifi } from "lucide-react";

interface MobileFrameProps {
  children: React.ReactNode;
}

export const MobileFrame: React.FC<MobileFrameProps> = ({ children }) => {
  const [isMobileView, setIsMobileView] = useState(true);

  return (
    <div className="min-h-screen bg-[#140E0A] flex flex-col items-center justify-start text-white py-4 px-2 sm:px-4">
      {/* Top App Control Bar */}
      <header className="w-full max-w-5xl flex flex-wrap items-center justify-between gap-3 mb-4 px-4 py-2.5 bg-[#201510] rounded-2xl border border-[#3E291F] shadow-lg">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-xl bg-brand-terracotta flex items-center justify-center font-bold text-white shadow-md">
            👔
          </div>
          <div>
            <h1 className="text-sm font-bold text-white flex items-center gap-1.5">
              <span>Fashion Stylist App</span>
              <span className="text-[10px] bg-brand-terracotta/20 text-brand-terracotta px-2 py-0.5 rounded-full border border-brand-terracotta/30">
                Figma Production Code
              </span>
            </h1>
            <p className="text-[11px] text-[#A69386]">
              แนะนำการแต่งตัวตามสไตล์ของคุณ
            </p>
          </div>
        </div>

        {/* Status Pills */}
        <div className="flex items-center gap-2">
          <div className="hidden sm:flex items-center gap-1.5 px-2.5 py-1 bg-[#2C1D16] text-[#D8C7BC] rounded-lg text-xs border border-[#442E23]">
            <Database size={13} className="text-emerald-400" />
            <span>SQLite Ready</span>
          </div>

          {/* View Mode Switcher */}
          <div className="bg-[#2C1D16] p-1 rounded-xl flex items-center border border-[#442E23]">
            <button
              onClick={() => setIsMobileView(true)}
              className={`flex items-center gap-1 px-3 py-1 rounded-lg text-xs font-semibold transition-all ${
                isMobileView
                  ? "bg-brand-terracotta text-white shadow-sm"
                  : "text-[#A69386] hover:text-white"
              }`}
              title="สลับเป็นมุมมอง iPhone เหมือนใน Figma"
            >
              <Smartphone size={14} />
              <span className="hidden md:inline">iPhone View</span>
            </button>
            <button
              onClick={() => setIsMobileView(false)}
              className={`flex items-center gap-1 px-3 py-1 rounded-lg text-xs font-semibold transition-all ${
                !isMobileView
                  ? "bg-brand-terracotta text-white shadow-sm"
                  : "text-[#A69386] hover:text-white"
              }`}
              title="สลับเป็นมุมมองเต็มจอ Responsive"
            >
              <Monitor size={14} />
              <span className="hidden md:inline">Responsive</span>
            </button>
          </div>
        </div>
      </header>

      {/* Main Container */}
      {isMobileView ? (
        /* iPhone Device Frame with Dynamic Island & Deep Purple Titanium border */
        <div className="relative w-full max-w-[414px] min-h-[850px] bg-brand-bg rounded-[50px] shadow-[0_25px_60px_-15px_rgba(0,0,0,0.9)] border-[10px] border-[#53495C] outline outline-2 outline-[#2D2633] overflow-hidden flex flex-col">
          {/* Dynamic Island & Status Bar */}
          <div className="sticky top-0 z-40 bg-brand-bg/90 backdrop-blur-md px-6 pt-3 pb-2 flex items-center justify-between text-brand-textDark select-none">
            {/* Clock */}
            <span className="text-xs font-bold tracking-tight">9:41</span>

            {/* Dynamic Island Pill */}
            <div className="w-24 h-5 bg-black rounded-full flex items-center justify-between px-2.5 shadow-inner">
              <div className="w-2.5 h-2.5 rounded-full bg-[#111] border border-[#222]" />
              <div className="w-2.5 h-2.5 rounded-full bg-[#0a192f] border border-[#1e3a8a] flex items-center justify-center">
                <div className="w-1 h-1 rounded-full bg-blue-500/80" />
              </div>
            </div>

            {/* Signal & Battery */}
            <div className="flex items-center gap-1.5 text-xs">
              <Wifi size={13} strokeWidth={2.5} />
              <div className="w-5 h-2.5 rounded-sm border border-brand-textDark/80 p-0.5 flex items-center">
                <div className="w-full h-full bg-brand-textDark rounded-2xs" />
              </div>
            </div>
          </div>

          {/* Screen Scrollable Body */}
          <div className="flex-1 overflow-y-auto no-scrollbar relative">
            {children}
          </div>

          {/* Bottom Home Indicator */}
          <div className="sticky bottom-0 z-30 pointer-events-none pb-2 flex justify-center">
            <div className="w-32 h-1 bg-black/40 rounded-full" />
          </div>
        </div>
      ) : (
        /* Responsive View Container */
        <div className="w-full max-w-xl bg-brand-bg text-brand-textDark rounded-3xl shadow-2xl min-h-[850px] overflow-hidden border border-[#3E291F] flex flex-col relative">
          <div className="flex-1 overflow-y-auto no-scrollbar">
            {children}
          </div>
        </div>
      )}
    </div>
  );
};
