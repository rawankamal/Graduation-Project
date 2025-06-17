using Autine.Application.IServices;
using Autine.Application.IServices.AIApi;

namespace Autine.Application.Features.Bots.Commands.Update;
public class UpdateBotCommandHandler(
    IRoleService roleService,
    IAIModelService aIModelService,
    IUnitOfWork unitOfWork) : ICommandHandler<UpdateBotCommand>
{
    public async Task<Result> Handle(UpdateBotCommand request, CancellationToken cancellationToken)
    {
        var bot = await unitOfWork.Bots
            .GetAsync(
            e => e.Id == request.BotId &&
            e.CreatedBy == request.UserId,
            ct: cancellationToken);

        if (bot is null)
            return BotErrors.BotNotFound;

        var checkBotNameValid = bot.Name != request.UpdateRequest.Name &&
            await unitOfWork.Bots.CheckExistAsync(e => request.UpdateRequest.Name == e.Name, cancellationToken);

        if (checkBotNameValid)
            return BotErrors.DuplicatedBot;

        using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {

            await unitOfWork.Bots.ExcuteUpdateAsync(
                b => b.Id == request.BotId,
                b => b.SetProperty(e => e.Name, request.UpdateRequest.Name)
                    .SetProperty(e => e.Context, request.UpdateRequest.Context)
                    .SetProperty(e => e.Bio, request.UpdateRequest.Bio),
                ct: cancellationToken);

            var isAdmin = await roleService.UserIsAdminAsync(request.UserId);

            var aiResult = await aIModelService.UpdateModelAsync(
                request.UserId,
                bot.Name,
                new(request.UpdateRequest.Name, request.UpdateRequest.Context, request.UpdateRequest.Bio),
                isAdmin.IsSuccess,
                cancellationToken);

            if (aiResult.IsFailure)
            {
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return aiResult;
            }

            await unitOfWork.CommitTransactionAsync(transaction, cancellationToken);
            return Result.Success();
        }
        catch
        {
            // TODO: log error
            await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
            return Error.BadRequest("Error", "an error occure");
        }
        
    }
}
