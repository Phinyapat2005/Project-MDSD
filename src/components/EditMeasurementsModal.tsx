"use client";

import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X, Check, Ruler, Scale } from "lucide-react";
import { UserMeasurements } from "@/types";

interface EditMeasurementsModalProps {
  isOpen: boolean;
  onClose: () => void;
  measurements: UserMeasurements;
  onSave: (updated: UserMeasurements) => void;
}

export const EditMeasurementsModal: React.FC<EditMeasurementsModalProps> = ({
  isOpen,
  onClose,
  measurements,
  onSave,
}) => {
  const [form, setForm] = useState<UserMeasurements>(measurements);
  const [loading, setLoading] = useState(false);

  // Sync state if initial measurements change
  React.useEffect(() => {
    setForm(measurements);
  }, [measurements]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await fetch("/api/measurements", {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
      const data = await res.json();
      if (data.success) {
        onSave(data.data);
        onClose();
      }
    } catch (err) {
      console.error("Save measurements error:", err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/60 backdrop-blur-sm">
          <motion.div
            initial={{ opacity: 0, y: 100 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 100 }}
            transition={{ type: "spring", damping: 28, stiffness: 350 }}
            className="w-full max-w-[430px] bg-white rounded-t-4xl sm:rounded-4xl p-6 shadow-2xl max-h-[90vh] overflow-y-auto"
          >
            {/* Header */}
            <div className="flex items-center justify-between pb-4 border-b border-brand-border">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-2xl bg-brand-terracotta/10 flex items-center justify-center text-brand-terracotta">
                  <Ruler size={20} />
                </div>
                <div>
                  <h3 className="text-lg font-bold text-brand-textDark">แก้ไขสัดส่วนร่างกาย</h3>
                  <p className="text-xs text-brand-textMuted">อัปเดตข้อมูลสัดส่วนของคุณ</p>
                </div>
              </div>
              <button
                onClick={onClose}
                className="w-8 h-8 rounded-full bg-brand-cream flex items-center justify-center text-brand-textMuted hover:text-brand-textDark"
              >
                <X size={18} />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="mt-5 space-y-4">
              <div className="grid grid-cols-2 gap-3">
                {/* ส่วนสูง */}
                <div className="bg-brand-creamLight p-3.5 rounded-2xl border border-brand-border/60">
                  <label className="text-xs font-medium text-brand-textMuted block mb-1">ส่วนสูง (ซม.)</label>
                  <input
                    type="number"
                    min="120"
                    max="220"
                    value={form.height}
                    onChange={(e) => setForm({ ...form, height: Number(e.target.value) })}
                    className="w-full text-xl font-bold bg-transparent text-brand-textDark focus:outline-none"
                    required
                  />
                </div>

                {/* น้ำหนัก */}
                <div className="bg-brand-creamLight p-3.5 rounded-2xl border border-brand-border/60">
                  <label className="text-xs font-medium text-brand-textMuted block mb-1">น้ำหนัก (กก.)</label>
                  <input
                    type="number"
                    min="30"
                    max="180"
                    value={form.weight}
                    onChange={(e) => setForm({ ...form, weight: Number(e.target.value) })}
                    className="w-full text-xl font-bold bg-transparent text-brand-textDark focus:outline-none"
                    required
                  />
                </div>
              </div>

              {/* รอบเอว */}
              <div className="bg-brand-creamLight p-3.5 rounded-2xl border border-brand-border/60">
                <div className="flex justify-between items-center mb-1">
                  <label className="text-xs font-medium text-brand-textMuted">รอบเอว (นิ้ว)</label>
                  <span className="text-xs font-semibold text-brand-terracotta">{form.waist} นิ้ว</span>
                </div>
                <input
                  type="range"
                  min="24"
                  max="48"
                  value={form.waist}
                  onChange={(e) => setForm({ ...form, waist: Number(e.target.value) })}
                  className="w-full accent-brand-terracotta cursor-pointer"
                />
              </div>

              {/* รอบอก & รอบสะโพก */}
              <div className="grid grid-cols-2 gap-3">
                <div className="bg-brand-creamLight p-3.5 rounded-2xl border border-brand-border/60">
                  <label className="text-xs font-medium text-brand-textMuted block mb-1">รอบอก (นิ้ว)</label>
                  <input
                    type="number"
                    min="28"
                    max="60"
                    value={form.chest}
                    onChange={(e) => setForm({ ...form, chest: Number(e.target.value) })}
                    className="w-full text-xl font-bold bg-transparent text-brand-textDark focus:outline-none"
                    required
                  />
                </div>

                <div className="bg-brand-creamLight p-3.5 rounded-2xl border border-brand-border/60">
                  <label className="text-xs font-medium text-brand-textMuted block mb-1">รอบสะโพก (นิ้ว)</label>
                  <input
                    type="number"
                    min="28"
                    max="60"
                    value={form.hips}
                    onChange={(e) => setForm({ ...form, hips: Number(e.target.value) })}
                    className="w-full text-xl font-bold bg-transparent text-brand-textDark focus:outline-none"
                    required
                  />
                </div>
              </div>

              {/* Live Preview Tip */}
              <div className="p-3 bg-amber-50 rounded-2xl border border-amber-200 text-xs text-amber-900 leading-relaxed">
                💡 <strong>เคล็ดลับ:</strong> อัปเดตสัดส่วนให้เป็นปัจจุบันเพื่อใช้เป็นข้อมูลอ้างอิงในการเลือกเสื้อผ้า
              </div>

              {/* Save Button */}
              <div className="pt-2">
                <button
                  type="submit"
                  disabled={loading}
                  className="w-full py-3.5 bg-brand-terracotta hover:bg-brand-terracottaHover text-white rounded-2xl font-semibold shadow-md flex items-center justify-center gap-2 transition-all active:scale-[0.98]"
                >
                  {loading ? (
                    <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                  ) : (
                    <>
                      <Check size={18} />
                      <span>บันทึกข้อมูลสัดส่วน</span>
                    </>
                  )}
                </button>
              </div>
            </form>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
};
