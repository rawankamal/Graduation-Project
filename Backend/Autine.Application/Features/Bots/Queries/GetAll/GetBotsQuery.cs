using Autine.Application.Contracts.Bots;

namespace Autine.Application.Features.Bots.Queries.GetAll;
public record GetBotsQuery(string UserId) : IQuery<ICollection<BotResponse>>;
