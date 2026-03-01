import { visit } from "unist-util-visit";
import fs from "fs";
import path from "path";

export function remarkResolveLinks() {
  const cache = new Map();

  return function (tree, file) {
    const linksRegex = /^links\.(\w+)$/;
    const nodes = [];

    visit(tree, "link", (node) => {
      const match = node.url.match(linksRegex);
      if (match) nodes.push({ node, key: match[1] });
    });

    if (nodes.length === 0) return;

    const mdxPath = file.history[0];
    const tsPath = mdxPath.replace(/\.mdx$/, ".ts");

    if (!cache.has(tsPath)) {
      const src = fs.readFileSync(tsPath, "utf-8");
      const links = {};
      for (const [, key, url] of src.matchAll(/(\w+)\s*:\s*["'`]([^"'`]+)["'`]/g)) {
        links[key] = url;
      }
      cache.set(tsPath, links);
    }

    const links = cache.get(tsPath);

    for (const { node, key } of nodes) {
      if (links[key]) {
        node.url = links[key];
      } else {
        console.warn(`remark-resolve-links: unknown key "links.${key}" in ${path.basename(mdxPath)}`);
      }
    }
  };
}
