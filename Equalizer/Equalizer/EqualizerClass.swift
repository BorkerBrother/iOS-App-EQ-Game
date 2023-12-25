//
//  EqualizerClass.swift
//  MAIN_LAUT
//
//  Created by Borker on 16.12.23.
//
import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import AVFoundation
import SoundpipeAudioKit
import SwiftUI
import Foundation

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
class EqualizerClass: ObservableObject, ProcessesPlayerInput {
    
    @ObservedObject var authenticationManager = AuthenticationManager()
    
    // Audio
    let fader: Fader
    let engine = AudioEngine()
    let player = AudioPlayer()
    let buffer: AVAudioPCMBuffer
    
    let filterBand1: EqualizerFilter
    let filterBand2: EqualizerFilter
    let filterBand3: EqualizerFilter
    let filterBand4: EqualizerFilter
    let filterBand5: EqualizerFilter
    
    
    @Published var bandValues = [50, 125, 400, 1000, 4000]
    
    var selectedBand: Int?

    @Published var data = GraphicEqualizerData() {
        didSet {
            filterBand1.gain = data.gain1
            filterBand2.gain = data.gain2
            filterBand3.gain = data.gain3
            filterBand4.gain = data.gain4
            filterBand5.gain = data.gain5
        }
    }
    
    //PLAYER
    var nickname: String = ""
    var totalScoreAccumulated = 0
    @Published var totalScore = 0
    @Published var score = 100
    
    // GAME
    @Published var currentRound = 1
    @Published var isGameActive = false
    @Published var guessedBand: Int?
    private var correctBand: Int?
    let totalRounds = 5
    @Published var gamesPlayed = 0
    @Published var currentLevel = 1
    @Published var achievements: [String] = []
    
    // TIMER
    var timer: Timer?
    private let maxTime = 20.0 // Maximale Zeit in Sekunden
    @Published var timerCountdown = 10 // Setze den Timer auf 10 Sekunden
    
    // LEVEL
    let pointsRequiredForNextLevel = 1500
    private let maxLevel = 10
    private let maxScore = 100
    

    // MESSAGE
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    
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
    
    // START ENGINE
    func start() {
        do {
            try engine.start()
        } catch {
            print("AudioEngine konnte nicht gestartet werden: \(error)")
        }
    }

    // STOP GAME
    func stop() {
        engine.stop()
    }

    // GAME INTRODUCTION
    func startGameIntroduction() {
        alertMessage = "Game starts in 5 seconds"
        showAlert = true
        isGameActive = true
        timerCountdown = 5 // Setze den Timer auf 5 Sekunden
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.countdownBeforeGameStart()
        }
    }
    
    // COUNTDOWN
    func countdownBeforeGameStart() {
        if timerCountdown > 0 {
            timerCountdown -= 1
        } else {
            timer?.invalidate()
            startGame()
        }
    }
    
    // START GAME
    func startGame() {
        
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
    
    // TIMER UPDATE & SCORE UPDATE
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
    
    
    // FINISH GAME AFTER X ROUNDS
    func finishGame() {
        print("test4")
        score = 0
        isGameActive = false
        alertMessage = "Game end! Score: \(totalScore)"
        resetGame()
        currentRound = 0
        player.stop()

        nickname = loadname() ?? "default"
        Task {
            await authenticationManager.fetchCurrentScore(nickname: nickname)
            let currentScore = await self.authenticationManager.fetchCurrentScore(nickname: nickname)
            // Update score if it's higher
            await self.authenticationManager.updateScoreIfHigher(nickname: nickname, newScore: currentScore)
            DispatchQueue.main.async {
                self.authenticationManager.userScore = currentScore
            }
        }
    }
         
    // RESET GAME
    func resetGame() {
        isGameActive = false
        timer?.invalidate()
        timer = nil
        resetBandGain(band: correctBand)
        timerCountdown = 20 // Setzen Sie den Timer auf den Anfangswert zurück
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
                print("test3")
            }
        }

    // CHECK IF CORRECT
    func checkAnswer(_ guessedBand: Int) -> Bool {
        
        let isCorrect = guessedBand == correctBand
        if isCorrect {
            updateTotalScore()
            alertMessage = "Correct!"
        } else {
            alertMessage = "Wrong!"
        }
        showAlert = true
         // Zeige den Alert unabhängig davon, ob die Antwort richtig oder falsch ist
        nextRound() // Startet die nächste Runde
        return isCorrect
    }
    
    // UPODATE SCORE IF Correct Answer
    func updateTotalScore() {
        nickname = loadname() ?? "default"
        Task {
            let viewScore = await self.authenticationManager.fetchCurrentScore(nickname: nickname)
            totalScore = self.authenticationManager.userScore + score

            await self.authenticationManager.updateScoreIfHigher(nickname: nickname, newScore: totalScore)
            
            DispatchQueue.main.async {
                self.authenticationManager.userScore = self.totalScore
                print("Aktualisierter Score: \(self.totalScore)")
            }
            print("test2")
        }
    }
    
    // RESET BAND GAIN
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
    
    
    // GAME GOALS
    func checkForAchievements() {
        // Beispiel: Füge einen Erfolg hinzu, wenn ein bestimmter Meilenstein erreicht wird
        if gamesPlayed == 10 {
            achievements.append("10 Spiele gespielt!")
        }
    }
    
}
