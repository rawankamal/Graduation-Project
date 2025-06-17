using Autine.Application.Contracts.Auths;

namespace Autine.Application.Features.Auth.Commands.Register;
public record RegisterCommand(RegisterRequest Request) : ICommand<RegisterResponse>;
