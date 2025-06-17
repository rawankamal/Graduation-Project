using Autine.Application.IServices;
using Autine.Application.IServices.AIApi;

namespace Autine.Application.Features.Bots.Commands.Remove;
public class RemoveBotCommandHandler(
    IUnitOfWork unitOfWork,
    IRoleService roleService,
    IFileService fileService,
    IAIModelService aIModelService) : ICommandHandler<RemoveBotCommand>
{
    public async Task<Result> Handle(RemoveBotCommand request, CancellationToken cancellationToken)
    {
        var bot = await unitOfWork.Bots
            .GetAsync(e =>
            e.Id == request.BotId &&
            e.CreatedBy == request.UserId,
            ct: cancellationToken);

        if (bot is null)
            return BotErrors.BotNotFound;

        using var beginTransaction = await unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            var botImage = bot.BotImage;

            await unitOfWork.Bots.DeleteBotAsync(bot.Id);

            var isAdmin = await roleService.UserIsAdminAsync(request.UserId);
            
            var aiResult = await aIModelService.RemoveModelAsync(
                request.UserId,
                bot.Name,
                isAdmin.IsSuccess,
                cancellationToken);

            if (aiResult.IsFailure)
            {
                await unitOfWork.RollbackTransactionAsync(beginTransaction, cancellationToken);
                return aiResult;
            }

            await fileService.DeleteImageAsync(botImage!, true);

            await unitOfWork.CommitTransactionAsync(beginTransaction, cancellationToken);
            return Result.Success();
        }
        catch
        {
            await unitOfWork.RollbackTransactionAsync(beginTransaction, cancellationToken);
            return Error.BadRequest("Error", "an error occure");
        }
    }
}
