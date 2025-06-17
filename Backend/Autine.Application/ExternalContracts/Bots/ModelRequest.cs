namespace Autine.Application.ExternalContracts.Bots;
public record ModelRequest(
    string model_name,
    string model_context,
    string model_bio
    );