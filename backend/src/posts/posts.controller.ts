import { Controller, Post, Get, Patch, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { PostsService } from './posts.service';
import { JwtAuthGuard } from '../auth/auth.guard';
import { CreatePostDto, UpdatePostDto } from './dto/post.dto';

@Controller('posts')
export class PostsController {
  constructor(private readonly postsService: PostsService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  async create(@Body() createDto: CreatePostDto, @Request() req) {
    return this.postsService.create(createDto, req.user.sub);
  }

  @Get()
  async findAll(@Query('limit') limit = 10, @Query('offset') offset = 0) {
    return this.postsService.findAll(+limit, +offset);
  }

  @UseGuards(JwtAuthGuard)
  @Patch(':id')
  async update(@Param('id') id: string, @Body() updateDto: UpdatePostDto, @Request() req) {
    return this.postsService.update(id, updateDto, req.user.sub);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  async remove(@Param('id') id: string, @Request() req) {
    return this.postsService.remove(id, req.user.sub);
  }
}