using Autine.Application.Contracts.Bots;

namespace Autine.Application.Features.UserBots.Queries.GetMyBots;
public record GetMyBotsQuery(string UserId) : IQuery<IEnumerable<PatientBotsResponse>>;
