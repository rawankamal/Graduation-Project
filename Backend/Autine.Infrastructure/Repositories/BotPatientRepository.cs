using Autine.Infrastructure.Persistence.DBCommands;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;

namespace Autine.Infrastructure.Repositories;
public class BotPatientRepository(ApplicationDbContext context, ILogger<BotPatientRepository> logger) : Repository<BotPatient>(context), IBotPatientRepository
{
   // private readonly ILogger<BotPatientRepository> _logger;
    public async Task<IEnumerable<Message>> GetMessagesAsync(Guid botPatientId, CancellationToken ct = default)
        => await _context.Messages
            .Where(e => e.BotPatientId == botPatientId)
            .OrderBy(e => e.CreatedDate)
            .ToListAsync(ct);


    public async Task<Result> DeleteBotPatientAsync(Guid id, CancellationToken ct = default)
    {
        try
        {
            await _context.Database.ExecuteSqlRawAsync(
                $"{StoredProcedures.BotPatientSPs.DeleteBotPatientWithRelationsCall}",
                [new SqlParameter("@BotPatientId", id)],
                ct);
            return Result.Success();
        }
        catch(Exception ex) 
        {
            // TODO:log error
            logger.LogError(ex, "Failed to delete BotPatient with ID {Id}", id);
            return Error.BadRequest("Exception", "error occure while delete bot");
        }
    }
}