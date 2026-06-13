import { ServerCrash } from "lucide-react";

type ErrorStateProps = {
  title?: string;
  description?: string;
};

export function ErrorState({
  title = "No se pudo cargar la informacion",
  description = "Revisa que el backend este activo en http://localhost:8000 e intenta de nuevo.",
}: ErrorStateProps) {
  return (
    <div className="state-box state-error">
      <span className="placeholder-icon">
        <ServerCrash size={22} />
      </span>
      <strong>{title}</strong>
      {description ? <p className="muted">{description}</p> : null}
    </div>
  );
}
