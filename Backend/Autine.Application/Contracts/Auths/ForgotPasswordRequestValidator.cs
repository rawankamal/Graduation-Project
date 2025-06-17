namespace Autine.Application.Contracts.Auth;

public class ForgotPasswordRequestValidator : AbstractValidator<ForgotPasswordRequest>
{
    public ForgotPasswordRequestValidator()
    {
        RuleFor(e => e.Email)
            .NotEmpty()
            .EmailAddress();
    }
}
