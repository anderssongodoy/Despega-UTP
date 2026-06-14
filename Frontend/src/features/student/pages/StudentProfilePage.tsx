import { useState } from "react";
import clsx from "clsx";
import { ExternalLink, Link2, Mic2, Plus, Sparkles } from "lucide-react";

import { createEvidence, getEvidences, getInterviewKit, getStudentDashboard } from "../student.api";
import { getCurrentUserId, useSession } from "../../../shared/auth/authStore";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";
import { EmptyState } from "../../../shared/components/EmptyState";
import { ErrorState } from "../../../shared/components/ErrorState";
import { LoadingState } from "../../../shared/components/LoadingState";
import { PitchCoach } from "../components/PitchCoach";
import { CvAnalyzer } from "../components/CvAnalyzer";
import { StudentPortfolio } from "../components/StudentPortfolio";

const TABS = ["CV", "Evidencias", "Entrevista", "Portafolio"] as const;
type Tab = (typeof TABS)[number];

function ProfileHeader() {
  const dash = useApi(() => getStudentDashboard(), []);
  const session = useSession();
  const studentId = getCurrentUserId();
  const shareUrl = `${window.location.origin}/portfolio/${studentId}`;
  const [copied, setCopied] = useState(false);

  function copy() {
    navigator.clipboard
      ?.writeText(shareUrl)
      .then(() => {
        setCopied(true);
        window.setTimeout(() => setCopied(false), 2000);
      })
      .catch(() => undefined);
  }

  const name = dash.data?.student.name ?? session?.user.name ?? "Mi perfil";
  const initial = name.charAt(0).toUpperCase();
  const meta = [
    dash.data?.student.career,
    dash.data?.student.cycle ? `${dash.data.student.cycle} ciclo` : null,
    dash.data?.goal.roleName,
  ]
    .filter(Boolean)
    .join(" · ");

  return (
    <Card>
      <div className="profile-hero">
        <span className="avatar">{initial}</span>
        <div className="stack compact" style={{ gap: "0.25rem", minWidth: 0 }}>
          <h2>{name}</h2>
          {meta ? (
            <p className="muted" style={{ margin: 0 }}>
              {meta}
            </p>
          ) : null}
          <div style={{ display: "flex", flexWrap: "wrap", gap: "0.5rem", marginTop: "0.3rem" }}>
            {typeof dash.data?.goal.readinessScore === "number" ? (
              <span className="chip">Preparacion {dash.data.goal.readinessScore}/100</span>
            ) : null}
            {typeof dash.data?.progress.evidences === "number" ? (
              <span className="chip">{dash.data.progress.evidences} evidencias</span>
            ) : null}
          </div>
        </div>
        <div className="hero-actions" style={{ display: "flex", gap: "0.6rem" }}>
          <a className="btn btn-secondary" href={shareUrl} target="_blank" rel="noreferrer">
            <ExternalLink size={18} /> Ver portafolio
          </a>
          <button type="button" className="btn btn-primary" onClick={copy}>
            <Link2 size={18} /> {copied ? "Copiado!" : "Compartir"}
          </button>
        </div>
      </div>
    </Card>
  );
}

function CvTab() {
  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">
          <Sparkles size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
          Analizador de CV con IA
        </p>
        <h2>Sube tu CV y recibe un diagnóstico real</h2>
        <p className="muted">
          Detecta fortalezas, vacíos y tu score ATS, y revisa tu CV contra la metodología de empleabilidad de la Ruta
          Laboral UTP.
        </p>
      </section>
      <CvAnalyzer />
    </div>
  );
}

const emptyForm = { title: "", context: "", actions: "", result: "" };

function EvidencesTab() {
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
    <Card>
      <div className="row-between">
        <div>
          <h3 style={{ margin: 0 }}>Evidencias</h3>
          <p className="muted" style={{ margin: "0.2rem 0 0" }}>Tus logros y proyectos: la materia prima de tu CV.</p>
        </div>
        <button type="button" className="btn btn-secondary" onClick={() => setShowForm((value) => !value)}>
          <Plus size={18} /> {showForm ? "Cancelar" : "Agregar evidencia"}
        </button>
      </div>

      {showForm ? (
        <div className="evidence-item" style={{ marginTop: "1rem", gap: "0.6rem" }}>
          <input className="field" placeholder="Titulo de la evidencia" value={form.title} onChange={(event) => setForm({ ...form, title: event.target.value })} />
          <input className="field" placeholder="Contexto (donde ocurrio)" value={form.context} onChange={(event) => setForm({ ...form, context: event.target.value })} />
          <input className="field" placeholder="Acciones (que hiciste)" value={form.actions} onChange={(event) => setForm({ ...form, actions: event.target.value })} />
          <input className="field" placeholder="Resultado (que lograste)" value={form.result} onChange={(event) => setForm({ ...form, result: event.target.value })} />
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
  );
}

function InterviewTab() {
  const interview = useApi(() => getInterviewKit(), []);

  return (
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
          <div className="stack compact">
            <span className="chip">Responde estas preguntas en tu pitch</span>
            <ul className="stack compact" style={{ margin: 0, paddingLeft: "1.1rem" }}>
              {interview.data.questions.map((question, index) => (
                <li key={index} style={{ lineHeight: 1.5 }}>
                  {question}
                </li>
              ))}
            </ul>
          </div>
          <PitchCoach />
        </div>
      )}
    </Card>
  );
}

function PortfolioTab() {
  const studentId = getCurrentUserId();
  return (
    <div className="stack">
      <p className="muted" style={{ margin: 0 }}>
        Asi se ve tu portafolio publico. Comparte el link con el boton de arriba.
      </p>
      <StudentPortfolio studentId={studentId} />
    </div>
  );
}

export function StudentProfilePage() {
  const [tab, setTab] = useState<Tab>("CV");

  return (
    <div className="stack">
      <ProfileHeader />

      <div className="tabs" role="tablist" aria-label="Secciones del perfil">
        {TABS.map((item) => (
          <button
            key={item}
            type="button"
            role="tab"
            aria-selected={tab === item}
            className={clsx("tab", tab === item && "active")}
            onClick={() => setTab(item)}
          >
            {item}
          </button>
        ))}
      </div>

      {tab === "CV" ? <CvTab /> : null}
      {tab === "Evidencias" ? <EvidencesTab /> : null}
      {tab === "Entrevista" ? <InterviewTab /> : null}
      {tab === "Portafolio" ? <PortfolioTab /> : null}
    </div>
  );
}
