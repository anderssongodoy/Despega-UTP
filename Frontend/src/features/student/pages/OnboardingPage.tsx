import { useState } from "react";
import { useNavigate } from "react-router-dom";
import clsx from "clsx";
import { ArrowLeft, ArrowRight, Check } from "lucide-react";

import { completeOnboarding, getRoles } from "../student.api";
import { appRoutes } from "../../../shared/config/routes";
import { getCurrentUserId } from "../../../shared/auth/authStore";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";
import { ALL_SKILLS, SKILL_GROUPS } from "../../../shared/config/skills";
import type { OnboardingResult, Role } from "../../../shared/api/types";

// Carreras con malla/skills cargadas en la BD (data dura, no texto libre).
const CAREERS = [
  "Ingenieria de Sistemas e Informatica",
  "Administracion de Empresas",
  "Administracion de Negocios Internacionales",
  "Psicologia",
  "Derecho",
  "Ingenieria Industrial",
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
  { value: "course_project", label: "Proyecto de curso" },
  { value: "work_experience", label: "Experiencia laboral / practica" },
  { value: "volunteer", label: "Voluntariado" },
  { value: "extracurricular", label: "Competencia / actividad" },
];

const STEPS = ["Perfil", "Meta", "Autoevaluacion", "Evidencia"] as const;

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

function roleCoverage(role: Role, knownSet: Set<string>): number {
  const reqs = role.skills ?? [];
  if (reqs.length === 0) return 0;
  return reqs.filter((req) => knownSet.has(req.skillId)).length / reqs.length;
}

export function OnboardingPage() {
  const navigate = useNavigate();
  const roles = useApi(() => getRoles(), []);
  const roleOptions = roles.data?.roles ?? [{ id: "role_data_intern", name: "Practicante de Analisis de Datos" }];

  const [step, setStep] = useState(1);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [result, setResult] = useState<OnboardingResult | null>(null);

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

  // Paso 3 - Autoevaluacion (estado por skill: have = la manejo, gap = a reforzar)
  const [skillState, setSkillState] = useState<Record<string, "have" | "gap">>({});
  const [skillCat, setSkillCat] = useState(0);
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

  const knownSkills = Object.keys(skillState).filter((id) => skillState[id] === "have");
  const perceivedGaps = Object.keys(skillState).filter((id) => skillState[id] === "gap");

  function cycleSkill(id: string) {
    setSkillState((prev) => {
      const current = prev[id];
      const next = current === undefined ? "have" : current === "have" ? "gap" : undefined;
      const copy = { ...prev };
      if (next === undefined) delete copy[id];
      else copy[id] = next;
      return copy;
    });
  }

  // Sugerencia de meta: compara las skills del alumno vs los requisitos de cada rol (/roles).
  const knownSet = new Set(knownSkills);
  const currentCov = roleCoverage(roleOptions.find((role) => role.id === roleId) ?? ({ id: "", name: "" } as Role), knownSet);
  const best = roleOptions
    .map((role) => ({ role, cov: roleCoverage(role, knownSet) }))
    .sort((a, b) => b.cov - a.cov)[0];
  const suggestion = best && best.cov > 0 && best.role.id !== roleId && best.cov >= currentCov + 0.2 ? best : null;

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
      const response = await completeOnboarding(getCurrentUserId(), payload);
      setResult(response);
    } catch {
      setError("No se pudo completar el onboarding. Revisa que el backend este activo.");
    } finally {
      setSaving(false);
    }
  }

  // Pantalla de resultado (cierra el circulo). Encuadrada en positivo, sin desmotivar.
  if (result) {
    const addedEvidence = hasEvidence && evTitle.trim().length > 0;
    const gaps = result.initialDiagnosis?.criticalGaps ?? [];
    return (
      <main className="auth-page">
        <Card className="auth-card wide">
          <div className="brand-lockup">
            <span className="utp-logo">UTP</span>
            <strong>Despega UTP</strong>
          </div>
          <span className="chip" style={{ background: "rgba(34,169,149,0.15)", color: "#09685c" }}>
            <Check size={12} style={{ marginRight: 4 }} /> Perfil creado
          </span>
          <h1>¡Tu perfil esta listo!</h1>
          <p className="muted">
            Tu meta: <strong>{result.goal.roleName}</strong>. Desde aqui empezamos a prepararte para ese rol.
          </p>

          {result.initialDiagnosis.readinessScore > 0 ? (
            <div className="stack compact">
              <div className="score-block">
                <span className="score-number">
                  {result.initialDiagnosis.readinessScore}
                  <small>/100</small>
                </span>
                <span className="muted">Tu preparacion inicial · la subiremos juntos</span>
              </div>
              <div className="bar" aria-hidden="true">
                <span
                  className={
                    result.initialDiagnosis.readinessScore >= 55
                      ? "bar-ready"
                      : result.initialDiagnosis.readinessScore >= 30
                        ? "bar-partial"
                        : "bar-critical"
                  }
                  style={{ width: `${Math.min(100, result.initialDiagnosis.readinessScore)}%` }}
                />
              </div>
            </div>
          ) : null}

          {gaps.length > 0 ? (
            <div className="stack compact">
              <span className="chip">Lo que reforzaremos juntos</span>
              <div className="chip-group">
                {gaps.map((gap, index) => (
                  <span key={index} className="chip">
                    {gap}
                  </span>
                ))}
              </div>
            </div>
          ) : (
            <p className="muted" style={{ margin: 0 }}>
              Tu perfil ya cubre lo principal para tu meta. ¡Excelente arranque!
            </p>
          )}

          {addedEvidence && result.createdEvidence ? (
            <div className="evidence-item">
              <span className="chip">Tu primer punto para el CV</span>
              <p className="cv-bullet">{result.createdEvidence.cvBullet}</p>
            </div>
          ) : (
            <p className="muted" style={{ margin: 0 }}>
              Cuando quieras, agrega tu primera evidencia en tu perfil para potenciar tu CV.
            </p>
          )}

          <button
            type="button"
            className="btn btn-primary"
            onClick={() => navigate(result.redirectTo || appRoutes.studentHome)}
            style={{ marginTop: "0.5rem" }}
          >
            Ir a mi inicio <ArrowRight size={18} />
          </button>
        </Card>
      </main>
    );
  }

  return (
    <main className="auth-page">
      <Card className="auth-card wide">
        <div className="brand-lockup">
          <span className="utp-logo">UTP</span>
          <strong>Despega UTP</strong>
        </div>
        <p className="eyebrow">Bienvenido</p>
        <h1>Construyamos tu perfil</h1>
        <p className="muted">
          Paso {step} de {STEPS.length} · {STEPS[step - 1]}
        </p>

        <div className="stepper">
          {STEPS.map((label, index) => {
            const number = index + 1;
            const done = number < step;
            const active = number === step;
            return (
              <div key={label} className={clsx("step-item", active && "active", done && "done")}>
                <span className="step-dot">{done ? <Check size={14} /> : number}</span>
                {label}
              </div>
            );
          })}
        </div>

        {/* PASO 1 - Perfil academico */}
        {step === 1 ? (
          <div className="stack compact">
            <label className="eyebrow" htmlFor="career">
              Carrera
            </label>
            <select id="career" className="field" value={career} onChange={(event) => setCareer(event.target.value)}>
              <option value="" disabled>
                Selecciona tu carrera…
              </option>
              {CAREERS.map((item) => (
                <option key={item} value={item}>
                  {item}
                </option>
              ))}
            </select>

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
              Modalidad de estudio
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
            <label className="eyebrow">Tus habilidades</label>
            <p className="muted" style={{ margin: 0, fontSize: "0.85rem" }}>
              Toca una habilidad: 1 vez = <strong style={{ color: "#0f8a78" }}>la manejas</strong>, 2 veces ={" "}
              <strong style={{ color: "#a06400" }}>la quieres reforzar</strong>, 3 veces la quitas.
            </p>

            <div className="tabs" role="tablist" aria-label="Categorias de habilidades">
              {SKILL_GROUPS.map((group, index) => (
                <button
                  key={group.label}
                  type="button"
                  role="tab"
                  aria-selected={skillCat === index}
                  className={clsx("tab", skillCat === index && "active")}
                  onClick={() => setSkillCat(index)}
                >
                  {group.label}
                </button>
              ))}
            </div>

            <div className="chip-group">
              {SKILL_GROUPS[skillCat].skills.map((skill) => {
                const state = skillState[skill.id];
                return (
                  <button
                    key={skill.id}
                    type="button"
                    className={clsx("chip-toggle", state === "have" && "chip-have", state === "gap" && "chip-gap")}
                    onClick={() => cycleSkill(skill.id)}
                  >
                    {state === "have" ? "✓ " : state === "gap" ? "↗ " : ""}
                    {skill.name}
                  </button>
                );
              })}
            </div>

            {knownSkills.length > 0 || perceivedGaps.length > 0 ? (
              <p className="muted" style={{ margin: 0, fontSize: "0.82rem" }}>
                Manejas {knownSkills.length} · A reforzar {perceivedGaps.length}
              </p>
            ) : null}

            {suggestion ? (
              <div
                className="state-box"
                style={{ textAlign: "left", borderStyle: "solid", borderColor: "rgba(213,0,50,0.3)", background: "rgba(213,0,50,0.05)" }}
              >
                <strong>Por tus habilidades encajas mejor en: {suggestion.role.name}</strong>
                <p className="muted" style={{ margin: "0.2rem 0 0.6rem" }}>
                  Cubres {Math.round(suggestion.cov * 100)}% de ese rol. Tu meta actual cubre {Math.round(currentCov * 100)}%. Tu decides.
                </p>
                <button type="button" className="btn btn-secondary" onClick={() => setRoleId(suggestion.role.id)}>
                  Cambiar mi meta a {suggestion.role.name}
                </button>
              </div>
            ) : null}

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
            <div className="state-box" style={{ textAlign: "left" }}>
              <strong>¿Que es una evidencia?</strong>
              <p className="muted" style={{ margin: "0.2rem 0 0" }}>
                Cualquier logro, proyecto o experiencia donde demostraste una habilidad — <strong>no tiene que ser un
                trabajo</strong>. Ej: un proyecto de curso, una app personal, un voluntariado o una competencia. Si recien
                empiezas, puedes omitirlo.
              </p>
            </div>

            <div className="chip-group">
              <button
                type="button"
                className={clsx("chip-toggle", !hasEvidence && "selected")}
                onClick={() => setHasEvidence(false)}
              >
                Omitir por ahora
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
                  Tipo de evidencia
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
                  placeholder="Titulo (ej. Dashboard de ventas en Power BI)"
                  value={evTitle}
                  onChange={(event) => setEvTitle(event.target.value)}
                />
                <input
                  className="field"
                  placeholder="Contexto: donde y cuando lo hiciste"
                  value={evContext}
                  onChange={(event) => setEvContext(event.target.value)}
                />
                <input
                  className="field"
                  placeholder="Acciones: que hiciste tu"
                  value={evActions}
                  onChange={(event) => setEvActions(event.target.value)}
                />
                <input
                  className="field"
                  placeholder="Resultado: que lograste (con numeros si puedes)"
                  value={evResult}
                  onChange={(event) => setEvResult(event.target.value)}
                />
                <label className="eyebrow">Habilidades que demuestra</label>
                <ChipMulti options={ALL_SKILLS} selected={evSkills} onToggle={(id) => toggle(evSkills, setEvSkills, id)} />
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
              {saving ? "Guardando…" : "Completar perfil"} <Check size={18} />
            </button>
          )}
        </div>
      </Card>
    </main>
  );
}
