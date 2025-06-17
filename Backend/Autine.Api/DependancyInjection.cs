using Autine.Api.OpenApiTransfromers;
using Autine.Infrastructure;
using Autine.Application;
using Autine.Domain;

namespace Autine.Api;
public static class DependancyInjection
{
    public static IServiceCollection AddApi(this IServiceCollection services, IConfigurationManager configuration)
    {

        services.AddProjectLayers(configuration);

        services.AddAuthentication();
        services.AddAuthorization();

        services.AddOpenApi("v1", optinos =>
        {
            optinos.AddDocumentTransformer<BearerSecuritySchemeTransformer>();
        });
        return services;
    }

    private static IServiceCollection AddProjectLayers(this IServiceCollection services, IConfigurationManager configuration)
    {
        services.AddInfrastructure(configuration);
        services.AddApplication(configuration);
        services.AddDomain(configuration);


        return services;
    }
}
