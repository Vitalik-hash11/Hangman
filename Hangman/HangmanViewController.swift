//
//  ViewController.swift
//  Hangman
//
//  Created by newbie on 29.08.2022.
//

import UIKit

class HangmanViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var usedLettersLabel: UILabel!
    @IBOutlet weak var lifesLabel: UILabel!
    
    private var words = [String]()
    private var level = 0
    private var wordToGuess = ""
    private var promptWord = ""
    private var usedLetters = [String]()
    
    private var lifesCount = 7
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        
        // Loading words from txt file.
        loadLevels()
        // Update lifes indicator
        updateLifeRemaining()
        
    }
    
    private func checkMatches() {
        promptWord = ""
        for char in wordToGuess {
            let letter = String(char).lowercased()
            if usedLetters.contains(String(letter)) {
                promptWord += letter
            } else {
                promptWord += "?"
            }
        }
        self.title = promptWord.uppercased()
        if promptWord.uppercased() == wordToGuess {
            nextLevel(with: "You win!")
        }
    }
    
    private func updateUsedLettersLabel(_ letter: String?) {
        if letter != nil && letter! != "" && !usedLetters.contains(letter!) {
            usedLetters.append(letter!)
            usedLettersLabel.text = usedLettersLabel.text! + " " + letter! + " "
            if !wordToGuess.contains(letter!.uppercased()) {
                lifesCount -= 1
                if lifesCount == 0 {
                    nextLevel(with: "You lose")
                }
            }
        }
    }
    
    private func updateLifeRemaining() {
        var lifesIndicator = "Lifes remain: "
        for _ in 0..<lifesCount {
            lifesIndicator += "❤️"
        }
        lifesLabel.text = lifesIndicator
    }
    
    private func nextLevel(with alertTitle: String) {
        level += 1
        lifesCount = 7
        wordToGuess = words[level].uppercased()
        usedLetters = []
        updateLifeRemaining()
        usedLettersLabel.text = "Used letters:"
        let ac = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Next word", style: .default))
        present(ac, animated: true)
    }
    
    private func loadLevels() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let fileUrl = Bundle.main.url(forResource: "words", withExtension: "txt") {
                if let fileContent = try? String(contentsOf: fileUrl) {
                    self?.words = fileContent.components(separatedBy: "\n")
                    self?.words = (self?.words)!.shuffled()
                    DispatchQueue.main.async {
                        self?.wordToGuess = (self?.words[(self?.level)!].uppercased())!
                        for _ in (self?.wordToGuess)!.indices {
                            if self?.title == nil {
                                self?.title = ""
                            }
                            self?.title! += "?"
                        }
                    }
                } else {
                    fatalError("Cannot load file content")
                }
            } else {
                fatalError("Cannot find words.txt file")
            }
        }
    }


}

extension HangmanViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateUsedLettersLabel(textField.text)
        checkMatches()
        updateLifeRemaining()
        textField.text = ""
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 1
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =  currentString.replacingCharacters(in: range, with: string) as NSString

        return newString.length <= maxLength
    }
}

