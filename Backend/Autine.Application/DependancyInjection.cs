using Autine.Application.Contracts.Auths;
using Autine.Application.Mapster;
using FluentValidation.AspNetCore;
using Mapster;
using MapsterMapper;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Autine.Application;
public static class DependancyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services, IConfigurationManager configuration)
    {
        services.RegisterServices();

        return services;
    }

    private static IServiceCollection RegisterServices(this IServiceCollection services)
    {
        services.AddFluentValidationAutoValidation()
            .AddValidatorsFromAssembly(typeof(LoginRequestValidator).Assembly);

        var mappingConfig = TypeAdapterConfig.GlobalSettings;
        mappingConfig.Scan(typeof(MappingConfiguration).Assembly);
        services.AddSingleton<IMapper>(new Mapper(mappingConfig));

        services.AddMediatR(config =>
        {
            config.RegisterServicesFromAssembly(typeof(DependancyInjection).Assembly);
        });

        return services;
    }

}
