import { useRef, useState } from "react";
import type { CSSProperties, DragEvent } from "react";
import {
  Award,
  Briefcase,
  CheckCircle2,
  Code2,
  FileText,
  FileUp,
  GraduationCap,
  Languages,
  Lightbulb,
  Link2,
  ListChecks,
  Mail,
  MapPin,
  Phone,
  Sparkles,
  TriangleAlert,
  X,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";

import { analyzeCv } from "../cv.api";
import { Card } from "../../../shared/components/Card";
import type { CvAnalysis } from "../../../shared/api/types";

function clean(value?: string | null): string | null {
  if (value == null) return null;
  const text = String(value).trim();
  if (!text || text.toLowerCase() === "null") return null;
  if (text.startsWith("[") && text.endsWith("]")) return null; // placeholders tipo "[Mes/Ano]"
  return text;
}

function dateRange(start?: string | null, end?: string | null): string | null {
  const a = clean(start);
  const b = clean(end);
  if (a && b) return `${a} – ${b}`;
  return a ?? b ?? null;
}

function errorMessage(error: unknown, fallback: string): string {
  if (error && typeof error === "object" && "payload" in error) {
    const payload = (error as { payload?: { detail?: string } }).payload;
    if (payload?.detail) return payload.detail;
  }
  return fallback;
}

function ringColor(score: number): string {
  if (score >= 70) return "#22a995";
  if (score >= 45) return "#f6b84b";
  return "#d50032";
}

function ScoreRing({ value, label }: { value: number; label: string }) {
  const safe = Math.min(100, Math.max(0, Math.round(value)));
  return (
    <div className="stack compact" style={{ alignItems: "center", gap: "0.35rem", textAlign: "center" }}>
      <span className="score-ring" style={{ ["--pct"]: safe, ["--ring"]: ringColor(safe) } as CSSProperties}>
        <span>{safe}</span>
      </span>
      <span className="muted" style={{ fontSize: "0.82rem", maxWidth: 120 }}>
        {label}
      </span>
    </div>
  );
}

function Section({ icon: Icon, title, children }: { icon: LucideIcon; title: string; children: React.ReactNode }) {
  return (
    <div className="stack compact">
      <span className="list-row" style={{ gap: "0.45rem" }}>
        <Icon size={16} /> <strong>{title}</strong>
      </span>
      {children}
    </div>
  );
}

function FeedbackList({
  icon: Icon,
  title,
  items,
  tone,
}: {
  icon: LucideIcon;
  title: string;
  items: string[];
  tone: "good" | "warn" | "info";
}) {
  if (items.length === 0) return null;
  const color = tone === "good" ? "var(--color-teal)" : tone === "warn" ? "var(--color-red)" : "var(--color-yellow, #f6b84b)";
  return (
    <div className="cv-feedback-card">
      <span className="list-row" style={{ gap: "0.45rem" }}>
        <Icon size={16} style={{ color }} /> <strong>{title}</strong>
      </span>
      <ul className="stack compact" style={{ margin: 0, paddingLeft: "1.1rem" }}>
        {items.map((item, index) => (
          <li key={index} style={{ lineHeight: 1.5 }}>
            {item}
          </li>
        ))}
      </ul>
    </div>
  );
}

export function CvAnalyzer() {
  const inputRef = useRef<HTMLInputElement>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [fileName, setFileName] = useState("");
  const [dragging, setDragging] = useState(false);
  const [cv, setCv] = useState<CvAnalysis | null>(null);

  async function handleFile(file?: File | null) {
    if (!file) return;
    if (file.type !== "application/pdf") {
      setError("Solo se permiten archivos PDF.");
      return;
    }
    setError("");
    setCv(null);
    setFileName(file.name);
    setLoading(true);
    try {
      const response = await analyzeCv(file);
      setCv(response.data);
    } catch (err) {
      setError(errorMessage(err, "No se pudo analizar el CV. Revisa el backend y la OPENAI_API_KEY."));
    } finally {
      setLoading(false);
    }
  }

  function onDrop(event: DragEvent<HTMLDivElement>) {
    event.preventDefault();
    setDragging(false);
    handleFile(event.dataTransfer.files?.[0]);
  }

  const fullName = cv ? [clean(cv.nombre), clean(cv.apellido)].filter(Boolean).join(" ") : "";
  const contacts: { icon: LucideIcon; value: string }[] = cv
    ? (
        [
          { icon: MapPin, value: clean(cv.direccion) },
          { icon: Mail, value: clean(cv.correo) },
          { icon: Phone, value: clean(cv.telefono) },
          { icon: Link2, value: clean(cv.linkedin) },
          { icon: Code2, value: clean(cv.github) },
        ].filter((item) => item.value) as { icon: LucideIcon; value: string }[]
      )
    : [];

  const experiencia = (cv?.experiencia ?? []).filter((job) => clean(job.empresa) || clean(job.cargo));
  const educacion = (cv?.educacion ?? []).filter((item) => clean(item.institucion) || clean(item.titulo));
  const idiomas = (cv?.idiomas ?? []).filter((item) => clean(item.idioma));
  const techSkills = cv?.skills_tecnicas ?? [];
  const softSkills = cv?.skills_blandas ?? [];
  const fortalezas = cv?.fortalezas ?? [];
  const faltantes = cv?.faltantes ?? [];
  const recomendaciones = cv?.recomendaciones ?? [];

  // Checklist Ruta Laboral UTP (§10 CV, §11 elevator pitch, §17 LinkedIn).
  const checklist = cv
    ? [
        {
          ok: Boolean(clean(cv.resumen)),
          label: "Resumen profesional (3-5 líneas)",
          hint: "Sintetiza experiencia, formación, idiomas y habilidades clave.",
        },
        {
          ok: experiencia.length > 0,
          label: "Experiencia con cargo y empresa",
          hint: "Ordénala de la más reciente a la más antigua, con fechas.",
        },
        {
          ok: experiencia.some((job) => (job.responsabilidades?.length ?? 0) > 0),
          label: "Logros en viñetas con verbos de acción",
          hint: "Empieza con “logré”, “lideré”, “optimicé”.",
        },
        {
          ok: educacion.length > 0,
          label: "Formación académica relevante",
          hint: "Estudios superiores y cursos recientes (menos de 5 años).",
        },
        {
          ok: techSkills.length + softSkills.length > 0,
          label: "Habilidades técnicas y blandas",
          hint: "Relevantes para tu rol objetivo.",
        },
        {
          ok: contacts.length >= 2,
          label: "Datos de contacto completos",
          hint: "Correo, teléfono y ubicación.",
        },
        {
          ok: Boolean(clean(cv.linkedin)),
          label: "Perfil de LinkedIn",
          hint: "Refuerza tu marca personal (Ruta Laboral UTP).",
        },
        {
          ok: idiomas.length > 0,
          label: "Idiomas con nivel",
          hint: "Indica el nivel de cada idioma.",
        },
      ]
    : [];
  const checklistDone = checklist.filter((item) => item.ok).length;

  return (
    <div className="stack">
      <input
        ref={inputRef}
        type="file"
        accept="application/pdf,.pdf"
        onChange={(event) => {
          const file = event.target.files?.[0];
          event.target.value = "";
          handleFile(file);
        }}
        style={{ display: "none" }}
      />

      {/* Zona de carga */}
      <div
        className={`cv-dropzone${dragging ? " is-dragging" : ""}`}
        role="button"
        tabIndex={0}
        onClick={() => inputRef.current?.click()}
        onKeyDown={(event) => {
          if (event.key === "Enter" || event.key === " ") inputRef.current?.click();
        }}
        onDrop={onDrop}
        onDragOver={(event) => {
          event.preventDefault();
          setDragging(true);
        }}
        onDragLeave={() => setDragging(false)}
      >
        <span className="cv-dropzone-icon">
          <FileUp size={26} />
        </span>
        <strong>{loading ? "Analizando tu CV…" : "Arrastra tu CV o haz clic para subirlo"}</strong>
        <span className="muted" style={{ fontSize: "0.85rem" }}>
          {fileName ? fileName : "Formato PDF · máximo 2 páginas (recomendado por Ruta Laboral UTP)"}
        </span>
      </div>

      {error ? (
        <p className="error-text" role="alert">
          <TriangleAlert size={16} /> {error}
        </p>
      ) : null}

      {cv?.error ? (
        <p className="error-text" role="alert">
          <TriangleAlert size={16} /> {cv.error}
        </p>
      ) : null}

      {cv && !cv.error ? (
        <div className="stack">
          {/* Resultado del análisis */}
          <Card className="cv-score-hero">
            <div className="stack compact" style={{ minWidth: 0 }}>
              <span className="eyebrow">
                <Sparkles size={13} style={{ verticalAlign: "-2px", marginRight: 5 }} /> Diagnóstico de tu CV
              </span>
              <h3 style={{ margin: 0 }}>{fullName || "Tu CV"}</h3>
              {clean(cv.profesion) ? <span className="muted">{clean(cv.profesion)}</span> : null}
              {contacts.length > 0 ? (
                <div className="trust-strip" style={{ marginTop: "0.3rem" }}>
                  {contacts.map((contact, index) => {
                    const Icon = contact.icon;
                    return (
                      <span key={index}>
                        <Icon size={13} /> {contact.value}
                      </span>
                    );
                  })}
                </div>
              ) : null}
            </div>
            <div className="cv-score-rings">
              {typeof cv.score === "number" ? <ScoreRing value={cv.score} label="Calidad del CV" /> : null}
              {typeof cv.ats_score === "number" ? <ScoreRing value={cv.ats_score} label="ATS friendly" /> : null}
              <ScoreRing value={(checklistDone / (checklist.length || 1)) * 100} label="Checklist UTP" />
            </div>
          </Card>

          {/* Resumen */}
          {clean(cv.resumen) ? (
            <Card>
              <Section icon={FileText} title="Resumen profesional">
                <p className="muted" style={{ margin: 0, lineHeight: 1.6 }}>
                  {clean(cv.resumen)}
                </p>
              </Section>
            </Card>
          ) : null}

          {/* Diagnóstico + Checklist UTP */}
          <div className="content-grid">
            <Card>
              <div className="stack">
                <FeedbackList icon={CheckCircle2} title="Fortalezas" items={fortalezas} tone="good" />
                <FeedbackList icon={TriangleAlert} title="Por mejorar" items={faltantes} tone="warn" />
                <FeedbackList icon={Lightbulb} title="Recomendaciones" items={recomendaciones} tone="info" />
                {fortalezas.length === 0 && faltantes.length === 0 && recomendaciones.length === 0 ? (
                  <p className="muted" style={{ margin: 0 }}>
                    El análisis no devolvió observaciones adicionales.
                  </p>
                ) : null}
              </div>
            </Card>

            <Card>
              <div className="row-between">
                <span className="list-row" style={{ gap: "0.45rem" }}>
                  <ListChecks size={16} /> <strong>Checklist Ruta Laboral UTP</strong>
                </span>
                <span className="chip">
                  {checklistDone}/{checklist.length}
                </span>
              </div>
              <div className="stack compact" style={{ marginTop: "0.7rem" }}>
                {checklist.map((item) => (
                  <div key={item.label} className={`cv-check${item.ok ? " is-ok" : ""}`}>
                    <span className="cv-check-mark">{item.ok ? <CheckCircle2 size={16} /> : <X size={16} />}</span>
                    <span className="stack compact" style={{ gap: "0.1rem" }}>
                      <span style={{ fontWeight: 600 }}>{item.label}</span>
                      {!item.ok ? (
                        <span className="muted" style={{ fontSize: "0.82rem" }}>
                          {item.hint}
                        </span>
                      ) : null}
                    </span>
                  </div>
                ))}
              </div>
            </Card>
          </div>

          {/* Contenido detectado */}
          {experiencia.length > 0 || educacion.length > 0 || idiomas.length > 0 || techSkills.length + softSkills.length > 0 ? (
            <Card>
              <p className="eyebrow" style={{ marginBottom: "0.6rem" }}>
                Contenido detectado en tu CV
              </p>
              <div className="stack">
                {experiencia.length > 0 ? (
                  <Section icon={Briefcase} title="Experiencia">
                    <div className="card-list">
                      {experiencia.map((job, index) => {
                        const range = dateRange(job.fecha_inicio, job.fecha_fin);
                        return (
                          <div key={index} className="evidence-item">
                            <div className="row-between">
                              <strong>{clean(job.cargo) ?? "Cargo"}</strong>
                              {range ? <span className="chip">{range}</span> : null}
                            </div>
                            <span className="muted">
                              {[clean(job.empresa), clean(job.ubicacion)].filter(Boolean).join(" · ")}
                            </span>
                            {job.responsabilidades && job.responsabilidades.length > 0 ? (
                              <ul className="stack compact" style={{ margin: "0.2rem 0 0", paddingLeft: "1.1rem" }}>
                                {job.responsabilidades.map((task, taskIndex) => (
                                  <li key={taskIndex} style={{ lineHeight: 1.5 }}>
                                    {task}
                                  </li>
                                ))}
                              </ul>
                            ) : null}
                            {job.tecnologias && job.tecnologias.length > 0 ? (
                              <div className="trust-strip" style={{ marginTop: "0.3rem" }}>
                                {job.tecnologias.map((tech, techIndex) => (
                                  <span key={techIndex} className="chip">
                                    {tech}
                                  </span>
                                ))}
                              </div>
                            ) : null}
                          </div>
                        );
                      })}
                    </div>
                  </Section>
                ) : null}

                {educacion.length > 0 ? (
                  <Section icon={GraduationCap} title="Educación">
                    <div className="stack compact">
                      {educacion.map((item, index) => (
                        <div key={index} className="row-between">
                          <span>{[clean(item.titulo), clean(item.institucion)].filter(Boolean).join(" · ")}</span>
                          {clean(item.estado) || clean(item.ano) ? (
                            <span className="chip">{clean(item.estado) ?? clean(item.ano)}</span>
                          ) : null}
                        </div>
                      ))}
                    </div>
                  </Section>
                ) : null}

                {idiomas.length > 0 ? (
                  <Section icon={Languages} title="Idiomas">
                    <div className="trust-strip">
                      {idiomas.map((item, index) => (
                        <span key={index} className="chip">
                          {clean(item.idioma)}
                          {clean(item.nivel) ? ` · ${clean(item.nivel)}` : ""}
                        </span>
                      ))}
                    </div>
                  </Section>
                ) : null}

                {techSkills.length > 0 || softSkills.length > 0 ? (
                  <Section icon={Award} title="Habilidades">
                    <div className="trust-strip">
                      {[...techSkills, ...softSkills].map((skill, index) => (
                        <span key={index} className="chip">
                          {skill}
                        </span>
                      ))}
                    </div>
                  </Section>
                ) : null}
              </div>
            </Card>
          ) : null}
        </div>
      ) : null}
    </div>
  );
}
