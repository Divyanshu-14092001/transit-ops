#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== TransitOps Monorepo Bootstrap ==="
echo ""

# Get the script directory and find project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

cd "$PROJECT_ROOT"

echo "[1/3] Installing NPM Workspace dependencies..."
npm install

echo ""
echo "[2/3] Building @transitops/shared package..."
npm run shared:build

echo ""
echo "[3/3] Generating Prisma Client code..."
# Ensure database schema client is built locally (ignores DB connection check)
npx prisma generate --schema=apps/backend/prisma/schema.prisma

echo ""
echo "=== Monorepo bootstrapped successfully! ==="
echo "To run the backend development server:"
echo "  npm run backend:dev"
echo ""
echo "To verify backend TypeScript compile and lint rules:"
echo "  npm run lint"
echo ""
