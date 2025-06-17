using System.ComponentModel.DataAnnotations;

namespace Autine.Infrastructure.Persistence;
public class ApiSettings
{
    public const string Section = "AIApiSettings";
    [Required]
    [Length(0, 100)]
    public string AIApi { get; set; } = string.Empty;
}
