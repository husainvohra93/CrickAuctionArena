import type { NextApiRequest, NextApiResponse } from "next";
import { prisma } from "../../../../lib/prisma";

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === "GET") {
    const teams = await prisma.team.findMany({ include: { players: true } });
    return res.json(teams);
  }
  res.status(405).end();
}
