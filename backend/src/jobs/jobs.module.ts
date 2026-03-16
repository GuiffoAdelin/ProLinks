import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Job, JobSchema } from './schemas/job.schema';
import { Notification, NotificationSchema } from '../notifications/schemas/notification.schema'; // ← Ajout du modèle
import { JobsController } from './jobs.controller';
import { JobsService } from './jobs.service';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    // Job + Notification dans le même module (solution la plus simple et fiable)
    MongooseModule.forFeature([
      { name: Job.name, schema: JobSchema },
      { name: Notification.name, schema: NotificationSchema },
    ]),
    NotificationsModule,
  ],
  controllers: [JobsController],
  providers: [JobsService],
  exports: [JobsService],
})
export class JobsModule {}