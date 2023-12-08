import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import AVFoundation
import SoundpipeAudioKit
import SwiftUI


// Standard Values
struct GraphicEqualizerData {
    var gain1: AUValue = 0.0
    var gain2: AUValue = 0.0
    var gain3: AUValue = 0.0
    var gain4: AUValue = 0.0
    var gain5: AUValue = 0.0
    var gain6: AUValue = 0.0
}

// Equalizer class
class GraphicEqualizerConductor: ObservableObject, ProcessesPlayerInput {
    
    var authenticationManager = AuthenticationManager()
    
    let fader: Fader
    let engine = AudioEngine()
    let player = AudioPlayer()
    let buffer: AVAudioPCMBuffer
    var userNickname: String = ""

    let filterBand1: EqualizerFilter
    let filterBand2: EqualizerFilter
    let filterBand3: EqualizerFilter
    let filterBand4: EqualizerFilter
    let filterBand5: EqualizerFilter
    

    @Published var currentRound = 0
    let totalRounds = 5
    var selectedBand: Int?
    
    @Published var bandValues = [50, 125, 400, 1000, 4000]
    
    var totalScoreAccumulated = 0
    @Published var totalScore = 0
    @Published var score = 100
    
    let pointsRequiredForNextLevel = 1500
    private let maxLevel = 10
    private let maxScore = 100
    private var isGamePlaying = false
    
    
    var averageScore: Double {
            return gamesPlayed > 0 ? Double(totalScoreAccumulated) / Double(gamesPlayed) : 0
        }

    @Published var isGameActive = false
    @Published var guessedBand: Int?
    private var correctBand: Int?

    @Published var showAlert = false
    @Published var alertMessage = ""

    @Published var gamesPlayed = 0
    @Published var currentLevel = 1
    
    
    private let maxTime = 20.0 // Maximale Zeit in Sekunden
    
    @Published var timerCountdown = 10 // Setze den Timer auf 10 Sekunden
    var timer: Timer?
    
    
    
    @Published var data = GraphicEqualizerData() {
        didSet {
            filterBand1.gain = data.gain1
            filterBand2.gain = data.gain2
            filterBand3.gain = data.gain3
            filterBand4.gain = data.gain4
            filterBand5.gain = data.gain5
        }
    }

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        filterBand1 = EqualizerFilter(player, centerFrequency: 50, bandwidth: 44.7, gain: 1.0)
        filterBand2 = EqualizerFilter(filterBand1, centerFrequency: 125, bandwidth: 44.7, gain: 1.0)
        filterBand3 = EqualizerFilter(filterBand2, centerFrequency: 400, bandwidth: 44.7, gain: 1.0)
        filterBand4 = EqualizerFilter(filterBand3, centerFrequency: 1000, bandwidth: 44.7, gain: 1.0)
        filterBand5 = EqualizerFilter(filterBand4, centerFrequency: 4000, bandwidth: 90.0, gain: 1.0)

        fader = Fader(filterBand5, gain: 0.4)
        engine.output = fader
        
    }
    
    func start() {
            do {
                try engine.start()
            } catch {
                print("AudioEngine konnte nicht gestartet werden: \(error)")
            }
        }

    func stop() {
        engine.stop()
    }

    func startGameIntroduction() {
            alertMessage = "In 10 Sekunden geht es los"
            showAlert = true
            isGameActive = true
            timerCountdown = 10 // Setze den Timer auf 20 Sekunden

            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.countdownBeforeGameStart()
            }
        }
    
    func countdownBeforeGameStart() {
            if timerCountdown > 0 {
                timerCountdown -= 1
            } else {
                timer?.invalidate()
                startGame()
            }
        }
    
    func startGame() {
        
        isGameActive = true
        timer?.invalidate()
        
        correctBand = Int.random(in: 1...5)
        
        switch correctBand {
        case 1:
            data.gain1 += 10 // Beispielwert für die Erhöhung
        case 2:
            data.gain2 += 10
        case 3:
            data.gain3 += 10
        case 4:
            data.gain4 += 10
        case 5:
            data.gain5 += 10
        default:
            break
        }
        
        
        score = maxScore
        timerCountdown = 20 // Setze den Timer auf 20 Sekunden
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    func updateTimer() {
            if timerCountdown > 0 {
                timerCountdown -= 1
                // Aktualisiere die Punktzahl
                score = Int(Double(maxScore) * (Double(timerCountdown) / maxTime))
            } else {
                timer?.invalidate()
                timer = nil
                nextRound()
            }
        }
    
    
    func finishGame() {
            score = 0
            isGameActive = false
            showAlert = true
            alertMessage = "Spiel beendet! Dein Score: \(totalScore)"
            showAlert = true
            resetBandGain(band: correctBand)
            resetGame()
            currentRound = 0
            player.stop()
        
        
            
            // Hier prüfen Sie, ob der erzielte Score ein neuer Highscore ist
            authenticationManager.getCurrentHighscore(nickname: userNickname) { [weak self] currentHighscore in
                    if let self = self, self.score > currentHighscore {
                        Task {
                            await self.authenticationManager.updateScore(nickname: self.userNickname, newScore: self.totalScore)
                        }
                    }
                }

            DispatchQueue.main.async {
                self.isGamePlaying = false
            }
            
            
        }
    
    func resetGame() {
            isGameActive = false
            timer?.invalidate()
            timer = nil
            resetBandGain(band: correctBand)
        }
    
    @Published var achievements: [String] = []

    func checkForAchievements() {
        // Beispiel: Füge einen Erfolg hinzu, wenn ein bestimmter Meilenstein erreicht wird
        if gamesPlayed == 10 {
            achievements.append("10 Spiele gespielt!")
        }
    }

    func updateGameStats() {
        gamesPlayed += 1
        totalScoreAccumulated += score
    }

    func nextRound() {
            if currentRound < totalRounds {
                currentRound += 1
                resetGame()
                startGame() // Startet die nächste Runde
            } else {
                // Spiel beenden und Ergebnisse anzeigen
                finishGame()
            }
        }

    func checkAnswer(_ guessedBand: Int) -> Bool {
        let isCorrect = guessedBand == correctBand
        alertMessage = isCorrect ? "Richtig!" : "Leider falsch."
        if !showAlert {
                showAlert = true
            }
        
        if isCorrect {
            updateTotalScore()
        }
        nextRound() // Startet die nächste Runde
        

        return isCorrect
    }
    
    
    func updateTotalScore() {
            totalScore += score
            
        }
    
    private func resetBandGain(band: Int?) {
        guard let band = band else { return }

        switch band {
        case 1:
            data.gain1 = 0
        case 2:
            data.gain2 = 0
        case 3:
            data.gain3 = 0
        case 4:
            data.gain4 = 0
        case 5:
            data.gain5 = 0
        // ... Fälle für die anderen Bänder
        default:
            break
        }
    }
    
}


struct GraphicEqualizerView: View {
    @ObservedObject var conductor = GraphicEqualizerConductor()
    @State private var isGamePlaying = false
    @State private var isShowingAlert = false
    @EnvironmentObject var authenticationManager: AuthenticationManager
    

    var body: some View {
        VStack {
            Text("Punktzahl: \(conductor.score)")
                .foregroundColor(.white)
            Text("Score: \(conductor.totalScore)")
                .foregroundColor(.white)
            
            
            PlayerControls(conductor: conductor)
                
            HStack {
                Button(action: {
                    if isGamePlaying {
                        // Stoppe das Spiel
                        conductor.player.stop()
                        conductor.resetGame()
                        conductor.finishGame()
                        isGamePlaying = false
                        // Weitere Aktionen zum Stoppen des Spiels
                    } else {
                        // Starte das Spiel
                        conductor.startGameIntroduction()
                        conductor.player.play()
                        isGamePlaying = true
                    }
                    
                    isGamePlaying.toggle()
                }) {
                    Text(isGamePlaying ? "spiel stoppen" : "spiel starten")
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
            
//            HStack {
//                ForEach(1...5, id: \.self) { band in
//                    CookbookKnob(text: "band ",
//                                 parameter: binding(for: band),
//                                 range: 0 ... 20).padding(5)
//                }
//            }
//            .background(Color(uiColor: .white))
//            .padding(5)

            
                Text("welche frequenz ist angehoben?")
                    .padding()
                    .foregroundColor(.white)
                    .font(.custom("KRSNA-DREAMER", size: 20))

            if conductor.isGameActive {
                // Anzeigen der aktuellen Runde und verbleibenden Zeit
                Text("Runde: \(conductor.currentRound) von \(conductor.totalRounds)")
                    .foregroundColor(.white)
                
                Text("Verbleibende Zeit: \(conductor.timerCountdown)")
                    .foregroundColor(.white)

            }

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
            
        }.onChange(of: conductor.isGameActive) { newValue in
            isGamePlaying = newValue // Aktualisiere isGamePlaying basierend auf isGameActive im Conductor
        }
        
        .onChange(of: conductor.showAlert) { showAlert in
            if showAlert {
                isShowingAlert = true
                // Setze showAlert im Conductor zurück, um wiederholte Alerts zu vermeiden
                conductor.showAlert = false
            }
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text("Ergebnis"), message: Text(conductor.alertMessage), dismissButton: .default(Text("OK")))
        }
        .background(Color(uiColor: .black))
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




struct GraphicEqualizer_Preview: PreviewProvider {
    static var previews: some View {
        GraphicEqualizerView()
    }
}
