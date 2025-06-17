namespace Autine.Application.IServices;
public interface IUrlGenratorService
{
    string? GetImageUrl(string fileName,bool isBot);
}