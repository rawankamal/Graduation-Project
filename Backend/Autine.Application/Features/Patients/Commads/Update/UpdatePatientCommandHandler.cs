using Autine.Application.Contracts.Profiles;
using Autine.Application.ExternalContracts.Auth;
using Autine.Application.IServices;
using Autine.Application.IServices.AIApi;
using Microsoft.Extensions.Logging;
using System.Net.NetworkInformation;

namespace Autine.Application.Features.Patients.Commads.Update;

//string FirstName,
//string LastName,
//string Bio,
//string Gender,
//DateTime DateOfBirth,
//string? Country,
//string? City,

public class UpdatePatientCommandHandler(
    IAccountService accountService,
    IAIAuthService aIAuthService,
    IUnitOfWork unitOfWork,
    ILogger<UpdatePatientCommandHandler> logger) : ICommandHandler<UpdatePatientCommand>
{
    public async Task<Result> Handle(UpdatePatientCommand request, CancellationToken cancellationToken)
    {
        if (await unitOfWork.Patients
            .GetAsync(
            e => e.PatientId == request.PatientId && 
            e.IsSupervised && 
            e.CreatedBy == request.UserId, ct:cancellationToken) is not { } patient)
            return PatientErrors.PatientsNotFound;

        var updateProfileRequest = new UpdateUserProfileRequest(
            request.UpdateRequest.FirstName,
            request.UpdateRequest.LastName,
            request.UpdateRequest.Bio,
            request.UpdateRequest.Country,
            request.UpdateRequest.City,
            request.UpdateRequest.Gender,
            request.UpdateRequest.DateOfBirth
            );

        var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
           // logger.LogInformation("Updating patient: {PatientId} by User: {UserId}", request.PatientId, request.UserId);

            var userUpdateResult = await accountService.UpdateProfileAsync(patient.PatientId, updateProfileRequest, cancellationToken);
            
            if (userUpdateResult.IsFailure)
            {
                logger.LogWarning("Failed to update user profile for patient {PatientId}. Reason: {Reason}", request.PatientId, userUpdateResult.Error.Description);
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return userUpdateResult;
            }

            await unitOfWork.Patients.ExcuteUpdateAsync(
                e => e.Id == patient.Id,
                setters =>
                setters.SetProperty(e => e.NextSession, request.UpdateRequest.NextSession)
                .SetProperty(e => e.LastSession, request.UpdateRequest.LastSession)
                .SetProperty(e => e.Diagnosis, request.UpdateRequest.Diagnosis)
                .SetProperty(e => e.Status, request.UpdateRequest.Status)
                .SetProperty(e => e.Notes, request.UpdateRequest.Notes)
                .SetProperty(e => e.SessionFrequency, request.UpdateRequest.SessionFrequency),
                cancellationToken
                );
            var aiUpdateRequest = new AIUpdateRequest(
                fname: userUpdateResult.Value.fname,
                lname: userUpdateResult.Value.lname,
                gender: userUpdateResult.Value.gender
                );

            var aiResult = await aIAuthService.UpdateUserAsync(
                        "user",
                            request.PatientId,
                            aiUpdateRequest,
                            Consts.FixedPassword,
                            cancellationToken
                            );

            if (aiResult.IsFailure)
            {
                logger.LogWarning("Failed to sync updated patient {PatientId} with AI system. Reason: {Reason}", request.PatientId, aiResult.Error.Description);
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return aiResult.Error;
            }

            logger.LogInformation("Patient {PatientId} updated successfully by {UserId}", request.PatientId, request.UserId);
            await unitOfWork.CommitTransactionAsync(transaction, cancellationToken);
            return Result.Success();
        }
        catch(Exception ex) 
        {
            // TODO: log error
            logger.LogError(ex, "Error occurred while updating patient {PatientId}", request.PatientId);
            await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
            return Error.BadRequest("Error.UpdatePatientRequest", "error occure while update patient");
        }
    }
}
