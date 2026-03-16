import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Notification } from './schemas/notification.schema';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectModel(Notification.name) private notificationModel: Model<Notification>,
  ) {}

  // Récupérer les notifications du recruteur
  async getForUser(userId: string) {
    return this.notificationModel
      .find({ recipient: userId })
      .populate('applicant', 'nom prenom photoUrl')
      .populate('job', 'title')
      .sort({ createdAt: -1 })
      .exec();
  }
}