import { useEffect, useState } from "react";
import io from "socket.io-client";

const socket = typeof window !== "undefined" ? io(process.env.NEXT_PUBLIC_SOCKET_URL || "") : null;

export default function AdminPage() {
  const [players, setPlayers] = useState<any[]>([]);
  const [current, setCurrent] = useState<any>(null);
  const [teams, setTeams] = useState<any[]>([]);
  const [token, setToken] = useState<string | null>(null);
  const [password, setPassword] = useState("");
  const [selectedTeam, setSelectedTeam] = useState<string | null>(null);
  const [priceInput, setPriceInput] = useState<number | "">("");

  useEffect(() => {
    const t = localStorage.getItem("admin_token");
    if (t) setToken(t);
  }, []);

  useEffect(() => {
    if (!socket) return;
    socket.on("admin:players", (ps: any[]) => setPlayers(ps));
    socket.on("auction:currentPlayer", (p: any) => setCurrent(p));
    socket.on("auction:bid", (b: any) => console.log("bid", b));
    socket.on("auction:status", (s: any) => console.log("status", s));
    socket.on("auction:playerSold", () => socket.emit("admin:fetchPlayers"));
    socket.on("error", (err: any) => alert(`Server error: ${err}`));

    return () => {
      socket.off("admin:players");
      socket.off("auction:currentPlayer");
      socket.off("auction:playerSold");
    };
  }, []);

  useEffect(() => {
    fetch("/api/teams").then((r) => r.json()).then(setTeams);
  }, []);

  async function login() {
    const res = await fetch("/api/admin/login", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ password }) });
    if (!res.ok) return alert("login failed");
    const { token } = await res.json();
    localStorage.setItem("admin_token", token);
    setToken(token);
    socket?.emit("admin:fetchPlayers");
  }

  function startFor(playerId: string) {
    if (!token) return alert("not authenticated");
    socket?.emit("admin:startPlayer", { playerId, token });
  }

  function manualBid(teamId: string, amount: number) {
    if (!token) return alert("not authenticated");
    socket?.emit("admin:manualBid", { teamId, amount, token });
  }

  function markSold(playerId: string) {
    if (!token) return alert("not authenticated");
    const teamId = selectedTeam;
    const price = priceInput === "" ? (current?.basePrice ?? 0) : (priceInput as number);
    if (!teamId) return alert("select a team");
    socket?.emit("admin:markSold", { playerId, teamId, price, token });
  }

  return (
    <div className="min-h-screen p-8">
      <h1 className="text-3xl font-bold mb-6">Admin â€” Auction Controller</h1>

      <div className="mb-4 space-x-2">
        <a href="/wallets" target="_blank" rel="noreferrer" className="px-3 py-1 bg-indigo-600 text-white rounded">Show Wallet Grid</a>
        <a href="/admin/history" className="px-3 py-1 bg-gray-600 text-white rounded">Bid History</a>
      </div>

      {!token && (
        <div className="mb-6">
          <h2 className="font-semibold">Admin Login</h2>
          <input placeholder="password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} className="border px-2 py-1 mr-2" />
          <button className="px-3 py-1 bg-green-600 text-white rounded" onClick={login}>Login</button>
        </div>
      )}

      <div className="mb-8">
        <h2 className="font-semibold">Current Player</h2>
        {current ? (
          <div className="p-4 bg-slate-100 rounded">
            <div className="font-bold">{current.name} â€” {current.role}</div>
            <div className="mt-2">Base Price: {current.basePrice}</div>
            <div className="mt-2">Highest: {current.highest ?? "â€”"}</div>
            <div className="mt-4">
              <select onChange={(e) => setSelectedTeam(e.target.value)} value={selectedTeam ?? ""} className="border px-2 py-1 mr-2">
                <option value="">Select Team</option>
                {teams.map((t) => <option key={t.id} value={t.id}>{t.name} â€” Wallet: {t.wallet}</option>)}
              </select>
              <input type="number" placeholder="price" value={priceInput as any} onChange={(e) => setPriceInput(Number(e.target.value))} className="border px-2 py-1 mr-2" />
              <button className="px-3 py-1 bg-blue-600 text-white rounded" onClick={() => markSold(current.id)}>Mark Sold</button>
            </div>
          </div>
        ) : (
          <div>No player active</div>
        )}
      </div>

      <div>
        <h2 className="font-semibold">Players</h2>
        <ul>
          {players.map((p) => (
            <li key={p.id} className="p-2 border rounded my-2 flex justify-between">
              <div>{p.name} â€” {p.role} â€” {p.basePrice}</div>
              <div className="space-x-2">
                <button className="px-3 py-1 bg-blue-600 text-white rounded" onClick={() => startFor(p.id)}>Start</button>
                <button className="px-3 py-1 bg-yellow-600 text-white rounded" onClick={() => { const price = prompt("bid amount"); if (price) manualBid(selectedTeam ?? "", Number(price)); }}>Manual Bid</button>
              </div>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
