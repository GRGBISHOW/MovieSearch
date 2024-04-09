//
//  MovieSearchApp.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 6/4/2024.
//

import DesignSystem
import SwiftUI

@main
struct MovieSearchApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContainerView {
                MovieSearchView(viewModel: MovieSearchViewModel())
            }
        }
    }
}
