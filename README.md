# Turf Cricket Auction â€” IPL-style Auction Portal

Scaffolded Next.js + TypeScript app with Neon/Postgres (Prisma) and a Socket.IO server for real-time auction control.

Quick start

1. Copy `.env.example` to `.env` and set `DATABASE_URL` (Neon/Postgres) and `NEXT_PUBLIC_SOCKET_URL`.
2. Install dependencies: `npm install`
3. Generate Prisma client: `npm run prisma:generate`
4. Run migrations and seed: `npm run prisma:migrate` then `npm run prisma:seed`
5. Start dev servers:
   - Next.js app: `npm run dev`
   - Socket.IO server: `npm run server:dev`

Admin access

- In development, set `ADMIN_PASSWORD` and `ADMIN_SECRET` in `.env` (see `.env.example`).
- Login from the admin page at `/admin` using `ADMIN_PASSWORD`. The login endpoint returns an `ADMIN_SECRET` token which is used by the admin client to authorize socket-based actions.

Deployment
- Frontend: Vercel
- DB: Neon Postgres
- Real-time server: deploy to a Node host (Render, Fly, or Railway)
