import clsx from "clsx";
import type { ReactNode } from "react";

type StatusBadgeProps = {
  status: string;
  children?: ReactNode;
};

export function StatusBadge({ status, children }: StatusBadgeProps) {
  return <span className={clsx("status-badge", `status-${status}`)}>{children ?? status}</span>;
}
