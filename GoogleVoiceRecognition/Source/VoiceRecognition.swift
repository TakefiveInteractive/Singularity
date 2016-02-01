import Alamofire
import AVFoundation
import SwiftyJSON
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
    case ApiFailure
}

class VoiceRecognition {
    
    /// Converts a piece of audio to string
    class func recognize(audio: AVAudioPCMBuffer, atTime: AVAudioTime, lang: VoiceLanguages = .English) -> Promise<String> {
        return Promise { resolve, reject in
            if atTime.sampleRate != 44100 {
                reject(VoiceRecognitionError.InvalidSampleRate)
            }
            // Encode PCM into FLAC
            let outputState = FLAC__encode44100single16bit(audio.int16ChannelData.memory, audio.frameLength)
            
            let flacData = outputState.memory.data
            
            let url = "https://www.google.com/speech-api/v2/recognize?output=json&lang=\(lang.rawValue)&key=\(VoiceApiKeys[Int(arc4random_uniform(UInt32(VoiceApiKeys.count)))])&app=Singularity"
            let data = NSData(bytes: flacData, length: outputState.memory.pointer)
            
            Alamofire.upload(.POST, url, headers: ["Content-Type": "audio/x-flac; rate=44100;"], data: data)
            .responseJSON { response in
                let result = JSON(response.result.value!)["result"]
                print(result)
                if result.count == 0 {
                    reject(VoiceRecognitionError.ApiFailure)
                } else {
                    resolve(result[0]["alternative"][0]["transcript"].string!)
                }
            }
            
            // Free the writer structure
            flacWriterStateDes(outputState)
        }
    }
}

