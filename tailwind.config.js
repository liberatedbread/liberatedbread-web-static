/**
 * Liberated Bread — Tailwind configuration.
 *
 * Every colour below is a `var()` reference. The actual values live in exactly
 * one place, `src/input.css`, which also documents how each was sampled from
 * `assets/logo.png` (DESIGN §3.1/§3.3). Do not paste a hex code into this file.
 *
 * Because the utilities resolve to custom properties, Tailwind's opacity
 * modifiers (`bg-bread-sky/20`, `border-bread-steel/30`) compile to
 * `color-mix(...)` and work exactly as they would for a literal colour.
 *
 * Build:  npm run build:css        (see package.json)
 */

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./*.md",
    "./*.html",
    "./_layouts/**/*.html",
    "./_includes/**/*.html",
    "./_devices/**/*.md",
    "./contribute/**/*.md",
    "./ha-plugins/**/*.md",
  ],
  theme: {
    extend: {
      colors: {
        bread: {
          /* sampled straight from the logo */
          base: "var(--bread-base)",
          accent: "var(--bread-accent)",
          sky: "var(--bread-sky)",
          /* computed variants — see the derivation comment in src/input.css */
          "base-dark": "var(--bread-base-dark)",
          "accent-bright": "var(--bread-accent-bright)",
          steel: "var(--bread-steel)",
          khaki: "var(--bread-khaki)",
        },
      },
      fontFamily: {
        serif: "var(--bread-font-serif)",
        sans: "var(--bread-font-sans)",
        mono: "var(--bread-font-mono)",
      },
    },
  },
  plugins: [],
};
