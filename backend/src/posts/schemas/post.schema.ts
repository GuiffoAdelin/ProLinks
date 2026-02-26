import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

@Schema({ timestamps: true })
export class Post extends Document {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  author: Types.ObjectId; 

  @Prop({ required: true })
  content: string;

  @Prop()
  mediaUrl?: string;

  @Prop({ default: [] })
  likes: string[]; 

  @Prop({ default: [] })
  comments: any[];
}

export const PostSchema = SchemaFactory.createForClass(Post);