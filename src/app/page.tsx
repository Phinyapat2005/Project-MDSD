"use client";

import { BottomNav } from "@/components/BottomNav";
import { HomeScreen } from "@/components/HomeScreen";
import { MobileFrame } from "@/components/MobileFrame";
import { UserMeasurements, UserProfile } from "@/types";

const profile: UserProfile = {
  id: "user_001",
  name: "สมชาย ใจดี",
  email: "somchai@email.com",
  phone: "081-234-5678",
  birthdate: "15 มีนาคม 2538",
  isPremium: true,
  avatarUrl:
    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80",
};

const measurements: UserMeasurements = {
  height: 175,
  weight: 68,
  waist: 32,
  chest: 38,
  hips: 36,
  updatedAt: "2026-09-24T00:00:00.000Z",
};

const stayOnHome = () => undefined;

export default function HomePage() {
  return (
    <MobileFrame>
      <HomeScreen
        profile={profile}
        measurements={measurements}
        onEditMeasurements={stayOnHome}
        onNavigateTab={stayOnHome}
      />
      <BottomNav currentTab="home" onTabChange={stayOnHome} />
    </MobileFrame>
  );
}
