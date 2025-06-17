namespace Autine.Application.Contracts.Patients;

public class UpdatePatientRequestValidator : AbstractValidator<UpdatePatientRequest>
{
    public UpdatePatientRequestValidator()
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

        RuleFor(e => e.Status)
            .NotEmpty().WithMessage(ValidationConstants.RequiredErrorMessage)
            .Length(ValidationConstants.MinLength, ValidationConstants.MaxLength).WithMessage(ValidationConstants.LengthErrorMesssage);

        RuleFor(e => e.Diagnosis)
            .NotEmpty().WithMessage(ValidationConstants.RequiredErrorMessage)
            .Length(ValidationConstants.MinLength, ValidationConstants.MaxLength).WithMessage(ValidationConstants.LengthErrorMesssage);

        RuleFor(e => e.Notes)
            .NotEmpty().WithMessage(ValidationConstants.RequiredErrorMessage)
            .Length(3, 10000).WithMessage(ValidationConstants.LengthErrorMesssage);
        
        RuleFor(e => e.Notes)
            .NotEmpty().WithMessage(ValidationConstants.RequiredErrorMessage)
            .Length(3, 100).WithMessage(ValidationConstants.LengthErrorMesssage);

        RuleFor(e => e.NextSession)
            .NotEmpty().WithMessage(ValidationConstants.RequiredErrorMessage)
            .GreaterThanOrEqualTo(DateTime.Today).WithMessage("{PropertyName} must be a greater than today.");

        RuleFor(e => e.LastSession)
            .NotEmpty().WithMessage(ValidationConstants.RequiredErrorMessage)
            .LessThanOrEqualTo(DateTime.Today).WithMessage("{PropertyName} must be a past date.");

        RuleFor(e => e.Gender)
            .NotEmpty().WithMessage(ValidationConstants.RequiredErrorMessage)
            .Must(g =>
            {
                if (g == null) return false;
                var gender = g.ToLower();

                return gender == "male" || gender == "female";
            })
            .WithMessage("{PropertyName} must be Male, Female.");

        RuleFor(e => e.DateOfBirth)
            .NotEmpty().WithMessage(ValidationConstants.RequiredErrorMessage)
            .LessThan(DateTime.Today).WithMessage("{PropertyName} must be a past date.");
    }
}