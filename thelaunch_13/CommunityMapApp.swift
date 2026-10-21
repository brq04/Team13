//
//  CommunityMapApp.swift
//  thelaunch_13
//
//  Created by malhajri on 09/05/1448 AH.
//

import SwiftUI
 
@main
struct CommunityMapApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                // مرة وحدة بس هنا. لا تكررينها في كل View
                .environment(\.layoutDirection, .rightToLeft)
                .environment(\.locale, Locale(identifier: "ar"))
        }
    }
}
