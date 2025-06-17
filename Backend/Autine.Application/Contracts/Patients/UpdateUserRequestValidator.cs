namespace Autine.Application.Contracts.Patients;

public sealed class UpdateUserRequestValidator : AbstractValidator<UpdateUserRequest>
{
    public UpdateUserRequestValidator()
    {
        RuleFor(e => e.FirstName)
           .NotEmpty().WithMessage(ValidationConstants.RequiredErrorMessage)
           .Length(ValidationConstants.MinLength, ValidationConstants.MaxLength).WithMessage(ValidationConstants.LengthErrorMesssage);

        RuleFor(e => e.LastName)
            .NotEmpty().WithMessage(ValidationConstants.RequiredErrorMessage)
            .Length(ValidationConstants.MinLength, ValidationConstants.MaxLength).WithMessage(ValidationConstants.LengthErrorMesssage);

        RuleFor(e => e.City)
            .NotEmpty().WithMessage(ValidationConstants.RequiredErrorMessage)
            .Length(ValidationConstants.MinLength, ValidationConstants.MaxLength).WithMessage(ValidationConstants.LengthErrorMesssage);

        RuleFor(e => e.Country)
            .NotEmpty().WithMessage(ValidationConstants.RequiredErrorMessage)
            .Length(ValidationConstants.MinLength, ValidationConstants.MaxLength).WithMessage(ValidationConstants.LengthErrorMesssage);

        RuleFor(e => e.Bio)
            .NotEmpty().WithMessage("Bio is required.")
            .Length(1, 2500).WithMessage(ValidationConstants.LengthErrorMesssage);

        RuleFor(e => e.Gender)
            .NotEmpty().WithMessage(ValidationConstants.RequiredErrorMessage)
            .Must(g =>
            {
                if (g == null) return false;
                var gender = g.ToLower();

                return gender == "male" || g == "female";
            })
            .WithMessage("{PropertyName} must be Male, Female.");

        RuleFor(e => e.DateOfBirth)
            .NotEmpty().WithMessage(ValidationConstants.RequiredErrorMessage)
            .LessThan(DateTime.Today).WithMessage("{PropertyName} must be a past date.");
    }
}