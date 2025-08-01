using LambdaApplication.Interfaces;
using LambdaDomain.Entidades;
using LambdaDomain.Repositories;

namespace LambdaApplication.Impl;

public class WeatherForecastService(IWeatherForecastRepository weatherForecastRepository) : IWeatherForecastService
{
    public List<Weather> ObterWeathers()
    {
        return weatherForecastRepository.GetWeatherForecast();
    }
}