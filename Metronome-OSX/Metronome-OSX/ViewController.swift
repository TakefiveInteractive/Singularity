//
//  ViewController.swift
//  Metronome-OSX
//
//  Created by mac on 2/20/16.
//  Copyright © 2016 Yilin Ma. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    
    
    //MARK: Properties
    @IBOutlet weak var BPM_Label: NSTextField!
    @IBOutlet weak var BPM_Textfield: NSTextField!
    @IBOutlet weak var BPM_Update_Button: NSButton!
   
    var ticksound : AVAudioPlayer?
    var ticktimer : NSTimer!

    //MARK: Functions
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
     
        //1
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        
        //2
        var audioPlayer:AVAudioPlayer?
        
        //3
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
    }
    
    
    
    func tick() {
        
        ticksound?.play()
        //print("tickkkkkk")
        
    }
    
    
    func Metronome_stop() {
        
        self.ticktimer.invalidate()

    }


    override func viewDidLoad() {
     
        if let ticksound = self.setupAudioPlayerWithFile("Metromf", type:"mp3") {
            self.ticksound = ticksound
            }
        BPM_Textfield.stringValue = "96"
        let BPM = (BPM_Textfield.intValue)
        //BPM_Label.text = "BPM=\(BPM)"
        let BPM_Interval = 60.0/Float(BPM)
        ticktimer = NSTimer.scheduledTimerWithTimeInterval(Double(BPM_Interval), target: self, selector: "tick", userInfo: nil, repeats: true)

        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

   
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
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

