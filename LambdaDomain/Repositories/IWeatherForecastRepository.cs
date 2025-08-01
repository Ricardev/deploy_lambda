using LambdaDomain.Entidades;

namespace LambdaDomain.Repositories;

public interface IWeatherForecastRepository
{
    List<Weather> GetWeatherForecast();
}