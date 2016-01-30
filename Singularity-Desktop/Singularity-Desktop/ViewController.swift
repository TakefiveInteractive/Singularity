//
//  ViewController.swift
//  Singularity-Desktop
//
//  Created by Wang Yu on 1/30/16.
//  Copyright © 2016 Takefive Interactive. All rights reserved.
//

import Cocoa
import Beethoven

class ViewController: NSViewController {
    
    lazy var pitchEngine: PitchEngine = { [unowned self] in
        let pitchEngine = PitchEngine(config: Config(bufferSize: 10000, estimationStrategy: .QuinnsSecond), delegate: self)
            return pitchEngine
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pitchEngine.start()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


// MARK: - PitchEngineDelegate

extension ViewController: PitchEngineDelegate {
    
    func pitchEngineDidRecievePitch(pitchEngine: PitchEngine, pitch: Pitch) {
        print(pitch.frequency)
    }
    
    func pitchEngineDidRecieveError(pitchEngine: PitchEngine, error: ErrorType) {
        print(error)
    }
}
