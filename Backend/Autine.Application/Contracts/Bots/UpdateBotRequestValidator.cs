namespace Autine.Application.Contracts.Bots;

public class UpdateBotRequestValidator : AbstractValidator<UpdateBotRequest>
{
    public UpdateBotRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .WithMessage("{ProperityName} is required.")
            .MaximumLength(100)
            .WithMessage("{ProperityName} must be at most {MaxLength} characters long.");
        RuleFor(x => x.Context)
            .NotEmpty();

        RuleFor(x => x.Bio)
            .NotEmpty();
    }
}