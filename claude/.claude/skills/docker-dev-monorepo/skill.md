# Docker Dev Setup for Monorepos

## Purpose
Establish production-standard Docker development environment with hot-reload for monorepo projects (pnpm/npm workspaces) with Node.js backends and frontends.

## Key Patterns

### 1. Multi-Stage Dockerfile Structure
```dockerfile
# Stage 1: deps - only installs dependencies
FROM node:18-alpine AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
COPY apps/*/backend/package.json ./apps/*/backend/
COPY packages/*/package.json ./packages/*/
RUN pnpm install --frozen-lockfile

# Stage 2: build - compiles everything
FROM deps AS build
COPY . .
RUN pnpm build

# Stage 3: prod - minimal runtime
FROM node:18-alpine AS prod
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
CMD ["node", "dist/main.js"]
```

### 2. Docker Compose Dev Override
```yaml
# docker-compose.dev.yml - use with: docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
version: '3.8'

services:
  builder-backend:
    build:
      context: .
      target: deps  # Stop at deps stage in dev
    volumes:
      - ./:/app  # Mount entire monorepo
      # Anonymous volumes preserve node_modules
      - /app/node_modules
      - /app/apps/builder/backend/node_modules
      - /app/packages/database/node_modules
    command: pnpm --filter builder-backend dev
    environment:
      - NODE_ENV=development
```

### 3. Test Service with Docker Socket Mount
```yaml
test-builder-backend:
  build:
    context: .
    target: build  # Includes test runners
  profiles: ["test"]  # Don't auto-start
  volumes:
    - ./:/app
    - /var/run/docker.sock:/var/run/docker.sock  # For Testcontainers
    - /app/node_modules
    - /app/apps/builder/backend/node_modules
  command: pnpm --filter builder-backend test:all
```

### 4. Anonymous Volume Strategy
Why mount `/app/node_modules` as anonymous volume?
- Host (macOS/Windows) node_modules compiled with different architecture
- Container (Linux) needs Linux-compiled binaries
- Anonymous volume preserves container's `node_modules` from deps stage

## Common Setup Steps

1. **Create docker-compose.dev.yml** with complete service definitions
2. **Mount entire monorepo** (./:/app), not partial directories
3. **Add anonymous volumes** for each /app/*/node_modules path
4. **Use Docker profiles** for test services (profiles: ["test"])
5. **Document run commands** in README or DOCKER_DEV.md

## Usage Examples

```bash
# Start dev environment (first time or after dependency changes)
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build

# View logs
docker compose logs -f builder-backend

# Run tests in Docker (Linux environment)
docker compose run --rm test-builder-backend
docker compose run --rm test-builder-backend pnpm --filter builder-backend test:integration

# Stop
docker compose down
```

## Why This Pattern (Interview Perspective)

- **Dev/Prod Parity**: Same Dockerfile, same base image, different stages/overrides
- **Multi-Stage Benefits**: Caching (deps layer), separation of concerns, minimal prod image
- **Hot-Reload**: Volume mounts + framework watch features (nest start --watch, vite HMR)
- **Monorepo Complexity**: Full workspace mount + anonymous volumes per package = pnpm resolution works
- **Test Isolation**: Docker profiles + socket mount = tests in Linux, don't interfere with dev
- **Enterprise Standard**: Used in production teams (Docker Compose Override Files official pattern)

## Common Mistakes to Avoid

1. ❌ Mounting only `src/` per package — breaks TypeScript build (needs `tsconfig.json`)
2. ❌ No anonymous volumes — host node_modules overwrite container's Linux binaries
3. ❌ Rebuilding on code changes — use framework watch instead
4. ❌ Single docker-compose.yml with environment conditionals — separate files cleaner
5. ❌ DinD for tests — use Docker socket mount (sibling approach) instead

## Further Improvements (If Needed)

- **Named volumes** for easier cleanup and inspection
- **`docker compose watch`** (Compose 2.22+) for native file sync, faster on macOS
- **BuildKit cache mounts** for pnpm/npm to avoid re-downloading deps

## Related Files

- DOCKER_DEV.md (project documentation with full examples)
- docker_dev_patterns.md (memory file with detailed explanations)
