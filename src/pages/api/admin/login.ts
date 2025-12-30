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
