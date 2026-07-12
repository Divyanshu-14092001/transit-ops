import { PrismaClient } from "@prisma/client";
import * as fs from "fs";
import * as path from "path";

const prisma = new PrismaClient();

async function main() {
  console.log("Starting database seed...");

  // 1. Seed Permissions
  console.log("Seeding permissions...");
  const permissions = [
    { resource: "auth_management", action: "read", code: "auth_management:read", description: "Read auth configuration" },
    { resource: "auth_management", action: "manage", code: "auth_management:manage", description: "Manage authentication" },
    { resource: "organization_management", action: "create", code: "organization_management:create", description: "Create organizations" },
    { resource: "organization_management", action: "read", code: "organization_management:read", description: "Read organizations" },
    { resource: "organization_management", action: "update", code: "organization_management:update", description: "Update organizations" },
    { resource: "fleet_management", action: "create", code: "fleet_management:create", description: "Create fleets" },
    { resource: "fleet_management", action: "read", code: "fleet_management:read", description: "Read fleets" },
    { resource: "fleet_management", action: "update", code: "fleet_management:update", description: "Update fleets" },
    { resource: "fleet_management", action: "delete", code: "fleet_management:delete", description: "Delete fleets" },
    { resource: "driver_management", action: "assign", code: "driver_management:assign", description: "Assign drivers" },
    { resource: "trip_management", action: "create", code: "trip_management:create", description: "Create trips" },
    { resource: "trip_management", action: "assign", code: "trip_management:assign", description: "Assign trips" },
    { resource: "trip_management", action: "update", code: "trip_management:update", description: "Update trips" },
    { resource: "maintenance_management", action: "create", code: "maintenance_management:create", description: "Create maintenance records" },
    { resource: "fuel_management", action: "create", code: "fuel_management:create", description: "Log fuel records" },
    { resource: "expense_management", action: "create", code: "expense_management:create", description: "Log expenses" },
    { resource: "expense_management", action: "approve", code: "expense_management:approve", description: "Approve expenses" },
    { resource: "report_management", action: "read", code: "report_management:read", description: "Read reports" },
    { resource: "report_management", action: "export", code: "report_management:export", description: "Export reports" }
  ];

  const dbPermissions = [];
  for (const perm of permissions) {
    const dbPerm = await prisma.permission.upsert({
      where: { code: perm.code },
      update: {
        resource: perm.resource,
        action: perm.action,
        description: perm.description
      },
      create: perm
    });
    dbPermissions.push(dbPerm);
  }

  // 2. Seed Roles
  console.log("Seeding roles...");
  const roles = [
    { name: "Admin", code: "ADMIN", description: "System Administrator with full access", isSystemRole: true },
    { name: "Fleet Manager", code: "FLEET_MANAGER", description: "Manages fleets, vehicles, drivers and trips", isSystemRole: true },
    { name: "Driver", code: "DRIVER", description: "Operational driver with basic access", isSystemRole: true },
    { name: "Safety Officer", code: "SAFETY_OFFICER", description: "Monitors driver safety, compliance and reports", isSystemRole: true },
    { name: "Financial Analyst", code: "FINANCIAL_ANALYST", description: "Tracks expenses, fuel logs and financial metrics", isSystemRole: true }
  ];

  const dbRoles: Record<string, any> = {};
  for (const role of roles) {
    const dbRole = await prisma.role.upsert({
      where: { code: role.code },
      update: {
        name: role.name,
        description: role.description,
        isSystemRole: role.isSystemRole
      },
      create: role
    });
    dbRoles[role.code] = dbRole;
  }

  // 3. Seed Role-Permissions
  console.log("Mapping role permissions...");
  const rolePermissionAssignments: Record<string, string[]> = {
    ADMIN: permissions.map(p => p.code),
    FLEET_MANAGER: [
      "fleet_management:create", "fleet_management:read", "fleet_management:update", "fleet_management:delete",
      "driver_management:assign",
      "trip_management:create", "trip_management:assign", "trip_management:update",
      "maintenance_management:create",
      "fuel_management:create",
      "expense_management:create",
      "report_management:read"
    ],
    DRIVER: [
      "trip_management:update",
      "fuel_management:create",
      "expense_management:create"
    ],
    SAFETY_OFFICER: [
      "report_management:read",
      "report_management:export"
    ],
    FINANCIAL_ANALYST: [
      "expense_management:create",
      "expense_management:approve",
      "fuel_management:create",
      "report_management:read",
      "report_management:export"
    ]
  };

  for (const [roleCode, permCodes] of Object.entries(rolePermissionAssignments)) {
    const roleId = dbRoles[roleCode].id;
    // Clear existing permissions mapping for the role to enforce synchronization
    await prisma.rolePermission.deleteMany({
      where: { roleId }
    });

    const activePermissions = dbPermissions.filter(p => permCodes.includes(p.code));
    for (const perm of activePermissions) {
      await prisma.rolePermission.create({
        data: {
          roleId,
          permissionId: perm.id
        }
      });
    }
  }

  // 4. Seed Locations from locations.json
  console.log("Seeding Indian states and cities...");
  const locationsFilePath = path.join(__dirname, "data", "locations.json");
  if (fs.existsSync(locationsFilePath)) {
    const locationsData = JSON.parse(fs.readFileSync(locationsFilePath, "utf-8"));

    // Seed Country (India)
    const countryData = locationsData.country;
    let country = await prisma.location.findFirst({
      where: {
        parentId: null,
        name: countryData.name,
        type: countryData.type
      }
    });

    if (country) {
      country = await prisma.location.update({
        where: { id: country.id },
        data: {
          code: countryData.code,
          latitude: countryData.latitude,
          longitude: countryData.longitude,
          timezone: countryData.timezone,
          countryCode: countryData.countryCode,
          isActive: true
        }
      });
    } else {
      country = await prisma.location.create({
        data: {
          name: countryData.name,
          code: countryData.code,
          type: countryData.type,
          parentId: null,
          latitude: countryData.latitude,
          longitude: countryData.longitude,
          timezone: countryData.timezone,
          countryCode: countryData.countryCode,
          isActive: true
        }
      });
    }

    // Seed States
    for (const stateData of locationsData.states) {
      let state = await prisma.location.findFirst({
        where: {
          parentId: country.id,
          name: stateData.name,
          type: stateData.type
        }
      });

      if (state) {
        state = await prisma.location.update({
          where: { id: state.id },
          data: {
            code: stateData.code,
            latitude: stateData.latitude,
            longitude: stateData.longitude,
            timezone: stateData.timezone,
            countryCode: stateData.countryCode,
            isActive: true
          }
        });
      } else {
        state = await prisma.location.create({
          data: {
            name: stateData.name,
            code: stateData.code,
            type: stateData.type,
            parentId: country.id,
            latitude: stateData.latitude,
            longitude: stateData.longitude,
            timezone: stateData.timezone,
            countryCode: stateData.countryCode,
            isActive: true
          }
        });
      }

      // Seed Cities
      for (const cityData of stateData.cities) {
        let city = await prisma.location.findFirst({
          where: {
            parentId: state.id,
            name: cityData.name,
            type: cityData.type
          }
        });

        if (city) {
          await prisma.location.update({
            where: { id: city.id },
            data: {
              code: cityData.code,
              latitude: cityData.latitude,
              longitude: cityData.longitude,
              timezone: cityData.timezone,
              countryCode: cityData.countryCode,
              isActive: true
            }
          });
        } else {
          await prisma.location.create({
            data: {
              name: cityData.name,
              code: cityData.code,
              type: cityData.type,
              parentId: state.id,
              latitude: cityData.latitude,
              longitude: cityData.longitude,
              timezone: cityData.timezone,
              countryCode: cityData.countryCode,
              isActive: true
            }
          });
        }
      }
    }
    console.log("Locations successfully seeded.");
  } else {
    console.warn(`Warning: locations.json not found at ${locationsFilePath}. Skipping locations seed.`);
  }

  console.log("Database seed completed successfully.");
}

main()
  .catch((e) => {
    console.error("Error during database seed:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
