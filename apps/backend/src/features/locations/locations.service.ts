import { prisma } from "../../config/prisma";

export class LocationsService {
  async getLocations() {
    return prisma.location.findMany({
      where: {
        type: "CITY",
      },
      orderBy: { name: "asc" },
    });
  }
}
