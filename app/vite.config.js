import { defineConfig } from "vite";
import rabbita from "@rabbita/vite";
import { cloudflare } from "@cloudflare/vite-plugin";

export default defineConfig({
  plugins: [rabbita({ mainPkgDir: "src/cmd/main" }), cloudflare()],
});
