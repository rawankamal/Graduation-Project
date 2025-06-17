using Autine.Application.Contracts.Bots;
using Autine.Application.Contracts.Patients;
using Autine.Application.Features.Patients.Commads.Add;
using Autine.Application.Features.Patients.Commads.Remove;
using Autine.Application.Features.Patients.Commads.Update;
using Autine.Application.Features.Patients.Queries.Get;
using Autine.Application.Features.Patients.Queries.GetAll;
using Autine.Application.Features.Patients.Queries.GetBots;

namespace Autine.Api.Controllers;
[Route("api/[controller]")]
[ApiController]
[Authorize(Roles = $"{DefaultRoles.Doctor.Name}, {DefaultRoles.Parent.Name}")]
[Produces("application/json")]
[ProducesResponseType(StatusCodes.Status401Unauthorized)]
[ProducesResponseType(StatusCodes.Status403Forbidden)]
public class PatientsController(ISender sender) : ControllerBase
{
    [HttpPost("")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    public async Task<IActionResult> AddPatient([FromBody] PatientRequest request, CancellationToken ct)
    {
        var userId = User.GetUserId()!;
        var command = new AddPatientCommand(userId, request);
        var result = await sender.Send(command, ct);
        return result.IsSuccess
            ? CreatedAtAction(
                nameof(GetPatientById),
                new { id = result.Value },
                null!
                )
            : result.ToProblem();
    }
    [HttpPut("{id:guid}")]
    public async Task<IActionResult> UpdatePatient([FromRoute] string id, [FromBody] UpdatePatientRequest request, CancellationToken ct)
    {
        var userId = User.GetUserId()!;
        var command = new UpdatePatientCommand(userId, id, request);
        var result = await sender.Send(command, ct);
        return result.IsSuccess
            ? NoContent()
            : result.ToProblem();
    }
    [HttpGet("{id}")]
    [ProducesResponseType(typeof(PatientResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetPatientById([FromRoute] string id, CancellationToken ct)
    {
        var userId = User.GetUserId()!;
        var query = new GetPatientQuery(userId, id);
        var result = await sender.Send(query, ct);
        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }
    [HttpGet("my-patient")]
    [ProducesResponseType(typeof(ICollection<PatientResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetMyPatients(CancellationToken ct)
    {
        var userId = User.GetUserId()!;

        var query = new GetPatientsQuery(userId, false);

        var result = await sender.Send(query, ct);
        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }
    [HttpGet("follow-patient")]
    [ProducesResponseType(typeof(ICollection<PatientResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetFollowPatients(CancellationToken ct)
    {
        var userId = User.GetUserId()!;

        var query = new GetPatientsQuery(userId, true);

        var result = await sender.Send(query, ct);
        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }
    [HttpGet("{id:guid}/patient-bot")]
    [ProducesResponseType(typeof(IEnumerable<PatientBotsResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetPatientBots([FromRoute] string id, CancellationToken ct)
    {
        var userId = User.GetUserId()!;
        var query = new GetPatientBotsQuery(userId, id);
        var result = await sender.Send(query, ct);
        return result.IsSuccess
            ? Ok(result.Value)
            : result.ToProblem();
    }

    [HttpDelete("{patientId:guid}")]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> DeletePatient([FromRoute] string patientId, CancellationToken ct)
    {
        var userId = User.GetUserId()!;
        
        var command = new RemovePatientCommand(userId, patientId);
        var result = await sender.Send(command, ct);
        return result.IsSuccess
            ? NoContent()
            : result.ToProblem();
    }
}