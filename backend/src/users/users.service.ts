import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, Role } from './schemas/user.schema';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(
    @InjectModel(User.name) private userModel: Model<User>,
    private jwtService: JwtService,
  ) {}

  async register(email: string, password: string, role: string) {
    if (!Object.values(Role).includes(role as Role)) {
      throw new BadRequestException('Rôle invalide : professionnel ou recruteur');
    }

    const existing = await this.userModel.findOne({ email });
    if (existing) {
      throw new BadRequestException('Cet email est déjà utilisé');
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    // CRÉATION AVEC VALEURS PAR DÉFAUT
    const user = new this.userModel({
      email,
      password: hashedPassword,
      role: role as Role,
      nom: email.split('@')[0], // Prend la partie avant le @
      prenom: 'Utilisateur',
      headline: 'Nouveau membre ProLinks',
      location: 'Cameroun', // Valeur standard
      photoUrl: 'https://www.w3schools.com/howto/img_avatar.png', // Image générique
      isActive: true,
    });

    await user.save();

    return {
      message: 'Inscription réussie',
      user: {
        id: user._id,
        email: user.email,
        role: user.role,
        nom: user.nom,
        prenom: user.prenom,
      },
    };
  }

  async login(email: string, password: string) {
    const user = await this.userModel.findOne({ email }).select('+password');
    if (!user || !(await bcrypt.compare(password, user.password))) {
      throw new BadRequestException('Identifiants incorrects');
    }

    const payload = { email: user.email, sub: user._id, role: user.role };
    const access_token = this.jwtService.sign(payload);

    return {
      message: 'Connexion réussie',
      access_token,
      user: {
        id: user._id,
        email: user.email,
        role: user.role,
        nom: user.nom,
        prenom: user.prenom,
        photoUrl: user.photoUrl,
      },
    };
  }

  async searchUsers(query: string): Promise<User[]> {
  return this.userModel.find({
    $or: [
      { nom: { $regex: query, $options: 'i' } },
      { prenom: { $regex: query, $options: 'i' } },
      { headline: { $regex: query, $options: 'i' } },
      // Pour les skills (tableau de strings)
      { skills: { $in: [new RegExp(query, 'i')] } }, 
      // Pour l'expérience (recherche dans le titre du poste)
      { 'experience.position': { $regex: query, $options: 'i' } },
    ],
    isActive: true,
  }).exec();
}

async update(userId: string, updateData: Partial<User>): Promise<User> {
  const updatedUser = await this.userModel
    .findByIdAndUpdate(userId, { $set: updateData }, { new: true })
    .exec();

  if (!updatedUser) {
    throw new BadRequestException('Utilisateur non trouvé');
  }
  return updatedUser;
}
}