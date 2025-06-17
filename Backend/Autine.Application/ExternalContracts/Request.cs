namespace Autine.Application.ExternalContracts;
public record Request(
    string Url, 
    ApiMethod ApiMethod = ApiMethod.Post,
    object Data = null!
    );
