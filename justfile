default:
    @just --list

# Install the locked dependencies (Node 22, npm 10).
setup:
    npm ci

# Localhost with automatic updates on save.
dev:
    npm run dev

# Reset stale dev caches and start localhost.
fresh:
    npm run dev -- --force

# Build the site and search index.
build:
    npm run build

# Serve the last production build.
preview:
    npm run preview

# Verify that saved content reaches rendered pages.
check:
    npm run test:dev
