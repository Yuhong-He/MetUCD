//
//  MetUCDApp.swift
//  MetUCD
//
//  Created by Yuhong He on 19/11/2023.
//

import SwiftUI

@main
struct MetUCDApp: App {
    let viewModel = WeatherViewModel()
    var body: some Scene {
        WindowGroup {
            WeatherView(viewModel: viewModel)
        }
    }
}

