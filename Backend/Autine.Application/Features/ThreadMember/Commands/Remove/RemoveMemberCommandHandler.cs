namespace Autine.Application.Features.ThreadMember.Commands.Remove;
public class RemoveMemberCommandHandler(IUnitOfWork unitOfWork) : ICommandHandler<RemoveMemberCommand>
{
    public async Task<Result> Handle(RemoveMemberCommand request, CancellationToken ct)
    {
        if (await unitOfWork.ThreadMembers.FindByIdAsync(ct, [request.ThreadMemberId]) is not { } threadMember)
            return ThreadMemberErrors.ThreadMemberNotFound;

        if (threadMember.CreatedBy != request.UserId) 
            return ThreadMemberErrors.InvalidThreadMember;

        await unitOfWork.ThreadMembers.DeleteThreadMemberAsync(request.ThreadMemberId, ct);

        await unitOfWork.CommitChangesAsync(ct);

        return Result.Success();
    }
}
