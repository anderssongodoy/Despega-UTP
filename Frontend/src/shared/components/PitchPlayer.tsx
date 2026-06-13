import { useRef, useState } from "react";
import { Mic, Square, Volume2 } from "lucide-react";

/**
 * Pitch practice widget: reads the pitch aloud (SpeechSynthesis) and lets the
 * student record their own version (MediaRecorder) to compare. Fully client-side.
 */
export function PitchPlayer({ pitch }: { pitch: string }) {
  const [speaking, setSpeaking] = useState(false);
  const [recording, setRecording] = useState(false);
  const [audioUrl, setAudioUrl] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const recorderRef = useRef<MediaRecorder | null>(null);
  const chunksRef = useRef<Blob[]>([]);

  const speechSupported = typeof window !== "undefined" && "speechSynthesis" in window;
  const recordSupported =
    typeof navigator !== "undefined" && !!navigator.mediaDevices && typeof MediaRecorder !== "undefined";

  function speak() {
    if (!speechSupported) return;
    window.speechSynthesis.cancel();
    const utterance = new SpeechSynthesisUtterance(pitch);
    utterance.lang = "es-ES";
    utterance.onend = () => setSpeaking(false);
    utterance.onerror = () => setSpeaking(false);
    setSpeaking(true);
    window.speechSynthesis.speak(utterance);
  }

  function stopSpeak() {
    window.speechSynthesis.cancel();
    setSpeaking(false);
  }

  async function startRecording() {
    if (!recordSupported) {
      setNotice("Tu navegador no permite grabar audio.");
      return;
    }
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const recorder = new MediaRecorder(stream);
      chunksRef.current = [];
      recorder.ondataavailable = (event) => {
        if (event.data.size > 0) chunksRef.current.push(event.data);
      };
      recorder.onstop = () => {
        const blob = new Blob(chunksRef.current, { type: "audio/webm" });
        setAudioUrl((prev) => {
          if (prev) URL.revokeObjectURL(prev);
          return URL.createObjectURL(blob);
        });
        stream.getTracks().forEach((track) => track.stop());
      };
      recorderRef.current = recorder;
      recorder.start();
      setNotice(null);
      setRecording(true);
    } catch {
      setNotice("No se pudo acceder al microfono. Revisa los permisos.");
      setRecording(false);
    }
  }

  function stopRecording() {
    recorderRef.current?.stop();
    setRecording(false);
  }

  return (
    <div className="pitch-player stack">
      <blockquote className="pitch-quote">{pitch}</blockquote>

      <div className="pitch-controls">
        {speechSupported ? (
          speaking ? (
            <button type="button" className="btn btn-secondary" onClick={stopSpeak}>
              <Square size={18} /> Detener voz
            </button>
          ) : (
            <button type="button" className="btn btn-secondary" onClick={speak}>
              <Volume2 size={18} /> Escuchar pitch
            </button>
          )
        ) : null}

        {recording ? (
          <button type="button" className="btn btn-primary" onClick={stopRecording}>
            <span className="recording-dot" /> Detener grabacion
          </button>
        ) : (
          <button type="button" className="btn btn-primary" onClick={startRecording}>
            <Mic size={18} /> Grabar mi pitch
          </button>
        )}
      </div>

      {notice ? <p className="muted">{notice}</p> : null}

      {audioUrl ? (
        <div className="stack compact">
          <span className="chip">Tu grabacion</span>
          {/* eslint-disable-next-line jsx-a11y/media-has-caption */}
          <audio controls src={audioUrl} style={{ width: "100%" }} />
        </div>
      ) : null}
    </div>
  );
}
