import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import AVFoundation
import SoundpipeAudioKit
import SwiftUI
import KeychainSwift

struct OfflineView: View {
    @EnvironmentObject var conductor: EqualizerClass
    @State private var nickname: String = ""

    var body: some View {
        
        
        VStack(spacing: 20) {

            Text("Log In for Infos")
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
            

        
        }
        .padding()
        .cornerRadius(12)
        .shadow(radius: 10)
        .background(Color.black) // Hintergrund für die gesamte Liste

    }

}


