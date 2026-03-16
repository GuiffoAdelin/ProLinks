import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
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

  // Recherche (pour la barre de recherche)
async searchUsers(query: string): Promise<User[]> {
  return this.userModel
    .find({
      $or: [
        { nom: { $regex: query, $options: 'i' } },
        { prenom: { $regex: query, $options: 'i' } },
        { headline: { $regex: query, $options: 'i' } },
        { skills: { $in: [new RegExp(query, 'i')] } },
        { 'experience.position': { $regex: query, $options: 'i' } },
      ],
      isActive: true,
    })
    .select('nom prenom headline photoUrl location skills experience education') // ← AJOUTE CES CHAMPS !
    .exec();
}

// Si tu as getDiscovery (pour l'écran Réseau)
async getDiscovery() {
  return this.userModel
    .find({ isActive: true })
    .select('nom prenom headline photoUrl location skills experience education') // ← AJOUTE ICI AUSSI
    .exec();
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

async updateProfile(userId: string, updateData: any) {
  try {
    console.log('[UPDATE PROFILE] Données reçues :', JSON.stringify(updateData, null, 2));

    const $set: any = {};

    // Champs scalaires (toujours écrasés s’ils existent)
    if (updateData.nom !== undefined) $set.nom = updateData.nom;
    if (updateData.prenom !== undefined) $set.prenom = updateData.prenom;
    if (updateData.headline !== undefined) $set.headline = updateData.headline;
    if (updateData.location !== undefined) $set.location = updateData.location;

    // PHOTO (si présente)
    if (updateData.photoUrl !== undefined) {
      $set.photoUrl = updateData.photoUrl;
      console.log('[UPDATE] photoUrl mis à jour vers :', updateData.photoUrl);
    }

    // COMPÉTENCES → on accepte tableau ou chaîne vide
    if (updateData.skills !== undefined) {
      $set.skills = Array.isArray(updateData.skills) ? updateData.skills : [];
      console.log('[UPDATE] skills mis à jour vers :', $set.skills);
    }

    // EXPÉRIENCE & FORMATION (même logique)
    if (updateData.experience !== undefined) {
      $set.experience = Array.isArray(updateData.experience) ? updateData.experience : [];
    }
    if (updateData.education !== undefined) {
      $set.education = Array.isArray(updateData.education) ? updateData.education : [];
    }

    if (Object.keys($set).length === 0) {
      console.log('[UPDATE PROFILE] Aucun champ à mettre à jour');
      return await this.userModel.findById(userId).exec();
    }

    const updatedUser = await this.userModel.findByIdAndUpdate(
      userId,
      { $set },
      { new: true, runValidators: true }
    ).exec();

    if (!updatedUser) {
      throw new NotFoundException('Utilisateur introuvable');
    }

    console.log('[UPDATE SUCCESS] Profil après mise à jour :', JSON.stringify(updatedUser, null, 2));
    return updatedUser;
  } catch (error) {
    console.error('[UPDATE ERROR]', error);
    throw error;
  }
}
  async sendInvitation(senderId: string, receiverId: string) {
    if (senderId === receiverId) throw new BadRequestException("Action impossible");
    
    return this.userModel.findByIdAndUpdate(receiverId, {
      $addToSet: { pendingRequests: new Types.ObjectId(senderId) }
    }).exec();
  }

  async acceptInvitation(userId: string, friendId: string) {
    // 1. Ajouter l'ami aux deux listes de connexions
    // 2. Retirer de la liste des requêtes en attente
    await this.userModel.findByIdAndUpdate(userId, {
      $pull: { pendingRequests: new Types.ObjectId(friendId) },
      $addToSet: { connections: new Types.ObjectId(friendId) }
    });
    
    await this.userModel.findByIdAndUpdate(friendId, {
      $addToSet: { connections: new Types.ObjectId(userId) }
    });
    
    return { message: "Invitation acceptée" };
  }

  async findOne(id: string): Promise<User> {
  const user = await this.userModel
    .findById(id)
    .select('-password') // masque le mot de passe
    .exec();

  if (!user) {
    throw new NotFoundException('Utilisateur non trouvé');
  }

  return user;
}

// Méthode pour récupérer un utilisateur complet
async findByIdFull(id: string) {
  return this.userModel
    .findById(id)
    .select('+skills +experience +education -password') // + pour forcer l'inclusion
    .exec();
}
}