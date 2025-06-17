namespace Autine.Domain.Entities;

public class Chat
{
    public Guid Id { get; set; } = Guid.CreateVersion7();
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public string CreatedBy { get; set; } = string.Empty;
    public string UserId { get; set; } = string.Empty;
    public ICollection<Message> Messages { get; set; } = [];
}
