# Feature Isolation Layer

This directory must follow a modular, feature-based design. Each application domain (e.g., `trips`, `auth`, `vehicles`, `users`) should have its own isolated folder.

A feature folder should look like:
```
features/trips/
├── trips.routes.ts        # Route declarations & endpoint mappings
├── trips.controller.ts    # Request parameters unpacker & status responses (No business logic!)
├── trips.service.ts       # Main business logic, domain algorithms & transaction limits
├── trips.repository.ts    # Direct Database communication using Prisma
├── trips.validator.ts     # Zod payload structures (body, params, query)
└── types.ts               # Feature-specific interface mappings
```
