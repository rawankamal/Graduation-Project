using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Autine.Persistence;
public static class DependancyInjection
{
    public static IServiceCollection AddPersistence(this IServiceCollection services, IConfigurationManager configuration)
    {
        // Add persistence services here
        return services;
    }
}
