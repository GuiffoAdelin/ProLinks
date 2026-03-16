import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type JobDocument = Job & Document;

@Schema({ timestamps: true })
export class Job {
  @Prop({ required: true }) title: string;
  @Prop({ required: true }) company: string;
  @Prop({ required: true }) location: string; // Mis en requis pour plus de clarté
  @Prop({ required: true }) description: string; // Mis en requis
  @Prop({ default: 'Temps plein' }) type: string;
  @Prop({ required: true }) domain: string;

  // ON GARDE UN SEUL CHAMP POUR LE RECRUTEUR
  @Prop({ type: Types.ObjectId, ref: 'User', required: true }) poster: Types.ObjectId; 
  @Prop({ type: [{ type: Types.ObjectId, ref: 'User' }], default: [] }) applicants: Types.ObjectId[];
}

export const JobSchema = SchemaFactory.createForClass(Job);