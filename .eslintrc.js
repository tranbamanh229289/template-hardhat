module.exports = {
  env: {
    browser: false,
    es2021: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:prettier/recommended",
    "plugin:node/recommended",
  ],
  parser: "@typescript-eslint/parser",
  plugins: ["@@typescript-eslint"],
  rules: {
    "@typescript-eslint/no-explicit-any": "warn",
  },
};
