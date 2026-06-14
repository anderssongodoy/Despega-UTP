import { useState } from "react";
import { useNavigate } from "react-router-dom";
import clsx from "clsx";
import { ArrowLeft, ArrowRight, Check } from "lucide-react";

import { completeOnboarding, getRoles } from "../student.api";
import { appRoutes } from "../../../shared/config/routes";
import { getCurrentUserId } from "../../../shared/auth/authStore";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";

const CAREERS = [
  "Ingenieria de Sistemas e Informatica",
  "Ingenieria de Software",
  "Ingenieria Industrial",
  "Administracion",
  "Marketing",
  "Comunicaciones",
  "Psicologia",
  "Contabilidad",
  "Diseno Grafico",
];

const CAMPUSES = ["Lima Centro", "Lima Norte", "Lima Sur", "Arequipa", "A distancia"];
const MODALITIES = ["Presencial", "Semipresencial", "A distancia"];
const AVAILABILITIES = [
  "Medio tiempo",
  "Practicas preprofesionales - 30h",
  "Tiempo completo",
  "Solo fines de semana",
];
const WORK_MODES = ["Hibrido", "Presencial", "Remoto"];
const TIMEFRAMES = ["Aun explorando", "Este ciclo", "En 1 mes", "En las proximas 2 semanas"];
const ENGLISH_LEVELS = ["Basico", "Intermedio", "Avanzado"];
const CV_STATUS = [
  { value: "missing", label: "Aun no tengo CV" },
  { value: "incomplete", label: "Lo tengo incompleto" },
  { value: "updated", label: "Esta actualizado" },
];
const EVIDENCE_TYPES = [
  { value: "academic_project", label: "Proyecto academico" },
  { value: "work_experience", label: "Experiencia laboral" },
  { value: "volunteer", label: "Voluntariado" },
  { value: "course_project", label: "Proyecto de curso" },
  { value: "extracurricular", label: "Actividad extracurricular" },
];

const SKILLS = [
  { id: "sk_excel", name: "Excel" },
  { id: "sk_powerbi", name: "Power BI" },
  { id: "sk_sql", name: "SQL" },
  { id: "sk_python", name: "Python" },
  { id: "sk_git", name: "Git" },
  { id: "sk_english", name: "Ingles" },
  { id: "sk_communication", name: "Comunicacion" },
  { id: "sk_writing", name: "Redaccion" },
  { id: "sk_digital_marketing", name: "Marketing Digital" },
  { id: "sk_problem_solving", name: "Resolucion de problemas" },
  { id: "sk_critical_thinking", name: "Pensamiento critico" },
  { id: "sk_organization", name: "Organizacion" },
  { id: "sk_process_management", name: "Gestion de procesos" },
  { id: "sk_interview", name: "Entrevista" },
];

const STEPS = ["Perfil", "Meta", "Autoevaluacion", "Evidencia"];

function ChipMulti({
  options,
  selected,
  onToggle,
}: {
  options: { id: string; name: string }[];
  selected: string[];
  onToggle: (id: string) => void;
}) {
  return (
    <div className="chip-group">
      {options.map((option) => (
        <button
          key={option.id}
          type="button"
          className={clsx("chip-toggle", selected.includes(option.id) && "selected")}
          aria-pressed={selected.includes(option.id)}
          onClick={() => onToggle(option.id)}
        >
          {option.name}
        </button>
      ))}
    </div>
  );
}

export function OnboardingPage() {
  const navigate = useNavigate();
  const roles = useApi(() => getRoles(), []);
  const roleOptions = roles.data?.roles ?? [{ id: "role_data_intern", name: "Practicante de Analisis de Datos" }];

  const [step, setStep] = useState(1);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  // Paso 1 - Perfil academico
  const [career, setCareer] = useState("");
  const [cycle, setCycle] = useState(1);
  const [campus, setCampus] = useState("Lima Centro");
  const [modality, setModality] = useState("Presencial");

  // Paso 2 - Meta laboral
  const [roleId, setRoleId] = useState("");
  const [availability, setAvailability] = useState("Medio tiempo");
  const [workMode, setWorkMode] = useState("Hibrido");
  const [timeframe, setTimeframe] = useState("Aun explorando");

  // Paso 3 - Autoevaluacion
  const [knownSkills, setKnownSkills] = useState<string[]>([]);
  const [perceivedGaps, setPerceivedGaps] = useState<string[]>([]);
  const [cvStatus, setCvStatus] = useState("missing");
  const [englishLevel, setEnglishLevel] = useState("Basico");
  const [linkedinUrl, setLinkedinUrl] = useState("");

  // Paso 4 - Evidencia (opcional)
  const [hasEvidence, setHasEvidence] = useState(false);
  const [evType, setEvType] = useState("academic_project");
  const [evTitle, setEvTitle] = useState("");
  const [evContext, setEvContext] = useState("");
  const [evActions, setEvActions] = useState("");
  const [evResult, setEvResult] = useState("");
  const [evSkills, setEvSkills] = useState<string[]>([]);

  function toggle(list: string[], setList: (value: string[]) => void, id: string) {
    setList(list.includes(id) ? list.filter((item) => item !== id) : [...list, id]);
  }

  const stepValid: Record<number, boolean> = {
    1: career.trim().length > 0 && cycle >= 1 && cycle <= 12 && !!campus && !!modality,
    2: !!roleId && !!availability && !!workMode && !!timeframe,
    3: !!cvStatus,
    4: !hasEvidence || evTitle.trim().length > 0,
  };

  async function finish() {
    setSaving(true);
    setError("");
    const selectedRole = roleOptions.find((role) => role.id === roleId);
    const payload: Record<string, unknown> = {
      academicProfile: { career: career.trim(), cycle: Number(cycle), campus, modality },
      employmentGoal: {
        targetRoleId: roleId,
        targetRoleName: selectedRole?.name ?? "",
        availability,
        preferredWorkMode: workMode,
        applicationTimeframe: timeframe,
      },
      selfAssessment: {
        knownSkills,
        perceivedGaps,
        cvStatus,
        englishLevel,
        linkedinUrl: linkedinUrl.trim(),
      },
    };
    if (hasEvidence && evTitle.trim()) {
      payload.initialEvidence = {
        type: evType,
        title: evTitle.trim(),
        context: evContext.trim(),
        actions: evActions.trim(),
        result: evResult.trim(),
        skills: evSkills,
      };
    }
    try {
      await completeOnboarding(getCurrentUserId(), payload);
      navigate(appRoutes.studentHome);
    } catch {
      setError("No se pudo completar el onboarding. Revisa que el backend este activo.");
    } finally {
      setSaving(false);
    }
  }

  return (
    <main className="auth-page">
      <Card className="auth-card wide">
        <div className="brand-lockup">
          <span className="utp-logo">UTP</span>
          <strong>Despega UTP</strong>
        </div>
        <p className="eyebrow">Primera vez</p>
        <h1>Cuentanos sobre ti</h1>
        <p className="muted">Toma 1 minuto. Si recien empiezas, deja vacio lo que no aplique.</p>

        <div className="onboarding-steps">
          {STEPS.map((label, index) => {
            const number = index + 1;
            return (
              <span key={label} className={clsx(number === step && "active", number < step && "done")}>
                {number < step ? <Check size={14} style={{ verticalAlign: "-2px" }} /> : `${number}.`} {label}
              </span>
            );
          })}
        </div>

        {/* PASO 1 - Perfil academico */}
        {step === 1 ? (
          <div className="stack compact">
            <label className="eyebrow" htmlFor="career">
              Carrera
            </label>
            <input
              id="career"
              className="field"
              list="careers"
              placeholder="Escribe o elige tu carrera"
              value={career}
              onChange={(event) => setCareer(event.target.value)}
            />
            <datalist id="careers">
              {CAREERS.map((item) => (
                <option key={item} value={item} />
              ))}
            </datalist>

            <label className="eyebrow" htmlFor="cycle">
              Ciclo (1 a 12)
            </label>
            <input
              id="cycle"
              type="number"
              min={1}
              max={12}
              className="field"
              value={cycle}
              onChange={(event) => setCycle(Number(event.target.value))}
            />

            <label className="eyebrow" htmlFor="campus">
              Campus
            </label>
            <select id="campus" className="field" value={campus} onChange={(event) => setCampus(event.target.value)}>
              {CAMPUSES.map((item) => (
                <option key={item} value={item}>
                  {item}
                </option>
              ))}
            </select>

            <label className="eyebrow" htmlFor="modality">
              Modalidad
            </label>
            <select id="modality" className="field" value={modality} onChange={(event) => setModality(event.target.value)}>
              {MODALITIES.map((item) => (
                <option key={item} value={item}>
                  {item}
                </option>
              ))}
            </select>
          </div>
        ) : null}

        {/* PASO 2 - Meta laboral */}
        {step === 2 ? (
          <div className="stack compact">
            <label className="eyebrow" htmlFor="role">
              Rol al que apuntas
            </label>
            <select id="role" className="field" value={roleId} onChange={(event) => setRoleId(event.target.value)}>
              <option value="" disabled>
                Selecciona un rol…
              </option>
              {roleOptions.map((role) => (
                <option key={role.id} value={role.id}>
                  {role.name}
                </option>
              ))}
            </select>

            <label className="eyebrow" htmlFor="availability">
              Disponibilidad
            </label>
            <select
              id="availability"
              className="field"
              value={availability}
              onChange={(event) => setAvailability(event.target.value)}
            >
              {AVAILABILITIES.map((item) => (
                <option key={item} value={item}>
                  {item}
                </option>
              ))}
            </select>

            <label className="eyebrow" htmlFor="workmode">
              Modalidad de trabajo preferida
            </label>
            <select id="workmode" className="field" value={workMode} onChange={(event) => setWorkMode(event.target.value)}>
              {WORK_MODES.map((item) => (
                <option key={item} value={item}>
                  {item}
                </option>
              ))}
            </select>

            <label className="eyebrow" htmlFor="timeframe">
              Cuando quieres postular
            </label>
            <select id="timeframe" className="field" value={timeframe} onChange={(event) => setTimeframe(event.target.value)}>
              {TIMEFRAMES.map((item) => (
                <option key={item} value={item}>
                  {item}
                </option>
              ))}
            </select>
          </div>
        ) : null}

        {/* PASO 3 - Autoevaluacion */}
        {step === 3 ? (
          <div className="stack compact">
            <label className="eyebrow">Habilidades que ya manejas (opcional)</label>
            <ChipMulti options={SKILLS} selected={knownSkills} onToggle={(id) => toggle(knownSkills, setKnownSkills, id)} />

            <label className="eyebrow" style={{ marginTop: "0.6rem" }}>
              Habilidades que quieres reforzar (opcional)
            </label>
            <ChipMulti
              options={SKILLS}
              selected={perceivedGaps}
              onToggle={(id) => toggle(perceivedGaps, setPerceivedGaps, id)}
            />

            <label className="eyebrow" htmlFor="cv" style={{ marginTop: "0.6rem" }}>
              Estado de tu CV
            </label>
            <select id="cv" className="field" value={cvStatus} onChange={(event) => setCvStatus(event.target.value)}>
              {CV_STATUS.map((item) => (
                <option key={item.value} value={item.value}>
                  {item.label}
                </option>
              ))}
            </select>

            <label className="eyebrow" htmlFor="english">
              Nivel de ingles
            </label>
            <select id="english" className="field" value={englishLevel} onChange={(event) => setEnglishLevel(event.target.value)}>
              {ENGLISH_LEVELS.map((item) => (
                <option key={item} value={item}>
                  {item}
                </option>
              ))}
            </select>

            <label className="eyebrow" htmlFor="linkedin">
              LinkedIn (opcional)
            </label>
            <input
              id="linkedin"
              className="field"
              placeholder="https://linkedin.com/in/…"
              value={linkedinUrl}
              onChange={(event) => setLinkedinUrl(event.target.value)}
            />
          </div>
        ) : null}

        {/* PASO 4 - Evidencia (opcional) */}
        {step === 4 ? (
          <div className="stack compact">
            <p className="muted" style={{ margin: 0 }}>
              Una evidencia es un logro, proyecto o experiencia que demuestre lo que sabes hacer.
              <strong> Si recien empiezas y aun no tienes una, puedes omitir este paso.</strong>
            </p>
            <div className="chip-group">
              <button
                type="button"
                className={clsx("chip-toggle", !hasEvidence && "selected")}
                onClick={() => setHasEvidence(false)}
              >
                No tengo todavia
              </button>
              <button
                type="button"
                className={clsx("chip-toggle", hasEvidence && "selected")}
                onClick={() => setHasEvidence(true)}
              >
                Quiero agregar una
              </button>
            </div>

            {hasEvidence ? (
              <div className="stack compact" style={{ marginTop: "0.4rem" }}>
                <label className="eyebrow" htmlFor="ev-type">
                  Tipo
                </label>
                <select id="ev-type" className="field" value={evType} onChange={(event) => setEvType(event.target.value)}>
                  {EVIDENCE_TYPES.map((item) => (
                    <option key={item.value} value={item.value}>
                      {item.label}
                    </option>
                  ))}
                </select>
                <input
                  className="field"
                  placeholder="Titulo (ej. Dashboard de ventas)"
                  value={evTitle}
                  onChange={(event) => setEvTitle(event.target.value)}
                />
                <input
                  className="field"
                  placeholder="Contexto (donde / cuando)"
                  value={evContext}
                  onChange={(event) => setEvContext(event.target.value)}
                />
                <input
                  className="field"
                  placeholder="Que hiciste"
                  value={evActions}
                  onChange={(event) => setEvActions(event.target.value)}
                />
                <input
                  className="field"
                  placeholder="Que lograste"
                  value={evResult}
                  onChange={(event) => setEvResult(event.target.value)}
                />
                <label className="eyebrow">Habilidades que demuestra</label>
                <ChipMulti options={SKILLS} selected={evSkills} onToggle={(id) => toggle(evSkills, setEvSkills, id)} />
              </div>
            ) : null}
          </div>
        ) : null}

        {error ? (
          <p className="error-text" role="alert">
            {error}
          </p>
        ) : null}

        {/* Navegacion */}
        <div className="row-between" style={{ marginTop: "0.5rem" }}>
          {step > 1 ? (
            <button type="button" className="btn btn-ghost" onClick={() => setStep(step - 1)}>
              <ArrowLeft size={18} /> Atras
            </button>
          ) : (
            <span />
          )}

          {step < STEPS.length ? (
            <button
              type="button"
              className="btn btn-primary"
              onClick={() => setStep(step + 1)}
              disabled={!stepValid[step]}
            >
              Siguiente <ArrowRight size={18} />
            </button>
          ) : (
            <button type="button" className="btn btn-primary" onClick={finish} disabled={saving || !stepValid[4]}>
              {saving ? "Guardando…" : "Completar onboarding"} <Check size={18} />
            </button>
          )}
        </div>
      </Card>
    </main>
  );
}
