using Autine.Application.Contracts.Bots;

namespace Autine.Infrastructure.Services;

public class BotService(ApplicationDbContext context) : IBotService
{
    public async Task<IEnumerable<PatientBotsResponse>> GetPatientBotsAsync(string userId, CancellationToken ct = default)
    {
        var query = await (
        from b in context.Bots
            join bp in context.BotPatients
            on b.Id equals bp.BotId
            where bp.UserId == userId
            select new PatientBotsResponse(
                b.Id,
                b.Name,
                b.BotImage!,
                bp.CreatedAt
                )
            ).ToListAsync(ct);

        return query;
    }
}