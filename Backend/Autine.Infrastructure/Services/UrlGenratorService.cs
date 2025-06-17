using Autine.Application.IServices;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Logging;

namespace Autine.Infrastructure.Services;

public class UrlGenratorService(IHttpContextAccessor httpContextAccessor,
    ILogger<UrlGenratorService> logger, LinkGenerator linkGenerator) : IUrlGenratorService
{
    public string? GetImageUrl(string fileName, bool isBot)
    {
        logger.LogInformation("Generating image URL for file: {FileName}, isBot: {IsBot}", fileName, isBot);

        if (string.IsNullOrEmpty(fileName))
        {
            logger.LogWarning("File name is null or empty");
            return null!;
        }

        var httpContext = httpContextAccessor.HttpContext!;

        var url = linkGenerator.GetUriByAction(
            httpContext,
            action: "GetImage",
            controller: "Files",
            values: new { imageName = fileName, isBot },
            scheme: httpContext.Request.Scheme,
            host: httpContext.Request.Host
            );

        logger.LogInformation("Generated image URL: {Url}", url);
        return url;
    }
} 