using LambdaDomain.Entidades;
using LambdaDomain.Repositories;

namespace LambdaRepository.Repositories;

public class WeatherForecastRepository : IWeatherForecastRepository
{
    public List<Weather> Weathers = new()
    {
        new()
        {
            Name = "Freezing", 
        },
        new ()
        {
            Name = "Bracing", 
        },
        new ()
        {
            Name = "Chilly", 
        },
        new ()
        {
            Name = "Cool", 
        },
        
    };
    
    public List<Weather> GetWeatherForecast()
    {
        return Weathers;
    }
}