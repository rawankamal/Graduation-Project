using Autine.Application.Contracts.Auths;
using Autine.Application.IServices;
using Autine.Application.IServices.AIApi;
using Microsoft.AspNetCore.Server.HttpSys;
using Microsoft.Extensions.Logging;

namespace Autine.Application.Features.Patients.Commads.Add;
public class AddPatientCommandHandler(
    IUnitOfWork unitOfWork, 
    IAuthService authService, 
    IAIAuthService aIAuthService,
    ILogger<AddPatientCommandHandler> logger) : ICommandHandler<AddPatientCommand, string>
{
    public async Task<Result<string>> Handle(AddPatientCommand request, CancellationToken ct)
    {
        var transaction = await unitOfWork.BeginTransactionAsync(ct);
        try
        {
          //  logger.LogInformation("Registering new patient: {Email}", request.Request.Email);
           
            var registerRequest = new RegisterRequest(
                request.Request.FirstName,
                request.Request.LastName,
                request.Request.Email,
                request.Request.UserName,
                request.Request.Password,
                request.Request.Gender,
                request.Request.DateOfBirth,
                request.Request.Country,
                request.Request.City,
                request.Request.Bio
                );
            var authResult = await authService.RegisterPatient(registerRequest, ct);

            if (authResult.IsFailure)
            {
             //   logger.LogWarning("Failed to register patient: {Email}. Reason: {Reason}", request.Request.Email, authResult.Error.Description);
                await unitOfWork.RollbackTransactionAsync(transaction, ct);
                return authResult.Error;
            }
            string userPatientId = authResult.Value;

            var age = (DateTime.Today - request.Request.DateOfBirth).Days;
            var patient = new Patient()
            {
                IsSupervised = true,
                PatientId = authResult.Value,
                Diagnosis = request.Request.Diagnosis,
                Status = request.Request.Status,
                Notes = request.Request.Notes,
                NextSession = request.Request.NextSession,
                LastSession = request.Request.LastSession,
                Age = age / 365,
                ThreadTitle = $"{request.Request.FirstName} {request.Request.LastName}"
            };
            await unitOfWork.Patients.AddAsync(patient, ct);

            await unitOfWork.ThreadMembers.AddAsync(
                new()
                {
                    ThreadId = patient.Id,
                    MemberId = request.UserId
                }, ct);

            var aIResult = await aIAuthService.AddPatientAsync(
                request.UserId, new(
                    request.Request.Email,
                    userPatientId,
                    Consts.FixedPassword,
                    request.Request.FirstName,
                    request.Request.LastName,
                    request.Request.DateOfBirth,
                    request.Request.Gender
                    ), ct);

            if (aIResult.IsFailure)
            {
                logger.LogWarning("Failed to sync patient with AI system: {PatientId}. Reason: {Reason}", userPatientId, aIResult.Error.Description);
                await unitOfWork.RollbackTransactionAsync(transaction, ct);
                return aIResult.Error;
            }
            logger.LogInformation("Patient added successfully. PatientId: {PatientId}", userPatientId);
            await unitOfWork.CommitTransactionAsync(transaction, ct);
            return Result.Success(authResult.Value);
        }
        catch(Exception ex) 
        {
            // TODO: log error
            logger.LogError(ex, "Unexpected error while adding patient: {Email}", request.Request.Email);
            await unitOfWork.RollbackTransactionAsync(transaction, ct);
            return Error.BadRequest("Error", "Error while adding patient");
        }
    }
}