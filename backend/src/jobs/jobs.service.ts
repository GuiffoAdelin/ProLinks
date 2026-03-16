import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Job } from './schemas/job.schema';
import { Notification } from '../notifications/schemas/notification.schema';   // ← Import correct

@Injectable()
export class JobsService {
  constructor(
    @InjectModel(Job.name) private jobModel: Model<Job>,
    @InjectModel(Notification.name) private notificationModel: Model<Notification>,   // ← Injection correcte
  ) {}

  // Publier une offre
  async create(creatorId: string, jobData: any) {
    const newJob = new this.jobModel({
      ...jobData,
      poster: new Types.ObjectId(creatorId),
    });
    return newJob.save();
  }

  async findAll(query?: string) {
    if (!query || query.trim() === '') {
      return this.jobModel.find().sort({ createdAt: -1 }).exec();
    }

    const regex = new RegExp(query, 'i');
    return this.jobModel.find({
      $or: [
        { title: regex },
        { company: regex },
        { location: regex },
        { description: regex },
        { domain: regex },
      ]
    }).sort({ createdAt: -1 }).exec();
  }

  // POSTULER + CRÉER NOTIFICATION
  async applyToJob(jobId: string, applicantId: string) {
    const job = await this.jobModel.findById(jobId);
    if (!job) throw new NotFoundException("Offre non trouvée");

    await this.jobModel.findByIdAndUpdate(
      jobId,
      { $addToSet: { applicants: new Types.ObjectId(applicantId) } }
    );

    // Création de la notification
    if (job.poster.toString() !== applicantId) {
      await this.notificationModel.create({
        recipient: job.poster,
        applicant: new Types.ObjectId(applicantId),
        job: job._id,
        isRead: false,
      });
    }

    return { message: "Candidature envoyée avec succès" };
  }
}