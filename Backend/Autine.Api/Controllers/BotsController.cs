using Autine.Application.Contracts.Bots;
using Autine.Application.Contracts.Files;
using Autine.Application.Features.Bots.Commands.Assign;
using Autine.Application.Features.Bots.Commands.Create;
using Autine.Application.Features.Bots.Commands.Remove;
using Autine.Application.Features.Bots.Commands.UnAssign;
using Autine.Application.Features.Bots.Commands.Update;
using Autine.Application.Features.Bots.Commands.UpdateBotImage;
using Autine.Application.Features.Bots.Queries.GetAll;
using Autine.Application.Features.Bots.Queries.GetById;
using Autine.Application.Features.Bots.Queries.GetPatients;

namespace Autine.Api.Controllers;
[Route("api/[controller]")]
[ApiController]
[Authorize(Roles = $"{DefaultRoles.Admin.Name}, {DefaultRoles.Parent.Name}, {DefaultRoles.Doctor.Name}")]
[Produces("application/json")]
[ProducesResponseType(StatusCodes.Status401Unauthorized)]
[ProducesResponseType(StatusCodes.Status403Forbidden)]
public class BotsController(ISender sender) : ControllerBase
{
    [HttpPost("")]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    [ProducesResponseType(StatusCodes.Status201Created)]
    public async Task<IActionResult> AddBot([FromBody] CreateBotRequest request, CancellationToken ct)
    {
        var userId = User.GetUserId()!;

        var command = new CreateBotCommand(userId, request);

        var result = await sender.Send(command, ct);

        return result.IsSuccess
            ? CreatedAtAction(nameof(GetBotById), new { id = result.Value }, null!)
            : result.ToProblem();
    }
    [HttpPut("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> UpdateBot([FromRoute] Guid id, [FromBody] UpdateBotRequest request, CancellationToken ct)
    {
        var userId = User.GetUserId()!;
        var command = new UpdateBotCommand(userId, id, request);
        var result = await sender.Send(command, ct);
        return result.IsSuccess
            ? NoContent()
            : result.ToProblem();
    }
    [HttpPut("{id:guid}/change-bot-image")]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> UpdateBotImage([FromRoute] Guid id, [FromForm] ImageRequest request, CancellationToken ct = default)
    {
        var userId = User.GetUserId()!;

        var command = new UpdateBotImageCommand(userId, request.Image, id);
        var result = await sender.Send(command, ct);
        return result.IsSuccess
            ? NoContent() 
            : result.ToProblem();
    }
    [HttpPost("{botId:guid}/assign-bot")]
    [Authorize(Roles = $"{DefaultRoles.Parent.Name}, {DefaultRoles.Doctor.Name}")]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> AssignBot([FromRoute] Guid botId, [FromQuery] string patientId, CancellationToken ct)
    {
        var userId = User.GetUserId()!;

        var command = new AssignModelCommand(userId, patientId, botId);
        var result = await sender.Send(command, ct);
        return result.IsSuccess
            ? NoContent()
            : result.ToProblem();
    }
    [HttpDelete("{botId:guid}/remove-assign")]
    [Authorize(Roles = $"{DefaultRoles.Parent.Name}, {DefaultRoles.Doctor.Name}")]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> RemoveAssign([FromRoute] Guid botId, [FromQuery] string patientId, CancellationToken ct)
    {
        var userId = User.GetUserId()!;
        var command = new DeleteAssignCommand(userId, botId, patientId);
        var result = await sender.Send(command, ct);
        return result.IsSuccess
            ? NoContent()
            : result.ToProblem();
    }
    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> DeleteBot([FromRoute] Guid id, CancellationToken ct)
    {
        var userId = User.GetUserId()!;
        var command = new RemoveBotCommand(userId, id);
        var result = await sender.Send(command, ct);
        return result.IsSuccess
            ? NoContent()
            : result.ToProblem();
    }
    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(BotResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetBotById([FromRoute] Guid id, CancellationToken ct)
    {
        var userId = User.GetUserId()!;
        var query = new GetBotByIdQuery(userId, id);

        var result = await sender.Send(query, ct);

        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }
    [HttpGet("my-bots")]
    [ProducesResponseType(typeof(ICollection<BotResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetBots(CancellationToken ct)
    {
        var userId = User.GetUserId()!;
        var query = new GetBotsQuery(userId);
        var result = await sender.Send(query, ct);
        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }
    [HttpGet("{id:guid}/bot-patients")]
    [Authorize(Roles = $"{DefaultRoles.Parent.Name}, {DefaultRoles.Doctor.Name}")]
    [ProducesResponseType(typeof(ICollection<BotPatientsResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetBotPatients([FromRoute] Guid id, CancellationToken ct)
    {
        var userId = User.GetUserId()!;
        var query = new GetBotPatientsQuery(userId, id);
        var result = await sender.Send(query, ct);
        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }
}
