import {NestExpressApplication} from "@nestjs/platform-express";
import {bootstrap} from "./app";
import {Logger} from "@nestjs/common";
const logger = new Logger('NestApplication');
bootstrap().then(async (app: NestExpressApplication) => {
  const port = process.env.PORT || 3000;
  await app.listen(port);
  logger.log(`Listening on ${await app.getUrl()}`);
  logger.log(`Process start up took ${process.uptime()} seconds`);
}).catch(err=>{
  logger.error(err);
});
