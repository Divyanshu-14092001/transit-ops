# TransitOps AI Guardrails & Project Guidelines

This file defines the project-scoped rules, coding standards, and architectural guardrails that the AI must strictly adhere to for every command and file modification.

---

## 1. Professional & Clean Code Comments
- **No AI-like Verbiage:** Avoid long-winded, overly polite, or redundant comments (e.g., "This function is used to...", "Here we declare a variable..."). Keep comments brief, technical, and objective.
- **No Emojis:** Do not use emojis in comments, git commit messages, pull request descriptions, or internal documentation.
- **Self-Documenting Code:** Prioritize writing clean, self-documenting code with clear variable and function names. Use comments only to explain complex logic, edge cases, or non-obvious business requirements.

## 2. Security & Secrets Management
- **Zero Secrets in Code:** Never hardcode API keys, database credentials, passwords, JWT secrets, private keys, or tokens in the codebase.
- **Environment Variables:** Always use `.env` files on the backend to load configuration settings dynamically. Ensure `.env` is listed in `.gitignore` and never committed to version control.
- **Flutter Configuration:** In the Flutter frontend, use secure configuration injection or environment variables (e.g., `--dart-define` or secure property files) instead of hardcoding API base URLs or keys.

## 3. Technology Stack Integrity
Do not change, replace, or add alternative technologies midway. Strictly stick to the defined tech stack:
- **Backend:** Express.js + Node.js (with TypeScript, Prisma ORM, Zod validation, and TypeScript-based dependencies).
- **Frontend:** Flutter (with Dart, using GetX for state management and routing, Dio for networking, and Google Fonts for typography).
- **Database:** PostgreSQL or MySQL (managed via Prisma schemas and migrations).
- **Tooling:** ESLint and Prettier for code formatting.

## 4. Git Branching, Versioning & Changelog Strategy
To support structured development, we use a 2-branch model (`main` and `dev`):
- **`dev` Branch:** Active development, feature implementation, and integration testing happen here.
- **`main` Branch:** Represents the stable, production-ready release state.
- **Merging & Releases:** When merging or pushing changes from `dev` to `main`:
  1. Increment the version number in `package.json` (backend) and `pubspec.yaml` (frontend) following Semantic Versioning rules (`MAJOR.MINOR.PATCH`).
  2. Maintain a `CHANGELOG.md` file in the project root. Document every release with sections: `[Added]`, `[Changed]`, `[Deprecated]`, `[Removed]`, `[Fixed]`, and `[Security]`.
  3. Ensure all tests pass and lint errors are resolved before any merge.

## 5. Hackathon-Specific Quality Guidelines

### A. Database Design
- **Prisma Schema:** Maintain a clean, relational schema with proper primary keys, foreign key relations, and indexes on frequently queried fields.
- **Relational Integrity:** Use Prisma's referential actions (`onDelete`, `onUpdate`) correctly.
- **Performance:** Avoid N+1 queries. Retrieve related models efficiently using Prisma's nested includes/joins.

### B. Robust Input Validation
- **Backend Validation:** Every incoming API request (body, query parameters, path variables) must be parsed and validated using **Zod** schemas before processing.
- **Frontend Validation:** Validate all forms, text inputs, and inputs in Flutter using reactive validators (e.g., GetX Controllers, FormField validators) to catch errors before making API requests.

### C. Clean & Responsive UI/UX
- **Design System:** Use a consistent color palette, spacing, and typography (via `google_fonts`) across the Flutter app.
- **Responsive Layouts:** Use `MediaQuery`, `LayoutBuilder`, or flexible widgets to ensure the UI adapts correctly to different screen sizes.
- **Intuitive Navigation:** Design menus, bottom navigation bars, and drawers that make logical sense. Keep the user flow simple and responsive with visual cues/loaders during API calls.
- **Reusable Components:** Prioritize using and extending existing core widgets under `lib/core/widgets/` (e.g., `AccessControl`, `LoadingOverlay`, `ResponsiveLayout`, `AppButton`, `AppTextField`, `DashboardCard`, `StatisticTile`, `EmptyState`, `StatusBadge`, and `PermissionAwareFAB`). Do not create duplicate widgets or ad-hoc overrides for these functions.
- **Currency Standard:** Always represent currency amounts using the Indian Rupee symbol (`₹`) in all views, widgets, mock data, and documentation. Never use the Dollar symbol (`$`).

### D. Performance, Security & Usability
- **Error Handling:** Gracefully handle errors on both backend and frontend. Show helpful user-facing errors while logging detailed technical errors.
- **Security Middleware:** Use `helmet`, `cors`, and `express-rate-limit` on the backend to secure Express routes.
- **Modularity:** Separate business logic from UI in Flutter (using GetX controllers) and split controllers/routes/services logically in the Express backend.
