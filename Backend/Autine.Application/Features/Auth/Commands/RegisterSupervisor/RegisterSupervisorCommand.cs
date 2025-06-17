using Autine.Application.Contracts.Auths;

namespace Autine.Application.Features.Auth.Commands.RegisterSupervisor;
public record RegisterSupervisorCommand(CreateSupervisorRequest Request) : ICommand<RegisterResponse>;
