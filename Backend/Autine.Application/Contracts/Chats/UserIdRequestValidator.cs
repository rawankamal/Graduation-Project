namespace Autine.Application.Contracts.Chats;

public class UserIdRequestValidator : AbstractValidator<UserIdRequest>
{
    public UserIdRequestValidator()
    {
        RuleFor(e => e.UserId)
            .NotEmpty()
            .Must(e => e != Guid.Empty.ToString())
            .WithMessage("{ProperityName} must be not empty");
    }
}
