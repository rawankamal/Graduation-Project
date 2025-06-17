using Microsoft.Extensions.Configuration;

namespace Autine.Infrastructure;

public static class ConfigurationExtensions
{
    public static string GetConnectionStringOrThrow(
        this IConfiguration configuration,
        string name)
        => configuration.GetConnectionString(name) 
        ?? throw new InvalidOperationException(
            $"The connection string {name} was not valid"
            );
}
