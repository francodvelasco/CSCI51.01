//
//  CSCI51_ProjectApp.swift
//  CSCI51 Project
//
//  Created by Franco Velasco on 4/11/24.
//

import SwiftUI
import SwiftData

@main
struct CSCI51_ProjectApp: App {
    @StateObject var environment = EnvironmentViewModel()

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .environmentObject(environment)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .windowStyle(.hiddenTitleBar)
    }
}
