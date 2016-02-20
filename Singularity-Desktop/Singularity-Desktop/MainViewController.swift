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
    var fft: FFT!
    
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
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateVisualizationView", userInfo: nil, repeats: true)
        
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
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        
        fft = FFT()
        fft.start()
    }

    func updateVisualizationView() {
        effectView.update(Double(Double(rand() % 100) / 30.0))
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

