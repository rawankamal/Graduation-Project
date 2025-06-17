namespace Autine.Application.Features.Profiles.Commands.ChangePassword;
public record ChangePasswordCommand(string UserId, ChangePasswordRequest ChangePasswordRequest) : ICommand;
