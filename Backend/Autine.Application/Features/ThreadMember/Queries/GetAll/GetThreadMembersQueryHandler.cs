using Autine.Application.Contracts.Threads;

namespace Autine.Application.Features.ThreadMember.Queries.GetAll;
public class GetThreadMembersQueryHandler(IUserService userService) : IQueryHandler<GetThreadMembersQuery, IEnumerable<ThreadChatMemberResponse>>
{
    public async Task<Result<IEnumerable<ThreadChatMemberResponse>>> Handle(GetThreadMembersQuery request, CancellationToken cancellationToken)
    {
        
        var response = await userService.GetThreadMemberResponse(request.ThreadId, cancellationToken);

        return Result.Success(response);
    }
}
