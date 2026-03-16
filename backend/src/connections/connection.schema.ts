import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export enum ConnectionStatus {
  PENDING = 'PENDING',
  ACCEPTED = 'ACCEPTED',
  REJECTED = 'REJECTED',
}

@Schema({ timestamps: true })
export class Connection extends Document {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  sender: Types.ObjectId;           // Celui qui envoie l’invitation

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  receiver: Types.ObjectId;         // Celui qui reçoit l’invitation

  @Prop({ type: String, enum: ConnectionStatus, default: ConnectionStatus.PENDING })
  status: ConnectionStatus;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;
}

export const ConnectionSchema = SchemaFactory.createForClass(Connection);