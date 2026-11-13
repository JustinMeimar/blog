// Exercise Astro's real dev middleware and content watcher without binding a port.
// The container API is internal to Astro; recheck this harness when upgrading it.
import assert from "node:assert/strict";
import fs from "node:fs";
import { IncomingMessage, ServerResponse } from "node:http";
import { Socket } from "node:net";
import { fileURLToPath, pathToFileURL } from "node:url";
import { tmpdir } from "node:os";
import { join } from "node:path";

const root = fileURLToPath(new URL("../", import.meta.url));
process.chdir(root);
process.argv.push("dev");
process.env.NODE_ENV = "development";
const load = (path) => import(new URL(`../node_modules/astro/dist/${path}`, import.meta.url));
const { createContainer } = await load("core/dev/container.js");
const { createSettings, resolveConfig } = await load("core/config/index.js");
const { loadOrCreateNodeLogger } = await load("core/logger/load.js");
const { attachContentServerListeners } = await load("content/server-listeners.js");
const { globalContentLayer } = await load("content/instance.js");
const { MutableDataStore } = await load("content/mutable-data-store.js");
const { getDataStoreFile } = await load("content/content-layer.js");

const slug = `dev-refresh-probe-${process.pid}`;
const file = `${root}src/content/project/${slug}.mdx`;
let container;
let store;
const testCache = fs.mkdtempSync(join(tmpdir(), "blog-dev-refresh-"));
const started = performance.now();
const source = (version) => `---
name: "Dev Refresh Probe"
description: "REFRESH_DESCRIPTION_${version}"
year: "${2020 + version}"
tags: ["refresh-tag-${version}"]
---

REFRESH_BODY_${version}
`;

async function until(check, message) {
  const deadline = performance.now() + 10000;
  do {
    if (await check()) return;
    await new Promise((resolve) => setTimeout(resolve, 100));
  } while (performance.now() < deadline);
  throw new Error(message);
}

function get(url) {
  return new Promise((resolve, reject) => {
    const socket = new Socket();
    const req = new IncomingMessage(socket);
    req.url = url;
    req.method = "GET";
    req.headers = { host: "localhost:4321", accept: "text/html" };
    const res = new ServerResponse(req);
    const chunks = [];
    const timeout = setTimeout(() => reject(new Error(`Timed out rendering ${url}`)), 10000);
    res.write = (chunk) => { chunks.push(Buffer.from(chunk)); return true; };
    res.end = (chunk) => {
      if (chunk) chunks.push(Buffer.from(chunk));
      clearTimeout(timeout);
      socket.destroy();
      resolve({ status: res.statusCode, body: Buffer.concat(chunks).toString() });
      return res;
    };
    res.on("error", (error) => { clearTimeout(timeout); reject(error); });
    container.handle(req, res);
  });
}

try {
  const inlineConfig = {
    root,
    logLevel: "error",
    vite: { server: { middlewareMode: true, hmr: false, ws: false } },
  };
  const { astroConfig } = await resolveConfig(inlineConfig, "dev", fs);
  const settings = await createSettings(astroConfig, "error", root);
  // Never compete with an already-running dev server for .astro/data-store.json.
  settings.dotAstroDir = pathToFileURL(`${testCache}/`);
  const logger = await loadOrCreateNodeLogger(astroConfig, inlineConfig);
  container = await createContainer({ settings, logger, inlineConfig, fs });
  await attachContentServerListeners(container);
  store = await MutableDataStore.fromFile(getDataStoreFile(container.settings, true));
  const layer = globalContentLayer.init({
    settings: container.settings, logger: container.logger,
    watcher: container.viteServer.watcher, store,
  });
  layer.watchContentConfig();
  await layer.sync();
  console.log(`Dev initialized in ${Math.round(performance.now() - started)} ms`);

  let reloads = 0;
  const hot = container.viteServer.environments.client.hot;
  const send = hot.send.bind(hot);
  hot.send = (...args) => {
    if (args[0]?.type === "full-reload") reloads++;
    return send(...args);
  };

  assert.equal((await get("/projects/")).status, 200);
  for (const version of [1, 2, 3]) {
    const previousReloads = reloads;
    fs.writeFileSync(file, source(version), { flag: version === 1 ? "wx" : "w" });
    await until(async () => {
      const listing = await get("/projects/");
      return listing.status === 200 && listing.body.includes(`REFRESH_DESCRIPTION_${version}`)
        && listing.body.includes(`refresh-tag-${version}`) && reloads > previousReloads;
    }, `Save ${version} did not update the listing and emit a browser reload`);
    const detail = await get(`/projects/${slug}/`);
    assert.equal(detail.status, 200);
    assert.ok(detail.body.includes(`REFRESH_DESCRIPTION_${version}`), "Detail frontmatter is stale");
    assert.ok(detail.body.includes(`REFRESH_BODY_${version}`), "MDX body is stale");
    assert.equal(store.get("project", slug).data.year, String(2020 + version));
    console.log(`Save ${version}: listing, detail, tags, year, MDX body, and reload notification passed`);
  }
  fs.unlinkSync(file);
  await until(async () => !(await get("/projects/")).body.includes("REFRESH_DESCRIPTION_"),
    "Deleted project remained in the listing");
  console.log("Deletion propagated without restarting");
} finally {
  if (fs.existsSync(file)) fs.unlinkSync(file);
  if (store?.has("project", slug)) {
    await until(() => !store.has("project", slug), "Test entry was not removed from the content store");
  }
  // Allow the normal debounced content-store write to finish before closing.
  if (store) await store.writeToDisk();
  globalContentLayer.dispose();
  if (container) await container.close();
  fs.rmSync(testCache, { recursive: true, force: true });
}
