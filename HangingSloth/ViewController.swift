//
//  ViewController.swift
//  HangingSloth
//
//  Created by Rodrigo Cavalcanti on 27/04/24.
//

import UIKit

class ViewController: UIViewController {
    let remaining = UILabel()
    var slothImageView = UIImageView(image: #imageLiteral(resourceName: "sloth.png"))
    let guessWord = UILabel()
    let hints = UILabel()
    var letters = [UIButton]()
    
    var answer: Answer?
    var hintsRevealed = 0
    var mistakesRemaining = 7 {
        didSet {
            remaining.text = "Mistakes remaining: \(mistakesRemaining)"
            slothImageView.layer.opacity = (Float(mistakesRemaining) * 15) / 100
        }
    }
    var guess = "" {
        didSet {
            guessWord.text = guess
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLevel()
        setupConstraints()
    }
    
    func setupConstraints() {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        title.text = "Don't let the sloth get away!"
        title.textColor = .brown
        title.sizeToFit()
        view.addSubview(title)
        
        remaining.translatesAutoresizingMaskIntoConstraints = false
        remaining.font = UIFont.preferredFont(forTextStyle: .body)
        remaining.text = "Mistakes remaining: \(mistakesRemaining)"
        remaining.textColor = .secondaryLabel
        remaining.sizeToFit()
        view.addSubview(remaining)
        
        slothImageView.contentMode = .scaleAspectFit
        slothImageView.translatesAutoresizingMaskIntoConstraints = false
        slothImageView.setContentCompressionResistancePriority(.init(2), for: .vertical)
        view.addSubview(slothImageView)
        
        guessWord.translatesAutoresizingMaskIntoConstraints = false
        guessWord.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        guessWord.addCharactersSpacing(10)
        guessWord.textColor = .brown
        guessWord.sizeToFit()
        view.addSubview(guessWord)
        
        hints.translatesAutoresizingMaskIntoConstraints = false
        hints.font = UIFont.preferredFont(forTextStyle: .body)
        hints.numberOfLines = 0
        hints.sizeToFit()
        hints.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(hints)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(buttonsView)
        
        letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map {
            let letterButton = UIButton(type: .system)
            letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            
            // give the button some temporary so we can see it on-screen
            letterButton.setTitle(String($0), for: .normal)
            letterButton.setTitleColor(.brown, for: .normal)
            letterButton.layer.borderColor = UIColor.secondaryLabel.cgColor
            letterButton.layer.borderWidth = 1
            letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
            letterButton.translatesAutoresizingMaskIntoConstraints = false
            
            buttonsView.addSubview(letterButton)
            
            return letterButton
        }
        
        var letterIndex = 0
        
        for row in 0...2 {
            for col in 0...8 {
                
                if row == 2 && col == 8 {
                    break
                }
                
                let currentLetter = letters[letterIndex]
                lazy var previousLetter = letters[letterIndex - 1]
                
                if col == 0 {
                    currentLetter.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor).isActive = true
                } else {
                    currentLetter.leadingAnchor.constraint(equalTo: previousLetter.trailingAnchor).isActive = true
                }
                
                if col == 8 {
                    currentLetter.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor).isActive = true
                }
                
                if row == 0 {
                    currentLetter.topAnchor.constraint(equalTo: buttonsView.topAnchor).isActive = true
                } else {
                    let previousRow = row - 1
                    let firstLetter = previousRow * 9
                    let letterAbove = letters[firstLetter]
                    currentLetter.topAnchor.constraint(equalTo: letterAbove.bottomAnchor).isActive = true
                }
                
                if letterIndex != 0 {
                    currentLetter.widthAnchor.constraint(equalTo: previousLetter.widthAnchor).isActive = true
                }
                
                letterIndex += 1
            }
        }
        
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            title.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            
            remaining.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            remaining.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            
            slothImageView.topAnchor.constraint(equalTo: remaining.bottomAnchor, constant: 8),
            slothImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            slothImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 250),
            
            guessWord.topAnchor.constraint(equalTo: slothImageView.bottomAnchor, constant: 8),
            guessWord.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            
            hints.topAnchor.constraint(equalTo: guessWord.bottomAnchor, constant: 8),
            hints.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            hints.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            buttonsView.topAnchor.constraint(equalTo: hints.bottomAnchor, constant: 8),
            buttonsView.heightAnchor.constraint(equalToConstant: 125),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20),
            buttonsView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
        ])
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        guard let text = sender.titleLabel?.text else { return }
        
        let answerLettersArray = answer?.word.map({ String($0) })
        let letterIndices = answerLettersArray?.enumerated().compactMap {
            $0.element == text ? $0.offset : nil
        }
        
        
        if let letterIndices, !letterIndices.isEmpty {
            var guessWordArray = guess.map { String($0) }
            for index in letterIndices {
                guessWordArray[index] = text
            }
            guess = guessWordArray.joined()
        } else {
            mistakesRemaining -= 1
            if mistakesRemaining > 0 && mistakesRemaining % 2 == 0 {
                revealHint()
            }
        }
        
        sender.isHidden = true
        
        if mistakesRemaining == 0 {
            let ac = UIAlertController(
                title: "The sloth got away!",
                message: "The answer was \(answer?.word ?? "")",
                preferredStyle: .alert
            )
            ac.view.tintColor = .brown
            ac.addAction(UIAlertAction(title: "Try again", style: .default, handler: loadLevel))
            present(ac, animated: true)
        }
        
        if answer?.word == guess {
            let ac = UIAlertController(
                title: "\(answer?.word ?? "")",
                message: "You guessed it! Hooray!",
                preferredStyle: .alert
            )
            ac.view.tintColor = .brown
            ac.addAction(UIAlertAction(title: "Next challenge", style: .default, handler: loadLevel))
            present(ac, animated: true)
        }
    }
    
    func loadLevel(_ action: UIAlertAction = UIAlertAction()) {
        hintsRevealed = 0
        mistakesRemaining = 7
        for letter in letters {
            letter.isHidden = false
        }
        guard let newAnswer = Answer.all.randomElement() else { return }
        answer = newAnswer
        guess = newAnswer.word.map { _ in
            "_"
        }.joined()
        
        let enumeratedHints = newAnswer.enumeratedHints.joined(separator: "\n")
        
        let rangeOfColoredString = (newAnswer.fullHint as NSString).range(of: enumeratedHints)
        
        // Create the attributedString.
        let attributedString = NSMutableAttributedString(string: newAnswer.fullHint)
        attributedString.setAttributes(
            [
                NSAttributedString.Key.backgroundColor: UIColor.quaternaryLabel,
                NSAttributedString.Key.foregroundColor: UIColor.clear
            ],
            range: rangeOfColoredString
        )
        
        hints.attributedText = attributedString
    }
    
    func revealHint() {
        let attributedString = hints.attributedText?.mutableCopy() as! NSMutableAttributedString
        let fullHint = answer?.fullHint ?? ""
        let hintRange = answer?.enumeratedHints[hintsRevealed]
        let rangeOfColoredString = (fullHint as NSString).range(of: hintRange ?? "")
        
        attributedString.setAttributes(
            [
                NSAttributedString.Key.backgroundColor: UIColor.clear,
                NSAttributedString.Key.foregroundColor: UIColor.label
            ],
            range: rangeOfColoredString
        )
        
        hints.attributedText = attributedString
        hintsRevealed += 1
    }
    
}
