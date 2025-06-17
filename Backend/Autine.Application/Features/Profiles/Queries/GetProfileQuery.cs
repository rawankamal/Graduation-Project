using Autine.Application.Contracts.Profiles;

namespace Autine.Application.Features.Profiles.Queries;
public record GetProfileQuery(string UserId) : IQuery<UserProfileResponse>;
