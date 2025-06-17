using Autine.Application.Contracts.Auths;
using Autine.Application.Features.Auth.Commands.ConfirmEmail;
using Autine.Application.Features.Auth.Commands.ForgotPassword;
using Autine.Application.Features.Auth.Commands.Login;
using Autine.Application.Features.Auth.Commands.ReConfirmEmail;
using Autine.Application.Features.Auth.Commands.RefreshTokens;
using Autine.Application.Features.Auth.Commands.Register;
using Autine.Application.Features.Auth.Commands.RegisterSupervisor;
using Autine.Application.Features.Auth.Commands.ResetPassword;
using Autine.Application.Features.Auth.Commands.RevokeRefreshToken;

namespace Autine.Api.Controllers;

[Route("auths")]
[ApiController]
public class AuthsController(ISender _sender) : ControllerBase
{
    [ProducesResponseType(typeof(RegisterResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request, CancellationToken cancellationToken)
    {
        var command = new RegisterCommand(request);

        var result = await _sender.Send(command, cancellationToken);

        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }
    [HttpPost("supervisor-register")]
    [ProducesResponseType(typeof(RegisterResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> SupervisorRegister([FromBody] CreateSupervisorRequest request, CancellationToken cancellationToken)
    {
        var command = new RegisterSupervisorCommand(request);

        var result = await _sender.Send(command, cancellationToken);

        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }
    [HttpPost("get-token")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetToken([FromBody] TokenRequest request, CancellationToken cancellationToken)
    {
        var command = new CreateTokenCommand(request);

        var result = await _sender.Send(command, cancellationToken);

        return result.IsSuccess ? Ok(result.Value) : result.ToProblem();
    }
    [HttpPost("confirm-email")]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ConfirmEmail([FromBody] ConfirmEmailRequest request)
    {
        var command = new ConfirmEmailCommand(request);

        var result = await _sender.Send(command);

        return result.IsSuccess ? Ok() : result.ToProblem();
    }
    [HttpPost("reconfirm-email")]
    [ProducesResponseType(typeof(RegisterResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> ReConfirmEmail([FromBody] ResendConfirmEmailRequest request)
    {
        var command = new ReConfirmEmailCommand(request);

        var result = await _sender.Send(command);

        return result.IsSuccess ? Ok(result.Value) : result.ToProblem();
    }

    [HttpPost("forgot-password")]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(RegisterResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
    {
        var command = new ForgotPasswordCommand(request);

        var result = await _sender.Send(command);

        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }

    [HttpPost("reset-password")]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
    {
        var command = new ResetPasswordCommand(request);
        var result = await _sender.Send(command);
        return result.IsSuccess
            ? Ok()
            : result.ToProblem();
    }

    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh([FromBody] RefreshTokenRequest request, CancellationToken ct = default)
    {
        var command = new RefreshTokenCommand(request);
        var result = await _sender.Send(command, ct);

        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }
    [HttpPost("revoke-refresh-token")]
    public async Task<IActionResult> RevokeRefresh([FromBody] RefreshTokenRequest request, CancellationToken ct = default)
    {
        var command = new RevokeRefreshTokenCommand(request);
        var result = await _sender.Send(command, ct);

        return result.IsSuccess
            ? NoContent()
            : result.ToProblem();
    }
}
