namespace Autine.Infrastructure.Identity.Entities;
public class ApplicationUser : IdentityUser
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Bio { get; set; } = string.Empty;
    public string ProfilePicture { get; set; } = string.Empty;
    public string Gender { get; set; } = string.Empty;
    public string? Country { get; set; } = string.Empty;
    public string? City { get; set; } = string.Empty;
    public DateTime DateOfBirth { get; set; }

    public ICollection<RefreshToken> RefreshTokens { get; set; } = [];
    public ICollection<Patient> Patients { get; set; } = [];
    public ICollection<Patient> Supervisors { get; set; } = [];
    public ICollection<BotPatient>? BotUsers { get; set; } = [];
    public ICollection<Bot> Bots { get; set; } = [];
    public virtual ICollection<ThreadMember>? ThreadMember { get; set; }
    public ICollection<Message>? Messages { get; set; }
}
