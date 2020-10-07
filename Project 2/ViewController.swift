//
//  ViewController.swift
//  Project 2
//
//  Created by Kristoffer Eriksson on 2020-08-28.
//  Copyright © 2020 Kristoffer Eriksson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
            total += 1
            
            
        } else {
            title = "Wrong! That was \(countries[sender.tag])"
            score -= 1
            total += 1
        }
        
        if score < highScore {
//
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
}

