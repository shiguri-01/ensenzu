import { readdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const workerAssetsDir = join("dist", "ensenzu", "assets");
const randomSeedCall = "const _M0FPB4seed = _M0FPB12random__seed();";
const deterministicSeed = "const _M0FPB4seed = 0x4d425453;";

let patched = 0;

for (const file of readdirSync(workerAssetsDir)) {
  if (!file.endsWith(".js")) {
    continue;
  }
  const path = join(workerAssetsDir, file);
  const source = readFileSync(path, "utf8");
  if (!source.includes(randomSeedCall)) {
    continue;
  }
  // Cloudflare Workers validates every deployed module and rejects global-scope
  // random I/O. MoonBit core currently initializes the Hash seed with
  // crypto.getRandomValues() at module evaluation time. The API Worker does not
  // rely on randomized hashing, so use a deterministic seed in the Worker-only
  // build output. Browser/client bundles are left untouched.
  writeFileSync(path, source.replace(randomSeedCall, deterministicSeed));
  patched += 1;
}

if (patched === 0) {
  throw new Error("MoonBit worker runtime seed was not found to patch.");
}

console.log(`Patched MoonBit worker runtime seed in ${patched} file(s).`);
