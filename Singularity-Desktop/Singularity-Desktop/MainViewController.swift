//
//  ViewController.swift
//  Singularity-Desktop
//
//  Created by Wang Yu on 1/30/16.
//  Copyright © 2016 Takefive Interactive. All rights reserved.
//

import Cocoa
import Beethoven

class MainViewController: NSViewController {
    
    lazy var pitchEngine: PitchEngine = { [unowned self] in
        let pitchEngine = PitchEngine(config: Config(bufferSize: 16000, estimationStrategy: .QuinnsSecond), delegate: self)
            return pitchEngine
        }()
    
    var effectView: VisualizerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pitchEngine.start()

    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        effectView = VisualizerView(frame: self.view.bounds)
        effectView.layer?.backgroundColor = NSColor.blackColor().CGColor
//        effectView.update(0.5)
        self.view.addSubview(effectView)
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "update", userInfo: nil, repeats: true)
    }

    func update() {
        effectView.update(Double(Double(rand() % 100) / 30.0))
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


// MARK: - PitchEngineDelegate

extension MainViewController: PitchEngineDelegate {
    
    func pitchEngineDidRecievePitch(pitchEngine: PitchEngine, pitch: Pitch) {
        print(pitch.frequency)
    }
    
    func pitchEngineDidRecieveError(pitchEngine: PitchEngine, error: ErrorType) {
        print(error)
    }
}
