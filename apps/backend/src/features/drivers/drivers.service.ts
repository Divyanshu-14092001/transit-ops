import { DriversRepository } from "./drivers.repository";
import { GetDriversQueryInput } from "./drivers.validator";

export class DriversService {
  private driversRepository = new DriversRepository();

  async getDrivers(params: GetDriversQueryInput) {
    return this.driversRepository.findDrivers(params);
  }
}
