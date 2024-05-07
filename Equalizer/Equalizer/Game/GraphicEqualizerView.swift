import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import AVFoundation
import SoundpipeAudioKit
import SwiftUI


struct GraphicEqualizerView: View {
    //@State private var isGamePlaying = false
    @State private var isShowingAlert = false
    
    @EnvironmentObject var conductor: EqualizerClass

    
    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                Button(action: {
                    if conductor.isGameActive {
                        // Stoppe das Spiel
                        conductor.player.stop()
                        conductor.resetGame()
                        conductor.isGameActive = false
                        // Weitere Aktionen zum Stoppen des Spiels
                    } else {
                        // Starte das Spiel
                        conductor.startGameIntroduction()
                        conductor.player.play()
                        conductor.isGameActive = true
                    }
                    
                }) {
                    Text(conductor.isGameActive  ? "stop game" : "start game")
                        .font(.custom("KRSNA-DREAMER", size: 20))
                        .padding()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.orange]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(8)
                        .shadow(radius: 5)
                }
            }
            .padding()

            /////////  DEBUG MODUS //////

            
                Text("wich frequency is pushed?")
                    .padding()
                    .foregroundColor(.white)
                    .font(.custom("KRSNA-DREAMER", size: 20))

            
                // Anzeigen der aktuellen Runde und verbleibenden Zeit
                Text("Round: \(conductor.currentRound) / \(conductor.totalRounds)")
                    .foregroundColor(.white)
                
                Text("Time Out: \(conductor.timerCountdown)")
                    .foregroundColor(.white)

            

            HStack(spacing: 20) {
                        ForEach(Array(zip(["a", "b", "c", "d", "e"], conductor.bandValues.enumerated())), id: \.0) { (bandLetter, band) in
                            let (bandNumber, bandValue) = band

                            VStack {
                                if bandValue > 999 {
                                    
                                    Text("\(bandValue/1000)" + "kHz") // Anzeigetext aus Array-Wert
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                else {
                                    Text("\(bandValue)" + "Hz") // Anzeigetext aus Array-Wert
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Button(action: {
                                    conductor.guessedBand = bandNumber + 1
                                    let isCorrect = conductor.checkAnswer(bandNumber + 1)
                                    // Logik für die Button-Aktion
                                }) {
                                    Text("\(bandLetter)")
                                        .font(.custom("KRSNA-DREAMER", size: 20))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.orange]), startPoint: .leading, endPoint: .trailing))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding()
            
            
            FFTView(conductor.fader)
            
        }

        


//        .alert(isPresented: $isShowingAlert) {
//            Alert(title: Text("SHOW BESTENLIOSTE"), message: Text(conductor.alertMessage), dismissButton: .default(Text("OK")))
//        }
        .background(Color(uiColor: .black))
        
        .alert(isPresented: $conductor.showAlert) {
            Alert(title: Text(""), message: Text(conductor.alertMessage), dismissButton: .default(Text("OK")))
        }
        
        .onAppear {
            conductor.start()
            
            
        }
        .onDisappear {
            conductor.stop()
        }
    }

    func binding(for band: Int) -> Binding<AUValue> {
        switch band {
        case 1:
            return $conductor.data.gain1
        case 2:
            return $conductor.data.gain2
        case 3:
            return $conductor.data.gain3
        case 4:
            return $conductor.data.gain4
        case 5:
            return $conductor.data.gain5
        
        default:
            return .constant(0.0)
        }
    }
}

