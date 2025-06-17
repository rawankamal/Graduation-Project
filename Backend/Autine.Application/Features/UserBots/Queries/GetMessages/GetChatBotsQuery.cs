using Autine.Application.Contracts.UserBots;

namespace Autine.Application.Features.UserBots.Queries.GetMessages;
public record GetChatBotsQuery(string UserId, Guid BotId) : IQuery<ChatResponse>;