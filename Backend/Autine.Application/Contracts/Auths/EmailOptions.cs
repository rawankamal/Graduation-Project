namespace Autine.Application.Contracts.Auth;
public class EmailOptions
{
    public static readonly string SectionName = "EmailSettings";
    public string Host { get; set; } = string.Empty;
    public int Port { get; set; } = 0;
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}
