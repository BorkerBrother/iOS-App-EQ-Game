import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SwiftUI

// Helper functions
class Cookbook {
    static var sourceBuffer: AVAudioPCMBuffer {
        let url = Bundle.main.resourceURL?.appendingPathComponent("beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        return try! AVAudioPCMBuffer(file: file)!
    }
}
