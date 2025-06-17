using Autine.Application.Features.FIles.Queries;

namespace Autine.Api.Controllers;
[Route("api/[controller]")]
[ApiController]
[Authorize]
public class FilesController(ISender sender) : ControllerBase
{

    [HttpGet("image/{imageName}")]
    public async Task<IActionResult> GetImage([FromRoute]string imageName, [FromQuery]bool isBot, CancellationToken cancellationToken)
    {
        var query = new GetImageQuery(imageName, isBot);
        var result = await sender.Send(query, cancellationToken);

        return result.IsSuccess
            ? File(result.Value.stream!, result.Value.contentType!, result.Value.fileName)
            : result.ToProblem();
    }
}
