import { Inject, Injectable } from "@nestjs/common";
import { UserImporterService } from "./user/user-importer.service";

@Injectable()
export class DataImporterService {
    @Inject()
    private readonly userImporterService: UserImporterService

    public async import() {
        await this.userImporterService.import();
    }
}