using LambdaApplication.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace LambdaService.Controllers;

[ApiController]
[Route("[controller]")]
public class WeatherForecastController(IWeatherForecastService weatherForecastService) : ControllerBase
{

    [HttpGet(Name = "GetWeatherForecast")]
    public IActionResult Get()
    {
        var response = weatherForecastService.ObterWeathers();
        return Ok(response);
    }
}