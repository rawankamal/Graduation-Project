using Autine.Application.Contracts.Auth;
using Autine.Application.Contracts.Profiles;
using Autine.Application.ExternalContracts.Auth;
using Autine.Application.IServices;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace Autine.Infrastructure.Services;

public class AccountService(
    ApplicationDbContext context, 
    UserManager<ApplicationUser> userManager,
    IFileService fileService,
    IUrlGenratorService urlGenratorService,
     ILogger<AuthService> logger) : IAccountService
{
    private readonly ILogger<AuthService> _logger = logger;
    //get
    public async Task<Result<UserProfileResponse>> GetProfileAsync(string userId, CancellationToken ct = default)
    {
        _logger.LogInformation("Fetching profile for userId: {UserId}", userId);

        var userProfile = await context.Users
            .Where(e => e.Id == userId)
            .Select(x => new UserProfileResponse (
                x.Id, 
                x.FirstName, 
                x.LastName, 
                x.Bio, 
                x.Gender, 
                x.Country, 
                x.City, 
                urlGenratorService.GetImageUrl(x.ProfilePicture, false),
                x.DateOfBirth
            )).SingleOrDefaultAsync(ct);

        if (userProfile is null)
        {
            _logger.LogWarning("User not found: {UserId}", userId);
            return UserErrors.UserNotFound;
        }

        return userProfile;
    }
    // put
    public async Task<Result<AIRegisterRequest>> UpdateProfileAsync(string userId, UpdateUserProfileRequest request, CancellationToken ct = default)
    {
       // _logger.LogInformation("Updating profile for userId: {UserId}", userId);

        var user = await context.Users
            .Where(e => e.Id == userId)
            .Select(x => new AIRegisterRequest(
                x.Email!,
                x.Id,
                x.PasswordHash!,
                request.FirstName,
                request.LastName,
                x.DateOfBirth,
                x.Gender
                )).SingleOrDefaultAsync(ct);

        if (user is null)
        {
            _logger.LogWarning("User not found for update: {UserId}", userId);
            return UserErrors.UserNotFound;
        }


        await context.Users
            .Where(e => e.Id == userId)
            .ExecuteUpdateAsync(setters =>
                setters
                .SetProperty(e => e.FirstName, request.FirstName)
                .SetProperty(e => e.LastName, request.LastName)
                .SetProperty(e => e.Bio, request.Bio)
                .SetProperty(e => e.City, request.City)
                .SetProperty(e => e.Country, request.Country)
                .SetProperty(e => e.Gender, request.Gender)
                .SetProperty(e => e.DateOfBirth, request.DateOfBirth),
                ct
            );
     //   _logger.LogInformation("Profile updated for userId: {UserId}", userId);

        return Result.Success(user);
    }
    public async Task<Result> ChangePasswordAsync(string userId, ChangePasswordRequest request, CancellationToken ct = default)
    {
        _logger.LogInformation("Changing password for userId: {UserId}", userId);

        if (await context.Users.FindAsync([userId], ct) is not { } user)
        {
            _logger.LogWarning("User not found for password change: {UserId}", userId);
            return UserErrors.UserNotFound;
        }

        var changeResult = await userManager.ChangePasswordAsync(user, request.CurrentPassword, request.NewPassword);

        if (!changeResult.Succeeded)
        {
            var error = changeResult.Errors.FirstOrDefault()!;
            _logger.LogWarning("Password change failed for userId: {UserId}. Reason: {Reason}", userId, error.Description);
            return Error.BadRequest(error.Code, error.Description);
        }

        _logger.LogInformation("Password successfully changed for userId: {UserId}", userId);

        return Result.Success();
    }

    public async Task<Result> ChangeProfilePictureAsync(string userId, IFormFile image, CancellationToken ct = default)
    {

        _logger.LogInformation("Changing profile picture for userId: {UserId}", userId);


        if (await context.Users.FindAsync([userId], ct)is not { } user)
        {
            _logger.LogWarning("User not found for profile picture update: {UserId}", userId);
            return UserErrors.UserNotFound;
        }

        var imageUrl = await fileService.UpdateImageAsync(user.ProfilePicture, image, false, ct);

        if (imageUrl.IsFailure)
        {
            _logger.LogError("Image upload failed for userId: {UserId}", userId);
            return imageUrl.Error;
        }


        await context.Users
            .Where(e => e.Id == userId)
            .ExecuteUpdateAsync(setters =>
            setters.SetProperty(e => e.ProfilePicture, imageUrl.Value),
            ct
            );

        _logger.LogInformation("Profile picture updated for userId: {UserId}", userId);

        return Result.Success();
    }
}