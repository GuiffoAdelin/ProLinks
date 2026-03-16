import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Connection } from './connection.schema';
import { User } from '../users/schemas/user.schema';

@Injectable()
export class ConnectionsService {
  constructor(
    @InjectModel(Connection.name) private connectionModel: Model<Connection>,
    @InjectModel(User.name) private userModel: Model<User>,
  ) {}

  // 1. Découverte (profils à inviter)
  async getDiscovery(userId: string) {
    const userObjectId = new Types.ObjectId(userId);
    return this.userModel
      .find({ _id: { $ne: userObjectId } })
      .select('nom prenom headline photoUrl')
      .exec();
  }

  // 2. Envoyer une invitation
  async sendInvite(senderId: string, receiverId: string) {
    const newInvite = new this.connectionModel({
      sender: new Types.ObjectId(senderId),
      receiver: new Types.ObjectId(receiverId),
      status: 'PENDING',
    });
    return newInvite.save();
  }

  // 3. Invitations reçues en attente
  async getPendingRequests(userId: string) {
    console.log("🔍 getPendingRequests appelé pour userId =", userId);
    return this.connectionModel
      .find({ receiver: new Types.ObjectId(userId), status: 'PENDING' })
      .populate('sender', 'nom prenom headline photoUrl')
      .exec();
  }

  // === NOUVEAU : Nombre total de connexions acceptées ===
  async getConnectionCount(userId: string) {
    const count = await this.connectionModel.countDocuments({
      $or: [
        { sender: new Types.ObjectId(userId), status: 'ACCEPTED' },
        { receiver: new Types.ObjectId(userId), status: 'ACCEPTED' },
      ],
    });
    return count;
  }

  // 4. Accepter ou refuser
  async respond(inviteId: string, status: 'ACCEPTED' | 'REJECTED') {
    return this.connectionModel.findByIdAndUpdate(inviteId, { status }, { new: true });
  }
}