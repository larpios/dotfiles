def location [] : nothing -> record<status: string, country: string, countryCode: string, city: string, region: int, regionName: string, timezone: string, lat: float, lon: float, isp: string, org: string, as: string, query: string> {
    http 'http://ip-api.com/json'
}

export def main [] {
    const WEATHER_API = 'https://wttr.in/?format=j1'

    let weather_info = http $WEATHER_API --raw | from json

    $weather_info | upsert request { |it| $it.request.query | parse 'Lat {lat} and Lon {lon}' }
}
