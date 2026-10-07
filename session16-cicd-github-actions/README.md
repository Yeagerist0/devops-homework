# Session 16 - CI/CD & GitHub Actions

**Student:** Hitarth Jain  
**Enrollment:** 24BCS10399  
**Platform:** GitHub Actions & Docker

---

## 1. CI vs CD Concepts

* **Continuous Integration (CI):** The practice of automating the integration of code changes from multiple contributors into a single software project. Automated linting, static analysis, unit testing, and packaging happen on every git push or pull request to catch defects before merge.
* **Continuous Delivery (CD):** Ensuring code is always in a deployable state. Deployments to staging environments are fully automated, but promoting to production may involve a manual approval gate.
* **Continuous Deployment (CD):** Every change that passes all stages of the production pipeline is released directly to customers in production with zero human intervention.

```
[ Developer Push ]
       │
       ▼
   ┌───────┐
   │  CI   │ ──► [ Lint Code ] ──► [ Run Unit Tests ] ──► [ Build Container ]
   └───────┘
       │
       ▼
   ┌───────┐
   │  CD   │ ──► [ Security Gate ] ──► [ Push to Registry ] ──► [ Deploy to K8s ]
   └───────┘
```

---

## 2. Anatomy of GitHub Actions

* **Workflows (`.github/workflows/*.yml`):** Configurable automated processes made up of one or more jobs.
* **Events (`on: [push, pull_request]`):** Triggers that cause a workflow to run.
* **Jobs (`jobs:`):** A set of steps that execute on the same runner. Jobs run in parallel by default, or sequentially when linked with `needs:`.
* **Steps (`steps:`):** Individual tasks that run commands (`run:`) or actions (`uses:`).
* **Runners (`runs-on: ubuntu-latest`):** A server provisioned by GitHub or self-hosted that executes the job.
* **Secrets (`${{ secrets.DOCKERHUB_TOKEN }}`):** Encrypted environment variables securely injected without exposing plaintext credentials in code.
* **Artifacts (`upload-artifact` / `download-artifact`):** Persistent files (compiled binaries, test reports, logs) retained after workflow execution.

---

## 3. Demo Project Implementation

* **Application Source:** [app/index.js](app/index.js) (Express REST API with `/` and `/health`)
* **Unit Tests:** [app/test.js](app/test.js) (Automated test suite)
* **Container Packaging:** [app/Dockerfile](app/Dockerfile) (Multi-stage Node.js container)
* **GitHub Actions Pipeline:** [.github/workflows/cicd.yml](.github/workflows/cicd.yml)

### Pipeline Execution Output (Simulated Terminal / Runner Log)

```
✓ Set up job
✓ Checkout Source Code (actions/checkout@v4)
✓ Setup Node.js Runtime (actions/setup-node@v4)
✓ Install Dependencies (npm ci)
  added 65 packages in 1.42s
✓ Execute Automated Unit Tests (npm test)
  > devops-cicd-demo-app@1.0.0 test
  > node test.js
  Running unit tests for CI pipeline...
  ✓ All unit tests passed successfully!
✓ Upload Test Report Artifact (actions/upload-artifact@v4)
✓ Set up Docker Buildx (actions/setup-buildx-action@v3)
✓ Build Docker Container Image (docker/build-push-action@v5)
  #1 [internal] load build definition from Dockerfile
  #2 [base 2/4] WORKDIR /app
  #3 [base 3/4] COPY package*.json ./
  #4 [base 4/4] RUN npm ci --only=production
  #5 exporting to image
  #5 naming to docker.io/library/devops-cicd-demo-app:sha-9e2f16b
  #5 DONE 2.1s
✓ Deploy to Staging / Production
  Simulating deployment with commit: sha-9e2f16b
  Target Environment: production
  Deployment succeeded!
```
