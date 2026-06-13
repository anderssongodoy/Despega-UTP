import { Card } from "./Card";

type MetricCardProps = {
  label: string;
  value: string | number;
  helper?: string;
};

export function MetricCard({ label, value, helper }: MetricCardProps) {
  return (
    <Card className="metric-card">
      <p className="eyebrow">{label}</p>
      <strong className="metric-value">{value}</strong>
      {helper ? <p className="muted">{helper}</p> : null}
    </Card>
  );
}
