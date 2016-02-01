workspace 'Singularity.xcworkspace'
source 'https://github.com/CocoaPods/Specs.git'
platform :osx, '10.11'
use_frameworks!

xcodeproj 'Singularity-Desktop/Singularity-Desktop.xcodeproj'

target :GoogleVoiceRecognition do
    xcodeproj 'GoogleVoiceRecognition/GoogleVoiceRecognition.xcodeproj'
    pod 'SwiftHTTP', '~> 1.0.3'
    pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
    pod "PromiseKit", "~> 3.0"
end
