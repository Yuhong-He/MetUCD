//
//  ContentView.swift
//  MetUCD
//
//  Created by Yuhong He on 22/11/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            MapView(dataViewModel: WeatherViewModel())
        }
    }
}
