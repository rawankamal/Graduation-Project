using Autine.Application.Contracts.Users;
using Autine.Application.IServices;

namespace Autine.Application.Features.Users.Queries.GetById;
public record GetUserByIdQuery(string AdminId, string UserId) : IQuery<DetailedUserResponse>;

public class GetAllUserQueryHandler(IUserService userService) : IQueryHandler<GetUserByIdQuery, DetailedUserResponse>
{
    public async Task<Result<DetailedUserResponse>> Handle(GetUserByIdQuery request, CancellationToken cancellationToken)
    {
        return await userService.GetAsync(request.UserId, cancellationToken);
    }
}
