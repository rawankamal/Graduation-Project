using Autine.Application.IServices;
using Autine.Application.IServices.AIApi;
using Autine.Domain.Entities;
using Microsoft.Extensions.Logging;

namespace Autine.Application.Features.Auth.Commands.RegisterSupervisor;
public class RegisterSupervisorCommandHandler(
    IUnitOfWork unitOfWork,
    IAuthService authService, 
    IAIAuthService aIAuthService,
     ILogger<RegisterSupervisorCommandHandler> logger) : ICommandHandler<RegisterSupervisorCommand, RegisterResponse>
{
    public async Task<Result<RegisterResponse>> Handle(RegisterSupervisorCommand request, CancellationToken cancellationToken)
    {
        var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            var authResult = await authService.RegisterSupervisorAsync(request.Request, cancellationToken);

            if (authResult.IsFailure)
            {
               // logger.LogWarning("Supervisor registration failed at AuthService: {Error}", authResult.Error);
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return authResult.Error;
            }

            var aiResult = await aIAuthService.SupervisorAsync(new(
                email: request.Request.Email,
                username: authResult.Value.UserId,
                password: Consts.FixedPassword,
                fname: request.Request.FirstName,
                lname: request.Request.LastName,
                dateofbirth: request.Request.DateOfBirth,
                gender: request.Request.Gender
                ), cancellationToken);

            if (aiResult.IsFailure)
            {
                logger.LogWarning("Supervisor registration failed at AIAuthService: {Error}", aiResult.Error);
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return aiResult.Error;
            }

            logger.LogInformation("Supervisor registered successfully With Id: {UserId}", authResult.Value.UserId);
            var response = new RegisterResponse(authResult.Value.Code, authResult.Value.UserId);
            await unitOfWork.CommitTransactionAsync(transaction, cancellationToken);
            return response;
        }
        catch(Exception ex) 
        {
            // TODO: log error
            logger.LogError(ex, "An unexpected error occurred while registering a supervisor for Email: {Email}", request.Request.Email);
            await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
            return Error.InternalServerError("Error", "An error occure while register user.");
        }
    }
}