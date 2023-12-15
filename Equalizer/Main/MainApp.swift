import SwiftUI

@main

struct EqualizerApp: App {
    @State private var isUserLoggedIn = false
    @State private var isUserEars = false
    
    @State private var selectedTab: Int = 0
    @StateObject var authenticationManager = AuthenticationManager() // Erstellen Sie das Objekt einmal hier
    
    var body: some Scene {
        WindowGroup {
            
            let conductor = GraphicEqualizerConductor(authenticationManager: authenticationManager)
            if authenticationManager.isUserLoggedIn {
                TabView(selection: $selectedTab) {
                    
                    GraphicEqualizerView()
                        .environmentObject(authenticationManager) // Verwenden Sie die gleiche Instanz hier
                        .environmentObject(conductor)
                        .tabItem {
                            Image(systemName: "music.note")
                            Text("Music")
                        }
                        .tag(0)
                    
                    LevelsView()
                        .environmentObject(authenticationManager) // Und hier
                        .environmentObject(conductor)
                        .tabItem {
                            Image(systemName: "chart.bar")
                            Text("Levels")
                        }.tag(3)
                    
                }
                
            } else {
                NavigationView {
                    LoginView(isUserLoggedIn: $isUserLoggedIn)
                        .environmentObject(authenticationManager) // Und auch hier
                        .onAppear {
                            let credentials = authenticationManager.loadCredentials()
                            if let nickname = credentials.nickname, let password = credentials.password {
                                Task {
                                    await authenticationManager.login(nickname: nickname, password: password)
                                }
                            }
                        }
                }
                
            }
        }
        
    }
}
