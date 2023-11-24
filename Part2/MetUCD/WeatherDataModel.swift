//
//  WeatherDataModel.swift
//  MetUCD
//
//  Created by Yuhong He on 20/11/2023..
//

import Foundation

// MARK: - WeatherDataModel

struct WeatherDataModel {
    private(set) var geoLocationData: GeoLocationData?
    private(set) var currentWeatherData: CurrentWeather?
    private(set) var airPollutionData: AirPollution?
    private(set) var forecastData: ForecastData?
    private(set) var airPollutionForecastData: AirPollution?
    
    private mutating func clear() {
        geoLocationData = nil
        currentWeatherData = nil
        airPollutionData = nil
        forecastData = nil
        airPollutionForecastData = nil
    }
    
    mutating func fetch(for location: String) async {
        clear()
        geoLocationData = await OpenWeatherMapAPI.geoLocation(for: location, countLimit: 1)
        guard let firstGeoLocation = geoLocationData?.first else { return }
        let lat = firstGeoLocation.lat
        let lon = firstGeoLocation.lon
        currentWeatherData = await OpenWeatherMapAPI.currentWeather(lat: lat, lon: lon)
        airPollutionData = await OpenWeatherMapAPI.airPollution(lat: lat, lon: lon)
        forecastData = await OpenWeatherMapAPI.forecast(lat: lat, lon: lon)
        airPollutionForecastData = await OpenWeatherMapAPI.airPollutionForecast(lat: lat, lon: lon)
    }
    
    mutating func tapFetch(lat: Double, lon: Double) async {
        clear()
        geoLocationData = await OpenWeatherMapAPI.reverseGeoLocation(lat: lat, lon: lon, countLimit: 1)
        currentWeatherData = await OpenWeatherMapAPI.currentWeather(lat: lat, lon: lon)
        airPollutionData = await OpenWeatherMapAPI.airPollution(lat: lat, lon: lon)
        forecastData = await OpenWeatherMapAPI.forecast(lat: lat, lon: lon)
        airPollutionForecastData = await OpenWeatherMapAPI.airPollutionForecast(lat: lat, lon: lon)
    }
}


// MARK: - Partial support for OpenWeatherMap API 2.5 (free api access)

struct OpenWeatherMapAPI {
    private static let apiKey = "ec342e474a07a094bc796ccce5cf00d9"
    private static let baseURL = "https://api.openweathermap.org/"
    
    static func fetchData<T: Codable>(from apiString: String) async throws -> T {
        let weatherAPIUrl = "\(Self.baseURL)\(apiString)&appid=\(Self.apiKey)"
        guard let url = URL(string: weatherAPIUrl) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            throw error
        }
    }

    static func geoLocation(for location: String, countLimit count: Int) async -> GeoLocationData? {
        let apiString = "geo/1.0/direct?q=\(location)&limit=\(count)"
        do {
            return try await fetchData(from: apiString)
        } catch {
            print("Error fetching geo location data: \(error)")
            return nil
        }
    }
    
    static func reverseGeoLocation(lat: Double, lon: Double, countLimit count: Int) async -> GeoLocationData? {
        let apiString = "geo/1.0/reverse?lat=\(lat)&lon=\(lon)&limit=\(count)"
        do {
            return try await fetchData(from: apiString)
        } catch {
            print("Error fetching reverse geo location data: \(error)")
            return nil
        }
    }
    
    static func currentWeather(lat: Double, lon: Double) async -> CurrentWeather? {
        let apiString = "data/2.5/weather?lat=\(lat)&lon=\(lon)&units=metric"
        do {
            return try await fetchData(from: apiString)
        } catch {
            print("Error fetching weather data: \(error)")
            return nil
        }
    }
    
    static func airPollution(lat: Double, lon: Double) async -> AirPollution? {
        let apiString = "data/2.5/air_pollution?lat=\(lat)&lon=\(lon)&units=metric"
        do {
            return try await fetchData(from: apiString)
        } catch {
            print("Error fetching air pollution data: \(error)")
            return nil
        }
    }
    
    static func forecast(lat: Double, lon: Double) async -> ForecastData? {
        let apiString = "data/2.5/forecast?lat=\(lat)&lon=\(lon)&units=metric"
        do {
            return try await fetchData(from: apiString)
        } catch {
            print("Error fetching forecast data: \(error)")
            return nil
        }
    }
    
    static func airPollutionForecast(lat: Double, lon: Double) async -> AirPollution? {
        let apiString = "data/2.5/air_pollution/forecast?lat=\(lat)&lon=\(lon)&units=metric"
        do {
            return try await fetchData(from: apiString)
        } catch {
            print("Error fetching air pollution data: \(error)")
            return nil
        }
    }
}


// MARK: - GeoLocationData

typealias GeoLocationData = [GeoLocation]


// MARK: - GeoLocation

struct GeoLocation: Codable, CustomStringConvertible {
    let name: String // Name of the found location
    let localNames: [String: String]? // Name of the found location in different languages. The list of names can be different for different locations
    let lat, lon: Double // Geographical coordinates of the found location (latitude, longitude)
    let country: String // Country of the found location
    let state: String? // (where available) State of the found location
    
    var description: String {
        let lat_s = convertDMS(degrees: lat, latOrLon: "lat")
        let lon_s = convertDMS(degrees: lon, latOrLon: "lon")
        return "\(lat_s), \(lon_s)"
    }

}

// MARK: - CurrentWeather

struct CurrentWeather: Codable {
    struct Coord: Codable {
        let lon: Double
        let lat: Double
    }
    
    struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct Main: Codable {
        let temp: Double
        let feels_like: Double
        let temp_min: Double
        let temp_max: Double
        let pressure: Int
        let humidity: Int
    }
    
    struct Wind: Codable {
        let speed: Double
        let deg: Int
    }
    
    struct Clouds: Codable {
        let all: Int
    }
    
    struct Sys: Codable {
        let type: Int?
        let id: Int?
        let country: String
        let sunrise: Int
        let sunset: Int
    }
    
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
}

struct AirPollution: Codable {
    struct Coord: Codable {
        let lon: Double
        let lat: Double
    }
    
    struct PollutionList: Codable {
        struct Main: Codable {
            let aqi: Int
        }
        
        struct Components: Codable {
            let co: Double
            let no: Double
            let no2: Double
            let o3: Double
            let so2: Double
            let pm2_5: Double
            let pm10: Double
            let nh3: Double
        }
        
        let main: Main
        let components: Components
        let dt: Int
    }
    
    let coord: Coord
    let list: [PollutionList]
}

struct ForecastData: Codable {
    struct Main: Codable {
        let temp: Double
        let feels_like: Double
        let temp_min: Double
        let temp_max: Double
        let pressure: Int
        let sea_level: Int
        let grnd_level: Int
        let humidity: Int
        let temp_kf: Double
    }
    
    struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct Clouds: Codable {
        let all: Int
    }
    
    struct Wind: Codable {
        let speed: Double
        let deg: Int
        let gust: Double
    }
    
    struct Sys: Codable {
        let pod: String
    }
    
    struct Rain: Codable {
        let threeHours: Double
        
        enum CodingKeys: String, CodingKey {
            case threeHours = "3h"
        }
    }
    
    struct City: Codable {
        let id: Int
        let name: String
        let coord: Coord
        let country: String
        let population: Int
        let timezone: Int
        let sunrise: Int
        let sunset: Int
    }
    
    struct Coord: Codable {
        let lat: Double
        let lon: Double
    }
    
    struct ForecastList: Codable {
        let dt: Int
        let main: Main
        let weather: [Weather]
        let clouds: Clouds
        let wind: Wind
        let visibility: Int
        let pop: Double
        let rain: Rain?
        let sys: Sys
        let dt_txt: String
    }
    
    let cod: String
    let message: Double
    let cnt: Int
    let list: [ForecastList]
    let city: City
}
