workspace 'Singularity.xcworkspace'
source 'https://github.com/CocoaPods/Specs.git'
platform :osx, '10.11'
use_frameworks!

xcodeproj 'Singularity-Desktop/Singularity-Desktop.xcodeproj'
pod 'EZAudio', '~> 1.1.4'
pod 'SnapKit'
pod 'PromiseKit'
pod 'MusicKit'

target :GoogleVoiceRecognition do
    xcodeproj 'GoogleVoiceRecognition/GoogleVoiceRecognition.xcodeproj'
    pod 'Alamofire'
    pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
    pod 'PromiseKit'
end

target :Hyphenator do
    xcodeproj 'Hyphenator/Hyphenator.xcodeproj'
    pod 'PySwiftyRegex', '~> 0.2.0'
end

