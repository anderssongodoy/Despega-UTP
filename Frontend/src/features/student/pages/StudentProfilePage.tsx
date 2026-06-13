import { useState } from "react";
import { Award, FileText, Mic2, Plus, Sparkles } from "lucide-react";

import { createEvidence, getCv, getDiagnosis, getEvidences, getInterviewKit, getPassport } from "../student.api";
import { getCurrentUserId } from "../../../shared/auth/authStore";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";
import { EmptyState } from "../../../shared/components/EmptyState";
import { ErrorState } from "../../../shared/components/ErrorState";
import { LoadingState } from "../../../shared/components/LoadingState";
import { PitchPlayer } from "../../../shared/components/PitchPlayer";

function barClass(status: string) {
  if (status === "ready") return "bar-ready";
  if (status === "partial") return "bar-partial";
  return "bar-critical";
}

const emptyForm = { title: "", context: "", actions: "", result: "" };

export function StudentProfilePage() {
  const cv = useApi(() => getCv(), []);
  const diagnosis = useApi(() => getDiagnosis(), []);
  const passport = useApi(() => getPassport(), []);
  const interview = useApi(() => getInterviewKit(), []);

  const [evidenceKey, setEvidenceKey] = useState(0);
  const evidences = useApi(() => getEvidences(), [evidenceKey]);

  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState(emptyForm);
  const [saving, setSaving] = useState(false);

  async function saveEvidence() {
    if (!form.title.trim()) return;
    setSaving(true);
    try {
      await createEvidence(getCurrentUserId(), { ...form, type: "academic_project", skills: [] });
      setForm(emptyForm);
      setShowForm(false);
      setEvidenceKey((key) => key + 1);
    } catch {
      // keep form open on failure
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Perfil profesional</p>
        <h2>Evidencias, CV, pasaporte y entrevista</h2>
        <p className="muted">Convierte tus evidencias en un perfil listo para postular.</p>
      </section>

      {/* CV analyzer: CV generado + analisis por dimension */}
      <div className="content-grid">
        <Card>
          <p className="eyebrow">
            <FileText size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
            CV orientado a rol
          </p>
          {cv.loading ? (
            <LoadingState />
          ) : cv.error || !cv.data ? (
            <ErrorState />
          ) : (
            <div className="stack compact">
              <p className="muted">{cv.data.summary}</p>
              {cv.data.bullets.length === 0 ? (
                <EmptyState title="Aun no hay bullets" description="Agrega evidencias para generar tu CV." />
              ) : (
                <ul className="stack compact" style={{ margin: 0, paddingLeft: "1.1rem" }}>
                  {cv.data.bullets.map((bullet, index) => (
                    <li key={index} style={{ lineHeight: 1.5 }}>
                      {bullet}
                    </li>
                  ))}
                </ul>
              )}
            </div>
          )}
        </Card>

        <Card>
          <p className="eyebrow">
            <Sparkles size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
            Analisis de preparacion
          </p>
          {diagnosis.loading ? (
            <LoadingState />
          ) : diagnosis.error || !diagnosis.data ? (
            <ErrorState />
          ) : (
            <div className="stack">
              <div className="score-block">
                <span className="score-number">
                  {diagnosis.data.readinessScore}
                  <small>/100</small>
                </span>
              </div>
              <div className="stack compact">
                {diagnosis.data.dimensions.map((dim) => (
                  <div key={dim.name} className="dim-row">
                    <span>{dim.name}</span>
                    <span className="bar" aria-hidden="true">
                      <span className={barClass(dim.status)} style={{ width: `${Math.min(100, Math.max(0, dim.score))}%` }} />
                    </span>
                    <span className="dim-score">{dim.score}</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </Card>
      </div>

      {/* Pasaporte de habilidades */}
      <Card>
        <p className="eyebrow">
          <Award size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
          Pasaporte de habilidades
        </p>
        {passport.loading ? (
          <LoadingState />
        ) : passport.error || !passport.data ? (
          <ErrorState />
        ) : passport.data.skills.length === 0 ? (
          <EmptyState title="Sin habilidades registradas" description="Tus habilidades apareceran al completar evidencias." />
        ) : (
          <div className="stack compact" style={{ marginTop: "0.5rem" }}>
            {passport.data.skills.map((skill) => (
              <div key={skill.id} className="dim-row">
                <span>{skill.name}</span>
                <span className="bar" aria-hidden="true">
                  <span className="bar-ready" style={{ width: `${Math.min(100, skill.level * 20)}%` }} />
                </span>
                <span className="dim-score">{skill.level}</span>
              </div>
            ))}
          </div>
        )}
      </Card>

      {/* Evidencias + agregar */}
      <Card>
        <div className="row-between">
          <h3 style={{ margin: 0 }}>Evidencias</h3>
          <button type="button" className="btn btn-secondary" onClick={() => setShowForm((value) => !value)}>
            <Plus size={18} /> {showForm ? "Cancelar" : "Agregar evidencia"}
          </button>
        </div>

        {showForm ? (
          <div className="evidence-item" style={{ marginTop: "1rem", gap: "0.6rem" }}>
            <input
              className="field"
              placeholder="Titulo de la evidencia"
              value={form.title}
              onChange={(event) => setForm({ ...form, title: event.target.value })}
            />
            <input
              className="field"
              placeholder="Contexto (donde ocurrio)"
              value={form.context}
              onChange={(event) => setForm({ ...form, context: event.target.value })}
            />
            <input
              className="field"
              placeholder="Acciones (que hiciste)"
              value={form.actions}
              onChange={(event) => setForm({ ...form, actions: event.target.value })}
            />
            <input
              className="field"
              placeholder="Resultado (que lograste)"
              value={form.result}
              onChange={(event) => setForm({ ...form, result: event.target.value })}
            />
            <button type="button" className="btn btn-primary" onClick={saveEvidence} disabled={saving || !form.title.trim()}>
              {saving ? "Guardando…" : "Guardar evidencia"}
            </button>
          </div>
        ) : null}

        {evidences.loading ? (
          <LoadingState />
        ) : evidences.error || !evidences.data ? (
          <ErrorState />
        ) : evidences.data.evidences.length === 0 ? (
          <EmptyState title="Sin evidencias todavia" description="Completa un reto o agrega tu primera evidencia." />
        ) : (
          <div className="card-list" style={{ marginTop: "1rem" }}>
            {evidences.data.evidences.map((evidence) => (
              <div key={evidence.id} className="evidence-item">
                <div className="row-between">
                  <strong>{evidence.title}</strong>
                  <span className="chip">{evidence.type?.replace(/_/g, " ")}</span>
                </div>
                {evidence.cv_bullet ? <p className="cv-bullet">{evidence.cv_bullet}</p> : null}
              </div>
            ))}
          </div>
        )}
      </Card>

      {/* Entrevista: practica de pitch en audio */}
      <Card>
        <p className="eyebrow">
          <Mic2 size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
          Practica tu pitch
        </p>
        <h3>Entrevista</h3>
        {interview.loading ? (
          <LoadingState />
        ) : interview.error || !interview.data ? (
          <ErrorState />
        ) : (
          <div className="stack">
            <PitchPlayer pitch={interview.data.pitch} />
            <div className="stack compact">
              <span className="chip">Preguntas frecuentes</span>
              <ul className="stack compact" style={{ margin: 0, paddingLeft: "1.1rem" }}>
                {interview.data.questions.map((question, index) => (
                  <li key={index} style={{ lineHeight: 1.5 }}>
                    {question}
                  </li>
                ))}
              </ul>
            </div>
          </div>
        )}
      </Card>
    </div>
  );
}
