using Autine.Application.Contracts.Auth;
using Autine.Application.Contracts.Auths;
using Autine.Application.IServices;
using Autine.Domain.Abstractions;
using Autine.Infrastructure.Identity.Authentication;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Logging;
using System.Security.Cryptography;
using System.Text;
using System.Threading;

namespace Autine.Infrastructure.Services;
public class AuthService(
    UserManager<ApplicationUser> userManager,
    SignInManager<ApplicationUser> signInManager,
    ApplicationDbContext context,
    IJwtProvider jwtProvider,
    ILogger<AuthService> logger) : IAuthService
{
    private readonly UserManager<ApplicationUser> _userManager = userManager;
    private readonly SignInManager<ApplicationUser> _signInManager = signInManager;
    private readonly ApplicationDbContext _context = context;
    private readonly IJwtProvider _jwtProvider = jwtProvider;
    private readonly int _refreshTokenExpiryDays = 14;
    private readonly ILogger<AuthService> _logger = logger;
    public async Task<Result<AuthResponse>> GetTokenAsync(TokenRequest request, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Attempting login for user: {Email}", request.Email);

        var user = await _userManager.FindByEmailAsync(request.Email);

        if (user is null)
        {
            _logger.LogWarning("Login failed: User with email {Email} not found", request.Email);
            return Result.Failure<AuthResponse>(UserErrors.InvalidCredinitails);
        }


        var result = await _signInManager.PasswordSignInAsync(user, request.Password, false, true);

        if (!result.Succeeded)
        {
            var error =
                result.IsNotAllowed
                ? UserErrors.EmailNotConfirmed
                : result.IsLockedOut
                ? UserErrors.LockedUser
                : UserErrors.InvalidCredinitails;

            _logger.LogWarning("Login failed for user {Email}: {Reason}", request.Email, error.Description);
            return Result.Failure<AuthResponse>(error);
        }

        _logger.LogInformation("Login successful for user: {Email}", request.Email);
        var response = await GenerateTokenAsync(user);

        return response.IsFailure
            ? response.Error
            : response.Value;
    }
    public async Task<Result<AuthResponse>> GetRefreshTokenAsync(string token, string refreshToken, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Refreshing token for access token.");

        var userId = _jwtProvider.ValidateToken(token);

        if (userId == null || await _userManager.FindByIdAsync(userId) is not { } user)
        {
            _logger.LogWarning("Refresh failed: Invalid token");
            return UserErrors.InvalidToken;
        }


        var userRefreshToken = user.RefreshTokens.SingleOrDefault(x => x.Token == refreshToken && x.IsActive);

        if (userRefreshToken == null)
        {
            _logger.LogWarning("Refresh failed: Refresh token is inactive or not found");
            return UserErrors.InvalidToken;
        }

        userRefreshToken.RevokedOn = DateTime.UtcNow;

        _logger.LogInformation("Refresh token validated and revoked. Generating new token...");
        var response = await GenerateTokenAsync(user);

        return response.IsFailure
            ? response.Error
            : response.Value;
    }
    public async Task<Result<string>> RegisterAdminAsync(RegisterRequest request, CancellationToken cancellationToken = default)
    {

        if (await _context.Users.AnyAsync(e => e.Email == request.Email, cancellationToken))
        {
            _logger.LogWarning("Attempt to register with duplicate email: {Email}", request.Email);
            return UserErrors.DuplicatedEmail;
        }

        if (await _context.Users.AnyAsync(e => e.UserName == request.UserName, cancellationToken))
        {
            _logger.LogWarning("Attempt to register with duplicate username: {UserName}", request.UserName);
            return UserErrors.DuplicatedUsername;
        }

        var user = request.Adapt<ApplicationUser>();
        user.EmailConfirmed = true;
        user.Bio ??= string.Empty;
        var result = await _userManager.CreateAsync(user, request.Password);

        if (!result.Succeeded)
        {
            var error = result.Errors.First();
            _logger.LogError("Admin registration failed for email: {Email} - Error: {Error}", request.Email, error.Description);
            return Error.BadRequest(error.Code, error.Description);
        }

        var roleResult = await _userManager.AddToRoleAsync(user, DefaultRoles.Admin.Name);
        if (!roleResult.Succeeded)
        {
            var error = result.Errors.First();
            _logger.LogError("Failed to assign admin role to userId: {UserId} - Error: {Error}", user.Id, error.Description);
            return Error.BadRequest(error.Code, error.Description);
        }

        

        return Result.Success(user.Id);
    }
    public async Task<Result<RegisterResponse>> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Registering user: {Email}", request.Email);
        var user = await RegisterValidationAsync(request, ct: cancellationToken);

        if (user.IsFailure)
        {
            _logger.LogWarning("User registration failed: {Reason}", user.Error.Description);
            return user.Error;
        }

        var addToRoleResult = await _userManager.AddToRoleAsync(user.Value, DefaultRoles.User.Name);

        if (!addToRoleResult.Succeeded)
        {
            var error = addToRoleResult.Errors.First();
            _logger.LogError("Failed to assign user role: {Error}", error.Description);
            return Error.BadRequest(error.Code, error.Description);
        }

        var code = await GenerateEmailConfirmationCodeAync(user.Value);
        var response = new RegisterResponse(code, user.Value.Id);

        return Result.Success(response);
    }
    public async Task<Result<RegisterResponse>> RegisterSupervisorAsync(CreateSupervisorRequest request, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Registering supervisor: {Email}", request.Email);

        var registerRequest = new RegisterRequest(
            request.FirstName,
            request.LastName,
            request.Email,
            request.UserName,
            request.Password,
            request.Gender,
            request.DateOfBirth,
            request.Country,
            request.City,
            request.Bio
            );

        var user = await RegisterValidationAsync(registerRequest,ct: cancellationToken);

        if (user.IsFailure)
        {
            _logger.LogWarning("Supervisor registration failed: {Email}. Error: {Reason}", request.Email, user.Error);
            return user.Error;
        }


        var addToRoleResult = await _userManager.AddToRoleAsync(user.Value!, request.SuperviorRole);
        
        if (!addToRoleResult.Succeeded)
        {
            var error = addToRoleResult.Errors.First();
            _logger.LogError("Failed to assign supervisor role to userId: {UserId}  Error :{Raeson}", user.Value.Id, error.Description);
            return Error.BadRequest(error.Code, error.Description);
        }

        var code = await GenerateEmailConfirmationCodeAync(user.Value);
      //  _logger.LogInformation("Supervisor registered: {UserId}", user.Value.Id);

        var response = new RegisterResponse(code, user.Value.Id);

        return Result.Success(response);
    }
    public async Task<Result<string>> RegisterPatient(RegisterRequest request, CancellationToken ct = default)
    {
        _logger.LogInformation("Registering patient: {Email}", request.Email);

        var result = await RegisterValidationAsync(request,true, ct: ct);

        if (result.IsFailure)
        {
            _logger.LogWarning("Patient registration failed: {Email}. Error: {Reason}", request.Email, result.Error);
            return result.Error;
        }


        var addToRoleResult = await _userManager.AddToRolesAsync(result.Value, [DefaultRoles.Patient.Name, DefaultRoles.User.Name]);

        if (!addToRoleResult.Succeeded)
        {
            var error = addToRoleResult.Errors.First();
            _logger.LogError("Failed to assign patient roles to userId: {UserId}. Error: {Reason}", result.Value.Id, error.Description);
            return Error.BadRequest(error.Code, error.Description);
        }
        _logger.LogInformation("Patient registered: {UserId}", result.Value.Id);
        return Result.Success(result.Value.Id);
    }
    
    public async Task<Result> ConfirmEmailAsync(ConfirmEmailRequest request)
    {
        _logger.LogInformation("Confirming email for userId: {UserId}", request.UserId);

        if (await _userManager.FindByIdAsync(request.UserId) is not { } user)
        {
            _logger.LogWarning("User not found during email confirmation: {UserId}", request.UserId);
            return UserErrors.InvalidCode;
        }

        if (user.EmailConfirmed)
        {
            _logger.LogInformation("Email already confirmed for userId: {UserId}", request.UserId);
            return UserErrors.EmailConfirmed;
        }

        var code = request.Code;
        IdentityResult result;
        try
        {
            code = Encoding.UTF8.GetString(WebEncoders.Base64UrlDecode(code));
            result = await _userManager.ConfirmEmailAsync(user, code);
        }
        catch (FormatException)
        {
            _logger.LogError("Invalid token format during email confirmation for userId: {UserId}", request.UserId);
            result = IdentityResult.Failed(_userManager.ErrorDescriber.InvalidToken());
        }

        if (!result.Succeeded)
        {
            var error = result.Errors.First();
            _logger.LogWarning("Email confirmation failed for userId: {UserId}, Reason: {Reason}", request.UserId, error.Description);
            return Error.BadRequest(error.Code, error.Description);
        }

        _logger.LogInformation("Email successfully confirmed for userId: {UserId}", request.UserId);
        return Result.Success();
    }
    public async Task<Result<RegisterResponse>> ReConfirmEmailAsync(ResendConfirmEmailRequest request)
    {
        _logger.LogInformation("Re-sending email confirmation to: {Email}", request.Email);

        if (await _userManager.FindByEmailAsync(request.Email) is not { } user)
        {
            _logger.LogWarning("User not found for re-confirm email: {Email}", request.Email);
            return Result.Failure<RegisterResponse>(UserErrors.UserNotFound);
        }

        if (user.EmailConfirmed)
        {
            _logger.LogInformation("User already confirmed email: {Email}", request.Email);
            return Result.Failure<RegisterResponse>(UserErrors.EmailConfirmed);
        }

        var code = await _userManager.GenerateEmailConfirmationTokenAsync(user);

        code = WebEncoders.Base64UrlEncode(Encoding.UTF8.GetBytes(code));

        _logger.LogInformation("Confirmation email re-sent to: {Email}", request.Email);

        var response = new RegisterResponse(code, user.Id);

        return Result.Success(response);
    }
    public async Task<Result<RegisterResponse>> ForgotPasswordAsync(ForgotPasswordRequest request, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Password reset requested for: {Email}", request.Email);

        if (await _userManager.FindByEmailAsync(request.Email) is not { } user)
        {
            _logger.LogWarning("User not found for forgot password: {Email}", request.Email);
            return UserErrors.UserNotFound;
        }

        if (!user.EmailConfirmed)
        {
            _logger.LogWarning("Email not confirmed for password reset: {Email}", request.Email);
            return UserErrors.EmailNotConfirmed;
        }

        var token = await _userManager.GeneratePasswordResetTokenAsync(user);

        token = WebEncoders.Base64UrlEncode(Encoding.UTF8.GetBytes(token));

        _logger.LogInformation("Password reset token generated for: {Email}", request.Email);

        var response = new RegisterResponse(token, user.Id);

        return response;
    }
    
    public async Task<Result> ResetPasswordAsync(ResetPasswordRequest request, CancellationToken ct = default)
    {
        _logger.LogInformation("Attempting password reset for user: {UserId}", request.UserId);

        if (await _userManager.FindByIdAsync(request.UserId) is not { } user)
        {
            _logger.LogWarning("Reset password failed: User not found {UserId}", request.UserId);
            return Result.Failure(UserErrors.InvalidCode);
        }

        var code = request.Code;
        IdentityResult result;
        try
        {
            code = Encoding.UTF8.GetString(WebEncoders.Base64UrlDecode(code));
            if (await _userManager.CheckPasswordAsync(user, request.Password))
            {
                _logger.LogWarning("Reset password failed: New password matches the old one for user {UserId}", request.UserId);
                return UserErrors.InvalidPassword;
            }

            result = await _userManager.ResetPasswordAsync(user, code, request.Password);
        }
        catch (FormatException)
        {
            _logger.LogError("Reset password failed: Invalid format for token for user {UserId}", request.UserId);
            result = IdentityResult.Failed(_userManager.ErrorDescriber.InvalidToken());
        }

        if (!result.Succeeded)
        {
            var error = result.Errors.FirstOrDefault();
            _logger.LogError("Password reset failed for user {UserId}: {Error}", request.UserId, error?.Description);
            return Error.BadRequest(error!.Code, error.Description);
        }

        return Result.Success();
    }
    private async Task<string> GenerateEmailConfirmationCodeAync(ApplicationUser user)
    {
        var code = await _userManager.GenerateEmailConfirmationTokenAsync(user);
        code = WebEncoders.Base64UrlEncode(Encoding.UTF8.GetBytes(code));
        return code;
    }
    private async Task<Result<ApplicationUser>> RegisterValidationAsync(RegisterRequest request, bool IsConfirmed = false, CancellationToken ct = default)
    {
        if (await _context.Users.AnyAsync(e => e.Email == request.Email, ct))
        {
            _logger.LogWarning("Email already registered: {Email}", request.Email);
            return UserErrors.DuplicatedEmail;
        }

        if (await _context.Users.AnyAsync(e => e.UserName == request.UserName, ct))
        {
            _logger.LogWarning("Username already taken: {UserName}", request.UserName);
            return UserErrors.DuplicatedUsername;
        }

        var user = request.Adapt<ApplicationUser>();
        user.EmailConfirmed = IsConfirmed;
        user.Bio ??= string.Empty;
        var result = await _userManager.CreateAsync(user, request.Password);

        if (!result.Succeeded)
        {
            var error = result.Errors.First();
            _logger.LogError("User registration failed: {Error}", error.Description);
            return Error.BadRequest(error.Code, error.Description);
        }

        _logger.LogInformation("User registered: {UserId}", user.Id);
        return Result.Success(user);
    }
    private static string GenerateRefreshToken()
        => Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));
    private async Task<Result<AuthResponse>> GenerateTokenAsync(ApplicationUser user)
    {
        var refreshToken = GenerateRefreshToken();
        var refreshTokenExpriation = DateTime.UtcNow.AddDays(_refreshTokenExpiryDays);

        user.RefreshTokens.Add(new()
        {
            Token = refreshToken,
            ExpiresOn = refreshTokenExpriation
        });

        await _userManager.UpdateAsync(user);
        _logger.LogInformation("Refresh token issued for userId: {UserId}", user.Id);

        var roles = await _userManager.GetRolesAsync(user);

        var (newToken, expireIn) = _jwtProvider.GenerateToken(user, roles);
        _logger.LogInformation("Access token generated for userId: {UserId}, expires in: {ExpireIn} minutes", user.Id, expireIn);

        var response = new AuthResponse(AccessToken: newToken, ExpiresIn: expireIn, RefreshToken: refreshToken, RefreshTokenExpiration: refreshTokenExpriation);

        return response;
    }

    public async Task<Result> RevokeRefreshTokenAsync(string token, string refreshToken, CancellationToken cancellationToken = default)
    {
        var userId = _jwtProvider.ValidateToken(token);

        if (userId == null || await _userManager.FindByIdAsync(userId) is not { } user)
        {
            _logger.LogWarning("No user found with userId: {UserId}", userId);
            return UserErrors.InvalidToken;
        }

        var userRefreshToken = user.RefreshTokens.SingleOrDefault(x => x.Token == refreshToken && x.IsActive);

        if (userRefreshToken == null)
        {
            _logger.LogWarning("No active refresh token found for userId: {UserId}", userId);
            return UserErrors.InvalidToken;
        }

        userRefreshToken.RevokedOn = DateTime.UtcNow;

        await _userManager.UpdateAsync(user);
        _logger.LogInformation("Refresh token revoked for userId: {UserId}", user.Id);

        return Result.Success();
    }
}