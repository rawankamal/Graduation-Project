namespace Autine.Application.Contracts.Patients;

public class AssignPatientRequestValidator : AbstractValidator<AssignPatientRequest>
{
    public AssignPatientRequestValidator()
    {
        RuleFor(x => x.PatientId).NotEmpty();
        RuleFor(x => x.AssigneeId).NotEmpty();
    }
}