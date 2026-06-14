// Traducción de valores que el backend devuelve en inglés.

export function severityEs(value?: string): string {
  if (value === "critical") return "Critica";
  if (value === "partial") return "Parcial";
  return value ?? "";
}

export function statusEs(value?: string): string {
  switch (value) {
    case "ready":
      return "Listo";
    case "viable":
      return "Viable";
    case "aspirational":
      return "Aspiracional";
    case "not_recommended":
      return "No recomendado";
    default:
      return value ?? "";
  }
}

export function jobStatusEs(value?: string): string {
  if (value === "active") return "Activa";
  if (value === "closed") return "Cerrada";
  return value ?? "";
}

export function applicationStatusEs(value?: string): string {
  switch (value) {
    case "prepared":
      return "Preparada";
    case "applied":
      return "Postulada";
    case "in_review":
      return "En revision";
    case "rejected":
      return "Rechazada";
    case "accepted":
      return "Aceptada";
    default:
      return value ?? "";
  }
}
