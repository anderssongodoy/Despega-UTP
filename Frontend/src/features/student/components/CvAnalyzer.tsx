import { useRef, useState } from "react";
import type { ChangeEvent } from "react";
import {
  Briefcase,
  CheckCircle2,
  Code2,
  FileUp,
  GraduationCap,
  Languages,
  Lightbulb,
  Link2,
  Mail,
  MapPin,
  Phone,
  TriangleAlert,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";

import { analyzeCv } from "../cv.api";
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

function ScoreBar({ label, value }: { label: string; value: number }) {
  const safe = Math.min(100, Math.max(0, value));
  return (
    <div className="dim-row">
      <span>{label}</span>
      <span className="bar" aria-hidden="true">
        <span
          className={safe >= 70 ? "bar-ready" : safe >= 45 ? "bar-partial" : "bar-critical"}
          style={{ width: `${safe}%` }}
        />
      </span>
      <span className="dim-score">{value}</span>
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

export function CvAnalyzer() {
  const inputRef = useRef<HTMLInputElement>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [fileName, setFileName] = useState("");
  const [cv, setCv] = useState<CvAnalysis | null>(null);

  async function onPick(event: ChangeEvent<HTMLInputElement>) {
    const file = event.target.files?.[0];
    event.target.value = "";
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

  return (
    <div className="stack">
      <input ref={inputRef} type="file" accept="application/pdf,.pdf" onChange={onPick} style={{ display: "none" }} />
      <div className="pitch-controls">
        <button type="button" className="btn btn-primary" onClick={() => inputRef.current?.click()} disabled={loading}>
          <FileUp size={18} /> {loading ? "Analizando…" : fileName ? "Subir otro PDF" : "Subir mi CV (PDF)"}
        </button>
        {fileName ? (
          <span className="muted" style={{ alignSelf: "center", fontSize: "0.85rem" }}>
            {fileName}
          </span>
        ) : null}
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
          {/* Cabecera */}
          {(fullName || clean(cv.profesion) || contacts.length > 0) ? (
            <div className="evidence-item" style={{ gap: "0.5rem" }}>
              {fullName ? <strong style={{ fontSize: "1.15rem" }}>{fullName}</strong> : null}
              {clean(cv.profesion) ? <span className="muted">{clean(cv.profesion)}</span> : null}
              {contacts.length > 0 ? (
                <div className="trust-strip" style={{ marginTop: "0.2rem" }}>
                  {contacts.map((contact, index) => {
                    const Icon = contact.icon;
                    return (
                      <span key={index}>
                        <Icon size={14} /> {contact.value}
                      </span>
                    );
                  })}
                </div>
              ) : null}
            </div>
          ) : null}

          {/* Scores */}
          {(typeof cv.score === "number" || typeof cv.ats_score === "number") ? (
            <div className="stack compact">
              {typeof cv.score === "number" ? <ScoreBar label="Calidad del CV" value={cv.score} /> : null}
              {typeof cv.ats_score === "number" ? <ScoreBar label="ATS friendly" value={cv.ats_score} /> : null}
            </div>
          ) : null}

          {/* Resumen */}
          {clean(cv.resumen) ? <p className="muted" style={{ margin: 0, lineHeight: 1.6 }}>{clean(cv.resumen)}</p> : null}

          {/* Experiencia */}
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

          {/* Educación */}
          {educacion.length > 0 ? (
            <Section icon={GraduationCap} title="Educacion">
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

          {/* Idiomas */}
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

          {/* Skills */}
          {techSkills.length > 0 || softSkills.length > 0 ? (
            <Section icon={CheckCircle2} title="Habilidades">
              <div className="trust-strip">
                {[...techSkills, ...softSkills].map((skill, index) => (
                  <span key={index} className="chip">
                    {skill}
                  </span>
                ))}
              </div>
            </Section>
          ) : null}

          {/* Fortalezas (solo si hay) */}
          {fortalezas.length > 0 ? (
            <Section icon={CheckCircle2} title="Fortalezas">
              <ul className="stack compact" style={{ margin: 0, paddingLeft: "1.1rem" }}>
                {fortalezas.map((item, index) => (
                  <li key={index} style={{ lineHeight: 1.5 }}>
                    {item}
                  </li>
                ))}
              </ul>
            </Section>
          ) : null}

          {/* Por mejorar */}
          {faltantes.length > 0 ? (
            <Section icon={TriangleAlert} title="Por mejorar">
              <ul className="stack compact" style={{ margin: 0, paddingLeft: "1.1rem" }}>
                {faltantes.map((item, index) => (
                  <li key={index} style={{ lineHeight: 1.5 }}>
                    {item}
                  </li>
                ))}
              </ul>
            </Section>
          ) : null}

          {/* Recomendaciones (solo si hay) */}
          {recomendaciones.length > 0 ? (
            <Section icon={Lightbulb} title="Recomendaciones">
              <ul className="stack compact" style={{ margin: 0, paddingLeft: "1.1rem" }}>
                {recomendaciones.map((item, index) => (
                  <li key={index} style={{ lineHeight: 1.5 }}>
                    {item}
                  </li>
                ))}
              </ul>
            </Section>
          ) : null}
        </div>
      ) : null}
    </div>
  );
}
