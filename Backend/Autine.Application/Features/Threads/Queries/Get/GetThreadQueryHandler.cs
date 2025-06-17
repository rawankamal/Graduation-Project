using Autine.Application.Contracts.Threads;

namespace Autine.Application.Features.Threads.Queries.Get;
public class GetThreadQueryHandler(IUnitOfWork unitOfWork) : IQueryHandler<GetThreadQuery, ThreadResponse>
{
    public async Task<Result<ThreadResponse>> Handle(GetThreadQuery request, CancellationToken cancellationToken)
    {
        var thread = await unitOfWork.Patients.GetThreadByIdAsync(request.Id, cancellationToken);

        if (thread is null)
            return PatientErrors.PatientsNotFound;

        var response = new ThreadResponse
        (
            Id: thread.Id,
            Title: thread.ThreadTitle,
            SupervisorId: thread.CreatedBy,
            PatientId: thread.PatientId,
            CraetedAt: thread.CreatedAt,
            ThreadMembers: [.. thread.Members
                .Select(e => new ThreadMemberResponse
                (
                    Id: e.Id,
                    UserId: e.MemberId,
                    e.CreatedAt
                ))]
        );

        return Result.Success(response);
    }
}
