import type { NextApiRequest, NextApiResponse } from "next";

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  const token = req.headers["x-admin-token"] || req.cookies?.admin_token;
  if (!process.env.ADMIN_SECRET) return res.status(500).json({ message: "server misconfigured" });
  if (token === process.env.ADMIN_SECRET) return res.json({ ok: true });
  return res.status(401).json({ ok: false });
}
