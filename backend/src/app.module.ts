import { Global,Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsersModule } from './users/users.module';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { PostsModule } from './posts/posts.module';
import { ConnectionsModule } from './connections/connections.module';
import { JobsModule } from './jobs/jobs.module';
import { NotificationsModule } from './notifications/notifications.module';

@Global()
@Module({
  imports: [
    MongooseModule.forRoot('mongodb+srv://guiffoadel05_db_user:6fLlyuVR1mxhXZ9P@cluster0.inl8mnj.mongodb.net/prolinks?retryWrites=true&w=majority'),
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.register({ 
      secret: 'secretKey123', // CHANGE ÇA EN PROD (mets dans .env)
      signOptions: { expiresIn: '1h' }, // token expire en 1 heure
    }),
    UsersModule,
    PostsModule,
    ConnectionsModule,
    JobsModule,
    NotificationsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
