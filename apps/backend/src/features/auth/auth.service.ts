import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { AuthRepository } from "./auth.repository";
import { LoginInput } from "./auth.validator";

export class AuthService {
  private authRepository = new AuthRepository();

  async login(input: LoginInput) {
    const user = await this.authRepository.findUserByEmail(input.email);

    if (!user || user.deletedAt) {
      throw new Error("Invalid email or password");
    }

    if (user.status !== "ACTIVE") {
      throw new Error(`Your account status is ${user.status.toLowerCase()}`);
    }

    const isPasswordValid = await bcrypt.compare(
      input.password,
      user.passwordHash,
    );
    if (!isPasswordValid) {
      throw new Error("Invalid email or password");
    }

    // Extract all unique permission codes across all active roles of the user
    const permissions = new Set<string>();
    for (const userRole of user.userRoles) {
      for (const rolePerm of userRole.role.rolePermissions) {
        permissions.add(rolePerm.permission.code);
      }
    }

    const permissionList = Array.from(permissions);

    // Update last login audit field
    await this.authRepository.updateLastLogin(user.id);

    // Generate JWT access token
    const secret =
      process.env.JWT_SECRET || "change-this-to-a-secure-random-key";
    const accessToken = jwt.sign(
      {
        id: user.id,
        email: user.email,
        permissions: permissionList,
      },
      secret,
      { expiresIn: "24h" },
    );

    const organizationsList = user.userOrganizations.map((uo) => ({
      id: uo.organization.id,
      name: uo.organization.name,
      code: uo.organization.code,
      status: uo.organization.status,
      joinedAt: uo.joinedAt,
    }));

    return {
      user: {
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        contactNumber: user.contactNumber,
        status: user.status,
        permissions: permissionList,
        organizations: organizationsList,
      },
      accessToken,
    };
  }

  async verifyAccessToken(token: string) {
    const secret =
      process.env.JWT_SECRET || "change-this-to-a-secure-random-key";
    const decoded = jwt.verify(token, secret) as {
      id: string;
      email: string;
      permissions: string[];
    };

    const user = await this.authRepository.findUserById(decoded.id);
    if (!user || user.deletedAt || user.status !== "ACTIVE") {
      throw new Error("User account is inactive or deleted");
    }

    // Re-extract permissions
    const permissions = new Set<string>();
    for (const userRole of user.userRoles) {
      for (const rolePerm of userRole.role.rolePermissions) {
        permissions.add(rolePerm.permission.code);
      }
    }
    const permissionList = Array.from(permissions);

    const organizationsList = user.userOrganizations.map((uo) => ({
      id: uo.organization.id,
      name: uo.organization.name,
      code: uo.organization.code,
      status: uo.organization.status,
      joinedAt: uo.joinedAt,
    }));

    return {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      contactNumber: user.contactNumber,
      status: user.status,
      permissions: permissionList,
      organizations: organizationsList,
    };
  }
}
