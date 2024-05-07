import SwiftUI

@main

struct EqualizerApp: App {
    @State private var isUserLoggedIn = false
    @State private var userOffline = true
    @State private var isUserEars = false
    
    @State private var selectedTab: Int = 0
    //@StateObject var authenticationManager = AuthenticationManager() // Erstellen Sie das Objekt einmal hier
    @StateObject var equalizerClass = EqualizerClass()
    
    var body: some Scene {
        WindowGroup {
            
            //if isUserLoggedIn {
            TabView(selection: $selectedTab) {
                
                GraphicEqualizerView()
                    .environmentObject(equalizerClass)
                    .tabItem {
                        Image(systemName: "music.note")
                        Text("Music")
                    }
                    .tag(0)
                
                /*LevelsView()
                 .environmentObject(equalizerClass)
                 .tabItem {
                 Image(systemName: "chart.bar")
                 Text("Levels")
                 }.tag(3)*/
            }
            
            //}
            
            /*if userOffline {
             TabView(selection: $selectedTab) {
             
             GraphicEqualizerView()
             .environmentObject(equalizerClass)
             .tabItem {
             Image(systemName: "music.note")
             Text("Music")
             }
             .tag(0)
             // VIEW - LOG IN For Infos
             OfflineView()
             .environmentObject(equalizerClass)
             .tabItem {
             Image(systemName: "chart.bar")
             Text("Levels")
             }.tag(3)
             }
             }
             else {
             NavigationView {
             LoginView(isUserLoggedIn: $isUserLoggedIn)
             
             }
             
             }
             }*/
            
        }
    }
}
