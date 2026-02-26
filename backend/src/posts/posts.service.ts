import { Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Post } from './schemas/post.schema';
import { CreatePostDto, UpdatePostDto } from './dto/post.dto';

@Injectable()
export class PostsService {
  constructor(@InjectModel(Post.name) private postModel: Model<Post>) {}

  async create(dto: CreatePostDto, authorId: string) {
    return new this.postModel({ ...dto, author: authorId }).save();
  }

  async findAll(limit: number, offset: number) {
    return this.postModel.find()
      .populate('author', 'nom prenom photoUrl headline')
      .skip(offset)
      .limit(limit)
      .sort({ createdAt: -1 })
      .exec();
  }

  async update(id: string, dto: UpdatePostDto, userId: string) {
    const post = await this.postModel.findById(id);
    if (!post) throw new NotFoundException('Post non trouvé');
    if (post.author.toString() !== userId) throw new ForbiddenException('Non autorisé');
    
    return this.postModel.findByIdAndUpdate(id, dto, { new: true }).exec();
  }

  async remove(id: string, userId: string) {
    const post = await this.postModel.findById(id);
    if (!post) throw new NotFoundException('Post non trouvé');
    if (post.author.toString() !== userId) throw new ForbiddenException('Non autorisé');
    
    return this.postModel.findByIdAndDelete(id).exec();
  }
}