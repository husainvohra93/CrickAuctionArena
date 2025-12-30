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
