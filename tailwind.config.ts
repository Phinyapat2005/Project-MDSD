import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          bg: "#F6F0E8",
          card: "#FFFFFF",
          cocoa: "#2F2018",
          terracotta: "#BA522B",
          terracottaHover: "#A14220",
          cream: "#F2EAE0",
          creamLight: "#FBF7F2",
          border: "#E9DFD3",
          textDark: "#261A14",
          textMuted: "#87786F",
        },
      },
      fontFamily: {
        sans: ["var(--font-kanit)", "sans-serif"],
      },
      boxShadow: {
        card: "0 4px 20px -2px rgba(47, 32, 24, 0.06)",
        nav: "0 -4px 25px rgba(47, 32, 24, 0.15)",
      },
      borderRadius: {
        '3xl': '24px',
        '4xl': '32px',
      }
    },
  },
  plugins: [],
};
export default config;
