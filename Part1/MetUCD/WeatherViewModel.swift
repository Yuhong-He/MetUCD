//
//  WeatherViewModel.swift
//  MetUCD
//
//  Created by Yuhong He on 20/11/2023.
//

import SwiftUI
import CoreLocation

@Observable class WeatherViewModel {
    var namedLocation: String = ""
    var foundLocation: Bool = false
    var isLoading: Bool = false
    
    // MARK: Model
    
    private var dataModel = WeatherDataModel()

    // MARK: User intent
    
    func fetchData() {
        Task {
            isLoading = true
            foundLocation = false // reset status
            await dataModel.fetch(for: namedLocation)
            isLoading = false
            guard let firstGeoLocation = dataModel.geoLocationData?.first else {
                namedLocation = namedLocation
                return
            }
            foundLocation = true
            let city = firstGeoLocation.name
            let state = firstGeoLocation.state ?? nil
            let country = firstGeoLocation.country
            if (state != nil) {
                namedLocation = "\(city), \(state!), \(country)"
            } else {
                namedLocation = "\(city), \(country)"
            }
        }
    }
    
    // MARK: Public Properties

    var getCoord: String? {
        guard let firstGeoLocation = dataModel.geoLocationData?.first else { return nil }
        return firstGeoLocation.description
    }
    
    var getSunriseUTC: String? {
        guard let currentWeatherData = dataModel.currentWeatherData else { return nil }
        let sunrise = currentWeatherData.sys.sunrise
        return convertTime(time: sunrise)
    }
    
    var getSunriseLocal: String? {
        guard let currentWeatherData = dataModel.currentWeatherData else { return nil }
        let sunrise = currentWeatherData.sys.sunrise
        let timezone = currentWeatherData.timezone
        return "(\(convertTime(time: sunrise + timezone)))"
    }
    
    var getSunsetUTC: String? {
        guard let currentWeatherData = dataModel.currentWeatherData else { return nil }
        let sunset = currentWeatherData.sys.sunset
        return convertTime(time: sunset)
    }
    
    var getSunsetLocal: String? {
        guard let currentWeatherData = dataModel.currentWeatherData else { return nil }
        let sunset = currentWeatherData.sys.sunset
        let timezone = currentWeatherData.timezone
        return "(\(convertTime(time: sunset + timezone)))"
    }
    
    var getTimezone: String? {
        guard let currentWeatherData = dataModel.currentWeatherData else { return nil }
        let timezone = currentWeatherData.timezone
        return "\(timezone / 3600)H"
    }
    
    var getWeatherDesc: String? {
        guard let currentWeatherData = dataModel.currentWeatherData else { return nil }
        return currentWeatherData.weather.first?.description
    }
    
    var getTemp: String? {
        guard let currentWeatherData = dataModel.currentWeatherData else { return nil }
        return "\(Int(currentWeatherData.main.temp))°"
    }
    
    var getLowHighTemp: String? {
        guard let currentWeatherData = dataModel.currentWeatherData else { return nil }
        let lowTemp = Int(currentWeatherData.main.temp_min)
        let highTemp = Int(currentWeatherData.main.temp_max)
        return "(L: \(lowTemp)° H: \(highTemp)°)"
    }
    
    var getFeelsLike: String? {
        guard let currentWeatherData = dataModel.currentWeatherData else { return nil }
        return "Feels \(Int(currentWeatherData.main.feels_like))°"
    }
    
    var getCloudCoverage: String? {
        guard let currentWeatherData = dataModel.currentWeatherData else { return nil }
        return "\(currentWeatherData.clouds.all)% coverage"
    }
    
    var getWind: String? {
        guard let currentWeatherData = dataModel.currentWeatherData else { return nil }
        let speed = currentWeatherData.wind.speed
        let deg = currentWeatherData.wind.deg
        return "\(speed) km/h, dir: \(deg)°"
    }
    
    var getHumidity: String? {
        guard let currentWeatherData = dataModel.currentWeatherData else { return nil }
        return "\(currentWeatherData.main.humidity)%"
    }
    
    var getPressure: String? {
        guard let currentWeatherData = dataModel.currentWeatherData else { return nil }
        return "\(currentWeatherData.main.pressure) hPa"
    }
    
    var getAirQuality: String? {
        guard let airPollutionData = dataModel.airPollutionData else { return nil }
        guard let firstAqi = airPollutionData.list.first?.main else { return nil }
        let aqi = firstAqi.aqi
        let qualityDict: [Int: String] = [1: "Good", 2: "Fair", 3: "Moderate", 4: "Poor", 5: "Very Poor"]
        return qualityDict[aqi]
    }
    
    var getAirQualityDetailLeft: [(String, String)]? {
        guard let airPollutionData = dataModel.airPollutionData else { return nil }
        guard let details = airPollutionData.list.first?.components else { return nil }
        let arr = [
            ("NO", String(format: "%.1f", details.no)),
            ("O3", String(format: "%.1f", details.o3)),
            ("NO2", String(format: "%.1f", details.no2)),
            ("CO", String(format: "%.1f", details.co))
        ]
        return arr
    }
    
    var getAirQualityDetailRight: [(String, String)]? {
        guard let airPollutionData = dataModel.airPollutionData else { return nil }
        guard let details = airPollutionData.list.first?.components else { return nil }
        let arr = [
            ("PM10", String(format: "%.1f", details.pm10)),
            ("NH3", String(format: "%.1f", details.nh3)),
            ("PM2.5", String(format: "%.1f", details.pm2_5)),
            ("SO2", String(format: "%.1f", details.so2))
        ]
        return arr
    }
    
    var getForecast: [String: (min: Int, max: Int)]? {
        guard let forecastData = dataModel.forecastData else { return nil }
        var temperaturesByDay: [String: (min: Int, max: Int)] = [:]
        for forecast in forecastData.list {
            let date = Date(timeIntervalSince1970: TimeInterval(forecast.dt))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            let dayOfWeekStr = dayOfWeek(from: dateString)
            guard let dayOfWeek = dayOfWeekStr else { return nil }
            if let temperature = temperaturesByDay[dayOfWeek] {
                let newMin = min(temperature.min, Int(forecast.main.temp_min))
                let newMax = max(temperature.max, Int(forecast.main.temp_max))
                temperaturesByDay[dayOfWeek] = (Int(newMin), Int(newMax))
            } else {
                temperaturesByDay[dayOfWeek] = (Int(forecast.main.temp_min), Int(forecast.main.temp_max))
            }
        }
        return temperaturesByDay
    }
}
