import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Personal Stylist - สไตล์ลิสต์ส่วนตัว",
  description: "แอปแนะนำการแต่งตัวและสถานที่ที่เข้ากับสไตล์ของคุณ",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="th">
      <body className="antialiased selection:bg-brand-terracotta selection:text-white">
        {children}
      </body>
    </html>
  );
}
