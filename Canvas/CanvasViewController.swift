//
//  ViewController.swift
//  Canvas
//
//  Created by Samuel on 3/13/18.
//  Copyright © 2018 Samuel. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController {

    @IBOutlet weak var trayView: UIView!
    var trayOriginalCenter : CGPoint!
    var trayDownOffset: CGFloat!
    var trayUp: CGPoint!
    var trayDown: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Do any additional setup after loading the view, typically from a nib.
        //print("og x pos: \(trayView.center.x)")
        trayDownOffset = 160
        trayUp = trayView.center // The initial position of the tray
        trayDown = CGPoint(x: trayView.center.x ,y: trayView.center.y + trayDownOffset) // The position of the tray transposed down
    }
    
    @IBAction func didPanTray(_ sender: UIPanGestureRecognizer) {
        let translate = sender.translation(in: trayView)
        if sender.state == .began{
            self.trayOriginalCenter = trayView.center
        }
        else if sender.state == .changed{
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translate.y)
        }
        
        else if sender.state == .ended{
            let velocity = sender.velocity(in: self.trayView)
            if velocity.y > 0 {
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
                    self.trayView.center = self.trayDown
                }, completion: nil)
            }
            else{
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
                    self.trayView.center = self.trayUp
                }, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

