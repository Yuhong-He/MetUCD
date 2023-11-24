//
//  WeatherUtils.swift
//  MetUCD
//
//  Created by Yuhong He on 21/11/2023.
//

import Foundation

func convertTime(time: Int) -> String {
    let timestamp = TimeInterval(time)
    let date = Date(timeIntervalSince1970: timestamp)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.string(from: date)
}

func convertDMS(degrees: Double, latOrLon: String) -> String {
    let degree = Int(degrees)
    let remainder = abs(degrees - Double(degree)) * 60
    let minute = Int(remainder)
    let seconds = Int((remainder - Double(minute)) * 60)
    var direction: String
    if (latOrLon == "lat") {
        direction = degrees >= 0 ? "N" : "S"
    } else {
        direction = degrees >= 0 ? "E" : "W"
    }
    return "\(abs(degree))°\(abs(minute))'\(abs(seconds))\" \(direction)"
}

func dayOfWeekAbbreviated(from dateString: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    guard let date = dateFormatter.date(from: dateString) else { return nil }
    
    let dateFormatter2 = DateFormatter()
    dateFormatter2.locale = Locale(identifier: "en_IE")
    dateFormatter2.dateFormat = "EEE"
    
    return dateFormatter2.string(from: date)
}

func rearrangeDaysInFutureWeek() -> [String] {
    let allDaysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    guard let todayIndex = Calendar.current.dateComponents([.weekday], from: Date()).weekday else {
        return allDaysOfWeek
    }
    let shift = todayIndex - 1
    let reorderedDays = Array(allDaysOfWeek[shift ..< allDaysOfWeek.count] + allDaysOfWeek[0 ..< shift])
    return reorderedDays
}

func getTodayInWeek() -> String {
    let allDaysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let todayIndex = Calendar.current.dateComponents([.weekday], from: Date()).weekday
    return allDaysOfWeek[(todayIndex ?? 0) - 1]
}
