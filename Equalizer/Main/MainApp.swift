import SwiftUI

@main


struct EqualizerApp: App {
    @State private var isUserLoggedIn = false
    @State private var isUserEars = false
    @StateObject var conductor = GraphicEqualizerConductor()
    @State private var selectedTab: Int = 0 // 1 für Home-Tab
    @StateObject var authenticationManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            
            if authenticationManager.isUserLoggedIn {
                // Verwende TabView, um zwischen verschiedenen Ansichten zu wechseln
                TabView(selection: $selectedTab) {
                    
                    GraphicEqualizerView(conductor: conductor)
                        .environmentObject(AuthenticationManager()) // Hier wird es der View Hierarchie hinzugefügt
                        .tabItem {
                            Image(systemName: "music.note")
                            Text("Music")
                        }
                        .tag(0)  // Eindeutiger Tag für Spiel-Tab
                    
                    
                    
                    LevelsView(conductor: conductor, authenticationManager: authenticationManager)
                        .environmentObject(AuthenticationManager()) // Hier wird es der View Hierarchie hinzugefügt
                        .tabItem {
                            Image(systemName: "chart.bar")
                            Text("Levels")
                        }.tag(3)
                    
                    
                }
                
            } else {
                // Anmeldebildschirm
                NavigationStack {
                    LoginView(isUserLoggedIn: $isUserLoggedIn, authenticationManager: authenticationManager)
                        .environmentObject(AuthenticationManager()) // Hier wird es der View Hierarchie hinzugefügt
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
