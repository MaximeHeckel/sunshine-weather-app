//
//  Store.swift
//  sunshine
//
//  Created by Maxime on 11/26/20.
//

import Foundation
import Combine

enum ViewState: String{
    case loading
    case error
    case idle
}

enum Temperature: Int{
    case fahrenheit = 0
    case celsius = 1
    case kelvin = 2
}

enum Speed: Int{
    case mph = 0
    case kmh = 1
    case mps = 2
}

enum MainDaypart: String{
    case dawn
    case mid
    case dusk
    case night
}

enum MainWeatherType: String, Decodable{
    case Thunderstorm
    case Drizzle
    case Rain
    case Snow
    case Clear
    case Few_Clouds
    case Clouds
    case Mist
    case Haze
    case Fog
    case Smoke
}

struct WeatherObject: Decodable {
    let id: Int
    let main: MainWeatherType
    let description: String
}

struct CurrentForecast: Decodable {
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: Double
    let feelsLike: Double
    let pressure: Int
    let humidity: Int
    let dewPoint: Double
    let clouds: Int
    let visibility: Int
    let windSpeed: Double
    let windDeg: Int
    let weather: [WeatherObject]
}

struct HourlyForecast: Hashable, Decodable {
    
    static func == (lhs: HourlyForecast, rhs: HourlyForecast) -> Bool {
        return lhs.dt > rhs.dt
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(dt)
    }
    
    let dt: Int
    let temp: Double
    let feelsLike: Double
    let pressure: Int
    let humidity: Int
    let dewPoint: Double
    let clouds: Int
    let visibility: Int
    let windSpeed: Double
    let weather: [WeatherObject]
}

struct DetailTemp: Decodable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct DetailFeelsLikeTemp: Decodable {
    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct DailyForecast: Hashable, Decodable {
    static func == (lhs: DailyForecast, rhs: DailyForecast) -> Bool {
        return lhs.dt > rhs.dt
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(dt)
    }
    
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: DetailTemp
    let feelsLike: DetailFeelsLikeTemp
    let pressure: Int
    let humidity: Int
    let dewPoint: Double
    let windSpeed: Double
    let windDeg: Int
    let weather: [WeatherObject]
    let clouds: Int
}

struct Response: Decodable {
    let lat: Double
    let lon: Double
    let timezone: String
    let timezoneOffset: Int
    let current: CurrentForecast
    let hourly: [HourlyForecast]
    let daily: [DailyForecast]
    
}

class WeatherAPIClient {
    private let apiKey = ""// OPEN WEATHER MAP TOKEN GOES HERE
    private let decoder = JSONDecoder()
    private let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func fetch (lat: Double, lon: Double, handler: @escaping (Result<Response, Error>) -> Void) {
        let baseURL = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&exclude=minutely")
        // Ensure the URL is unpacked
        guard let url = baseURL else {
            print("error...")
            return
        }
        
        let request = URLRequest(url: url)
        
        // Fetch data with URL session
        session.dataTask(with: request) {(data, response, error) in
            // If an error occurs, call the callback with the error
            if let error = error {
                handler(.failure(error))
            } else {
                // If there's no error try to decode the JSON response
                // The following is equivalent to a try/catch block in JS
                do {
                    // Convert from snake case to camel case
                    self.decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let data = data ?? Data()
                    let response = try self.decoder.decode(Response.self, from: data)
                    // Call the callback with the response
                    handler(.success(response))
                } catch {
                    // Call the callback with an error if decoding the JSON fails
                    handler(.failure(error))
                }
            }
            
        }.resume()
    }
}
