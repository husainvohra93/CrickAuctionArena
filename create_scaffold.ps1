# create_scaffold.ps1
# Fixed scaffold script for Turf Cricket Auction
# Writes all project files using Out-File -LiteralPath to avoid wildcard path issues.

$root = (Get-Location).Path

function Write-TextFile($path, $content) {
  $dir = Split-Path $path -Parent
  if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  $content | Out-File -LiteralPath $path -Encoding UTF8 -Force
}

# package.json
Write-TextFile "$root\package.json" @'
{
  "name": "turf-cricket-auction",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "server:dev": "ts-node-dev --respawn --transpile-only server/index.ts",
    "server:start": "node server/dist/index.js",
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate dev --name init",
    "prisma:seed": "ts-node prisma/seed.ts",
    "test": "echo \"No tests yet\" && exit 0"
  },
  "dependencies": {
    "next": "14.0.0",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "socket.io-client": "^4.7.0",
    "socket.io": "^4.7.0",
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.1.4",
    "axios": "^1.4.0",
    "@prisma/client": "^5.4.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "tailwindcss": "^3.4.0",
    "autoprefixer": "^10.4.14",
    "postcss": "^8.4.21",
    "prisma": "^5.4.0",
    "ts-node": "^10.9.0",
    "ts-node-dev": "^2.0.0",
    "eslint": "8.44.0",
    "eslint-config-next": "14.0.0"
  }
}
'@

# .gitignore
Write-TextFile "$root\.gitignore" @'
node_modules
.next
.env
.env.local
dist
server/dist
.DS_Store
coverage
.idea
.vscode
'@

# README.md
Write-TextFile "$root\README.md" @'
# Turf Cricket Auction — IPL-style Auction Portal

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
'@

# Configs
Write-TextFile "$root\next.config.js" @'
/** @type {import("next").NextConfig} */
const nextConfig = {
  reactStrictMode: true,
}

module.exports = nextConfig
'@

Write-TextFile "$root\tsconfig.json" @'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["DOM", "ES2020"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "module": "ESNext",
    "moduleResolution": "Node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", "server/**/*.ts"],
  "exclude": ["node_modules"]
}
'@

Write-TextFile "$root\postcss.config.js" @'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
'@

Write-TextFile "$root\tailwind.config.cjs" @'
module.exports = {
  content: ["./src/**/*.{js,ts,jsx,tsx}", "./pages/**/*.{js,ts,jsx,tsx}", "./components/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [],
}
'@

# Styles
Write-TextFile "$root\styles\globals.css" @'
@tailwind base;
@tailwind components;
@tailwind utilities;

html, body, #__next {
  height: 100%;
}
'@

# src pages & app
Write-TextFile "$root\src\pages\_app.tsx" @'
import "../styles/globals.css";
import type { AppProps } from "next/app";

export default function App({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}
'@

Write-TextFile "$root\src\pages\index.tsx" @'
import { useEffect, useState } from "react";
import io from "socket.io-client";

const socket = typeof window !== "undefined" ? io(process.env.NEXT_PUBLIC_SOCKET_URL || "") : null;

export default function Viewer() {
  const [player, setPlayer] = useState<any>(null);
  const [highestBid, setHighestBid] = useState<number | null>(null);
  const [highestTeam, setHighestTeam] = useState<string | null>(null);
  const [status, setStatus] = useState("");

  useEffect(() => {
    if (!socket) return;
    socket.on("auction:currentPlayer", (p: any) => setPlayer(p));
    socket.on("auction:bid", (b: any) => { setHighestBid(b.amount); setHighestTeam(b.teamId); });
    socket.on("auction:status", (s: any) => setStatus(s));

    return () => {
      socket.off("auction:currentPlayer");
      socket.off("auction:bid");
      socket.off("auction:status");
    };
  }, []);

  return (
    <div className="min-h-screen bg-slate-900 text-white p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold mb-6">Turf Cricket Auction — Viewer</h1>

        {!player && <div className="text-xl">Waiting for auction to start...</div>}

        {player && (
          <div className="bg-slate-800 p-6 rounded-lg">
            <h2 className="text-3xl font-semibold">{player.name}</h2>
            <div className="mt-2">Role: {player.role} • Age: {player.age}</div>
            <div className="mt-4 text-2xl">Base Price: {player.basePrice}</div>
            <div className="mt-4 text-3xl">Highest: {highestBid ?? player.basePrice}</div>
            <div className="mt-2 text-lg">Leading Team: {highestTeam ?? "—"}</div>
            <div className="mt-4 text-2xl">Status: {status}</div>
          </div>
        )}
      </div>
    </div>
  );
}
'@

# Admin pages
Write-TextFile "$root\src\pages\admin\index.tsx" @'
import { useEffect, useState } from "react";
import io from "socket.io-client";

const socket = typeof window !== "undefined" ? io(process.env.NEXT_PUBLIC_SOCKET_URL || "") : null;

export default function AdminPage() {
  const [players, setPlayers] = useState<any[]>([]);
  const [current, setCurrent] = useState<any>(null);
  const [teams, setTeams] = useState<any[]>([]);
  const [token, setToken] = useState<string | null>(null);
  const [password, setPassword] = useState("");
  const [selectedTeam, setSelectedTeam] = useState<string | null>(null);
  const [priceInput, setPriceInput] = useState<number | "">("");

  useEffect(() => {
    const t = localStorage.getItem("admin_token");
    if (t) setToken(t);
  }, []);

  useEffect(() => {
    if (!socket) return;
    socket.on("admin:players", (ps: any[]) => setPlayers(ps));
    socket.on("auction:currentPlayer", (p: any) => setCurrent(p));
    socket.on("auction:bid", (b: any) => console.log("bid", b));
    socket.on("auction:status", (s: any) => console.log("status", s));
    socket.on("auction:playerSold", () => socket.emit("admin:fetchPlayers"));
    socket.on("error", (err: any) => alert(`Server error: ${err}`));

    return () => {
      socket.off("admin:players");
      socket.off("auction:currentPlayer");
      socket.off("auction:playerSold");
    };
  }, []);

  useEffect(() => {
    fetch("/api/teams").then((r) => r.json()).then(setTeams);
  }, []);

  async function login() {
    const res = await fetch("/api/admin/login", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ password }) });
    if (!res.ok) return alert("login failed");
    const { token } = await res.json();
    localStorage.setItem("admin_token", token);
    setToken(token);
    socket?.emit("admin:fetchPlayers");
  }

  function startFor(playerId: string) {
    if (!token) return alert("not authenticated");
    socket?.emit("admin:startPlayer", { playerId, token });
  }

  function manualBid(teamId: string, amount: number) {
    if (!token) return alert("not authenticated");
    socket?.emit("admin:manualBid", { teamId, amount, token });
  }

  function markSold(playerId: string) {
    if (!token) return alert("not authenticated");
    const teamId = selectedTeam;
    const price = priceInput === "" ? (current?.basePrice ?? 0) : (priceInput as number);
    if (!teamId) return alert("select a team");
    socket?.emit("admin:markSold", { playerId, teamId, price, token });
  }

  return (
    <div className="min-h-screen p-8">
      <h1 className="text-3xl font-bold mb-6">Admin — Auction Controller</h1>

      <div className="mb-4 space-x-2">
        <a href="/wallets" target="_blank" rel="noreferrer" className="px-3 py-1 bg-indigo-600 text-white rounded">Show Wallet Grid</a>
        <a href="/admin/history" className="px-3 py-1 bg-gray-600 text-white rounded">Bid History</a>
      </div>

      {!token && (
        <div className="mb-6">
          <h2 className="font-semibold">Admin Login</h2>
          <input placeholder="password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} className="border px-2 py-1 mr-2" />
          <button className="px-3 py-1 bg-green-600 text-white rounded" onClick={login}>Login</button>
        </div>
      )}

      <div className="mb-8">
        <h2 className="font-semibold">Current Player</h2>
        {current ? (
          <div className="p-4 bg-slate-100 rounded">
            <div className="font-bold">{current.name} — {current.role}</div>
            <div className="mt-2">Base Price: {current.basePrice}</div>
            <div className="mt-2">Highest: {current.highest ?? "—"}</div>
            <div className="mt-4">
              <select onChange={(e) => setSelectedTeam(e.target.value)} value={selectedTeam ?? ""} className="border px-2 py-1 mr-2">
                <option value="">Select Team</option>
                {teams.map((t) => <option key={t.id} value={t.id}>{t.name} — Wallet: {t.wallet}</option>)}
              </select>
              <input type="number" placeholder="price" value={priceInput as any} onChange={(e) => setPriceInput(Number(e.target.value))} className="border px-2 py-1 mr-2" />
              <button className="px-3 py-1 bg-blue-600 text-white rounded" onClick={() => markSold(current.id)}>Mark Sold</button>
            </div>
          </div>
        ) : (
          <div>No player active</div>
        )}
      </div>

      <div>
        <h2 className="font-semibold">Players</h2>
        <ul>
          {players.map((p) => (
            <li key={p.id} className="p-2 border rounded my-2 flex justify-between">
              <div>{p.name} — {p.role} — {p.basePrice}</div>
              <div className="space-x-2">
                <button className="px-3 py-1 bg-blue-600 text-white rounded" onClick={() => startFor(p.id)}>Start</button>
                <button className="px-3 py-1 bg-yellow-600 text-white rounded" onClick={() => { const price = prompt("bid amount"); if (price) manualBid(selectedTeam ?? "", Number(price)); }}>Manual Bid</button>
              </div>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
'@

# Wallet grid & component
Write-TextFile "$root\src\components\WalletGrid.tsx" @'
export default function WalletGrid({ teams }: { teams: any[] }) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
      {teams.map(t => (
        <div key={t.id} className="p-6 bg-white text-slate-900 rounded shadow-lg">
          <div className="font-bold text-lg">{t.name}</div>
          <div className="mt-2">Wallet: <span className="font-mono">{t.wallet}</span></div>
          <div className="mt-1">Players: {t.playersCount ?? t.players?.length ?? 0}</div>
        </div>
      ))}
    </div>
  );
}
'@

Write-TextFile "$root\src\pages\wallets.tsx" @'
import { useEffect, useState } from "react";
import WalletGrid from "../components/WalletGrid";

export default function WalletsPage() {
  const [teams, setTeams] = useState<any[]>([]);
  useEffect(() => {
    fetch("/api/teams").then(r => r.json()).then(setTeams);
  }, []);

  return (
    <div className="min-h-screen bg-slate-900 text-white p-8">
      <div className="max-w-6xl mx-auto">
        <h1 className="text-4xl font-bold mb-6">Team Wallet Status</h1>
        <WalletGrid teams={teams} />
      </div>
    </div>
  );
}
'@

# Admin history page
Write-TextFile "$root\src\pages\admin\history.tsx" @'
import { useEffect, useState } from "react";

export default function HistoryPage() {
  const [bids, setBids] = useState<any[]>([]);

  useEffect(() => {
    fetch("/api/bids").then(r => r.json()).then(setBids);
  }, []);

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-4">Auction Bid History</h1>
      <table className="min-w-full bg-white">
        <thead>
          <tr>
            <th className="px-4 py-2">Time</th>
            <th className="px-4 py-2">Player</th>
            <th className="px-4 py-2">Team</th>
            <th className="px-4 py-2">Amount</th>
          </tr>
        </thead>
        <tbody>
          {bids.map(b => (
            <tr key={b.id} className="border-t">
              <td className="px-4 py-2">{new Date(b.createdAt).toLocaleString()}</td>
              <td className="px-4 py-2">{b.player?.name ?? b.playerId}</td>
              <td className="px-4 py-2">{b.team?.name ?? b.teamId}</td>
              <td className="px-4 py-2">{b.amount}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
'@

# API routes
Write-TextFile "$root\src\pages\api\admin\login.ts" @'
import type { NextApiRequest, NextApiResponse } from "next";

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== "POST") return res.status(405).end();
  const { password } = req.body;
  if (!process.env.ADMIN_PASSWORD || !process.env.ADMIN_SECRET) return res.status(500).json({ message: "server misconfigured" });
  if (password === process.env.ADMIN_PASSWORD) {
    return res.json({ token: process.env.ADMIN_SECRET });
  }
  return res.status(401).json({ message: "invalid password" });
}
'@

Write-TextFile "$root\src\pages\api\admin\check.ts" @'
import type { NextApiRequest, NextApiResponse } from "next";

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  const token = req.headers["x-admin-token"] || req.cookies?.admin_token;
  if (!process.env.ADMIN_SECRET) return res.status(500).json({ message: "server misconfigured" });
  if (token === process.env.ADMIN_SECRET) return res.json({ ok: true });
  return res.status(401).json({ ok: false });
}
'@

Write-TextFile "$root\src\pages\api\teams\index.ts" @'
import type { NextApiRequest, NextApiResponse } from "next";
import { prisma } from "../../../lib/prisma";

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === "GET") {
    const teams = await prisma.team.findMany({ include: { players: true } });
    return res.json(teams);
  }
  res.status(405).end();
}
'@

# Important: file with bracket in name — use LiteralPath when writing, this avoids wildcard issues
Write-TextFile "$root\src\pages\api\teams\[id].ts" @'
import type { NextApiRequest, NextApiResponse } from "next";
import { prisma } from "../../../lib/prisma";

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { id } = req.query;
  if (req.method === "GET") {
    const team = await prisma.team.findUnique({ where: { id: String(id) }, include: { players: true } });
    if (!team) return res.status(404).json({ message: "Not found" });
    return res.json(team);
  }
  res.status(405).end();
}
'@

Write-TextFile "$root\src\pages\api\bids\index.ts" @'
import type { NextApiRequest, NextApiResponse } from "next";
import { prisma } from "../../../lib/prisma";

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === "GET") {
    const bids = await prisma.bid.findMany({ orderBy: { createdAt: "desc" }, take: 200, include: { team: true, player: true } });
    return res.json(bids);
  }
  res.status(405).end();
}
'@

# Prisma client helper
Write-TextFile "$root\lib\prisma.ts" @'
import { PrismaClient } from "@prisma/client";

declare global {
  var prisma: PrismaClient | undefined;
}

export const prisma = global.prisma ?? new PrismaClient();
if (process.env.NODE_ENV === "development") global.prisma = prisma;
'@

# Prisma schema & seed
Write-TextFile "$root\prisma\schema.prisma" @'
generator client { provider = "prisma-client-js" }

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Team {
  id          String   @id @default(cuid())
  name        String
  logo        String?
  wallet      Int      @default(1000)
  color       String?
  players     Player[]
  createdAt   DateTime @default(now())
}

model Player {
  id        String   @id @default(cuid())
  name      String
  role      String
  age       Int
  basePrice Int
  status    String   @default("UNSOLD")
  team      Team?    @relation(fields: [teamId], references: [id])
  teamId    String?
}

model Auction {
  id             String   @id @default(cuid())
  title          String
  defaultIncrement Int    @default(5)
  dynamicRules   Json?
  isActive       Boolean  @default(true)
  createdAt      DateTime @default(now())
}

model Bid {
  id        String   @id @default(cuid())
  amount    Int
  team      Team     @relation(fields: [teamId], references: [id])
  teamId    String
  player    Player   @relation(fields: [playerId], references: [id])
  playerId  String
  createdAt DateTime @default(now())
}
'@

Write-TextFile "$root\prisma\seed.ts" @'
import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

async function main() {
  const teams = [];
  for (let i = 1; i <= 12; i++) {
    const t = await prisma.team.create({ data: { name: `Team ${i}`, wallet: 1000 } });
    teams.push(t);
  }

  const roles = ["Batsman", "Bowler", "All-Rounder", "Wicket-Keeper"];
  for (let i = 1; i <= 36; i++) {
    await prisma.player.create({ data: { name: `Player ${i}`, role: roles[i % 4], age: 18 + (i % 10), basePrice: 50 + (i * 5) } });
  }

  console.log("Seed finished");
}

main().catch((e) => { console.error(e); process.exit(1); }).finally(() => prisma.$disconnect());
'@

# Env example
Write-TextFile "$root\.env.example" @'
# Neon / Postgres URL
DATABASE_URL=postgresql://username:password@host:port/dbname

# Public socket URL used by the Next.js frontend
NEXT_PUBLIC_SOCKET_URL=http://localhost:4000

# Admin credentials (dev only)
ADMIN_PASSWORD=changeme
ADMIN_SECRET=super-secret-token
'@

# Socket.IO server
Write-TextFile "$root\server\index.ts" @'
import express from "express";
import http from "http";
import { Server } from "socket.io";
import cors from "cors";
import dotenv from "dotenv";
import { prisma } from "../lib/prisma";

dotenv.config();

const app = express();
app.use(cors());
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

let current: { playerId: string; highestBid: number; highestTeamId?: string } | null = null;

io.on("connection", (socket) => {
  console.log("socket connected", socket.id);

  socket.on("admin:fetchPlayers", async () => {
    const players = await prisma.player.findMany({ where: { status: "UNSOLD" } });
    socket.emit("admin:players", players);
  });

  socket.on("admin:startPlayer", async (data: any) => {
    if (data?.token !== process.env.ADMIN_SECRET) return socket.emit("error", "unauthorized");
    const player = await prisma.player.findUnique({ where: { id: data.playerId } });
    if (!player) return socket.emit("error", "player_not_found");
    if (player.status === "SOLD") return socket.emit("error", "already_sold");

    current = { playerId: player.id, highestBid: player.basePrice };
    const payload = { id: player.id, name: player.name, role: player.role, age: player.age, basePrice: player.basePrice };
    io.emit("auction:currentPlayer", payload);
    io.emit("auction:status", "OPEN");
  });

  socket.on("admin:manualBid", async (data: any) => {
    if (data?.token !== process.env.ADMIN_SECRET) return socket.emit("error", "unauthorized");
    if (!current) return socket.emit("error", "no_active_player");
    const team = await prisma.team.findUnique({ where: { id: data.teamId }, include: { players: true } });
    if (!team) return socket.emit("error", "team_not_found");
    if (team.wallet < data.amount) return socket.emit("error", "insufficient_wallet");

    current.highestBid = data.amount;
    current.highestTeamId = data.teamId;
    await prisma.bid.create({ data: { amount: data.amount, teamId: data.teamId, playerId: current.playerId } });
    io.emit("auction:bid", { amount: data.amount, teamId: data.teamId, playerId: current.playerId });
  });

  socket.on("admin:markSold", async (data: any) => {
    if (data?.token !== process.env.ADMIN_SECRET) return socket.emit("error", "unauthorized");
    if (!current) return socket.emit("error", "no_active_player");

    const player = await prisma.player.findUnique({ where: { id: data.playerId } });
    if (!player) return socket.emit("error", "player_not_found");
    if (player.status === "SOLD") return socket.emit("error", "already_sold");

    const team = await prisma.team.findUnique({ where: { id: data.teamId }, include: { players: true } });
    if (!team) return socket.emit("error", "team_not_found");
    if (team.players.length >= 6) return socket.emit("error", "team_full");
    if (team.wallet < data.price) return socket.emit("error", "insufficient_wallet");

    await prisma.$transaction([
      prisma.player.update({ where: { id: player.id }, data: { status: "SOLD", teamId: team.id } }),
      prisma.team.update({ where: { id: team.id }, data: { wallet: team.wallet - data.price } }),
      prisma.bid.create({ data: { amount: data.price, teamId: team.id, playerId: player.id } }),
    ]);

    io.emit("auction:playerSold", { playerId: player.id, teamId: team.id, price: data.price });
    io.emit("auction:status", "SOLD");
    current = null;
  });

  socket.on("admin:markUnsold", async (data: any) => {
    if (data?.token !== process.env.ADMIN_SECRET) return socket.emit("error", "unauthorized");
    if (!current) return socket.emit("error", "no_active_player");
    io.emit("auction:status", "UNSOLD");
    current = null;
  });

  socket.on("disconnect", () => console.log("socket disconnected", socket.id));
});

const PORT = process.env.PORT ? Number(process.env.PORT) : 4000;
server.listen(PORT, () => console.log(`Auction server listening on ${PORT}`));
'@

# CI workflow
Write-TextFile "$root\.github\workflows\ci.yml" @'
name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Use Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
      - name: Install
        run: npm ci
      - name: Prisma generate
        run: npm run prisma:generate
      - name: Build
        run: npm run build
      - name: Lint
        run: npm run lint
'@

# Copilot instructions
Write-TextFile "$root\.github\copilot-instructions.md" @'
# Copilot / AI agent instructions for Turf Cricket Auction ✅

This repository is an IPL-style live auction platform. Use these concise, actionable notes to be productive quickly.

Quick overview
- Tech stack: Next.js (TypeScript) frontend, Prisma + Neon (Postgres) DB, small Node Express + Socket.IO server for real-time auction control.
- Key folders:
  - `src/pages` — Next.js pages: `/` viewer, `/admin` admin panel, `/team/[id]` team view
  - `server/` — Socket.IO server that controls auction state and broadcasts events
  - `prisma/` — DB schema and `seed.ts` for initial data
  - `lib/prisma.ts` — Prisma client singleton used by server and API routes

Primary workflows & developer commands
- Local dev:
  - Fill `.env` from `.env.example` (set `DATABASE_URL` and `NEXT_PUBLIC_SOCKET_URL`)
  - Install deps: `npm install`
  - Prisma: `npm run prisma:generate` then `npm run prisma:migrate` then `npm run prisma:seed`
  - Start frontend: `npm run dev`
  - Start real-time server: `npm run server:dev` (uses `ts-node-dev`)

Real-time model & important events
- The server emits these events (see `server/index.ts`):
  - `auction:currentPlayer` — payload is the player object to display
  - `auction:bid` — payload is `{ amount, teamId, playerId }`
  - `auction:status` — string statuses such as `OPEN`, `SOLD`, `UNSOLD`
  - `auction:playerSold` — published when admin marks a player sold
- Admin client emits:
  - `admin:fetchPlayers` (receives `admin:players`)
  - `admin:startPlayer` (payload `{ playerId, token }`) — token must match `ADMIN_SECRET` environment variable
  - `admin:manualBid` (payload `{ teamId, amount, token }`) — server persists `Bid` rows
  - `admin:markSold` (payload `{ playerId, teamId, price, token }`) — server validates wallet and team size, and performs a transaction

If you need clarification about dynamic bid increments or behaviors, ask for targeted additions (e.g., `auction:countdown`, `auction:undo`).
'@

Write-Host "Fixed scaffold created. Run 'npm install' then follow README steps."