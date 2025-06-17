using Autine.Application.Contracts.UserBots;

namespace Autine.Application.Features.UserBots.Queries.GetById;
public record GetBotUserByIdQuery(string UserId, Guid BotId) : IQuery<UserBotDetailedResponse>;

