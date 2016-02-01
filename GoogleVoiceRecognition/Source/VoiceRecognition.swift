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
    case EncodingFailure
}

private let voiceEncodingQueue = dispatch_queue_create("voice-worker", DISPATCH_QUEUE_CONCURRENT)

class VoiceRecognition {
    
    /// Converts a piece of 16-bit single channel PCM audio to string
    class func recognize(audio: AVAudioPCMBuffer, atTime: AVAudioTime, lang: VoiceLanguages = .English) -> Promise<String> {
        return recognize(audio, sampleRate: Int(atTime.sampleRate), lang: lang)
    }
    
    /// Converts a piece of 16-bit single channel PCM audio to string
    class func recognize(audio: AVAudioPCMBuffer, sampleRate: Int, lang: VoiceLanguages = .English) -> Promise<String> {
        return dispatch_promise(on: voiceEncodingQueue, body: { () -> NSData in
            guard  sampleRate == 44100
                || sampleRate == 48000 else {
                    throw VoiceRecognitionError.InvalidSampleRate
            }
            // Encode PCM into FLAC
            let outputState = FLAC__encodeSingle16bit(audio.int16ChannelData.memory, UInt32(sampleRate), audio.frameLength)
            guard outputState.memory.success else { throw VoiceRecognitionError.EncodingFailure }
            
            let data = NSData(bytes: outputState.memory.data, length: outputState.memory.pointer)
            // Free the writer structure
            flacWriterStateDes(outputState)
            return data
        })
        .then({ data in
            return Promise { resolve, reject in
                let url = "https://www.google.com/speech-api/v2/recognize?output=json&lang=\(lang.rawValue)&key=\(VoiceApiKeys[Int(arc4random_uniform(UInt32(VoiceApiKeys.count)))])&app=Singularity"
                
                Alamofire.upload(.POST, url, headers: ["Content-Type": "audio/x-flac; rate=\(sampleRate);"], data: data)
                .responseString { response in
                    guard response.result.isSuccess else { reject(VoiceRecognitionError.ApiFailure); return }
                    
                    let choufengResult = response.result.value!
                    var goodResult = ""
                    if choufengResult.substringToIndex(choufengResult.startIndex.advancedBy(13)) == "{\"result\":[]}"
                        && choufengResult.characters.count > 14 {
                            goodResult = choufengResult.substringFromIndex(choufengResult.startIndex.advancedBy(14))
                    } else {
                        goodResult = choufengResult
                    }
                    
                    let result = JSON.parse(goodResult)["result"]
                    if result.count == 0 {
                        reject(VoiceRecognitionError.ApiFailure)
                    } else {
                        if let trans = result[0]["alternative"][0]["transcript"].string {
                            resolve(trans)
                        } else {
                            reject(VoiceRecognitionError.ApiFailure)
                        }
                    }
                }
            }
        })
    }
}

