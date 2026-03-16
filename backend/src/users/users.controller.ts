import { Controller, Get, Query, Post, UseGuards, Param, Patch, Body, BadRequestException, Request } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/auth.guard';
import { User } from './schemas/user.schema';
import { UseInterceptors, UploadedFile } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';


@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post('register')
  async register(
    @Body('email') email: string,
    @Body('password') password: string,
    @Body('role') role: string,
  ) {
    if (!email || !password || !role) {
      throw new BadRequestException('Email, mot de passe et rôle sont obligatoires');
    }

    return this.usersService.register(email, password, role);
  }

  @Post('login')
  async login(
    @Body('email') email: string,
    @Body('password') password: string,
  ) {
    if (!email || !password) {
      throw new BadRequestException('Email et mot de passe sont obligatoires');
    }

    return this.usersService.login(email, password);
  }

// 1. RECHERCHE D'UTILISATEURS (Utilisé par ton SearchDelegate)
  @UseGuards(JwtAuthGuard)
  @Get('search')
  async search(@Query('q') query: string) {
    return this.usersService.searchUsers(query);
  }

  // 2. MISE À JOUR DU PROFIL
@UseGuards(JwtAuthGuard)
@Patch('profile')
async updateProfile(@Request() req, @Body() updateData: any) {
  const userId = req.user.sub || req.user.id || req.user._id || req.user.userId;

  if (!userId) {
    console.log('[CONTROLLER] req.user complet :', req.user);
    throw new BadRequestException('ID utilisateur manquant dans le token');
  }

  console.log('[CONTROLLER] Mise à jour demandée pour userId:', userId, 'avec données:', updateData);

  return this.usersService.updateProfile(userId, updateData);
}

  // 3. ENVOYER UNE INVITATION
  @UseGuards(JwtAuthGuard)
  @Post('invite/:id')
  async sendInvitation(@Request() req, @Param('id') receiverId: string) {
    return this.usersService.sendInvitation(req.user.sub, receiverId);
  }

  // 4. ACCEPTER UNE INVITATION
  @UseGuards(JwtAuthGuard)
  @Post('accept/:id')
  async acceptInvitation(@Request() req, @Param('id') friendId: string) {
    return this.usersService.acceptInvitation(req.user.sub, friendId);
  }

  @UseGuards(JwtAuthGuard)
  @Post('upload-avatar')
@UseGuards(JwtAuthGuard)
@UseInterceptors(FileInterceptor('file', {
  storage: diskStorage({
    destination: './uploads/avatars',
    filename: (req, file, cb) => {
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
      cb(null, `avatar-${uniqueSuffix}${extname(file.originalname)}`);
    },
  }),
}))
async uploadAvatar(@Request() req, @UploadedFile() file: Express.Multer.File) {
  if (!file) throw new BadRequestException('Fichier manquant');

  const userId = req.user.sub || req.user.id;
  const relativePath = `/uploads/avatars/${file.filename}`;   // ← On garde seulement le chemin

  // Mise à jour avec chemin relatif (pas l'URL complète)
  return this.usersService.updateProfile(userId, { photoUrl: relativePath });
}

@UseGuards(JwtAuthGuard)
@Get('me')
async getCurrentUser(@Request() req) {
  const userId = req.user.sub || req.user.id;
  return this.usersService.findOne(userId); // retourne l'utilisateur COMPLET
}
}