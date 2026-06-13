import { HTMLAttributes } from "react";
import clsx from "clsx";

export function Card({ className, ...props }: HTMLAttributes<HTMLDivElement>) {
  return <section className={clsx("card", className)} {...props} />;
}
