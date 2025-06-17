using Microsoft.AspNetCore.Http;
namespace Autine.Domain.Abstractions;

public record Error(string Code, string Description, int? StatusCode)
{
    public readonly static Error Non = new(string.Empty, string.Empty, null);
    
    public static implicit operator Result(Error error)
        => new(false, error);

    public static Error NotFound(string code, string description)
        => new(code, description, StatusCodes.Status404NotFound);

    public static Error BadRequest(string code, string description)
        => new(code, description, StatusCodes.Status400BadRequest);

    public static Error Unauthorized(string code, string description)
        => new(code, description, StatusCodes.Status401Unauthorized);

    public static Error Forbidden(string code, string description)
        => new(code, description, StatusCodes.Status403Forbidden);

    public static Error InternalServerError(string code, string description)
        => new(code, description, StatusCodes.Status500InternalServerError);

    public static Error Conflict(string code, string description)
        => new(code, description, StatusCodes.Status409Conflict);
}
