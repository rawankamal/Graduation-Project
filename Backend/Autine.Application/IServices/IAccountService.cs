using Autine.Application.Contracts.Profiles;
using Autine.Application.ExternalContracts.Auth;

namespace Autine.Application.IServices;

public interface IAccountService
{
    Task<Result<AIRegisterRequest>> UpdateProfileAsync(string userId, UpdateUserProfileRequest request, CancellationToken ct = default);
    Task<Result<UserProfileResponse>> GetProfileAsync(string userId, CancellationToken ct = default);
    Task<Result> ChangePasswordAsync(string userId, ChangePasswordRequest request, CancellationToken ct = default);
    Task<Result> ChangeProfilePictureAsync(string userId, IFormFile image, CancellationToken ct = default);
}