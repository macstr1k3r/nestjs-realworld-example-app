import { Module } from "@nestjs/common";
import { DatabaseModule } from "../database.module";
import { DataImporterService } from "./data-importer.service";
import { UserImporterModule } from "./user/user-importer.module";

@Module({
  imports: [DatabaseModule, UserImporterModule],
  providers: [ DataImporterService ],
})
export class DataImporterModule {}
