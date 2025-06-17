namespace Autine.Application.ExternalContracts.Auth;

public record AIUpdateSuperRequest(
    string email = "",
    string username = "",
    string password = ""
    );