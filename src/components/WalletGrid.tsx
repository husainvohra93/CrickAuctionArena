export default function WalletGrid({ teams }: { teams: any[] }) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
      {teams.map(t => (
        <div key={t.id} className="p-6 bg-white text-slate-900 rounded shadow-lg">
          <div className="font-bold text-lg">{t.name}</div>
          <div className="mt-2">Wallet: <span className="font-mono">{t.wallet}</span></div>
          <div className="mt-1">Players: {t.playersCount ?? t.players?.length ?? 0}</div>
        </div>
      ))}
    </div>
  );
}
