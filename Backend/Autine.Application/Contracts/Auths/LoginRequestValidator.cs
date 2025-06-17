using Autine.Application.Contracts.Auths;

namespace Autine.Application.Contracts.Auth;

public class LoginRequestValidator : AbstractValidator<TokenRequest>
{
    public LoginRequestValidator()
    {
        RuleFor(e => e.Email)
            .NotEmpty()
            .EmailAddress();

        RuleFor(e => e.Password)
            .NotEmpty();
            //.Matches(@"^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$");
    }
}
