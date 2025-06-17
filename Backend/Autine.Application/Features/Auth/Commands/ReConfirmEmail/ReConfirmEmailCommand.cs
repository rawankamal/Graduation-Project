namespace Autine.Application.Features.Auth.Commands.ReConfirmEmail;
public record ReConfirmEmailCommand(ResendConfirmEmailRequest Request) : ICommand<RegisterResponse>;
