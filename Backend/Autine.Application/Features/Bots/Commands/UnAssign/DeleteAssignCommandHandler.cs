namespace Autine.Application.Features.Bots.Commands.UnAssign;
public class DeleteAssignCommandHandler(
    IUnitOfWork unitOfWork,
    IAIModelService aIModelService) : ICommandHandler<DeleteAssignCommand>
{
    public async Task<Result> Handle(DeleteAssignCommand request, CancellationToken cancellationToken)
    {
        if (await unitOfWork.Bots.GetAsync(e => e.Id == request.BotId && e.CreatedBy == request.UserId, ct: cancellationToken) is not { } bot)
            return BotErrors.BotNotFound;

        if (await unitOfWork.Patients.GetAsync(e => e.PatientId == request.PatientId && e.CreatedBy == request.UserId, ct: cancellationToken) is not { } patient)
            return PatientErrors.PatientsNotFound;

        if (await unitOfWork.BotPatients.GetAsync(e => !e.IsUser && e.BotId == request.BotId && e.UserId == request.PatientId, ct: cancellationToken) is not { } botPatient)
            return BotPatientError.PatientNotFound;

        using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            var result = await unitOfWork.BotPatients.DeleteBotPatientAsync(botPatient.Id, cancellationToken);
            if (result.IsFailure)
                return result;

            var aiResult = await aIModelService.DeleteAssignAsync(
                request.UserId,
                patient.PatientId,
                bot.Name,
                cancellationToken
                );

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
            return Error.BadRequest("Error", "An error occurred while removing the patient.");
        }

    }
}