import { 
  Controller, Post, Get, Patch, Delete, Body, Param, Query, 
  UseGuards, Request, UseInterceptors, UploadedFile, NotFoundException 
} from '@nestjs/common';
import { PostsService } from './posts.service';
import { JwtAuthGuard } from '../auth/auth.guard';
import { CreatePostDto, UpdatePostDto } from './dto/post.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { Post as PostSchema } from './schemas/post.schema'; // Alias pour éviter la confusion avec le décorateur @Post

@Controller('posts')
export class PostsController {
  constructor(private readonly postsService: PostsService) {}

  @UseGuards(JwtAuthGuard)
  @Post() 
  @UseInterceptors(FileInterceptor('image', {
    storage: diskStorage({
      destination: './uploads', 
      filename: (req, file, cb) => {
        const randomName = Array(32).fill(null).map(() => (Math.round(Math.random() * 16)).toString(16)).join('');
        return cb(null, `${randomName}${extname(file.originalname)}`);
      }
    })
  }))
  async create(@Body() createDto: CreatePostDto, @Request() req, @UploadedFile() file: Express.Multer.File): Promise<PostSchema> {
    const imageUrl = file ? `/uploads/${file.filename}` : undefined;
    return this.postsService.create(createDto, req.user.sub, imageUrl);
  }

  @Get()
  async findAll(@Query('limit') limit = 10, @Query('offset') offset = 0) {
    return this.postsService.findAll(+limit, +offset);
  }

  @UseGuards(JwtAuthGuard)
  @Patch(':id')
  async update(@Param('id') id: string, @Body() updateDto: UpdatePostDto, @Request() req): Promise<PostSchema> {
    const result = await this.postsService.update(id, updateDto, req.user.sub);
    if (!result) throw new NotFoundException('Post introuvable');
    return result;
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  async remove(@Param('id') id: string, @Request() req) {
    return this.postsService.remove(id, req.user.sub);
  }

  @UseGuards(JwtAuthGuard)
  @Patch(':id/like')
  async likePost(@Param('id') id: string, @Request() req): Promise<PostSchema> {
    const result = await this.postsService.toggleLike(id, req.user.sub);
    if (!result) throw new NotFoundException('Post introuvable');
    return result;
  }

  @Post(':id/comment')
@UseGuards(JwtAuthGuard)
async addComment(
  @Param('id') id: string,
  @Body('content') content: string,
  @Request() req,
) {
  return this.postsService.addComment(id, content, req.user.sub);
}

@Get(':id/comments')
async getComments(@Param('id') id: string) {
  return this.postsService.getComments(id);
}
}