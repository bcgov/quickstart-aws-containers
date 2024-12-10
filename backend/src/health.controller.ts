import { Controller, Get } from "@nestjs/common";
import { HealthCheckService, HealthCheck, PrismaHealthIndicator } from "@nestjs/terminus";
import { PrismaService } from "nestjs-prisma";
import { Logger } from "@nestjs/common";
@Controller("health")
export class HealthController {
  private logger = new Logger(HealthController.name);
  constructor(
    private health: HealthCheckService,
    private prisma: PrismaHealthIndicator,
    private readonly prismaService: PrismaService,
  ) {}

  @Get()
  check() {
    return "OK";
  }
}
