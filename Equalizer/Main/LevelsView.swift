
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

    var body: some View {
        VStack(spacing: 20) {
            Text("Name: \(nickname)")
                            .font(.title)
                            .fontWeight(.bold)
            
            Text("Level: \(conductor.currentLevel)")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Score: \(conductor.totalScore) / \(conductor.pointsRequiredForNextLevel)")
                            .font(.headline)
            
            ProgressView(value: Double(conductor.totalScore), total: Double(conductor.pointsRequiredForNextLevel))
                .progressViewStyle(LinearProgressViewStyle())
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding()

            // Zusätzliche Statistiken
            Group {
                Text("Gespielte Spiele: \(conductor.gamesPlayed)")
            }
            .font(.subheadline)

            // Belohnungen und Erfolge
            Text("Erfolge: \(conductor.achievements.joined(separator: ", "))")
                .font(.caption)
                .padding()


         
            
            
            VStack {
                    Text("Bestenliste")
                        .font(.headline)
                        .padding()

                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(radius: 5)
            
                    
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .onAppear {
            loadNickname()
        }

    }
    
    private func loadNickname() {
        let keychain = KeychainSwift()
        nickname = keychain.get("userNickname") ?? "Unbekannt"
    }
    
}



