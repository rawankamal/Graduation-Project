namespace Autine.Domain.Entities;

public class ThreadMember : AuditableEntity
{
    public string MemberId { get; set; } = string.Empty;
    public Guid ThreadId { get; set; }
    public virtual Patient Thread { get; set; } = default!;
    public virtual ICollection<Message>? Messages { get; set; }
}