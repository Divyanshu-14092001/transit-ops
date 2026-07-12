# TransitOps - Smart Transport Operations Platform

TransitOps is a state-of-the-art, enterprise-grade fleet and transport operations management platform built for the **Odoo 2026 Hackathon**. Featuring a modern monorepo architecture, type-safe API operations, and strict validation, TransitOps empowers fleet managers, safety officers, financial analysts, and drivers to coordinate seamlessly.

---

## 🚀 Live Cloud Deployment

Both the frontend dashboard and backend API services are fully deployed on the cloud via **Railway**:

- **Web Dashboard**: [https://gentle-tenderness-production-5c99.up.railway.app](https://gentle-tenderness-production-5c99.up.railway.app)
- **REST API Base**: `https://transit-ops-production.up.railway.app`

### 🔑 Demo Credentials

You can test the different role-based permission profiles using the following credentials:

* **Default Password**: `SecurePassword123`

| Role Name | Email Address | Description & Scope |
| :--- | :--- | :--- |
| **Fleet Manager** | `manager@transitops.com` | Full management of fleets, vehicles, drivers, trips, and maintenance. |
| **Driver** | `driver@transitops.com` | Operates trips, logs fuel, and views assigned dispatches. |
| **Safety Officer** | `safety@transitops.com` | Monitors compliance, driver safety scores, and exportable reports. |
| **Financial Analyst** | `finance@transitops.com` | Accesses and approves expenses, fuel logs, and financial metrics. |

---

## 🌟 Key Features

### 1. **Fleet & Vehicle Management**
* Register and modify vehicles with distinct attributes (Registration Numbers, Chassis Numbers, Odometer Readings, and Acquisition Costs).
* Define vehicle capacities in **Weight (Kg)** or **Volume (Litre)**.
* Filter vehicles by status (`Available`, `On Trip`, `In Shop`, `Retired`).
* Auto-validate unique registration numbers globally.

### 2. **Driver Profile & Compliance Management**
* Log driver profiles with active license tracking, category types (`LMV`, `HMV`, `Transport`), and expiry dates.
* Automated checks to block drivers with expired licenses or `Suspended` status from being assigned to any dispatches.
* Track individual safety scores and employee codes.

### 3. **Smart Trip Dispatch (Trip Lifecycle)**
* Dispatch new trips choosing source/destination locations dynamically.
* **Auto-Capacity Validation**: Ensures Cargo Weight does not exceed the selected vehicle's maximum load capacity before enabling dispatch.
* **Automatic Status Side-Effects**:
  - Dispatching a trip (`DISPATCHED`) sets both the vehicle and driver status to `On Trip`.
  - Completing a trip (`COMPLETED`) or cancelling it (`CANCELLED`) automatically restores both the vehicle and driver status to `Available`.

### 4. **Maintenance & Workshop Scheduling**
* Log routine, corrective, preventive, breakdown, and inspection maintenance records.
* Automatically updates vehicle status to `In Shop` upon maintenance creation, preventing scheduling on new trips.
* Track service providers, estimated costs, invoice details, and repair notes.

### 5. **Fuel & Financial Logs**
* Log fuel transactions with price per litre, odometer tracking, and fuel volumes.
* Capture expenses (tolls, food, maintenance, permits) linked to specific trips, with authorization steps for financial analysts.

---

## 🛠 Tech Stack

### Backend
* **Runtime & Framework**: Node.js + Express.js + TypeScript
* **Database**: PostgreSQL (Prisma ORM with fully normalized schemas and migrations)
* **Validation**: Zod (strict validation on headers, queries, path parameters, and request bodies)
* **Security**: JWT Authentication, RBAC (Role-Based Access Control) middlewares, Helmet, CORS, and Express Rate Limiter.

### Frontend
* **Framework**: Flutter Web / Mobile (Dart)
* **State Management**: GetX (highly reactive binding architecture)
* **Networking**: Dio (with custom interceptors, automatic authorization headers, and structured error mapping)
* **Design System**: Vanilla Material 3 styling (with custom premium color palettes, modern fonts via Google Fonts, responsive dashboards, and interactive widgets)

---

## 📂 Project Structure

```
TransitOps/
├── apps/
│   ├── frontend/         # Flutter application (GetX + Dio + Material 3)
│   └── backend/          # Express.js + TypeScript + Prisma ORM + Zod API
├── packages/
│   └── shared/           # Shared TypeScript types, enums, HTTP status utilities
├── docs/                 # API references, schema layouts, and guides
└── scripts/              # Workspace bootstrap and utility scripts
```

---

## 💻 Local Setup & Development

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Divyanshu-14092001/transit-ops.git
   cd transit-ops
   ```

2. **Install Workspace Dependencies**:
   ```bash
   ./scripts/bootstrap.sh
   ```

3. **Database Migrations (Backend)**:
   Ensure you have a local PostgreSQL database configured, configure `.env`, then:
   ```bash
   cd apps/backend
   npx prisma migrate dev
   npx prisma db seed
   ```

4. **Run Services**:
   - Run backend dev server:
     ```bash
     cd apps/backend && npm run dev
     ```
   - Run frontend app:
     ```bash
     cd apps/frontend && flutter run -d chrome
     ```
