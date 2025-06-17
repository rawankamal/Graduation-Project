namespace Autine.Application.Contracts.Profiles;

public class UpdateProfileRequestValidator : AbstractValidator<UpdateUserProfileRequest>
{
    public UpdateProfileRequestValidator()
    {
        RuleFor(e => e.FirstName)
            .NotEmpty()
            .Length(1, 100);

        RuleFor(e => e.LastName)
            .NotEmpty()
            .Length(1, 100);

        RuleFor(e => e.City)
            .NotEmpty()
            .Length(1, 100);

        RuleFor(e => e.Country)
            .NotEmpty()
            .Length(1, 100);

        RuleFor(e => e.Bio)
            .NotEmpty()
            .Length(1, 2500);

        //RuleFor(e => e.Gender)
        //    .NotEmpty().WithMessage(ValidationConstants.RequiredErrorMessage)
        //    .Must(g =>
        //    {
        //        if (g == null) return false;
        //        var gender = g.ToLower();

        //        return gender == "male" || g == "female";
        //    })
        //    .WithMessage("{PropertyName} must be Male, Female.");

        RuleFor(e => e.DateOfBirth)
            .NotEmpty().WithMessage(ValidationConstants.RequiredErrorMessage)
            .LessThan(DateTime.Today).WithMessage("{PropertyName} must be a past date.");
    }
}