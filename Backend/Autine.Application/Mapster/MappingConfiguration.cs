using Autine.Application.Contracts.Bots;

namespace Autine.Application.Mapster;
public class MappingConfiguration : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<(Bot bot, BotPatientsResponse botPatient), DetailedBotResponse>()
            .Map(dest => dest.Patients, src => src.botPatient)
            .Map(dest => dest, src => src.bot);

       
    }
}
