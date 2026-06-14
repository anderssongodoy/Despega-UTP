import { useEffect, useRef, useState } from "react";
import { Check, CheckCircle2, Circle, Lightbulb, Mic, Sparkles, TriangleAlert } from "lucide-react";

import { analyzePitchAudio } from "../audio.api";
import type { AudioDimension, PitchAnalysis, PitchStructure } from "../../../shared/api/types";

// Estructura del elevator pitch (curso Ruta Laboral UTP).
const PITCH_STEPS: { key: keyof PitchStructure; label: string; hint: string }[] = [
  { key: "presentacion", label: "Preséntate", hint: "Tu nombre, carrera y en qué te especializas." },
  { key: "propuesta_valor", label: "Tu propuesta de valor", hint: "Qué ofreces: habilidades y fortalezas clave." },
  { key: "problema_o_necesidad", label: "Problema que atiendes", hint: "Qué necesidad del puesto o empresa puedes resolver." },
  { key: "solucion_o_aporte", label: "Tu aporte", hint: "Cómo lo resuelves, con un ejemplo o evidencia (STAR)." },
  { key: "beneficios", label: "Beneficios", hint: "Qué impacto concreto generas (resultados, mejoras)." },
  { key: "por_que_tu", label: "Por qué tú", hint: "Qué te diferencia de otros candidatos." },
  { key: "llamado_a_accion", label: "Cierre / llamado a la acción", hint: "Invita a continuar la conversación. ~1 minuto en total." },
];

function errorMessage(error: unknown, fallback: string): string {
  if (error && typeof error === "object" && "payload" in error) {
    const payload = (error as { payload?: { detail?: string } }).payload;
    if (payload?.detail) return payload.detail;
  }
  return fallback;
}

function DimBar({ label, dim }: { label: string; dim?: AudioDimension }) {
  const score = dim?.puntaje ?? 0;
  return (
    <div className="stack compact" style={{ gap: "0.2rem" }}>
      <div className="dim-row">
        <span>{label}</span>
        <span className="bar" aria-hidden="true">
          <span
            className={score >= 7 ? "bar-ready" : score >= 4 ? "bar-partial" : "bar-critical"}
            style={{ width: `${Math.min(100, score * 10)}%` }}
          />
        </span>
        <span className="dim-score">{score}/10</span>
      </div>
      {dim?.observacion ? (
        <small className="muted" style={{ lineHeight: 1.4 }}>
          {dim.observacion}
        </small>
      ) : null}
    </div>
  );
}

function StringList({ items }: { items?: string[] }) {
  if (!items || items.length === 0) return null;
  return (
    <ul className="stack compact" style={{ margin: 0, paddingLeft: "1.1rem" }}>
      {items.map((item, index) => (
        <li key={index} style={{ lineHeight: 1.5 }}>
          {item}
        </li>
      ))}
    </ul>
  );
}

export function PitchCoach() {
  const [recording, setRecording] = useState(false);
  const [seconds, setSeconds] = useState(0);
  const [audioUrl, setAudioUrl] = useState<string | null>(null);
  const [analyzing, setAnalyzing] = useState(false);
  const [analysis, setAnalysis] = useState<PitchAnalysis | null>(null);
  const [transcript, setTranscript] = useState("");
  const [error, setError] = useState("");
  const [devices, setDevices] = useState<MediaDeviceInfo[]>([]);
  const [deviceId, setDeviceId] = useState("");
  const recorderRef = useRef<MediaRecorder | null>(null);
  const chunksRef = useRef<Blob[]>([]);
  const blobRef = useRef<Blob | null>(null);
  const timerRef = useRef<number | null>(null);

  useEffect(() => () => {
    if (timerRef.current) window.clearInterval(timerRef.current);
  }, []);

  async function loadDevices() {
    try {
      const all = await navigator.mediaDevices.enumerateDevices();
      setDevices(all.filter((device) => device.kind === "audioinput"));
    } catch {
      // ignore
    }
  }

  useEffect(() => {
    loadDevices();
  }, []);

  const mmss = `${Math.floor(seconds / 60)}:${String(seconds % 60).padStart(2, "0")}`;
  const recordSupported =
    typeof navigator !== "undefined" && !!navigator.mediaDevices && typeof MediaRecorder !== "undefined";

  async function startRecording() {
    if (!recordSupported) {
      setError("Tu navegador no permite grabar audio.");
      return;
    }
    try {
      // Punto medio: noiseSuppression ON (tapa el ruido electrico "piiiii"),
      // echoCancellation OFF (es la que "ahoga" la voz) y autoGainControl OFF
      // (amplifica el ruido).
      const stream = await navigator.mediaDevices.getUserMedia({
        audio: {
          ...(deviceId ? { deviceId: { exact: deviceId } } : {}),
          echoCancellation: false,
          noiseSuppression: true,
          autoGainControl: false,
        },
      });
      loadDevices(); // con permiso concedido ya aparecen los nombres de los micros

      // Sube el volumen de la voz con un GainNode (control manual, NO autoGainControl).
      const audioCtx = new AudioContext();
      await audioCtx.resume();
      const source = audioCtx.createMediaStreamSource(stream);
      const gainNode = audioCtx.createGain();
      gainNode.gain.value = 1.6;
      const destination = audioCtx.createMediaStreamDestination();
      source.connect(gainNode).connect(destination);

      const recorder = new MediaRecorder(destination.stream, { audioBitsPerSecond: 128000 });
      chunksRef.current = [];
      recorder.ondataavailable = (event) => {
        if (event.data.size > 0) chunksRef.current.push(event.data);
      };
      recorder.onstop = () => {
        const blob = new Blob(chunksRef.current, { type: "audio/webm" });
        blobRef.current = blob;
        setAudioUrl((prev) => {
          if (prev) URL.revokeObjectURL(prev);
          return URL.createObjectURL(blob);
        });
        stream.getTracks().forEach((track) => track.stop());
        audioCtx.close();
      };
      recorderRef.current = recorder;
      recorder.start();
      setError("");
      setAnalysis(null);
      setRecording(true);
      setSeconds(0);
      timerRef.current = window.setInterval(() => setSeconds((value) => value + 1), 1000);
    } catch {
      setError("No se pudo acceder al microfono. Revisa los permisos.");
      setRecording(false);
    }
  }

  function stopRecording() {
    recorderRef.current?.stop();
    setRecording(false);
    if (timerRef.current) {
      window.clearInterval(timerRef.current);
      timerRef.current = null;
    }
  }

  async function analyze() {
    if (!blobRef.current) return;
    setAnalyzing(true);
    setError("");
    try {
      const response = await analyzePitchAudio(blobRef.current);
      setAnalysis(response.data.analisis);
      setTranscript(response.data.transcripcion?.transcripcion_completa ?? "");
    } catch (err) {
      setError(errorMessage(err, "No se pudo analizar el audio. Revisa el backend y la OPENAI_API_KEY."));
    } finally {
      setAnalyzing(false);
    }
  }

  const evaluation = analysis?.evaluacion_discurso;
  const rawTotal = evaluation?.puntaje_total ?? 0;
  const total = rawTotal <= 10 ? Math.round(rawTotal * 10) : Math.round(rawTotal);
  const structure = analysis?.estructura_pitch;

  return (
    <div className="stack">
      {/* Guia: como armar tu pitch (UTP) */}
      <div className="stack compact">
        <span className="chip">Cómo armar tu pitch (~1 min)</span>
        <div className="card-list">
          {PITCH_STEPS.map((step, index) => {
            const covered = structure?.[step.key];
            return (
              <div key={step.key} className="list-row" style={{ alignItems: "flex-start", gap: "0.6rem" }}>
                <span className="row-icon" style={analysis ? (covered ? { color: "var(--color-teal)", background: "rgba(34,169,149,0.12)" } : { color: "var(--color-red)", background: "var(--color-critical)" }) : undefined}>
                  {analysis ? covered ? <Check size={16} /> : <Circle size={14} /> : index + 1}
                </span>
                <span className="stack compact" style={{ gap: "0.05rem" }}>
                  <strong>{step.label}</strong>
                  <small className="muted">{step.hint}</small>
                </span>
              </div>
            );
          })}
        </div>
      </div>

      {/* Grabar y analizar */}
      <div className="stack compact">
        <span className="chip">Graba tu pitch y recibe feedback</span>
        {devices.length > 1 ? (
          <select
            className="field"
            value={deviceId}
            onChange={(event) => setDeviceId(event.target.value)}
            disabled={recording}
            aria-label="Microfono"
          >
            <option value="">Microfono por defecto</option>
            {devices.map((device, index) => (
              <option key={device.deviceId} value={device.deviceId}>
                {device.label || `Microfono ${index + 1}`}
              </option>
            ))}
          </select>
        ) : null}
        <div className="pitch-controls">
          {recording ? (
            <button type="button" className="btn btn-secondary" onClick={stopRecording}>
              <span className="recording-dot" /> Detener grabacion
            </button>
          ) : (
            <button type="button" className="btn btn-secondary" onClick={startRecording}>
              <Mic size={18} /> {audioUrl ? "Grabar de nuevo" : "Grabar mi pitch"}
            </button>
          )}
          {audioUrl && !recording ? (
            <button type="button" className="btn btn-primary" onClick={analyze} disabled={analyzing}>
              <Sparkles size={18} /> {analyzing ? "Analizando…" : "Analizar mi pitch"}
            </button>
          ) : null}
          {recording ? (
            <span className="muted" style={{ alignSelf: "center", fontWeight: 700, fontVariantNumeric: "tabular-nums" }}>
              {mmss} · apunta a ~1 min
            </span>
          ) : null}
        </div>
        {audioUrl ? (
          // eslint-disable-next-line jsx-a11y/media-has-caption
          <audio controls src={audioUrl} style={{ width: "100%" }} />
        ) : null}
      </div>

      {error ? (
        <p className="error-text" role="alert">
          <TriangleAlert size={16} /> {error}
        </p>
      ) : null}

      {analysis ? (
        <div className="stack">
          <div className="row-between" style={{ flexWrap: "wrap", gap: "0.5rem" }}>
            <div className="score-block">
              <span className="score-number">
                {total}
                <small>/100</small>
              </span>
              {analysis.nivel_comunicacion ? <span className="chip">{analysis.nivel_comunicacion}</span> : null}
            </div>
            <span
              className="status-badge"
              style={
                analysis.apto_para_entrevista
                  ? { color: "#09685c", background: "rgba(34,169,149,0.16)" }
                  : { color: "#7a4b00", background: "rgba(246,184,75,0.22)" }
              }
            >
              {analysis.apto_para_entrevista ? "Apto para entrevista" : "Sigue practicando"}
            </span>
          </div>

          {analysis.resumen_general ? (
            <p className="muted" style={{ margin: 0, lineHeight: 1.6 }}>
              {analysis.resumen_general}
            </p>
          ) : null}

          {evaluation ? (
            <div className="stack compact">
              <DimBar label="Claridad" dim={evaluation.claridad} />
              <DimBar label="Estructura" dim={evaluation.estructura} />
              <DimBar label="Vocabulario" dim={evaluation.vocabulario} />
              <DimBar label="Confianza" dim={evaluation.confianza} />
              <DimBar label="Fluidez" dim={evaluation.fluidez} />
            </div>
          ) : null}

          {analysis.palabras_clave_tecnicas && analysis.palabras_clave_tecnicas.length > 0 ? (
            <div className="stack compact">
              <span className="chip">Palabras clave detectadas</span>
              <div className="trust-strip">
                {analysis.palabras_clave_tecnicas.map((word, index) => (
                  <span key={index} className="chip">
                    {word}
                  </span>
                ))}
              </div>
            </div>
          ) : null}

          <div className="content-grid">
            {analysis.fortalezas_comunicacion && analysis.fortalezas_comunicacion.length > 0 ? (
              <div className="evidence-item">
                <span className="list-row">
                  <CheckCircle2 size={16} style={{ color: "var(--color-teal)" }} /> <strong>Fortalezas</strong>
                </span>
                <StringList items={analysis.fortalezas_comunicacion} />
              </div>
            ) : null}
            {analysis.areas_de_mejora && analysis.areas_de_mejora.length > 0 ? (
              <div className="evidence-item">
                <span className="list-row">
                  <TriangleAlert size={16} style={{ color: "var(--color-red)" }} /> <strong>Por mejorar</strong>
                </span>
                <StringList items={analysis.areas_de_mejora} />
              </div>
            ) : null}
          </div>

          {analysis.recomendaciones && analysis.recomendaciones.length > 0 ? (
            <div className="evidence-item">
              <span className="list-row">
                <Lightbulb size={16} style={{ color: "var(--color-yellow)" }} /> <strong>Recomendaciones</strong>
              </span>
              <StringList items={analysis.recomendaciones} />
            </div>
          ) : null}

          {transcript ? (
            <details>
              <summary className="muted" style={{ cursor: "pointer" }}>
                Ver transcripcion
              </summary>
              <p className="muted" style={{ marginTop: "0.5rem", lineHeight: 1.6 }}>
                {transcript}
              </p>
            </details>
          ) : null}
        </div>
      ) : null}
    </div>
  );
}
