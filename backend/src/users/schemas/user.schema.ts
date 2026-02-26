import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export enum Role {
  PROFESSIONNEL = 'professionnel',
  RECRUTEUR = 'recruteur',
  ADMINISTRATEUR = 'administrateur', // optionnel si besoin
}

@Schema({ timestamps: true })
export class User extends Document {
  @Prop({ required: true, unique: true, lowercase: true, trim: true })
  email: string;

  @Prop({ required: true, select: false }) // select: false = ne renvoie pas le hash dans les queries
  password: string;

  @Prop({ type: String, enum: Role, required: true })
  role: Role;

  // Champs essentiels (ajoutés maintenant)
  @Prop({ trim: true })
  nom: string;

  @Prop({ trim: true })
  prenom: string;

  @Prop({ trim: true })
  headline?: string; // ex: "Développeur Flutter | Étudiant GLO3"

  @Prop()
  photoUrl?: string;

  @Prop({ trim: true })
  location?: string; // ville/pays

  @Prop()
  skills?: string[]; // ["Flutter", "NestJS", "MongoDB"]

  @Prop()
  education?: Array<{
    school: string;
    degree: string;
    field: string;
    startYear: number;
    endYear?: number;
  }>;

  @Prop()
  experience?: Array<{
    company: string;
    position: string;
    startDate: Date;
    endDate?: Date;
    description?: string;
  }>;

  @Prop()
  cvUrl?: string; // lien vers CV encrypté/stocké

  @Prop({ enum: ['public', 'private', 'connections'], default: 'private' })
  privacyLevel: string;

  @Prop({ default: true })
  isActive: boolean;

  @Prop()
  lastLogin?: Date;
}

export const UserSchema = SchemaFactory.createForClass(User);