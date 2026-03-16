import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

@Schema({ timestamps: true })
export class Notification extends Document {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  recipient: Types.ObjectId;   // Le recruteur qui reçoit la notif

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  applicant: Types.ObjectId;   // Celui qui postule

  @Prop({ type: Types.ObjectId, ref: 'Job', required: true })
  job: Types.ObjectId;         // L'offre concernée

  @Prop({ default: false })
  isRead: boolean;
}

export const NotificationSchema = SchemaFactory.createForClass(Notification);