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
        <h1 className="text-4xl font-bold mb-6">Turf Cricket Auction â€” Viewer</h1>

        {!player && <div className="text-xl">Waiting for auction to start...</div>}

        {player && (
          <div className="bg-slate-800 p-6 rounded-lg">
            <h2 className="text-3xl font-semibold">{player.name}</h2>
            <div className="mt-2">Role: {player.role} â€¢ Age: {player.age}</div>
            <div className="mt-4 text-2xl">Base Price: {player.basePrice}</div>
            <div className="mt-4 text-3xl">Highest: {highestBid ?? player.basePrice}</div>
            <div className="mt-2 text-lg">Leading Team: {highestTeam ?? "â€”"}</div>
            <div className="mt-4 text-2xl">Status: {status}</div>
          </div>
        )}
      </div>
    </div>
  );
}
