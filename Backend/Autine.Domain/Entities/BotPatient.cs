namespace Autine.Domain.Entities;

public class BotPatient
{
    public Guid Id { get; set; } = Guid.CreateVersion7();
    public Guid BotId { get; set; }
    public string UserId { get; set; } = default!;
    public bool IsUser { get; set; } = false;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public Bot Bot { get; set; } = default!;
    public virtual ICollection<Message>? Messages { get; set; } = [];
}