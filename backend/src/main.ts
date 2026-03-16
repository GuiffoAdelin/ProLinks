import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // === SERVIR LES IMAGES STATIQUES ===
  app.useStaticAssets(join(__dirname, '..', 'uploads'), {
    prefix: '/uploads/',           // Toutes les images seront accessibles via /uploads/...
  });

  // CORS pour ngrok
  app.enableCors({
    origin: '*',
    methods: 'GET,POST,PUT,PATCH,DELETE',
    allowedHeaders: '*',
  });

  await app.listen(3000, '0.0.0.0');

  console.log('🚀 Serveur démarré sur http://localhost:3000');
  console.log('📁 Images accessibles ici → http://localhost:3000/uploads/avatars/xxx.jpg');
  console.log(`URL complète : ${await app.getUrl()}`);
}
bootstrap();