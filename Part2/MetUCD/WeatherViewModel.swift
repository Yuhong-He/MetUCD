//
//  WeatherViewModel.swift
//  MetUCD
//
//  Created by Yuhong He on 20/11/2023.
//

import SwiftUI
import CoreLocation

@Observable class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    var authorizationStatus: CLAuthorizationStatus?
    var currentLocation: CLLocationCoordinate2D?
    var destLocation: CLLocationCoordinate2D?
    var pinLocation: CLLocationCoordinate2D?
    var city: String?
    
    var namedLocation: String = ""
    var startFindLocation = false
    var foundLocation = false
    var isFetchDataCompleted = false
    var isTapFetchDataCompleted = false
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // MARK: Model
    
    private var dataModel = WeatherDataModel()
    
    func clear() {
        destLocation = nil
        pinLocation = nil
        isTapFetchDataCompleted = false
        isFetchDataCompleted = false
        foundLocation = false
    }

    // MARK: User intent
    
    func fetchData() {
        Task {
            clear()
            await dataModel.fetch(for: namedLocation)
            startFindLocation = true
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
            self.city = city
            destLocation = CLLocationCoordinate2D(latitude: firstGeoLocation.lat, longitude: firstGeoLocation.lon)
            isFetchDataCompleted = true
        }
    }
    
    func tapFetchData(coord pl: CLLocationCoordinate2D?) {
        Task {
            clear()
            guard let location = pl else { return }
            let lat = location.latitude
            let lon = location.longitude
            await dataModel.tapFetch(lat: lat, lon: lon)
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
            self.city = city
            pinLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            isTapFetchDataCompleted = true
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
    
    struct ForecastByHour {
        let hour: String
        let url: String
        let min: Int
        let max: Int
    }
    
    struct ForecastByDay {
        let day: String
        let min: Int
        let max: Int
        let hourly: [ForecastByHour]
    }
    
    var getForecast: [ForecastByDay]? {
        guard let forecastData = dataModel.forecastData else { return nil }
        var forecastByDay: [ForecastByDay] = []
        
        var forecastByDate: [String: [ForecastByHour]] = [:]
        
        for forecast in forecastData.list {
            let date = Date(timeIntervalSince1970: TimeInterval(forecast.dt))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            let dayOfWeekStr = dayOfWeekAbbreviated(from: dateString)
            guard let dayOfWeek = dayOfWeekStr else { return nil }
            
            if forecastByDate[dayOfWeek] == nil {
                forecastByDate[dayOfWeek] = []
            }
            
            let hour = Calendar.current.component(.hour, from: date)
            let icon = forecast.weather.first?.icon ?? ""
            let min = Int(forecast.main.temp_min)
            let max = Int(forecast.main.temp_max)
            let url = "https://openweathermap.org/img/wn/\(icon)@2x.png"
            let forecastByHour = ForecastByHour(hour: "\(hour)H", url: url, min: min, max: max)
            forecastByDate[dayOfWeek]?.append(forecastByHour)
        }
        
        for (day, hourlyForecasts) in forecastByDate {
            let minTemp = hourlyForecasts.map { Int($0.min) }.min() ?? 0
            let maxTemp = hourlyForecasts.map { Int($0.max) }.max() ?? 0
            let forecastDay = ForecastByDay(day: day, min: minTemp, max: maxTemp, hourly: hourlyForecasts)
            forecastByDay.append(forecastDay)
        }
        return forecastByDay
    }
    
    struct AirQualityIndex {
        var time: Date
        var aqi: Int
    }
    
    var getAirPollutionForecast: [AirQualityIndex]? {
        guard let airPollutionForecastData = dataModel.airPollutionForecastData else { return nil }
        var airQualityIndex: [AirQualityIndex] = []
        for airPollutionForecast in airPollutionForecastData.list {
            let time = Date(timeIntervalSince1970: TimeInterval(airPollutionForecast.dt))
            airQualityIndex += [AirQualityIndex(time: time, aqi: airPollutionForecast.main.aqi)]
        }
        return airQualityIndex
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:  // Location services are available.
            // Insert code here of what should happen when Location services are authorized
            authorizationStatus = .authorizedWhenInUse
            locationManager.requestLocation()
            break
            
        case .restricted:  // Location services currently unavailable.
            // Insert code here of what should happen when Location services are NOT authorized
            authorizationStatus = .restricted
            break
            
        case .denied:  // Location services currently unavailable.
            // Insert code here of what should happen when Location services are NOT authorized
            authorizationStatus = .denied
            break
            
        case .notDetermined:        // Authorization not determined yet.
            authorizationStatus = .notDetermined
            manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("Coordinate: \(String(describing: location.coordinate))")
            currentLocation = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
}
