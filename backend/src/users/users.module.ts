import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { MongooseModule } from '@nestjs/mongoose';
import { UsersController } from './users.controller';
//import { UsersService } from './users.service';
import { UsersService } from './users.service';
//import { UsersController } from './users.controller';
import { User, UserSchema } from './schemas/user.schema';
import { JwtStrategy } from '../auth/jwt.strategy';

@Module({
  imports: [MongooseModule.forFeature([{ name: User.name, schema: UserSchema }]),
  JwtModule.register({
      secret: 'secretKey123',
      signOptions: { expiresIn: '1h' },
    }),
],
  controllers: [UsersController],
  //controllers: [UsersController],
  providers: [UsersService, JwtStrategy],
  exports: [UsersService],
})
export class UsersModule {}
