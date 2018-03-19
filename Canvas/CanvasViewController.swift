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
    
    @IBOutlet weak var downArrow: UIImageView!
    
    var newlyCreatedFace: UIImageView!
    var newlyCreatedFaceOriginalCenter: CGPoint!
    
    var panGesture : UIPanGestureRecognizer!
    var pinchGesture : UIPinchGestureRecognizer!
    var rotateGesture : UIRotationGestureRecognizer!
    var twoTapGesture : UITapGestureRecognizer!
    
    var currentRotation : CGFloat!
    var currentScale : CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentScale = 0.0
        currentRotation = 0.0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Do any additional setup after loading the view, typically from a nib.
        //print("og x pos: \(trayView.center.x)")
        trayDownOffset = 155
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
            let velocity = sender.velocity(in: view)
            if velocity.y > 0 {
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
                    self.trayView.center = self.trayDown
                    self.downArrow.transform = CGAffineTransform(rotationAngle: 3.14)
                }, completion: nil)
            }
            else{
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
                    self.trayView.center = self.trayUp
                    self.downArrow.transform = CGAffineTransform(rotationAngle: 0)
                }, completion: nil)
            }
        }
    }
    @IBAction func didPanFace(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        if sender.state == .began{
            let imageView = sender.view as! UIImageView
            newlyCreatedFace = UIImageView(image: imageView.image)
            view.addSubview(newlyCreatedFace)
            newlyCreatedFace.center = imageView.center
            newlyCreatedFace.center.y += trayView.frame.origin.y
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center
            
            UIView.animate(withDuration: 0.125, animations: {
                self.newlyCreatedFace.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
            })
            
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(CanvasViewController.imageDragged(_:)))
            pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(CanvasViewController.imagePinched(_:)))
            rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(CanvasViewController.imageRotated(_:)))
            twoTapGesture = UITapGestureRecognizer(target: self, action: #selector(CanvasViewController.imageTwoTapped(_:)))
            twoTapGesture.numberOfTapsRequired = 2
            
            newlyCreatedFace.isUserInteractionEnabled = true
            newlyCreatedFace.addGestureRecognizer(panGesture)
            newlyCreatedFace.addGestureRecognizer(pinchGesture)
            newlyCreatedFace.addGestureRecognizer(rotateGesture)
            newlyCreatedFace.addGestureRecognizer(twoTapGesture)
        }
        
        else if sender.state == .changed{
            newlyCreatedFace.center = CGPoint(x: newlyCreatedFaceOriginalCenter.x + translation.x, y: newlyCreatedFaceOriginalCenter.y + translation.y)
        }
        
        else if sender.state == .ended{
            if(self.trayView.frame.contains(self.newlyCreatedFace.center)){
                UIView.animate(withDuration: 0.5, animations: {
                    var t = CGAffineTransform.identity
                    t = t.scaledBy(x: 1, y: 1)
                    self.newlyCreatedFace.center = CGPoint(x: self.newlyCreatedFaceOriginalCenter.x, y: self.newlyCreatedFaceOriginalCenter.y)
                    self.newlyCreatedFace.transform = t
                }, completion: { (done) in
                    self.newlyCreatedFace.removeFromSuperview()
                })
            }
            else{
                UIView.animate(withDuration: 0.125, animations: {
                    self.newlyCreatedFace.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
            }
        }
    }
    
    @objc func imageTwoTapped(_ sender: UITapGestureRecognizer){
        sender.view?.removeFromSuperview()
    }
    
    @objc func imageDragged(_ sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: view)
        
        if sender.state == .began{
            newlyCreatedFace = sender.view as! UIImageView // to get the face that we panned on.
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center // so we can offset by translation later.
        }
        
        else if sender.state == .changed{
            newlyCreatedFace.center = CGPoint(x: newlyCreatedFaceOriginalCenter.x + translation.x, y: newlyCreatedFaceOriginalCenter.y + translation.y)
        }
    }
    
    @objc func imagePinched(_ sender:UIPinchGestureRecognizer){
        let scale = sender.scale
        let imageView = sender.view as! UIImageView
        var t = CGAffineTransform.identity
        
        if sender.state == .began{
            
        }
        
        else if sender.state == .changed{
            if scale >= 1{
               t = t.scaledBy(x: scale, y: scale)
            }
            t = t.rotated(by: self.currentRotation)
            imageView.transform = t
        }
        
        else if sender.state == .ended{
            self.currentScale = sender.scale
            sender.scale = 1
        }
    }
    
    @objc func imageRotated(_ sender:UIRotationGestureRecognizer){
        let rotation = sender.rotation
        let imageView = sender.view as! UIImageView
        var t = CGAffineTransform.identity
        
        if sender.state == .began{
           
        }
        
        else if sender.state == .changed{
            t = t.scaledBy(x: self.currentScale, y: self.currentScale)
            t = t.rotated(by: rotation)
            imageView.transform = t
        }
        
        else if sender.state == .ended{
            self.currentRotation = rotation
            sender.rotation = 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

