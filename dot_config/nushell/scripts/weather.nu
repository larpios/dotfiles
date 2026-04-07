def location [] : nothing -> record<status: string, country: string, countryCode: string, city: string, region: int, regionName: string, timezone: string, lat: float, lon: float, isp: string, org: string, as: string, query: string> {
  http 'http://ip-api.com/json'
}

export def "main" [] {
  const WEATHER_API = 'https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&hourly=temperature_2m&current=temperature_2m,is_day,rain,precipitation,showers,snowfall,weather_code,relative_humidity_2m,apparent_temperature'

  let loc = location
  let api_url = $WEATHER_API | str replace '{lat}' $"($loc.lat)" | str replace '{lon}' $"($loc.lon)"

  http $api_url
}
