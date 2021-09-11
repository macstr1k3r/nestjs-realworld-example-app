import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { UserEntity } from "../../user/user.entity";
import { UserImporterService } from "./user-importer.service";

@Module({
  imports: [TypeOrmModule.forFeature([UserEntity])],
  providers: [UserImporterService],
  exports: [UserImporterService],
})
export class UserImporterModule {}
