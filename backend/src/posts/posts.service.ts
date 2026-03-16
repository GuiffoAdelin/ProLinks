import { Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Post, PostDocument } from './schemas/post.schema'
import { CreatePostDto, UpdatePostDto } from './dto/post.dto';

@Injectable()
export class PostsService {
  constructor(@InjectModel(Post.name) private postModel: Model<Post>) {}

  async create(createDto: CreatePostDto, userId: string, imageUrl?: string): Promise<PostDocument> {
    const newPost = new this.postModel({
      ...createDto,
      author: new Types.ObjectId(userId),
      image: imageUrl,
    });
    return newPost.save();
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

 async toggleLike(postId: string, userId: string) {
  const post = await this.postModel.findById(postId);
  if (!post) throw new NotFoundException('Post introuvable');

  // On vérifie si l'utilisateur a déjà liké
  const hasLiked = post.likes.includes(userId as any);

  const updatedPost = await this.postModel.findByIdAndUpdate(
    postId,
    {
      [hasLiked ? '$pull' : '$addToSet']: { likes: userId },
    },
    { new: true }, // Pour renvoyer le post mis à jour à Flutter
  ).exec();

  return updatedPost;
}

async addComment(postId: string, content: string, userId: string) {
  const post = await this.postModel.findById(postId);
  if (!post) throw new NotFoundException('Post non trouvé');

  post.comments.push({
    user: new Types.ObjectId(userId),
    content,
    createdAt: new Date(),
  });

  await post.save();
  return post.populate('comments.user', 'nom prenom photoUrl');
}

async getComments(postId: string) {
  const post = await this.postModel.findById(postId)
    .populate('comments.user', 'nom prenom photoUrl headline')
    .select('comments');
  return post?.comments || [];
}
}