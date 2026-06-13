import { useEffect, useState } from "react";

import { getJobMatches } from "../../opportunities/opportunities.api";
import type { JobMatch } from "../../../shared/api/types";
import { Card } from "../../../shared/components/Card";
import { LoadingState } from "../../../shared/components/LoadingState";
import { StatusBadge } from "../../../shared/components/StatusBadge";

export function StudentOpportunitiesPage() {
  const [jobs, setJobs] = useState<JobMatch[] | null>(null);

  useEffect(() => {
    getJobMatches().then((response) => setJobs(response.jobs)).catch(() => setJobs([]));
  }, []);

  if (!jobs) return <LoadingState />;

  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Oportunidades</p>
        <h2>Vacantes recomendadas y kit de postulacion</h2>
      </section>
      <div className="card-list">
        {jobs.slice(0, 5).map((job) => (
          <Card key={job.jobId ?? job.job_id}>
            <div className="row-between">
              <div>
                <h3>{job.title}</h3>
                <p className="muted">{job.companyName ?? job.company_name}</p>
              </div>
              <StatusBadge status={job.status}>{job.matchScore}%</StatusBadge>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
