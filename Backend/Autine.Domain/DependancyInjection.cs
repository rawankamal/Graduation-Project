using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Autine.Domain;
public static class DependancyInjection
{
    public static IServiceCollection AddDomain(this IServiceCollection services, IConfigurationManager configuration)
    {
        // Add domain services here
        return services;
    }
}
