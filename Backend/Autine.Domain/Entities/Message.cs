using System.ComponentModel.DataAnnotations.Schema;

namespace Autine.Domain.Entities;

public class Message
{
    public Guid Id { get; set; } = Guid.CreateVersion7();
    public MessageStatus Status { get; set; } = MessageStatus.Sent;
    public string Content { get; set; } = string.Empty;
    public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    public bool IsRead { get; set; } = false;
    public DateTime? ReadAt { get; set; }
    public string? SenderId { get; set; }


    public Guid? ChatId { get; set; }
    public Guid? BotPatientId { get; set; }
    public Guid? ThreadMemberId { get; set; }
    public Chat? Chat { get; set; }
    public BotPatient? BotPatient { get; set; }
    public ThreadMember? ThreadMember { get; set; }

    [NotMapped]
    public MessageType MessageType =>
        ThreadMemberId.HasValue ? MessageType.Thread :
        BotPatientId.HasValue ? MessageType.Bot :
        MessageType.DM;
}
public enum MessageType
{
    DM,
    Bot,
    Thread
}