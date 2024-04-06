//
//  MovieSearchApp.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 6/4/2024.
//

import SwiftUI

@main
struct MovieSearchApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
