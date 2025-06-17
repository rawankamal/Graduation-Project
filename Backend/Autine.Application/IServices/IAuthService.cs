using Autine.Application.Contracts.Auths;

namespace Autine.Application.IServices;
public interface IAuthService
{
    Task<Result<RegisterResponse>> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken = default);
    Task<Result<string>> RegisterAdminAsync(RegisterRequest request, CancellationToken cancellationToken = default);
    Task<Result<AuthResponse>> GetRefreshTokenAsync(string token, string refreshTokne, CancellationToken cancellationToken = default);
    Task<Result> RevokeRefreshTokenAsync(string token, string refreshTokne, CancellationToken cancellationToken = default);
    Task<Result<RegisterResponse>> RegisterSupervisorAsync(CreateSupervisorRequest request, CancellationToken cancellationToken = default);
    Task<Result<string>> RegisterPatient(RegisterRequest request, CancellationToken ct = default);
    Task<Result<AuthResponse>> GetTokenAsync(TokenRequest loginRequest, CancellationToken cancellationToken = default);
    Task<Result> ConfirmEmailAsync(ConfirmEmailRequest request);
    Task<Result<RegisterResponse>> ReConfirmEmailAsync(ResendConfirmEmailRequest request);
    Task<Result<RegisterResponse>> ForgotPasswordAsync(ForgotPasswordRequest request, CancellationToken cancellationToken = default);
    Task<Result> ResetPasswordAsync(ResetPasswordRequest request, CancellationToken cancellationToken = default);
}
