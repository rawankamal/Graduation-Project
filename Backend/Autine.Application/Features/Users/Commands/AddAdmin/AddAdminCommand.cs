using Autine.Application.Contracts.Auths;
using Autine.Domain.Entities;
using Microsoft.Extensions.Logging;

namespace Autine.Application.Features.Users.Commands.AddAdmin;
public record AddAdminCommand(string AdminId, RegisterRequest Request) : ICommand<string>;

public class AddAdminCommandHandler(IUnitOfWork unitOfWork, IAuthService authService, IAIAuthService aIAuthService,ILogger<AddAdminCommandHandler>logger) : ICommandHandler<AddAdminCommand, string>
{
    public async Task<Result<string>> Handle(AddAdminCommand request, CancellationToken cancellationToken)
    {

        var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            var result = await authService.RegisterAdminAsync(request.Request, cancellationToken);

            if (result.IsFailure)
            {
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return result.Error;
            }

            var externalRegisterResult = await aIAuthService.AdminAddAdmin(
                request.AdminId,
                new(
                email: request.Request.Email,
                username: result.Value,
                password: Consts.FixedPassword,
                fname: request.Request.FirstName,
                lname: request.Request.LastName,
                dateofbirth: request.Request.DateOfBirth,
                gender: request.Request.Gender
            ), cancellationToken);

            if (!externalRegisterResult.IsSuccess)
            {
                logger.LogError("External AI admin registration failed. Username: {Username}, Error: {Error}", result.Value, externalRegisterResult.Error);
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return externalRegisterResult.Error;
            }

            logger.LogInformation("Successfully Add Admin To the system with email: {Email}  by Admin {admin}", request.Request.Email, request.AdminId);
          
            await unitOfWork.CommitTransactionAsync(transaction, cancellationToken);
            return Result.Success(result.Value);
        }
        catch(Exception ex) 
        {
            logger.LogError(ex, "Exception occurred while adding admin. Email: {Email}", request.Request.Email);
            await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
            return Error.BadRequest("Error", "An error occure while register user.");
        }

    }
}
