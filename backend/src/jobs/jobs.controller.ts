import { Controller, Get, Post, Body, Request, UseGuards, Query, Param } from '@nestjs/common';
import { JobsService } from './jobs.service';
import { JwtAuthGuard } from '../auth/auth.guard';
import { ForbiddenException } from '@nestjs/common';

@Controller('jobs')
export class JobsController {
  constructor(private readonly jobsService: JobsService) {}

  // PUBLIER : Seuls les recruteurs (Logique de vérification dans le service ou un Guard)
 @UseGuards(JwtAuthGuard)
@Post('create')
async createJob(@Request() req, @Body() jobData: any) {
  if (req.user.role !== 'recruteur') {
    throw new ForbiddenException("Seuls les recruteurs peuvent publier des offres.");
  }
  return this.jobsService.create(req.user.sub, jobData);   // req.user.sub = userId
}

  // RECHERCHER & LISTER : Accessible à tous
  // Remplace le findAll par celui-ci
@Get()
async findAll(@Query('search') query?: string) { // On change 'domain' par 'search'
  return this.jobsService.findAll(query);
}

  // POSTULER À UNE OFFRE
  @UseGuards(JwtAuthGuard) // <--- INDISPENSABLE
  @Post(':id/apply')
async applyToJob(@Request() req, @Param('id') jobId: string) {
  return this.jobsService.applyToJob(jobId, req.user.sub);
}
}