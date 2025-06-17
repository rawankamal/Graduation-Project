using Microsoft.Extensions.Logging;

namespace Autine.Application.Features.Patients.Commads.Remove;
public class RemovePatientCommandHandler(
    IUnitOfWork unitOfWork,
    IUserService userService,
    IAIAuthService aIAuthService,
    ILogger<RemovePatientCommandHandler> logger) : ICommandHandler<RemovePatientCommand>
{
    public async Task<Result> Handle(RemovePatientCommand request, CancellationToken cancellationToken)
    {
        if (await unitOfWork.Patients.GetAsync(e => e.PatientId == request.Id && e.CreatedBy == request.UserId && e.IsSupervised, ct: cancellationToken) is not { } patient)
            return PatientErrors.PatientsNotFound;

        var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken);

        try
        {
            logger.LogInformation("Removing patient: {PatientId} by User: {UserId}", request.Id, request.UserId);
            var deleteResult = await userService.DeleteUserAsync(patient.PatientId, cancellationToken, transaction);
            if (deleteResult.IsFailure)
            {
                logger.LogWarning("Failed to delete user for patient {PatientId}. Reason: {Reason}", patient.PatientId, deleteResult.Error.Description);
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return deleteResult;
            }

            var aiResult = await aIAuthService.RemovePatientAsync(request.UserId, request.Id, cancellationToken);
            if (aiResult.IsFailure)
            {
                logger.LogWarning("Failed to remove patient from AI system: {PatientId}. Reason: {Reason}", request.Id, aiResult.Error.Description);
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return aiResult;
            }

            logger.LogInformation("Patient {PatientId} removed successfully by {UserId}", request.Id, request.UserId);
            await unitOfWork.CommitTransactionAsync(transaction, cancellationToken);
            return Result.Success();
        }
        catch(Exception ex) 
        {
            // TODO: log error
            logger.LogError(ex, "Error occurred while removing patient {PatientId}", request.Id);
            await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
            return Error.BadRequest("Error", "An error occurred while removing the patient.");
        }
    }
}
