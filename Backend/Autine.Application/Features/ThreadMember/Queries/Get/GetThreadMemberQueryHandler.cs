using Autine.Application.Contracts.Threads;

namespace Autine.Application.Features.ThreadMember.Queries.Get;
public class GetThreadMemberQueryHandler(IUnitOfWork unitOfWork) : IQueryHandler<GetThreadMemberQuery, ThreadMemberResponse>
{
    public async Task<Result<ThreadMemberResponse>> Handle(GetThreadMemberQuery request, CancellationToken cancellationToken)
    {
        if (await unitOfWork.ThreadMembers.GetAsync(e => e.Id == request.Id, ct: cancellationToken) is not { } thread)
            return PatientErrors.PatientsNotFound;

        var response = new ThreadMemberResponse(
            thread.Id,
            thread.MemberId,
            thread.CreatedAt
            );
        // TODO: Add more properties to the response
        return Result.Success(response);
    }
}
