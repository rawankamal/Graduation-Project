namespace Autine.Infrastructure.Repositories;

public class MessageRepository(ApplicationDbContext context) : Repository<Message>(context), IMessageRepository
{
    public async new Task<Guid> AddAsync(Message entity, CancellationToken ct = default)
    {
        await _context.Messages.AddAsync(entity, ct);

        await _context.SaveChangesAsync(ct);

        return entity.Id;
    }
}
