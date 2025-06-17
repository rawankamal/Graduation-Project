using Autine.Application.Contracts.Users;
using Autine.Application.Features.Users.Queries.GetById;

namespace Autine.Application.Features.ThreadMember.Queries.GetMemberDetailed;
public record GetMemberByIdQuery(Guid Id) : IQuery<DetailedUserResponse>;

public class GetMemberByIdQueryHandler(
    ISender sender,
    IUnitOfWork unitOfWork) : IQueryHandler<GetMemberByIdQuery, DetailedUserResponse>
{
    public async Task<Result<DetailedUserResponse>> Handle(GetMemberByIdQuery request, CancellationToken cancellationToken)
    {
        if (await unitOfWork.ThreadMembers.GetAsync(e => e.Id == request.Id, ct: cancellationToken) is not { } member)
            return ThreadMemberErrors.ThreadMemberNotFound;

        var result = await sender.Send(new GetUserByIdQuery(string.Empty, member.MemberId), cancellationToken);
        
        return result.IsSuccess
            ? Result.Success(result.Value)
            : Result.Failure<DetailedUserResponse>(result.Error);
    }
}
