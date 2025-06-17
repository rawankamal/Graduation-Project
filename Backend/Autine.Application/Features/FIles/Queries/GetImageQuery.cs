using Autine.Application.IServices;

namespace Autine.Application.Features.FIles.Queries;
public record GetImageQuery(string ImageUrl, bool IsBot) : IQuery<(FileStream? stream, string? contentType, string? fileName)>;

public class GetImageQueryHandler(IFileService fileService) : IQueryHandler<GetImageQuery, (FileStream? stream, string? contentType, string? fileName)>
{
    public async Task<Result<(FileStream? stream, string? contentType, string? fileName)>> Handle(GetImageQuery request, CancellationToken cancellationToken)
    {
        var result = await fileService.StreamAsync(request.ImageUrl, request.IsBot, cancellationToken);

        if (result.fileName == null || result.contentType == null || result.stream == null)
            return Error.BadRequest("Image.NotFound", "image not found");

        return result;
    }
    
}
