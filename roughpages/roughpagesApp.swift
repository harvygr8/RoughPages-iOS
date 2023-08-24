//
//  roughpagesApp.swift
//  roughpages
//
//  Created by Pranjal Chaudhari on 02/05/23.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct roughpagesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var dataController = LocalDataCoreDataClass()
    @ObservedObject var appState = InAppDetails.inAppDetails
    var body: some Scene {
        WindowGroup {
            ContentView().id(appState.rootViewId).environmentObject(appState)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
