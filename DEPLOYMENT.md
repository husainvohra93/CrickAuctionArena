Deployment checklist — Vercel (frontend) + Neon (Postgres) + Node host (Socket.IO)

1. Database (Neon)
- Create a Neon project and a Postgres database.
- Copy connection URL and set as `DATABASE_URL` in Vercel env variables and for any server host.
- Run migrations and seed (in a production-safe manner): `prisma migrate deploy` then `prisma db seed` (adjust as needed).

2. Frontend (Vercel)
- Push repo to GitHub.
- In Vercel, import the project and set environment variables:
  - `DATABASE_URL` (optional for some serverless API routes)
  - `NEXT_PUBLIC_SOCKET_URL` → the publicly reachable Socket server URL (e.g., https://auction-socket.example.com)
  - `ADMIN_SECRET` and `ADMIN_PASSWORD` (for admin login in production)
- Build command: `npm run build`. Vercel will run the build step automatically.

3. Realtime server (Socket.IO)
- Socket servers are stateful and often require an always-on host. Recommended hosts: Render, Fly, Railway, or a small VPS.
- Deploy the server (`server/index.ts`) as a Node app. Ensure environment variables are set: `DATABASE_URL`, `ADMIN_SECRET`, and any other secrets.
- Configure CORS to allow the frontend origin.
- In CI, run `npm run server:build` to compile server TypeScript into `server/dist` before deployment.

4. Domain & SSL
- Configure a custom domain or use Vercel-provided domain for frontend and ensure the socket host has TLS enabled.

5. Monitoring & Logs
- Ensure the Node host exposes logs and restarts on crashes.
- Monitor Neon metrics and set alerts for high connections or low resources.

Notes
- If you prefer serverless realtime on Vercel, consider using webhooks or a third-party pub/sub (e.g., Pusher) — but Socket.IO is easiest to control and host on a small Node service.
- Keep `ADMIN_SECRET` private and rotate if needed.
