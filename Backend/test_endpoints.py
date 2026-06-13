import urllib.request
import json

BASE_URL = "http://localhost:8000/api"

def test_endpoint(path, name):
    url = f"{BASE_URL}{path}"
    print(f"Testing {name} ({url})...")
    try:
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req) as response:
            status = response.status
            body = response.read().decode('utf-8')
            data = json.loads(body)
            print(f"  Status: {status}")
            print(f"  Keys: {list(data.keys()) if isinstance(data, dict) else len(data)}")
            if "error" in data:
                print(f"  ERROR field present in body: {data['error']}")
            return data
    except Exception as e:
        print(f"  FAILED: {e}")
        return None

if __name__ == "__main__":
    print("=== STARTING BACKEND 3 TESTS ===")
    
    # 1. Config Roles
    roles = test_endpoint("/roles", "List Roles")
    
    # 2. Company Dashboard
    dash = test_endpoint("/companies/comp_retail_andino/dashboard", "Company Dashboard")
    if dash:
        print(f"  Company Name: {dash.get('company', {}).get('name')}")
        print(f"  Active Jobs count: {dash.get('metrics', {}).get('activeJobs')}")
        print(f"  Recommended Candidates: {dash.get('metrics', {}).get('recommendedCandidates')}")
        print(f"  Average Match: {dash.get('metrics', {}).get('averageMatch')}%")
    
    # 3. Company Jobs
    jobs = test_endpoint("/companies/comp_retail_andino/jobs", "Company Jobs")
    if jobs:
        print(f"  Jobs found: {[j['id'] for j in jobs.get('jobs', [])]}")
        
    # 4. Job Candidates
    cands = test_endpoint("/companies/comp_retail_andino/jobs/job_data_retail/candidates", "Job Candidates")
    if cands:
        print(f"  Job Title: {cands.get('job', {}).get('title')}")
        print(f"  Candidates count: {len(cands.get('candidates', []))}")
        for c in cands.get('candidates', []):
            print(f"    - {c['name']} (Match: {c['matchScore']}%, Status: {c['status']})")
            
    # 5. Candidate Detail
    detail = test_endpoint("/companies/comp_retail_andino/candidates/stu_camila?jobId=job_data_retail", "Candidate Detail")
    if detail:
        print(f"  Student Name: {detail.get('student', {}).get('name')}")
        print(f"  Career: {detail.get('student', {}).get('career')}")
        print(f"  Match Score: {detail.get('match', {}).get('score')}%")
        print(f"  Suggested Interview Questions: {detail.get('suggestedInterviewQuestions')}")
        print(f"  Risks (Gaps): {detail.get('risks')}")
        
    # 6. Advisor Impact
    adv = test_endpoint("/advisor/impact", "Advisor Impact")
    if adv:
        print(f"  Active Students: {adv.get('metrics', {}).get('activeStudents')}")
        print(f"  Top Roles count: {len(adv.get('topRoles', []))}")
        print(f"  Top Gaps: {adv.get('topGaps')}")

    print("=== TESTS COMPLETE ===")
