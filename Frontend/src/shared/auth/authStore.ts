import { useSyncExternalStore } from "react";

import type { SessionResponse } from "../api/types";

const STORAGE_KEY = "despega.session";

function readInitial(): SessionResponse | null {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? (JSON.parse(raw) as SessionResponse) : null;
  } catch {
    return null;
  }
}

let current: SessionResponse | null = readInitial();
const listeners = new Set<() => void>();

function emit() {
  listeners.forEach((listener) => listener());
}

export function setSession(session: SessionResponse) {
  current = session;
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(session));
  } catch {
    // ignore storage errors (private mode, etc.)
  }
  emit();
}

export function clearSession() {
  current = null;
  try {
    localStorage.removeItem(STORAGE_KEY);
  } catch {
    // ignore
  }
  emit();
}

function subscribe(listener: () => void) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

function getSnapshot() {
  return current;
}

/** Reactive hook: re-renders when the session changes. */
export function useSession(): SessionResponse | null {
  return useSyncExternalStore(subscribe, getSnapshot, getSnapshot);
}

/** Current student id (or Camila as demo fallback) — used as API default. */
export function getCurrentUserId(): string {
  return current?.user.id ?? "stu_camila";
}

/** Current company id from the session, with the demo company as fallback. */
export function getCurrentCompanyId(): string {
  return current?.companyId ?? "comp_retail_andino";
}
