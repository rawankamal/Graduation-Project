
namespace Autine.Application.Features.Messages.Queries.GetConnections;
public record GetUserConnectionsQuery(string UserId) : IQuery<IList<string>>;
