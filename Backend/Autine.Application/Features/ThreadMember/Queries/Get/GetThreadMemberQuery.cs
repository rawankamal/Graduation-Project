using Autine.Application.Contracts.Threads;

namespace Autine.Application.Features.ThreadMember.Queries.Get;
public record GetThreadMemberQuery(Guid Id) : IQuery<ThreadMemberResponse>;
