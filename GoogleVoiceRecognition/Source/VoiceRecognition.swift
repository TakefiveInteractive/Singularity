import SwiftHTTP
import AVFoundation
import PromiseKit
import Flac

public enum VoiceLanguages : String {
    case English = "en_US"
    case Mandarin = "zh_CN"
    case Japanese = "jp_JP"
}

private let VoiceApiKeys = [
    "AIzaSyDG6H_g7olZFWdIIWCtWPiYsqSrkWSRyzM",
    "AIzaSyBLnwjUYipg5mOFxG5bNAPrlvQmroMHvss",
    "AIzaSyDcaEqYmbfmRtMMSCRRgwYrituNgrhmlsE"
]

enum VoiceRecognitionError: ErrorType {
    case InvalidSampleRate
}

class VoiceRecognition {
    
    /// Converts a piece of audio to string
    class func recognize(audio: AVAudioPCMBuffer, atTime: AVAudioTime) -> Promise<String> {
        return Promise { resolve, reject in
            if atTime.sampleRate != 44100 {
                reject(VoiceRecognitionError.InvalidSampleRate)
            }
            // Encode PCM into FLAC
            
        }
    }
}

