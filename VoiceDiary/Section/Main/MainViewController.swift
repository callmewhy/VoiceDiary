//
//  ViewController.swift
//  VoiceDiary
//
//  Created by dongyixuan on 16/6/8.
//  Copyright © 2016年 dongyixuan. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore

class MainViewController: UIViewController, UINavigationControllerDelegate{
    let recordTool: RecordTool = RecordTool()
    var recordingSession: AVAudioSession!
    let dbTool = Database()
    
    @IBOutlet weak var calenderView: CalenderView!
    var mood: Mood? = nil
    
    @IBOutlet weak var borderView: BorderView!
    @IBOutlet weak var recordBtn: RecordButton!
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var recordView: UIView!
    @IBOutlet weak var emojiView: UIView!
    @IBOutlet weak var mainpageGreetingView: UIView!
    @IBOutlet weak var emojiGreetingView: UIView!
    @IBOutlet weak var happyBtn: UIButton!
    @IBOutlet weak var nofeelBtn: UIButton!
    @IBOutlet weak var sadBtn: UIButton!
    @IBOutlet weak var completeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Do any additional setup after loading the view, typically from a nib.
        dbTool.createTable()
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { result in
                if (result) {
                    log.verbose("Record Permission ALLOWED")
                } else {
                    log.verbose("Record Permission NOT ALLOWED")
                }
            }
        } catch {
            log.error("Catch recordingSession error")
        }
        let date = NSDate()
        let month = date.getMonthStr()
        let day = date.getDayStr()
        monthLabel.text = month
        dayLabel.text = day
        recordBtn.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBarHidden = true
        emojiView.hidden = true
        emojiGreetingView.hidden = true
        
        navigationController?.delegate = self        
    }

    @IBAction func recordTapped(sender: AnyObject) {
        if(recordTool.audioRecorder == nil){
            recordTool.startRecording()
            recordBtn.currentState = .Recording
            borderView.animate()
            mood = nil
        }else{
            borderView.cancelAnimate()
            recordTool.finishRecording(success: true)
            recordView.hidden = true
            emojiView.hidden = false
            mainpageGreetingView.hidden = true
            emojiGreetingView.hidden = false
        }
        recordBtn.setNeedsDisplay()
    }
    
    @IBAction func happyMood(sender: AnyObject) {
        mood = Mood.Happy
        happyBtn.setTitle("我今天很开心", forState: .Normal)
        completeBtn.enabled = true
    }
    
    @IBAction func noMood(sender: AnyObject) {
        mood = Mood.NoMood
        nofeelBtn.setTitle("我今天不好也不坏", forState: .Normal)
        completeBtn.enabled = true
    }
    
    @IBAction func badMood(sender: AnyObject) {
        mood = Mood.Sad
        sadBtn.setTitle("我今天不开心", forState: .Normal)
        completeBtn.enabled = true
    }
    
    @IBAction func finishRecordBtnPressed(sender: AnyObject) {
        if let mood = mood {
            recordBtn.currentState = .Idle
            recordTool.saveRecordingWithMood(mood)
            recordView.hidden = false
            emojiView.hidden = true
            mainpageGreetingView.hidden = false
            emojiGreetingView.hidden = true
            
            recordBtn.setNeedsDisplay()
            
            // TODO: RELOAD DATA
            for viewItem in self.view.subviews {
                if viewItem is CalenderView {
                    let date = NSDate()
                    let day = date.getDay()
                    let calendarView = viewItem as! CalenderView
                    calendarView.updateRoundedViewColor(day, mood: mood)
                }
            }
        } else {
            let button = sender as! UIButton
            button.enabled = false
            return
        }
                
    }
  
    
    let animatedTransition = CustomerAnimatedTransitionController()
   
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animatedTransition
    }
}

