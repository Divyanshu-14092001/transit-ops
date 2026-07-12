# TransitOps - Smart Transport Operations Platform

TransitOps is an enterprise-grade smart transport operations platform designed for the Odoo 2026 Hackathon. It features a modern, clean-architecture monorepo setup targeting robust scalability, data normalization, and strict validation.

## Repository Structure

```
TransitOps/
├── apps/
│   ├── frontend/         # Flutter mobile/desktop app (Clean Architecture + GetX + Dio)
│   └── backend/          # Node.js + Express + TypeScript + Prisma API
├── packages/
│   └── shared/           # Common TypeScript types, validation rules, constants
├── docs/                 # Architecture, schemas, and API documentation
└── scripts/              # Setup, utility, and build scripts
```

## Architectural Guidelines

### Backend Rules
- **Modular Feature Architecture**: Keep each feature completely isolated in `src/features/<feature-name>`.
- **Layer Separation**: No business logic is permitted in controllers. Ensure strict separation:
  - **Routes**: HTTP routing and parameter mapping.
  - **Validators**: Schema validation (using validation libraries) of body, params, query, and headers.
  - **Controllers**: Handle requests/responses, call services, map errors.
  - **Services**: All business logic, transaction handling, orchestration.
  - **Repositories**: Data access logic (Prisma).
  - **Middlewares**: Auth, RBAC, error boundaries, rate limiting.

### Database Design Rules (PostgreSQL + Prisma)
- Normalize schemas completely. No JSON blobs for relational data.
- Ensure referential integrity using Foreign Keys and constraints.
- Define proper indexes, unique constraints, and composite keys where appropriate.
- Include audit timestamps (`createdAt`, `updatedAt`) and soft delete mechanisms where relevant.

### Frontend Rules (Flutter + Material 3)
- **Clean Architecture & MVVM**:
  - `data/`: Models, data sources, and repositories implementation.
  - `domain/`: Pure business logic, entity definitions, repository interfaces, and usecases.
  - `presentation/`: Views, ViewModels/Controllers (using GetX), and private widgets.
- **Dependency Injection & Routing**: Handled uniformly via GetX bindings and routing.
- **API Client**: Implemented with `Dio`, centralized request configuration, interceptors, token refresh, and safe error mapping.
- **Reusable UI**: Do not repeat layout or design elements. Use theme tokens and core widgets.

## Development Workflows

### Setup & Bootstrap
To install all dependencies across the monorepo workspaces:
```bash
./scripts/bootstrap.sh
```

### Git Strategy & Branches
- **main**: Always stable, only receives tested merges via PR.
- **dev**: Primary active development branch.
- **Commit Messages**: Follow Conventional Commits format:
  - `feat: ...` for new features
  - `fix: ...` for bug fixes
  - `refactor: ...` for code refactoring
  - `docs: ...` for documentation updates
  - `style: ...` for code style updates
  - `test: ...` for adding/fixing tests
  - `build: ...` or `chore: ...` for tooling and meta tasks

## AI Guardrails for Developers (and Coding Assistants)
1. **Never write business logic blindly**: Always sketch the architecture, verify against constraints, and update specifications first.
2. **Do not duplicate code**: Always verify if a type, constant, or utility should reside in `packages/shared`.
3. **Follow the directory structure**: Keep modules, components, and services localized and organized by features.
4. **Never introduce breaking changes** without consulting the Tech Lead.
5. **No commented-out code or magic numbers**: Write clean, self-documenting code.
