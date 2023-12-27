import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import AVFoundation
import SoundpipeAudioKit
import SwiftUI
import KeychainSwift

struct LevelsView: View {
    @EnvironmentObject var conductor: EqualizerClass
    @State private var nickname: String = ""
    @State private var leaderboard: [User] = []

    var body: some View {
        
        
        VStack(spacing: 20) {
            Text("Name: \(nickname)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Level: \(conductor.currentLevel)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Score: \(conductor.totalScore) / \(conductor.pointsRequiredForNextLevel)")
                .font(.headline)
                .foregroundColor(.white)
            
            ProgressView(value: Double(conductor.totalScore), total: Double(conductor.pointsRequiredForNextLevel))
                .progressViewStyle(LinearProgressViewStyle())
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding()
            
            Group {
                Text("Gespielte Spiele: \(conductor.gamesPlayed)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            
            
            Text("Erfolge: \(conductor.achievements.joined(separator: ", "))")
                .font(.caption)
                .foregroundColor(.white)
                .padding()
            
            // Bestenliste
            VStack {
                Text("Bestenliste")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .listRowBackground(Color.black) // Hintergrund für jede Zeile
                
                ScrollView {
                    
                        ForEach(leaderboard, id: \.id) { user in
                            HStack {
                                Text(user.nickname ?? "Unbekannt")
                                    //.foregroundColor(.white)
                                Spacer()
                                Text("\(user.score)")
                                    //.foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.white)
                        }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground).opacity(0.1))
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .padding()
        .background(Color.black) // Änderung auf schwarzen Hintergrund
        .cornerRadius(12)
        .shadow(radius: 10)
//        .onAppear {
//            loadNickname()
//            Task {
//                leaderboard = await conductor.authenticationManager.fetchLeaderboard()
//            }
//        }
        .background(Color.black) // Hintergrund für die gesamte Liste

    }
//
//    private func loadNickname() {
//        let keychain = KeychainSwift()
//        nickname = keychain.get("userNickname") ?? "Unbekannt"
//    }
//    
    
    
}
