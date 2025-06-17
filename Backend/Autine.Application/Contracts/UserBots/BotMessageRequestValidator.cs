namespace Autine.Application.Contracts.UserBots;
public class BotMessageRequestValidator : AbstractValidator<BotMessageRequest>
{
    public BotMessageRequestValidator()
    {
        RuleFor(e => e.Content)
            .NotEmpty();
    }
}
