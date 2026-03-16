import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

@Schema({ timestamps: true })
export class Invitation extends Document {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true }) sender: Types.ObjectId;
  @Prop({ type: Types.ObjectId, ref: 'User', required: true }) receiver: Types.ObjectId;
  @Prop({ default: 'pending', enum: ['pending', 'accepted', 'rejected'] }) status: string;
}

export const InvitationSchema = SchemaFactory.createForClass(Invitation);