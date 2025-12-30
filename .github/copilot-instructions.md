# Copilot / AI agent instructions for Turf Cricket Auction âœ…

This repository is an IPL-style live auction platform. Use these concise, actionable notes to be productive quickly.

Quick overview
- Tech stack: Next.js (TypeScript) frontend, Prisma + Neon (Postgres) DB, small Node Express + Socket.IO server for real-time auction control.
- Key folders:
  - `src/pages` â€” Next.js pages: `/` viewer, `/admin` admin panel, `/team/[id]` team view
  - `server/` â€” Socket.IO server that controls auction state and broadcasts events
  - `prisma/` â€” DB schema and `seed.ts` for initial data
  - `lib/prisma.ts` â€” Prisma client singleton used by server and API routes

Primary workflows & developer commands
- Local dev:
  - Fill `.env` from `.env.example` (set `DATABASE_URL` and `NEXT_PUBLIC_SOCKET_URL`)
  - Install deps: `npm install`
  - Prisma: `npm run prisma:generate` then `npm run prisma:migrate` then `npm run prisma:seed`
  - Start frontend: `npm run dev`
  - Start real-time server: `npm run server:dev` (uses `ts-node-dev`)

Real-time model & important events
- The server emits these events (see `server/index.ts`):
  - `auction:currentPlayer` â€” payload is the player object to display
  - `auction:bid` â€” payload is `{ amount, teamId, playerId }`
  - `auction:status` â€” string statuses such as `OPEN`, `SOLD`, `UNSOLD`
  - `auction:playerSold` â€” published when admin marks a player sold
- Admin client emits:
  - `admin:fetchPlayers` (receives `admin:players`)
  - `admin:startPlayer` (payload `{ playerId, token }`) â€” token must match `ADMIN_SECRET` environment variable
  - `admin:manualBid` (payload `{ teamId, amount, token }`) â€” server persists `Bid` rows
  - `admin:markSold` (payload `{ playerId, teamId, price, token }`) â€” server validates wallet and team size, and performs a transaction

If you need clarification about dynamic bid increments or behaviors, ask for targeted additions (e.g., `auction:countdown`, `auction:undo`).
