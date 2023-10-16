//
//  HttpRequestApp.swift
//  HttpRequest
//
//  Created by Kadek Edwin on 14/10/23.
//

import SwiftUI

@main
struct HttpRequestApp: App {
    let persistenceController = PersistenceController.shared
    let linkViewModel = LinkViewModel(viewContext: PersistenceController.shared.container.viewContext)
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(linkViewModel)
        }
    }
}
