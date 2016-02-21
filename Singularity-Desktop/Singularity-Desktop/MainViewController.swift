//
//  ViewController.swift
//  Singularity-Desktop
//
//  Created by Wang Yu on 1/30/16.
//  Copyright © 2016 Takefive Interactive. All rights reserved.
//

import Cocoa
import SnapKit

class MainViewController: NSViewController {
    
    var effectView: VisualizerView!
    @IBOutlet weak var headerView: NSView!
    @IBOutlet weak var backView: NSView!
    @IBOutlet weak var footerView: NSView!
    @IBOutlet weak var recordButtonFrame: NSView!
    @IBOutlet weak var recordButtonClickArea: NSButton!
    var engine: PitchEngine!
    @IBOutlet weak var recordImageButton: NSButton!
    
    @IBOutlet weak var BPM_Label: NSTextField!
    @IBOutlet weak var BPM_Textfield: NSTextField!
    @IBOutlet weak var BPM_Update_Button: NSButton!
    var visualTimer: NSTimer!
    
    
    var BPM: Int32 { return (BPM_Textfield.intValue) }
    var playOn: Bool = false {
        didSet {
            if playOn == true {
                recordImageButton.image = NSImage(named: "pause_icon@2x.png")
                let BPM_Interval = 60.0/Float(BPM)
                ticktimer = NSTimer.scheduledTimerWithTimeInterval(Double(BPM_Interval), target: self, selector: "tick", userInfo: nil, repeats: true)
                visualTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateVisualizationView", userInfo: nil, repeats: true)

            } else {
                recordImageButton.image = NSImage(named: "record_icon@2x.png")
                ticktimer.invalidate()
                visualTimer.invalidate()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.snp_makeConstraints {
            $0.width.equalTo(1024)
            $0.height.equalTo(576)
        }
        preferredContentSize = view.fittingSize
        
        self.view.window?.styleMask = NSClosableWindowMask | NSTitledWindowMask | NSMiniaturizableWindowMask
        effectView = VisualizerView(frame: self.view.bounds)
        effectView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
        effectView.layer?.backgroundColor = Palette.blurBackColor
        self.backView.addSubview(effectView)
        
        let blurView = NSVisualEffectView(frame: self.view.bounds)
        blurView.blendingMode = NSVisualEffectBlendingMode.WithinWindow
        blurView.material = NSVisualEffectMaterial.Light
        self.backView.addSubview(blurView)
        
        self.view.wantsLayer = true
        self.view.superview?.wantsLayer = true
        self.headerView.wantsLayer = true
        
        let setShadow: NSView -> Void = {
            $0.shadow = NSShadow()
            $0.alphaValue = 0.9
            $0.layer?.shadowOpacity = 0.7
            $0.layer?.shadowColor = NSColor.blackColor().CGColor
            $0.layer?.shadowOffset = NSMakeSize(0, 0)
            $0.layer?.shadowRadius = 3
            $0.layer?.backgroundColor = Palette.windowColor
        }
        
        setShadow(headerView)
        setShadow(footerView)
        
        recordButtonFrame.layer?.cornerRadius = recordButtonFrame.bounds.width / 2
        recordButtonFrame.layer?.borderWidth = 2
        recordButtonFrame.layer?.borderColor = NSColor.whiteColor().CGColor
        
        if let ticksound = self.setupAudioPlayerWithFile("Metromf", type:"mp3") {
            self.ticksound = ticksound
        }
        BPM_Textfield.stringValue = "96"

        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        engine = PitchEngine()
        engine.start(100)
    }

    func updateVisualizationView() {
        effectView.update(Double(Double(rand() % 100) / 30.0))
    }
    
    @IBAction func recordButtonDidClicked(sender: NSButton) {
        playOn = !playOn
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
  
    var ticksound : AVAudioPlayer?
    var ticktimer : NSTimer!
    
    //MARK: Functions
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
        
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        
        var audioPlayer:AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        return audioPlayer
    }
    
    func tick() {
        ticksound?.play()
    }
    
    
    func Metronome_stop() {
        self.ticktimer.invalidate()
    }
    
    //Actions:
    @IBAction func Update_BPM(sender: AnyObject) {
        let BPM = BPM_Textfield.intValue
        //BPM_Label.text = "BPM=\(BPM)"
        self.ticktimer.invalidate()
        let BPM_Interval = 60.0/Float(BPM)
        ticktimer    = NSTimer.scheduledTimerWithTimeInterval(Double(BPM_Interval), target: self, selector: "tick", userInfo: nil, repeats: true)
    }


}

