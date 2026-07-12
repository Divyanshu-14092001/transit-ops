import { DriversRepository } from "./drivers.repository";
import { GetDriversQueryInput, CreateDriverInput } from "./drivers.validator";

export class DriversService {
  private driversRepository = new DriversRepository();

  async getDrivers(params: GetDriversQueryInput, organizationId?: string) {
    return this.driversRepository.findDrivers(params, organizationId);
  }

  async createOrUpdateDriver(input: CreateDriverInput, organizationId: string) {
    return this.driversRepository.createOrUpdateDriver(input, organizationId);
  }
}
