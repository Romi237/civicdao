# CivicDAO — Sprint Retrospectives

## Sprint 1 Retrospective — Foundation
**Duration:** 2 weeks | **Story Points:** 20 | **Completed:** 20

### What went well
- GitHub repository set up cleanly with branch strategy (main, develop, feature branches)
- MongoDB schemas designed correctly from the start — no major revisions needed
- JWT authentication worked on the first attempt
- Flutter project scaffold created and both team members able to run it locally

### What could have been better
- We underestimated the time needed to configure the Android emulator to reach
  the backend at 10.0.2.2 — lost half a day debugging network connectivity
- Secrets management was not set up from day one — we committed a placeholder
  .env file and had to fix the .gitignore afterwards

### Action items for Sprint 2
- Set up .gitignore before any other file in future projects
- Document emulator networking setup in README immediately

---

## Sprint 2 Retrospective — Core Features
**Duration:** 2 weeks | **Story Points:** 28 | **Completed:** 28

### What went well
- Proposals CRUD API implemented cleanly and reused consistently across screens
- The voting logic (one vote per user, enforced at DB level with compound index)
  worked perfectly and has not needed a single fix since
- Flutter screens were built in parallel with the backend without conflicts

### What could have been better
- Days 5–7 were blocked because the voting endpoint returned incorrect HTTP
  status codes — the frontend was receiving 200 for validation errors.
  This caused the Flutter screen to navigate to VoteSubmitted even on failure.
  Fixed by ensuring all error paths return 400 with an error field.
- Team coordination slipped on Day 6 — both members modified api_service.dart
  at the same time causing a merge conflict. Resolved by agreeing that only
  Person B touches Flutter service files.

### Action items for Sprint 3
- Add automated tests for every new endpoint before moving to the next feature
- Agree on file ownership before each sprint starts

---

## Sprint 3 Retrospective — DevOps
**Duration:** 2 weeks | **Story Points:** 38 | **Completed:** 38

### What went well
- Docker multi-stage build reduced the image size from 320MB to 85MB
- Jenkins pipeline configured cleanly — all 8 stages running without intervention
- Kubernetes HPA tested successfully — scaled from 2 to 4 replicas under load test
- GitHub Actions runs on every push and catches test failures before merge

### What could have been better
- Kubernetes Secrets management was initially done with plain base64 — not truly
  secure. Acknowledged as a known limitation for this academic environment.
- The first Ansible playbook run failed because Python 3 was not the default
  interpreter on the test VPS. Fixed by explicitly setting
  ansible_python_interpreter in inventory.yml.

### Action items for Sprint 4
- Use Kubernetes Secrets properly in production deployments
- Document all Ansible requirements in the README

---

## Sprint 4 Retrospective — Monitoring and Documentation
**Duration:** 2 weeks | **Story Points:** 24 | **Completed:** 24

### What went well
- Prometheus /metrics endpoint took only 30 minutes to implement
- Grafana dashboard configured with 5 panels showing real-time data
- Project report written collaboratively — each member wrote their own chapters
- Demo video recorded in one take — app working smoothly end to end

### What could have been better
- Documentation was left to the last sprint — should have been written
  incrementally as features were built
- We ran out of time to implement email notifications (the Notify microservice
  remained a placeholder)

### Recommendations for future work
- Implement on-chain voting using a smart contract for true decentralisation
- Add email verification on registration
- Expand test coverage with Flutter integration tests using integration_test package
