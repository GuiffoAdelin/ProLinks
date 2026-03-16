import { Controller, Get, Post, Param, Body, Request } from '@nestjs/common';
import { ConnectionsService } from './connections.service';
import { JwtAuthGuard } from '../auth/auth.guard';
import { UseGuards } from '@nestjs/common';

@Controller('connections')
@UseGuards(JwtAuthGuard)
export class ConnectionsController {
  constructor(private readonly connectionsService: ConnectionsService) {}

  @Get('discovery')
  async getDiscovery(@Request() req) {
    const userId = req.user.userId || req.user.sub || req.user.id;
    return this.connectionsService.getDiscovery(userId);
  }

  @Post('invite/:receiverId')
  async sendInvite(@Request() req, @Param('receiverId') receiverId: string) {
    const userId = req.user.userId || req.user.sub || req.user.id;
    return this.connectionsService.sendInvite(userId, receiverId);
  }

  @Get('pending')
  async getPendingRequests(@Request() req) {
    const userId = req.user.userId || req.user.sub || req.user.id;
    return this.connectionsService.getPendingRequests(userId);
  }

  // === NOUVEAU : Compteur de connexions ===
  @Get('count')
  async getConnectionCount(@Request() req) {
    const userId = req.user.userId || req.user.sub || req.user.id;
    return this.connectionsService.getConnectionCount(userId);
  }

  @Post('respond/:id')
  async respond(@Param('id') id: string, @Body() body: { status: 'ACCEPTED' | 'REJECTED' }) {
    return this.connectionsService.respond(id, body.status);
  }
}