//
//  ContentView.swift
//  MetUCD
//
//  Created by Yuhong He on 19/11/2023.
//

import SwiftUI

struct WeatherView: View {
    @Bindable var viewModel: WeatherViewModel
    let alterText: String = "No Data"
    
    var body: some View {
        Form {
            if viewModel.foundLocation {
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
                        Text(alterText)
                    }
                } header: {
                    Text("Air Quality: \(viewModel.getAirQuality ?? alterText)")
                        .foregroundStyle(.gray)
                }
                
                Section(header: Text("5 Day Forecast").foregroundStyle(.gray)) {
                    if let forecast = viewModel.getForecast {
                        let orderedWeekdays = rearrangeDaysInFutureWeek()
                        let today = getTodayInWeek()
                        ForEach(orderedWeekdays, id: \.self) { day in
                            let displayedDay = today == day ? "Today" : day
                            if let temperature = forecast[day] {
                                HStack {
                                    HStack {
                                        Text(displayedDay)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.blue)
                                    }
                                    HStack {
                                        Image(systemName: "thermometer.low").foregroundColor(.gray)
                                        Text("(L: \(temperature.min)° H: \(temperature.max)°)")
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    } else {
                        Text(alterText)
                    }
                }
            } else {
                Text("No Location").foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    WeatherView(viewModel: WeatherViewModel())
}
