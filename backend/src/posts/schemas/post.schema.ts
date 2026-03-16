import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PostDocument = Post & Document;

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

  @Prop({
  type: [{
    user: { type: Types.ObjectId, ref: 'User' },
    content: String,
    createdAt: { type: Date, default: Date.now },
  }],
  default: [],
})
comments: { user: Types.ObjectId; content: string; createdAt: Date }[];

  @Prop()
  image: string;
}

export const PostSchema = SchemaFactory.createForClass(Post);