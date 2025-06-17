using Autine.Application.IServices.AIApi;

namespace Autine.Application.Features.Bots.Commands.Assign;
public class AssignModelCommandHandler(
    IUnitOfWork unitOfWork,
    IAIModelService aIModelService) : ICommandHandler<AssignModelCommand>
{
    public async Task<Result> Handle(AssignModelCommand request, CancellationToken cancellationToken)
    {
        if (await unitOfWork.Bots.FindByIdAsync(cancellationToken, [request.BotId]) is not { } bot)
            return BotErrors.BotNotFound;

        if (bot.CreatedBy != request.UserId)
            return BotErrors.BotNotFound;

        if(await unitOfWork.Patients.GetAsync(e => e.PatientId == request.PatientId, ct: cancellationToken) is not { } patient)
            return PatientErrors.PatientsNotFound;

        using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {

            await unitOfWork.BotPatients.AddAsync(new()
            {
                BotId = request.BotId,
                UserId = request.PatientId,
                IsUser = false
            }, cancellationToken);

            var result = await aIModelService.AssignModelAsync(request.UserId, bot.Name, patient.PatientId, cancellationToken);

            if (result.IsFailure)
            {
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return result.Error;
            }
            await unitOfWork.CommitTransactionAsync(transaction, cancellationToken);
            return Result.Success();
        }
        catch
        {
            // TODO: log error
            await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
            return Error.BadRequest("Error", "An error occurred while assigning the model.");
        }
    }
}
