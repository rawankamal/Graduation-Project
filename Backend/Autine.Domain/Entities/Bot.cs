namespace Autine.Domain.Entities;

public class Bot : AuditableEntity
{
    public string Name { get; set; } = string.Empty;
    public string Context { get; set; } = string.Empty;
    public string Bio { get; set; } = string.Empty;
    public bool IsPublic { get; set; } = false;
    public string? BotImage {  get; set; }
    public virtual ICollection<BotPatient>? BotPatients { get; set; } = [];
}
