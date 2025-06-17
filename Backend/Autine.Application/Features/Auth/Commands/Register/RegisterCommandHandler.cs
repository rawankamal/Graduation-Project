using Autine.Domain.Entities;
using Microsoft.Extensions.Logging;

namespace Autine.Application.Features.Auth.Commands.Register;
public class RegisterCommandHandler(
    IAuthService _authService,
    IAIAuthService _aIAuthService,
    IUnitOfWork unitOfWork,
    ILogger<RegisterCommandHandler> logger) : ICommandHandler<RegisterCommand, RegisterResponse>
{
    public async Task<Result<RegisterResponse>> Handle(RegisterCommand request, CancellationToken cancellationToken)
    { 

        var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            var result = await _authService.RegisterAsync(request.Request, cancellationToken);
        
            if (!result.IsSuccess)
            {
               // logger.LogWarning("User registration failed at AuthService: {Error}", result.Error);
                return result.Error;
            }


            var externalRegisterResult = await _aIAuthService.RegisterAsync(new(
                request.Request.Email,
                result.Value.UserId,
                Consts.FixedPassword,
                request.Request.FirstName,
                request.Request.LastName,
                request.Request.DateOfBirth,
                request.Request.Gender
            ), cancellationToken);

            if (!externalRegisterResult.IsSuccess)
            {
               // logger.LogWarning("User registration failed at AIAuthService: {Error}", externalRegisterResult.Error);
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return externalRegisterResult.Error; 
            }
            logger.LogInformation("User registered: {UserId}", result.Value.UserId);
            var response = new RegisterResponse(result.Value.Code, result.Value.UserId);
            await unitOfWork.CommitTransactionAsync(transaction, cancellationToken);
            return Result.Success(response);
        }
        catch(Exception ex) 
        {
            logger.LogError(ex, "An unexpected error occurred while registering user with email: {Email}", request.Request.Email);
            await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
            return Error.InternalServerError("Error", "An error occure while register user.");
        }
    }
}
