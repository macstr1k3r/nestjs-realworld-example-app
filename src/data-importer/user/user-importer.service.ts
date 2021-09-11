import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { UserEntity } from "../../user/user.entity";
import users from "./users.data.json";

@Injectable()
export class UserImporterService {
  @InjectRepository(UserEntity)
  private readonly userRepository: Repository<UserEntity>;

  public async import() {
    console.trace("import");
    return;
    for (const rawUser of users) {
      const user = new UserEntity();

      user.articles = rawUser.articles;
      user.favorites = rawUser.favorites;
      user.bio = rawUser.bio;
      user.email = rawUser.email;
      user.id = rawUser.id;
      user.image = rawUser.image;
      user.password = rawUser.password;
      user.username = rawUser.username;

      await this.userRepository.save(user);
    }
  }
}
