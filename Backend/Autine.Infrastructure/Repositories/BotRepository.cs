using Autine.Infrastructure.Persistence.DBCommands;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;

namespace Autine.Infrastructure.Repositories;
public class BotRepository(ApplicationDbContext context, ILogger<BotRepository> logger) : Repository<Bot>(context), IBotRepository
{
    private readonly ILogger<BotRepository> _logger;
    public async new Task<Guid> AddAsync(Bot entity, CancellationToken ct = default)
    {
        await _context.Bots.AddAsync(entity, ct);

        await _context.SaveChangesAsync(ct);

        return entity.Id;
    }
    // without stored procedure
    //public async Task DeleteBotAsync(Bot bot, CancellationToken ct = default)
    //{
    //    var botPatients = _context.BotPatients
    //        .Where(e => e.BotId == bot.Id)
    //        .Join(_context.BotMessages.Include(e => e.Message),
    //        bp => bp.Id,
    //        bm => bm.BotPatientId,
    //        (bp, bm) => new BotPatient
    //        {
    //            Id = bp.Id,
    //            BotId = bp.BotId,
    //            PatientId = bp.PatientId,
    //            BotMessages = new List<BotMessage> 
    //            {
    //                bm
    //            },
    //            CreatedBy = bp.CreatedBy,
    //            CreatedAt = bp.CreatedAt,
    //            IsDisabled = bp.IsDisabled
    //        });



    //    var botMessage = _context.BotMessages
    //        .Where(e => e.BotPatient.BotId == bot.Id)
    //        .Include(e => e.Message);

    //    foreach (var botPatient in botPatients)
    //    {
    //        if (botPatient.BotMessages != null)
    //        {
    //            _context.BotMessages.RemoveRange(botPatient.BotMessages);
    //            _context.Messages.RemoveRange(botPatient.BotMessages.Select(e => e.Message));
    //        }
    //    }

    //    _context.BotPatients.RemoveRange(botPatients);
    //    _context.Bots.Remove(bot);

    //    await _context.SaveChangesAsync(ct);
    //}
    public async Task<Result> DeleteBotAsync(Guid botId)
    {
        try
        {
            await _context.Database.ExecuteSqlRawAsync(
                $"EXEC {StoredProcedures.BotSPs.DeleteBotWithRelations} @BotId",
                new SqlParameter("@BotId", botId));

            return Result.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to delete Bot with ID {BotId}", botId);
            return Error.BadRequest("Failed to delete bot", ex.ToString());
        }
    }
}
