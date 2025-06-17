using Autine.Application.Contracts.Bots;

namespace Autine.Application.Features.Bots.Queries.GetPatients;
public record GetBotPatientsQuery(string UserId, Guid BotId) : IQuery<IEnumerable<BotPatientsResponse>>;