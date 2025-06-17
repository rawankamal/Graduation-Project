using Autine.Application.Contracts.Profiles;
using Autine.Application.IServices;

namespace Autine.Application.Features.Profiles.Queries;
public class GetProfileQueryHandler(IAccountService accountService) : IQueryHandler<GetProfileQuery, UserProfileResponse>
{
    public async Task<Result<UserProfileResponse>> Handle(GetProfileQuery request, CancellationToken ct)
        => await accountService.GetProfileAsync(request.UserId, ct);
}