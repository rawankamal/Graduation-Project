using Autine.Application.IServices;

namespace Autine.Application.Features.Bots.Commands.UpdateBotImage;

public class UpdateBotImageCommandHandler(
    IFileService fileService, 
    IUnitOfWork unitOfWork) : ICommandHandler<UpdateBotImageCommand>
{
    public async Task<Result> Handle(UpdateBotImageCommand request, CancellationToken cancellationToken)
    {
        var bot = await unitOfWork.Bots.FindByIdAsync(cancellationToken, [request.BotId]);
        
        if (bot is null)
            return BotErrors.BotNotFound;

        try
        {
            
            var result = await fileService.UpdateImageAsync(bot.BotImage!, request.Image, true, cancellationToken);
                
            if (result.IsFailure)
                return result.Error;

            await unitOfWork.Bots
                .ExcuteUpdateAsync(
                e => e.Id == request.BotId, 
                setter => setter.SetProperty(e => e.BotImage, result.Value),
                cancellationToken);
            
            return Result.Success();
        }
        catch
        {
            // TODO: log error
            return Error.BadRequest("Error.UpdateBotImage", "error while updating bot image.");
        } 
    }
}
