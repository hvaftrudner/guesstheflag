//
//  ViewController.swift
//  Project 2
//
//  Created by Kristoffer Eriksson on 2020-08-28.
//  Copyright © 2020 Kristoffer Eriksson. All rights reserved.
//
import UserNotifications
import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score: Int = 0
    var highScore: Int = 0
    var correctAnswer: Int = 0
    var total: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        countries += ["estonia", "france", "germany","ireland", "italy", "monaco", "poland", "nigeria", "russia", "spain", "uk", "us"]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(checkScore))
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        let defaults = UserDefaults.standard
        if let savedScore = defaults.value(forKey: "highScore") as? Int {
            self.highScore = savedScore
            print("loaded highscore : \(highScore)")
        } else {
            print("could not load highscore")
        }
        
        askQuestion()
    }
    
    func askQuestion(action: UIAlertAction! = nil){
        
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        title = "Guess -- \(countries[correctAnswer].uppercased()) -- Your score is \(score)"
        
    }

    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        // animation button when pressed
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
        }) { finished in
            sender.transform = .identity
        }
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
            total += 1
            
            
        } else {
            title = "Wrong! That was \(countries[sender.tag])"
            score -= 1
            total += 1
        }
        
       
        
        if total == 10 {
            if score > highScore {
                highScore = score
                save()
                let highScoreAc = UIAlertController(title: "Highscore", message: "NEW High Score! \(highScore) of \(total)", preferredStyle: .alert)
                highScoreAc.addAction(UIAlertAction(title: "Play again?", style: .default, handler: askQuestion))
                present(highScoreAc, animated: true)
                score = 0
                total = 0
                
            } else {
                let newAc = UIAlertController(title: "Finished", message: "10 rounds have been played your score was \(score) out of 10", preferredStyle: .alert)
                newAc.addAction(UIAlertAction(title: "Restart?", style: .default, handler: askQuestion))
                present(newAc, animated: true)
                
                score = 0
                total = 0
            }
            
        } else {
            
            let ac = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
            present(ac, animated: true)
            
        }
        
        
        print(total)
        
        
    }
    @objc func checkScore() {
        
        let vc = UIActivityViewController(activityItems: [String("your score is \(score)")], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func save(){
        let jsonEncoder = JSONEncoder()
        
        if let savedScore = try? jsonEncoder.encode(highScore){
            let defaults = UserDefaults.standard
            defaults.set(savedScore, forKey: "highScore")
        } else {
            print("failed to save score")
        }
    }
    
    //:-- MARK UNnotificationCenter methods
    func registerLocal(){
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) {
            granted, error in
            if granted {
                print("yahooo")
            } else {
                print("noooo")
            }
        }
    }
    
   func scheduleLocal(){
        registerLocal()
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder to play"
        content.body = "This is a reminder that lets you know that you should play everyday"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbizz"]
        content.sound = .default
        
        var dateComponent = DateComponents()
        dateComponent.hour = 10
        dateComponent.minute = 30
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories(){
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "tell me more", options: .foreground)
       
        
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        if let customData = userInfo["customData"] as? String {
            print("Custom data received \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                //user swiped to unlock
                print("default identifier")
                let ac = UIAlertController(title: "swiped", message: "to unlock", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .default) {_ in
                    
                    self.scheduleLocal()
                })
                present(ac, animated: true)
                
            
            default:
                break
            }
        }
        completionHandler()
    }
}

