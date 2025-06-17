namespace Autine.Application.Contracts.Auth;

public sealed class ResendConfirmEmailRequestValidator : AbstractValidator<ResendConfirmEmailRequest>
{
    public ResendConfirmEmailRequestValidator()
    {
        RuleFor(e => e.Email)
            .NotEmpty().WithMessage("Email is requird")
            .EmailAddress().WithMessage("Invalid email formate");

    }
}
