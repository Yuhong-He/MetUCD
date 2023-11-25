//
//  MapView.swift
//  MetUCD
//
//  Created by Yuhong He on 22/11/2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Bindable var dataViewModel: WeatherViewModel
    @Namespace var mapScope
    @State private var placedCreateLocationPin = false
    @State private var camera: MapCameraPosition = .automatic
    @State private var presentSheet = false
    @State private var clickedClearBtn = false
    @State private var centerCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0) // default value
    @State private var latitudinalMeters = 20000.0
    @State private var longitudinalMeters = 20000.0
    
    let alterText: String = "No Data"
    
    var body: some View {
        ZStack(alignment: .bottom) {
            MapReader { reader in
                Map(position: $camera, interactionModes: [.all], scope: mapScope) {
                    if let coordinate = dataViewModel.currentLocation {
                        Annotation("My Location", coordinate: coordinate) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).stroke(Color.black, lineWidth: 2)
                                Image(systemName: "location").padding(5)
                            }
                        }.annotationTitles(.hidden)
                    }
                    if let pinCoord = dataViewModel.pinLocation {
                        if dataViewModel.isTapFetchDataCompleted {
                            Marker("", coordinate: pinCoord)
                        }
                    }
                }.onMapCameraChange { mapCameraUpdateContext in
                    centerCoord = mapCameraUpdateContext.camera.centerCoordinate
                }.onTapGesture(perform: { screenCoord in
                    placedCreateLocationPin.toggle()
                    let pl = reader.convert(screenCoord, from: .local)
                    print("tapped location: \(pl?.latitude ?? 0.0) \(pl?.longitude ?? 0.0)")
                    dataViewModel.tapFetchData(coord: pl)
                })
                .safeAreaInset(edge: .top) {
                    HStack {
                        TextField(text: $dataViewModel.namedLocation) {
                            Text("Enter location e.g. Dublin")
                        }.padding(.bottom, 10)
                        .onSubmit {
                            dataViewModel.pinLocation = nil
                            if !dataViewModel.namedLocation.isEmpty {
                                dataViewModel.fetchData()
                                clickedClearBtn = false
                            }
                        }
                        .onChange(of: dataViewModel.namedLocation) { oldState, newState in
                            if newState.isEmpty {
                                dataViewModel.pinLocation = nil
                                clickedClearBtn = true
                            }
                        }
                        .onChange(of: dataViewModel.currentLocation) { oldState, newState in
                            if (newState != nil), let location = dataViewModel.currentLocation {
                                camera = .region(
                                    MKCoordinateRegion(
                                        center: location,
                                        latitudinalMeters: latitudinalMeters,
                                        longitudinalMeters: longitudinalMeters))
                            }
                        }
                        .onChange(of: dataViewModel.isFetchDataCompleted) { oldState, newState in
                            if newState, let location = dataViewModel.destLocation {
                                clickedClearBtn = false
                                camera = .region(
                                    MKCoordinateRegion(
                                        center: location,
                                        latitudinalMeters: latitudinalMeters,
                                        longitudinalMeters: longitudinalMeters))
                            }
                        }
                        .onChange(of: dataViewModel.isTapFetchDataCompleted) { oldState, newState in
                            if newState {
                                clickedClearBtn = false
                            }
                        }
                        .padding([.leading, .trailing])
                        Spacer()
                        Button {
                            dataViewModel.namedLocation = ""
                            dataViewModel.pinLocation = nil
                            clickedClearBtn = true
                        } label: {
                            Circle()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray)
                                .overlay(
                                    Image(systemName: "multiply")
                                        .foregroundColor(.white)
                                )
                                .padding(.bottom, 10)
                        }
                        Button {
                            if let currentLocation = dataViewModel.currentLocation {
                                camera = .region(
                                    MKCoordinateRegion(
                                        center: currentLocation,
                                        latitudinalMeters: latitudinalMeters,
                                        longitudinalMeters: longitudinalMeters))
                            }
                        } label: {
                            Circle()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                                .overlay(
                                    Image(systemName: "location")
                                        .foregroundColor(.white)
                                )
                                .padding(.trailing, 10)
                                .padding(.bottom, 10)
                        }
                    }
                    .padding(.top)
                    .background(.thinMaterial)
                }
            }
            VStack() {
                Button {
                    minusMeters(latitudinalMeters: &latitudinalMeters, longitudinalMeters: &longitudinalMeters)
                    camera = .region(
                        MKCoordinateRegion(
                            center: centerCoord,
                            latitudinalMeters: latitudinalMeters,
                            longitudinalMeters: longitudinalMeters))
                } label: {
                    Rectangle()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color.white.opacity(0.8))
                        .cornerRadius(5)
                        .overlay(
                            Image(systemName: "plus")
                                .foregroundColor(.black)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                Button {
                    plusMeters(latitudinalMeters: &latitudinalMeters, longitudinalMeters: &longitudinalMeters)
                    camera = .region(
                        MKCoordinateRegion(
                            center: centerCoord,
                            latitudinalMeters: latitudinalMeters,
                            longitudinalMeters: longitudinalMeters))
                } label: {
                    Rectangle()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color.white.opacity(0.8))
                        .cornerRadius(5)
                        .overlay(
                            Image(systemName: "minus")
                                .foregroundColor(.black)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: UIScreen.main.bounds.width - 50))
            if !dataViewModel.namedLocation.isEmpty && dataViewModel.foundLocation && !clickedClearBtn {
                Button(action: {
                    presentSheet.toggle()
                }) {
                    VStack {
                        Rectangle()
                            .frame(height: 150)
                            .frame(width: 250)
                            .foregroundColor(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .overlay(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2)
                                    GeometryReader { geometry in
                                        VStack(spacing: 8) {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Text(dataViewModel.city ?? alterText)
                                                    .padding(.vertical, 2)
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.black)
                                                Spacer()
                                            }
                                            HStack {
                                                Image(systemName: "thermometer.low")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 30))
                                                Text(dataViewModel.getTemp ?? alterText)
                                                    .padding(.vertical, 2)
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 30))
                                            }
                                            HStack {
                                                Text(dataViewModel.getWeatherDesc ?? alterText)
                                                    .padding(.vertical, 2)
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.black)
                                            }
                                            HStack {
                                                Text(dataViewModel.getLowHighTemp ?? alterText)
                                                    .padding(.vertical, 2)
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 15))
                                            }
                                            Spacer()
                                        }.padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                            .frame(width: geometry.size.width, height: geometry.size.height)
                                    }
                                }
                                    .clipped()
                            )
                    }
                    .padding(.bottom, 30)
                    .sheet(isPresented: $presentSheet) {
                        ZStack {
                            WeatherView(viewModel: dataViewModel)
                        }
                    }
                }
            }
            if !dataViewModel.foundLocation && dataViewModel.startFindLocation && !clickedClearBtn {
                VStack {
                    Rectangle()
                        .frame(height: 50)
                        .frame(width: 250)
                        .foregroundColor(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .overlay(
                            ZStack {
                                RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2)
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Text("Location Not Found")
                                            .padding(.vertical, 2)
                                            .font(.system(size: 20))
                                            .foregroundColor(.black)
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }
                        )
                }
                .padding(.bottom, 30)
            }
            if dataViewModel.currentLocation == nil {
                VStack {
                    Rectangle()
                        .frame(height: 50)
                        .frame(width: 250)
                        .foregroundColor(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .overlay(
                            ZStack {
                                RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2)
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Text("We don't have your location permission")
                                            .padding(.vertical, 2)
                                            .font(.system(size: 10))
                                            .foregroundColor(.black)
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }
                        )
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    func plusMeters(latitudinalMeters: inout Double, longitudinalMeters: inout Double) {
        let thresholds = [1000000.0, 100000.0, 10000.0, 1000.0, 100.0, 10.0]
        for threshold in thresholds {
            if latitudinalMeters >= threshold && longitudinalMeters >= threshold {
                if ((latitudinalMeters + threshold) > 6000000.0 && (longitudinalMeters + threshold) > 6000000.0) {
                    break
                }
                latitudinalMeters += threshold
                longitudinalMeters += threshold
                break
            }
        }
    }
    
    func minusMeters(latitudinalMeters: inout Double, longitudinalMeters: inout Double) {
        let thresholds = [1000000.0, 100000.0, 10000.0, 1000.0, 100.0, 10.0]
        for threshold in thresholds {
            if latitudinalMeters > threshold && longitudinalMeters > threshold {
                latitudinalMeters -= threshold
                longitudinalMeters -= threshold
                break
            }
        }
    }

}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(dataViewModel: WeatherViewModel())
    }
}
