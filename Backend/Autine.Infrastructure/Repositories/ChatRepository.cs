namespace Autine.Infrastructure.Repositories;

public class ChatRepository(ApplicationDbContext context) : Repository<Chat>(context), IChatRepository
{
    public async Task<Result> GetMyConnections(string userId, CancellationToken ct = default)
    {
        var connections = await _context.Chats
            .Where(e => e.CreatedBy == userId || e.UserId == userId)
            .ToListAsync(ct);

        return Result.Success();
    }
}