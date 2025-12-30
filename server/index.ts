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
