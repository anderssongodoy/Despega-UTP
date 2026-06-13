export function LoadingState({ label = "Cargando informacion..." }: { label?: string }) {
  return <div className="state-box">{label}</div>;
}
