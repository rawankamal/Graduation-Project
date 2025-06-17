using Autine.Application.Contracts.Threads;

namespace Autine.Application.Features.Threads.Queries.GetAll;
public record GetThreadsQuery(string UserId) : IQuery<IEnumerable<ThreadResponse>>;
