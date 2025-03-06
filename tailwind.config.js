/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{vue,js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        primary: "#40E0D0", // Turquoise
        secondary: "#1E90FF", // Blue
        background: "#F8FAFC", // Light grayish-white
      },
    },
  },
  safelist: ["bg-primary", "text-primary", "bg-secondary", "bg-background"],
  plugins: [],
};