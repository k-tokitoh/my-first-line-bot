import { APIGatewayProxyHandler, APIGatewayEvent, Context } from "aws-lambda";
import {
  ClientConfig,
  Client,
  WebhookEvent,
  validateSignature,
  SignatureValidationFailed,
  WebhookRequestBody,
} from "@line/bot-sdk";
import { Message, MessageAPIResponseBase } from "@line/bot-sdk/lib/types";

const accessToken = process.env.CHANNEL_ACCESS_TOKEN!;
const channelSecret = process.env.CHANNEL_SECRET!;

const config: ClientConfig = {
  channelAccessToken: accessToken,
  channelSecret: channelSecret,
};
const client = new Client(config);

const eventHandler: (
  event: WebhookEvent
) => Promise<MessageAPIResponseBase | void> = async (event) => {
  if (event.type !== "message" || event.message.type !== "text") {
    return;
  }
  const message: Message = {
    type: "text",
    text: event.message.text,
  };
  return client.replyMessage(event.replyToken, message);
};

export const handler: APIGatewayProxyHandler = async (
  proxyEevent: APIGatewayEvent,
  _context: Context
) => {
  // 署名確認
  const signature = proxyEevent.headers["x-line-signature"] ?? "";
  if (!validateSignature(proxyEevent.body!, channelSecret, signature)) {
    throw new SignatureValidationFailed(
      "signature validation failed",
      signature
    );
  }

  const body: WebhookRequestBody = JSON.parse(proxyEevent.body!);
  await Promise.all(
    body.events.map(async (event) => eventHandler(event))
  ).catch((err) => {
    console.error(err.Message);
    return {
      statusCode: 500,
      body: "Error",
    };
  });
  return {
    statusCode: 200,
    body: "OK",
  };
};
