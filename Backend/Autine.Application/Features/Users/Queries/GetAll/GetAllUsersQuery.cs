using Autine.Application.Contracts.Users;

namespace Autine.Application.Features.Users.Queries.GetAll;
public record GetAllUsersQuery(string UserId) : IQuery<IEnumerable<UserResponse>>;

public class GetAllUserQueryHandler(IUserService userService) : IQueryHandler<GetAllUsersQuery, IEnumerable<UserResponse>>
{
    public async Task<Result<IEnumerable<UserResponse>>> Handle(GetAllUsersQuery request, CancellationToken cancellationToken)
    {
        var result = await userService.GetAllAsync(request.UserId, null, cancellationToken);

        return Result.Success(result);
    }
}
