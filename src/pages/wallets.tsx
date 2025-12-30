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
