using Autine.Application.Features.Messages.Queries.GetChat;
using Autine.Application.Features.Messages.Queries.GetChats;
using Autine.Application.Features.Messages.Queries.GetConnections;

namespace Autine.Api.Controllers;
[Route("api/[controller]")]
[ApiController]
[Authorize(Roles = $"{DefaultRoles.Parent.Name}, {DefaultRoles.Doctor.Name}")]
public class ChatsController(ISender _sender) : ControllerBase
{

    [HttpGet("contacts")]
    public async Task<IActionResult> GetMyContacts(CancellationToken cancellationToken)
    {
        var userId = User.GetUserId()!;
        var query = new GetUserConnectionsQuery(userId);
        var result = await _sender.Send(query, cancellationToken);

        return Ok(result.Value);
    }
    [HttpGet("chat")]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetChat([FromHeader] string receiverId, CancellationToken ct = default)
    {
        var userId = User.GetUserId()!;

        var query = new GetChatByIdQuery(userId, receiverId);
        var result = await _sender.Send(query, ct);

        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }
    [HttpGet("all-chat")]
    public async Task<IActionResult> GetChats(CancellationToken ct = default)
    {
        var userId = User.GetUserId()!;

        var query = new GetChatsQuery(userId);
        var result = await _sender.Send(query, ct);

        return Ok(result.Value);
    }
} 
