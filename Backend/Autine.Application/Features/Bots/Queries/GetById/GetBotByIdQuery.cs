using Autine.Application.Contracts.Bots;

namespace Autine.Application.Features.Bots.Queries.GetById;
public record GetBotByIdQuery(string UserId, Guid BotId) : IQuery<DetailedBotResponse>;
