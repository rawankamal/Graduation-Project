namespace Autine.Application.Errors;

public class PatientErrors
{
    public static readonly Error PatientsNotFound
        = Error.NotFound($"Patient.{nameof(PatientsNotFound)}", "Patients not found");
    public static readonly Error DuplicatedPatient
        = Error.Conflict($"Patient.{nameof(DuplicatedPatient)}", "this patient is already supervised by you.");
    public static readonly Error MemberNotSupervisor
        = Error.BadRequest($"Patient.{nameof(MemberNotSupervisor)}", "Member is not a parent or doctor to add to thread.");
    public static readonly Error InvalidPatients
        = Error.BadRequest($"Patient.{nameof(InvalidPatients)}", "One or more patient not found try again.");
}
