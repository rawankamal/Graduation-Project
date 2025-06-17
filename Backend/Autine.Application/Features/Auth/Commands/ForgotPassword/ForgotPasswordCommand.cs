namespace Autine.Application.Features.Auth.Commands.ForgotPassword;
public record ForgotPasswordCommand(ForgotPasswordRequest Request) : ICommand<RegisterResponse>;
