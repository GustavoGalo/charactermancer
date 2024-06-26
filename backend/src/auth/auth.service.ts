import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { randomBytes, scrypt as _scrypt } from 'crypto';
import { PrismaService } from 'prisma/prisma.service';
import { promisify } from 'util';
import { v4 as uuidv4 } from 'uuid';

const scrypt = promisify(_scrypt);

@Injectable()
export class AuthService {
  constructor(private prisma: PrismaService) {}

  async signUp(
    email: string,
    password: string,
    name: string,
    username: string,
  ) {
    const existingUser = await this.prisma.user.findUnique({
      where: { email },
    });
    if (existingUser) {
      return new BadRequestException('Email in use');
    }

    const salt = randomBytes(8).toString('hex');
    const hash = (await scrypt(password, salt, 32)) as Buffer;
    const saltAndHash = `${salt}.${hash.toString('hex')}`;

    const newUser = await this.prisma.user.create({
      data: {
        email,
        password: saltAndHash,
        name,
        username,
        id: uuidv4(),
      },
    });

    return {
      email: newUser.name,
      name: newUser.email,
      username: newUser.username,
    };
  }

  async signIn(email: string, password: string) {
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) {
      return new UnauthorizedException('Invalid credentials');
    }

    const [salt, storedHash] = user.password.split('.');
    const hash = (await scrypt(password, salt, 32)) as Buffer;

    if (storedHash != hash.toString('hex')) {
      return new UnauthorizedException('Invalid credentials');
    }

    return {
      email: user.name,
      name: user.email,
      username: user.username,
    };
  }
}
