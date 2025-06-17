namespace Autine.Application.ExternalContracts.Auth;
public record AIRegisterRequest (
    string email,
    string username,
    string password,
    string fname,
    string lname,
    DateTime dateofbirth,
    string gender
);
