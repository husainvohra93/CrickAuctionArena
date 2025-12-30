import type { NextApiRequest, NextApiResponse } from "next";
import { prisma } from "../../../../lib/prisma";

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === "GET") {
    const bids = await prisma.bid.findMany({ orderBy: { createdAt: "desc" }, take: 200, include: { team: true, player: true } });
    return res.json(bids);
  }
  res.status(405).end();
}
