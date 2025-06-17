using Autine.Application.Contracts.Auths;
using Autine.Application.Contracts.Users;
using Autine.Application.Features.Users.Commands.AddAdmin;
using Autine.Application.Features.Users.Commands.Delete;
using Autine.Application.Features.Users.Queries.GetAll;
using Autine.Application.Features.Users.Queries.GetById;

namespace Autine.Api.Controllers;
[Route("api/[controller]")]
[ApiController]
[Authorize(Roles = $"{DefaultRoles.Admin.Name}")]
public class UsersController(ISender sender) : ControllerBase
{
    [HttpPost("add-admin")]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    [ProducesResponseType(StatusCodes.Status201Created)]
    public async Task<IActionResult> AddAdmin([FromBody] RegisterRequest request, CancellationToken ct)
    {
        var userId = User.GetUserId()!;

        var query = new AddAdminCommand(userId, request);
        var result = await sender.Send(query, ct);

        return result.IsSuccess
            ? CreatedAtAction(
                nameof(Get),
                new {id = result.Value},
                null!
                )
            : result.ToProblem();
    }
    [HttpGet("all-users")]
    [Produces<UserResponse>]
    public async Task<IActionResult> GetAllUsers(CancellationToken ct)
    {
        var userId = User.GetUserId()!;

        var query = new GetAllUsersQuery(userId);
        var result = await sender.Send(query, ct);

        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }
    [HttpGet("{id:guid}/get-user-by-id")]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [Produces<DetailedUserResponse>]
    public async Task<IActionResult> Get([FromRoute] string id, CancellationToken ct)
    {
        var userId = User.GetUserId()!;

        var query = new GetUserByIdQuery(userId, id);
        var result = await sender.Send(query, ct);

        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }
    [HttpDelete("{id:guid}/delete-user")]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> Delete([FromRoute] string id, CancellationToken ct)
    {
        var query = new DeleteUserByIdCommand(User.GetUserId()!, id);
        var result = await sender.Send(query, ct);

        return result.IsSuccess
            ? NoContent()
            : result.ToProblem();
    }

}
