using Autine.Application.Contracts.Threads;

namespace Autine.Application.Features.Threads.Queries.GetAll;
public class GetThreadsQueryHandler(IUnitOfWork unitOfWork) : IQueryHandler<GetThreadsQuery, IEnumerable<ThreadResponse>>
{
    public async Task<Result<IEnumerable<ThreadResponse>>> Handle(GetThreadsQuery request, CancellationToken cancellationToken)
    {
        var threads = await unitOfWork.Patients.GetAllThreads(request.UserId, cancellationToken);

        var threadResponses = threads.Select(t => new ThreadResponse(
            Id: t.Id,
            Title: t.ThreadTitle,
            SupervisorId: t.CreatedBy,
            PatientId: t.PatientId,
            t.CreatedAt,
            []
        ));

        return Result.Success(threadResponses);
    }
}
