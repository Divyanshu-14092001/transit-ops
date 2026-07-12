// Shared core definitions

export interface BaseEntity {
  id: string;
  createdAt: Date;
  updatedAt: Date;
}

export enum UserRole {
  ADMIN = "ADMIN",
  DISPATCHER = "DISPATCHER",
  DRIVER = "DRIVER",
  PASSENGER = "PASSENGER",
}

export interface UserSession {
  userId: string;
  email: string;
  role: UserRole;
}
