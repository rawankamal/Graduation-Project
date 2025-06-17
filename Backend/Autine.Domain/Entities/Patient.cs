namespace Autine.Domain.Entities;

public class Patient  : AuditableEntity
{
    public string PatientId { get; set; } = string.Empty;
    public int Age { get; set; }
    public string Diagnosis { get; set; } = string.Empty;
    public DateTime LastSession { get; set; } = DateTime.UtcNow;
    public DateTime NextSession { get; set; } = DateTime.UtcNow;
    public string Status {  get; set; } = string.Empty;
    public string? Notes { get; set; } = string.Empty;
    public string SessionFrequency { get; set; } = string.Empty;
    public bool IsSupervised { get; set; } = true;
    public string ThreadTitle { get; set; } = string.Empty;
    public ICollection<ThreadMember> Members { get; set; } = [];
}