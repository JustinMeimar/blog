# Blog

Use Node 22 (version in `.nvmrc`) and npm 10. The committed `package-lock.json`
is the dependency lockfile used locally and in CI.

```sh
# If using nvm:
nvm use

npm ci
npm run dev
```

Open http://localhost:4321/. Save Astro, CSS, Markdown, or MDX files to update
pages automatically. Content frontmatter belongs between the `---` delimiters.
`npm run preview` serves the last build; it does not watch source changes.

```sh
npm run build    # Static site and search index in dist/
npm run preview  # Preview that production build
npm run test:dev # Check repeated saves, rendered content, and reload notifications
```

The dev and build dependency caches are separate. The watcher excludes
`.direnv/` so it does not traverse the Nix environment's profile symlinks.
Run one dev server per checkout. Stop an older Bun/Node dev process before
starting a new one: concurrent servers share Astro's content cache.
The refresh test uses a separate temporary cache and cleans up its test entry.
