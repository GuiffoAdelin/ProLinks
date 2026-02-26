import { Controller, Get, Query, Post, UseGuards, Patch, Body, BadRequestException, Request } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/auth.guard';
import { User } from './schemas/user.schema';


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

  @Get('search')
async search(@Query('q') query: string) {
  return this.usersService.searchUsers(query);
}

@Patch('profile')
  @UseGuards(JwtAuthGuard)
  // 2. UTILISATION DU TYPE Request DE NESTJS (req: any ou importé spécifiquement)
  async updateProfile(@Request() req, @Body() updateData: Partial<User>) {
    // req.user contient les infos décodées du JWT (sub est souvent l'ID)
    return this.usersService.update(req.user.sub, updateData);
  }
}