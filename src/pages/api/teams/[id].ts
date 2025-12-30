import type { NextApiRequest, NextApiResponse } from "next";
import { prisma } from "../../../../lib/prisma";

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { id } = req.query;
  if (req.method === "GET") {
    const team = await prisma.team.findUnique({ where: { id: String(id) }, include: { players: true } });
    if (!team) return res.status(404).json({ message: "Not found" });
    return res.json(team);
  }
  res.status(405).end();
}
