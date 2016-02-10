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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.snp_makeConstraints {
            $0.width.equalTo(1024)
            $0.height.equalTo(576)
        }
        preferredContentSize = view.fittingSize
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.styleMask = NSClosableWindowMask | NSTitledWindowMask | NSMiniaturizableWindowMask
        effectView = VisualizerView(frame: self.view.bounds)
        effectView.layer?.backgroundColor = NSColor.blackColor().CGColor
        self.view.addSubview(effectView)
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateVisualizationView", userInfo: nil, repeats: true)
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

