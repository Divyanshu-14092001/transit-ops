# Railway Production Deployment Guide

This document describes the steps required to deploy the TransitOps monorepo application to Railway.

## Deployment Architecture

The application is deployed as three separate services in a single Railway project:
1. **PostgreSQL Database**: Holds all user, vehicle, trip, and organization data.
2. **Node.js/Express Backend**: Serves REST APIs, validates JWT, runs migrations.
3. **Flutter Web Frontend**: Serves UI/UX assets statically.

---

## Deployment Steps

### 1. Provision PostgreSQL Database
1. Go to your Railway Dashboard and create a new project.
2. Click **New Service** -> **Database** -> **Add PostgreSQL**.
3. Under the **Variables** tab of the PostgreSQL service, locate the generated `DATABASE_URL` string. You will link this to the backend.

### 2. Deploy Node.js/Express Backend Service
1. In the same Railway project, click **New** -> **GitHub Repository** and select the `transit-ops` repo.
2. Under the service settings, configure:
   * **Service Name**: `backend`
   * **Root Directory**: `/` (Leave as root to allow the Docker context to build the `@transitops/shared` package dependency).
   * **Dockerfile Path**: `apps/backend/Dockerfile`
   * **Pre-deploy Command**: `npx prisma migrate deploy`
3. Under the **Variables** tab, add:
   * `NODE_ENV` = `production`
   * `DATABASE_URL` = `${{Postgres.DATABASE_URL}}` (Dynamic reference to the PostgreSQL service variable)
   * `JWT_SECRET` = `<generate-secure-32-char-string>`
   * `JWT_EXPIRES_IN` = `24h`
   * `FRONTEND_URL` = `<your-frontend-public-url>` (You will update this once the frontend service is active).
   * `CORS_ORIGIN` = `<your-frontend-public-url>`
4. Go to **Settings** -> **Public Domain** and click **Generate Domain** to create a public backend link.
5. Test the endpoint by opening `https://<backend-domain>/health` in your browser. It should output:
   ```json
   {
     "status": "ok",
     "message": "Backend is running",
     "timestamp": "...",
     "uptime": ...
   }
   ```

### 3. Deploy Flutter Web Frontend Service
1. In the same Railway project, click **New** -> **GitHub Repository** and select the `transit-ops` repo.
2. Under the service settings, configure:
   * **Service Name**: `frontend`
   * **Root Directory**: `apps/frontend`
   * **Dockerfile Path**: `Dockerfile` (Since context is `apps/frontend`, it resolves directly to the Dockerfile in that folder).
3. Under the **Variables** tab, add:
   * `API_BASE_URL` = `https://<your-generated-backend-domain>`
4. Go to **Settings** -> **Public Domain** and click **Generate Domain** to create a public frontend link.

### 4. Update CORS in Backend Service
1. Go back to your **backend** service configuration in the Railway dashboard.
2. Update the environment variables:
   * `FRONTEND_URL` = `https://<your-generated-frontend-domain>`
   * `CORS_ORIGIN` = `https://<your-generated-frontend-domain>`
3. Trigger a redeployment of the backend service to apply the CORS origin rules.

---

## Deployment Verification Checklist
* [ ] Verify database connection strings and active user seeds.
* [ ] Verify that `GET https://<backend-domain>/health` returns status `"ok"`.
* [ ] Verify that the frontend correctly connects to the backend API and processes logins without CORS blocking.
* [ ] Confirm that JWT authentication, permission checks, and page loads complete without routing issues.
