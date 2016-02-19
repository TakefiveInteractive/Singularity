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
        
        self.headerView.shadow = NSShadow()
        self.headerView.alphaValue = 0.7
        self.headerView.layer?.shadowOpacity = 0.7
        self.headerView.layer?.shadowColor = NSColor.blackColor().CGColor
        self.headerView.layer?.shadowOffset = NSMakeSize(0, 0)
        self.headerView.layer?.shadowRadius = 3
        self.headerView.layer?.backgroundColor = Palette.windowColor
        
        self.footerView.shadow = NSShadow()
        self.footerView.alphaValue = 0.7
        self.footerView.layer?.shadowOpacity = 0.7
        self.footerView.layer?.shadowColor = NSColor.blackColor().CGColor
        self.footerView.layer?.shadowOffset = NSMakeSize(0, 0)
        self.footerView.layer?.shadowRadius = 3
        self.footerView.layer?.backgroundColor = Palette.windowColor
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

