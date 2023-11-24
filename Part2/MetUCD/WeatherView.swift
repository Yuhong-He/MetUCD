//
//  ContentView.swift
//  MetUCD
//
//  Created by Yuhong He on 19/11/2023.
//

import SwiftUI
import Charts

struct WeatherView: View {
    @Bindable var viewModel: WeatherViewModel
    let alterText: String = "No Data"
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: "location").foregroundColor(.blue)
                    Text(viewModel.getCoord ?? alterText).foregroundColor(.black)
                }
                HStack {
                    Image(systemName: "sunrise").foregroundColor(.blue)
                    Text(viewModel.getSunriseUTC ?? alterText).foregroundColor(.black)
                    Text(viewModel.getSunriseLocal ?? alterText).foregroundStyle(.gray)
                    Image(systemName: "sunset").foregroundColor(.blue)
                    Text(viewModel.getSunsetUTC ?? alterText).foregroundColor(.black)
                    Text(viewModel.getSunsetLocal ?? alterText).foregroundStyle(.gray)
                }
                HStack {
                    Image(systemName: "clock.arrow.2.circlepath").foregroundColor(.blue)
                    Text(viewModel.getTimezone ?? alterText).foregroundColor(.black)
                }
            } header: {
                Text("Geo Info").foregroundStyle(.gray)
            }
            
            Section {
                HStack {
                    Image(systemName: "thermometer.low").foregroundColor(.blue)
                    Text(viewModel.getTemp ?? alterText).foregroundColor(.black)
                    Text(viewModel.getLowHighTemp ?? "").foregroundColor(.gray)
                    Image(systemName: "thermometer.variable.and.figure").foregroundColor(.blue)
                    Text(viewModel.getFeelsLike ?? alterText).foregroundColor(.black)
                }
                HStack {
                    Image(systemName: "cloud").foregroundColor(.blue)
                    Text(viewModel.getCloudCoverage ?? alterText).foregroundColor(.black)
                }
                HStack {
                    Image(systemName: "wind").foregroundColor(.blue)
                    Text(viewModel.getWind ?? alterText).foregroundColor(.black)
                }
                HStack {
                    Image(systemName: "humidity").foregroundColor(.blue)
                    Text(viewModel.getHumidity ?? alterText).foregroundColor(.black)
                    Image(systemName: "barometer").foregroundColor(.blue)
                    Text(viewModel.getPressure ?? alterText).foregroundColor(.black)
                }
            } header: {
                Text("Weather: \(viewModel.getWeatherDesc ?? alterText)").foregroundStyle(.gray)
            }
            
            Section(header: Text("5 Day Forecast").foregroundStyle(.gray)) {
                if let forecastByDay = viewModel.getForecast {
                    let orderedWeekdays = rearrangeDaysInFutureWeek()
                    let today = getTodayInWeek()
                    ForEach(orderedWeekdays, id: \.self) { day in
                        let displayedDay = today == day ? "Today" : day
                        if let forecast = forecastByDay.first(where: { $0.day == day }) {
                            HStack {
                                VStack {
                                    HStack {
                                        Text(displayedDay).font(.system(size: 15)).foregroundColor(.blue)
                                        Spacer()
                                        Image(systemName: "thermometer.low").font(.system(size: 15)).foregroundColor(.gray)
                                        Text("\(forecast.min)°").font(.system(size: 15)).foregroundColor(.gray)
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 3)
                                                .foregroundColor(Color.gray)
                                                .frame(width: 80, height: 5)
                                            
                                            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.red]), startPoint: .leading, endPoint: .trailing)
                                                .frame(width: 80, height: 5)
                                                .mask(RoundedRectangle(cornerRadius: 3))
                                        }
                                        Image(systemName: "thermometer.low").font(.system(size: 15)).foregroundColor(.gray)
                                        Text("\(forecast.max)°").font(.system(size: 15)).foregroundColor(.gray)
                                    }
                                    HStack {
                                        ForEach(forecast.hourly, id: \.hour) { hourForecast in
                                            Spacer()
                                            VStack(spacing: 2) {
                                                Text("\(hourForecast.hour)").font(.system(size: 12)).foregroundColor(.black)
                                                AsyncImage(url: URL(string: hourForecast.url)) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        ProgressView()
                                                    case .success(let image):
                                                        image
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 25, height: 25)
                                                            .background(Color.gray.opacity(0.2))
                                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                                    case .failure:
                                                        Image(systemName: "xmark.octagon")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 25, height: 25)
                                                            .foregroundColor(.red)
                                                            .background(Color.gray.opacity(0.2))
                                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                                            }
                                            Spacer()
                                        }
                                    }
                                }.frame(height: 50)
                            }
                        }
                    }
                } else {
                    Text(alterText).foregroundColor(.black)
                }
            }
            
            Section {
                if let leftDetails = viewModel.getAirQualityDetailLeft, let rightDetails = viewModel.getAirQualityDetailRight {
                    HStack {
                        VStack {
                            Spacer()
                            ForEach(leftDetails.indices, id: \.self) { index in
                                HStack {
                                    Text(leftDetails[index].0).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(.blue)
                                    Text(leftDetails[index].1).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.black)
                                }
                                Spacer()
                            }
                            HStack {
                                Text(" ").font(.system(size: 12))
                            }
                        }
                        
                        VStack {
                            Spacer()
                            ForEach(rightDetails.indices, id: \.self) { index in
                                HStack {
                                    Text(rightDetails[index].0).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(.blue)
                                    Text(rightDetails[index].1).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.black)
                                }
                                Spacer()
                            }
                            HStack {
                                Text("units: μg/m3").frame(maxWidth: .infinity, alignment: .trailing).foregroundStyle(.gray).font(.system(size: 12))
                            }
                        }
                    }
                } else {
                    Text(alterText).foregroundColor(.black)
                }
            } header: {
                Text("Air Quality: \(viewModel.getAirQuality ?? alterText)")
                    .foregroundStyle(.gray)
            }
            
            Section {
                if let airPollutionForest = viewModel.getAirPollutionForecast {
                    VStack {
                        Chart(airPollutionForest, id: \.time) { item in
                            LineMark(
                                x: .value("Time", item.time),
                                y: .value("Air Quality", item.aqi)
                            )
                        }
                        .frame(height: 150)
                        .chartYScale(
                            domain: [5, 1]
                        )
                        .chartYAxis {
                            AxisMarks() { value in
                                AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 1))
                                AxisValueLabel() {
                                    let arr = ["Good", "Fair", "Moderate", "Poor", "Very Poor"]
                                    if let intValue = value.as(Int.self) {
                                        Text("\(arr[intValue - 1])")
                                        .font(.system(size: 10))
                                    }
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day, count: 1)) { _ in
                                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                            }
                        }
                    }
                } else {
                    Text(alterText).foregroundColor(.black)
                }
            } header: {
                Text("Air Pollution Index Forecast")
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    WeatherView(viewModel: WeatherViewModel())
}
