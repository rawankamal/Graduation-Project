namespace Autine.Application.Contracts.UserBots;

public class UserMessageRequestValidator : AbstractValidator<UserMessageRequest>
{
    public UserMessageRequestValidator()
    {
        RuleFor(e => e.Content)
            .NotEmpty();
        
        RuleFor(e => e.ReceiverId)
            .NotEmpty();
    }
}
