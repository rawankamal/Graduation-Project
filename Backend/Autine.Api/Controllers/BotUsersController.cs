using Autine.Application.Contracts.Bots;
using Autine.Application.Contracts.UserBots;
using Autine.Application.Features.UserBots.Commands.Remove;
using Autine.Application.Features.UserBots.Commands.Send;
using Autine.Application.Features.UserBots.Queries.GetBots;
using Autine.Application.Features.UserBots.Queries.GetById;
using Autine.Application.Features.UserBots.Queries.GetMessages;
using Autine.Application.Features.UserBots.Queries.GetMyBots;

namespace Autine.Api.Controllers;
[Route("api/[controller]")]
[ApiController]
[Authorize(Roles = $"{DefaultRoles.User.Name}, {DefaultRoles.Parent.Name}")]
[Produces("application/json")]
[ProducesResponseType(StatusCodes.Status401Unauthorized)]

public class BotUsersController(ISender sender) : ControllerBase
{
    [HttpPost("{botId:guid}/send-to-bot")]
    [ProducesResponseType(typeof(MessageResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> SendMessage(
        [FromRoute] Guid botId,
        [FromBody] BotMessageRequest request,
        CancellationToken cancellationToken)
    {
        string userId = User.GetUserId()!;

        var command = new SendMessageToBotCommand(userId, botId, request.Content);
        var result = await sender.Send(command, cancellationToken);

        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }
    [HttpGet("{botId}/chat-bot")]
    [ProducesResponseType(typeof(IEnumerable<MessageResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetMessageHistory(
        [FromRoute] Guid botId,
        CancellationToken cancellationToken)
    {
        var query = new GetChatBotsQuery(User.GetUserId()!, botId);
        var result = await sender.Send(query, cancellationToken);
        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }
    [HttpGet("my-bots")]
    [ProducesResponseType(typeof(IEnumerable<PatientBotsResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetMyBots(CancellationToken ct = default)
    {
        var query = new GetMyBotsQuery(User.GetUserId()!);
        var result = await sender.Send(query, ct);
        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }
    [HttpDelete("{botId:guid}/delete-chat")]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> DeleteById([FromRoute] Guid botId, CancellationToken ct = default)
    {
        var query = new DeleteChatCommand(User.GetUserId()!, botId);
        var result = await sender.Send(query, ct);
        return result.IsSuccess
            ? NoContent()
            : result.ToProblem();
    }
    [HttpGet("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [Produces<UserBotDetailedResponse>()]
    public async Task<IActionResult> GetById([FromRoute] Guid id, CancellationToken ct = default)
    {
        var query = new GetBotUserByIdQuery(User.GetUserId()!, id);
        var result = await sender.Send(query, ct);
        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();

    }
    [HttpGet("")]
    [Produces<PatientBotsResponse>()]
    public async Task<IActionResult> GetBots(CancellationToken ct = default)
    {
        var query = new GetAllBotsQuery();
        var result = await sender.Send(query, ct);

        return Ok(result.Value);
    }
}
