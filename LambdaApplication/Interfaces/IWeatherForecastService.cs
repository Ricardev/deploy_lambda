using LambdaDomain.Entidades;

namespace LambdaApplication.Interfaces;

public interface IWeatherForecastService
{
    public List<Weather> ObterWeathers();
}