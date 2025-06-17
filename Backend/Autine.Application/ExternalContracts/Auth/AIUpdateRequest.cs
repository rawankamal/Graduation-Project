namespace Autine.Application.ExternalContracts.Auth;

public record AIUpdateRequest(
    string email = "",
    string username = "",
    string password = "",
    string fname = "",
    string lname = "",
    string gender = ""
    );