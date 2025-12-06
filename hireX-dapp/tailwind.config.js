/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        "hirex-blue": "#2563EB",
        "hirex-dark": "#0F172A",
      },
    },
  },
  plugins: [],
};
