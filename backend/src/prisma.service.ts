import { Injectable, OnModuleDestroy, OnModuleInit, Logger, Scope  } from "@nestjs/common";
import { PrismaClient, Prisma } from "@prisma/client";

const DB_HOST = process.env.POSTGRES_HOST || "localhost";
const DB_USER = process.env.POSTGRES_USER || "postgres";
const DB_PWD = encodeURIComponent(process.env.POSTGRES_PASSWORD || "default"); // this needs to be encoded, if the password contains special characters it will break connection string.
const DB_PORT = process.env.POSTGRES_PORT || 5432;
const DB_NAME = process.env.POSTGRES_DATABASE || "postgres";
const DB_SCHEMA = process.env.POSTGRES_SCHEMA || "app";
const DB_POOL_SIZE = parseInt(process.env.POSTGRES_POOL_SIZE || "5", 10);
// SSL settings for PostgreSQL 17+ which requires SSL by default
const SSL_MODE = (process.env.NODE_ENV === 'local' || 'unittest') ? 'prefer' : 'require'; // 'require' for aws deployments, 'prefer' for local development or ut in gha
const dataSourceURL = `postgresql://${DB_USER}:${DB_PWD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?schema=${DB_SCHEMA}&connection_limit=${DB_POOL_SIZE}&sslmode=${SSL_MODE}`;

@Injectable({ scope:  Scope.DEFAULT})
class PrismaService extends PrismaClient<Prisma.PrismaClientOptions, 'query'> implements OnModuleInit, OnModuleDestroy {
  private static instance: PrismaService;
  private logger = new Logger("PRISMA");

  constructor() {
    if (PrismaService.instance) {
      console.log('Returning existing PrismaService instance');
      return PrismaService.instance;
    }
    super({
      errorFormat: 'pretty',
      datasources: {
        db: {
          url: dataSourceURL,
        },
      },
      log: [
        { emit: 'event', level: 'query' },
        { emit: 'stdout', level: 'info' },
        { emit: 'stdout', level: 'warn' },
        { emit: 'stdout', level: 'error' },
      ]
    });
    PrismaService.instance = this;
  }


  async onModuleInit() {
    await this.$connect();
    this.$on<any>('query', (e: Prisma.QueryEvent) => {
      // dont print the health check queries
      if(e?.query?.includes("SELECT 1")) return;
      this.logger.log(
        `Query: ${e.query} - Params: ${e.params} - Duration: ${e.duration}ms`,
      );
    });
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}

export { PrismaService };
