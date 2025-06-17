namespace Autine.Domain.Entities;
public class User 
{
    public string Id { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Bio { get; set; } = string.Empty;
    public string ProfilePicture { get; set; } = string.Empty;
    public string Gender { get; set; } = string.Empty;
    public string? Country { get; set; } = string.Empty;
    public string? City { get; set; } = string.Empty;
    public DateTime DateOfBirth { get; set; }

    //public ICollection<Chat> UserChats { get; set; } = [];
    //public virtual ICollection<ChatThread>? OwnedThreads { get; set; } = new List<ChatThread>();
    //public virtual ChatThread? PatientThread { get; set; }
    //public virtual ICollection<ThreadMessage>? ThreadMessages { get; set; } = new List<ThreadMessage>();
    
}
