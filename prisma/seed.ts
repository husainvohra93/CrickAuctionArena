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
