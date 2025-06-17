namespace Autine.Application.Contracts.Validation;

public class ValidationConstants
{
    public const int MinLength = 3;
    public const int MaxLength = 100;
    public const int MinUsernameLength = 3;
    public const string UsernamePattern = @"^[a-zA-Z0-9._!@#$]+$";
    public const string LengthErrorMesssage = "{PropertyName} must be between {MinLength} and {MaxLength} characters.";
    public const string RequiredErrorMessage = "{PropertyName} is required.";
}
