import { NestFactory } from "@nestjs/core"
import { DataImporterModule } from "./data-importer.module"
import { DataImporterService } from "./data-importer.service";

(async () => {
    const app = await NestFactory.createApplicationContext(DataImporterModule);

    const dataImporter = app.get(DataImporterService);
    await dataImporter.import();
})()