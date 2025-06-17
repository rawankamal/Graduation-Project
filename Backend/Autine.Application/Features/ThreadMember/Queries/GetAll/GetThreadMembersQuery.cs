using Autine.Application.Contracts.Threads;

namespace Autine.Application.Features.ThreadMember.Queries.GetAll;
public record GetThreadMembersQuery(Guid ThreadId) : IQuery<IEnumerable<ThreadChatMemberResponse>>;