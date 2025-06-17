using Autine.Application.Contracts.Auth;

namespace Autine.Application.Contracts.Auth;

public sealed class ConfirmEmailRequestValidator : AbstractValidator<ConfirmEmailRequest>
{
    public ConfirmEmailRequestValidator()
    {
        RuleFor(e => e.UserId)
            .NotEmpty();

        RuleFor(e => e.Code)
            .NotEmpty();

    }
}
