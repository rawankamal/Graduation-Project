namespace Autine.Application.Errors;

public class RoleErrors
{
    public static readonly Error RoleNotFound
        = Error.NotFound(nameof(RoleNotFound), "Role not found");
    public static readonly Error UserNotFound
        = Error.NotFound(nameof(UserNotFound), "User not found in this role");
}