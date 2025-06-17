using Autine.Application.Contracts.Bots;
using Autine.Application.Contracts.Patients;
using Microsoft.Extensions.Logging;

namespace Autine.Infrastructure.Services;

public class PatientService(
    ApplicationDbContext context,
    IUrlGenratorService urlGenratorService,
    ILogger<PatientService> logger) : IPatientService
{

    public async Task<IEnumerable<PatientResponse>> GetPatientsAsync(string userId, bool isFollowing = false, CancellationToken ct = default)
    {
     //   logger.LogInformation("GetPatientsAsync called for userId: {UserId}, isFollowing: {IsFollowing}", userId, isFollowing);

        try
        {
            var query = await (
                from tm in context.ThreadMembers
                join t in context.Patients
                on tm.ThreadId equals t.Id
                join u in context.Users
                on t.PatientId equals u.Id
                where
                (isFollowing && tm.MemberId == userId && t.CreatedBy != userId)
                ||
                (!isFollowing && tm.MemberId == userId && tm.CreatedBy == userId)
                select new PatientResponse(
                u.Id,
                u.FirstName,
                u.LastName,
                u.UserName!,
                u.Bio!,
                u.DateOfBirth,
                u.Gender,
                u.Country!,
                u.City!,
                t.CreatedAt,
                urlGenratorService.GetImageUrl(u.ProfilePicture, true)!,
                 t.Age,
                t.Diagnosis,
                t.LastSession,
                t.NextSession,
                t.Status,
                t.Notes!,
                t.SessionFrequency
            )).ToListAsync(cancellationToken: ct);

        //    logger.LogInformation("Retrieved {Count} patients for userId {UserId}", query.Count, userId);
            return query ?? [];
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error occurred in GetPatientsAsync for userId {UserId}", userId);
            throw;
        }
        //if (query is null)
        //    return [];

        //return query;
    }
    public async Task<PatientResponse?> GetPatientByIdAsync(string userId, string id, CancellationToken ct = default)
    {
       // logger.LogInformation("GetPatientByIdAsync called with userId: {UserId}, patientId: {PatientId}", userId, id);

        try
        {
            var patient = await (
            from t in context.Patients
            join u in context.Users
            on t.PatientId equals u.Id
            join tm in context.ThreadMembers
            on t.Id equals tm.ThreadId
            where t.PatientId == id && (tm.MemberId == userId)
            select new PatientResponse(
                    u.Id,
                    u.FirstName,
                    u.LastName,
                    u.UserName!,
                    u.Bio!,
                    u.DateOfBirth,
                    u.Gender,
                    u.Country!,
                    u.City!,
                    t.CreatedAt,
                    urlGenratorService.GetImageUrl(u.ProfilePicture, false)!,
                    t.Age,
                    t.Diagnosis,
                    t.LastSession,
                    t.NextSession,
                    t.Status,
                    t.Notes!,
                    t.SessionFrequency
            ))
            .SingleOrDefaultAsync(ct);
         if (patient == null)
         {
           logger.LogWarning("Patient not found with id: {PatientId} for userId: {UserId}", id, userId);
         }

            return patient;
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error occurred in GetPatientByIdAsync for patientId {PatientId}", id);
            throw;
        }
    }
    public async Task<IEnumerable<BotPatientsResponse>> GetBotPatientAsync(Guid botId, CancellationToken ct = default)
    { 
        try
        {
            var patients = await (
            from p in context.Patients
            join u in context.Users
            on p.PatientId equals u.Id
            join bp in context.BotPatients
            on p.PatientId equals bp.UserId
            where bp.BotId == botId
            select new BotPatientsResponse(
                u.Id,
                $"{u.FirstName} {u.LastName}",
                bp.CreatedAt,
                urlGenratorService.GetImageUrl(u.ProfilePicture, false)!
                )
            ).ToListAsync(ct);

            return patients;
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error getting patients for bot {BotId}", botId);
            throw;
        }
    }
}
