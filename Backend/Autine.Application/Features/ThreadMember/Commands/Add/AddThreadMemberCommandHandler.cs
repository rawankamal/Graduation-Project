namespace Autine.Application.Features.ThreadMember.Commands.Add;
public class AddThreadMemberCommandHandler(
    IUnitOfWork unitOfWork,
    IRoleService roleService) : ICommandHandler<AddThreadMemberCommand, Guid>
{
    public async Task<Result<Guid>> Handle(AddThreadMemberCommand request, CancellationToken cancellationToken)
    {
        if (await unitOfWork.Patients.GetAsync(e => e.Id == request.ThreadId, ct: cancellationToken) is not { } patient)
            return PatientErrors.PatientsNotFound;

        if (patient.CreatedBy != request.UserId)
            return PatientErrors.PatientsNotFound;
        
        if (await unitOfWork.ThreadMembers.CheckExistAsync(e => e.MemberId == request.MemberId && e.ThreadId == patient.Id, ct:cancellationToken) )
            return ThreadMemberErrors.ThreadMemberAlreadyExists;

        if (!await roleService.UserIsSupervisorAsync(request.MemberId))
            return PatientErrors.MemberNotSupervisor;

        var threadMemberId = await unitOfWork.ThreadMembers.AddAsync(new()
        {
            ThreadId = patient.Id,
            MemberId = request.MemberId
        }, cancellationToken);

        return Result.Success(patient.Id);
    }
}