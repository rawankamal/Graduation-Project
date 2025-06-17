using System.Security.Claims;

namespace Autine.Api.Abstractions;

public static class Extentions
{
    public static string? GetUserId(this ClaimsPrincipal user)
        => user.FindFirstValue(ClaimTypes.NameIdentifier)! ?? string.Empty;   
}