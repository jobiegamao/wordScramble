//
//  ContentView.swift
//  wordScramble
//
//  Created by may on 11/15/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
   
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var Score = 0


    var body: some View {
        NavigationView{
            List{
                Section{
                    TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                        //text save in $newWord
                        // on enter/commit go to function addNewWord
                        .autocapitalization(.none)
                }
                
                Section{
                    // section for words typed list
                    // loops thru usedWords array
                    ForEach(usedWords, id: \.self){
                        word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            // icon before word
                            Text(word)
                        }
                        
                    }
                }
            } // end of List
            
            //at the end, write navigation view add ons
            .navigationTitle(rootWord)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: {self.startGame() }, label: { Text("Restart") } )

                }
                ToolbarItem(placement: .navigationBarLeading){
                    Text("Score: \(Score)")
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing, 16.0)
                }

            }
            
        } //end of nav view
        
        // on load of App
        .onAppear(perform: startGame)
        
        .alert(errorTitle, isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    func startGame(){
        // reset
        Score = 0
        usedWords.removeAll()
        
        // 1. Find the URL for start.txt in our app bundle
            if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
                // 2. Load start.txt into a string
                if let startWords = try? String(contentsOf: startWordsURL) {
                    // 3. Split the string up into an array of strings, splitting on line breaks
                    let allWords = startWords.components(separatedBy: "\n")

                    // 4. Pick one random word, or use "word" as a sensible default
                    rootWord = allWords.randomElement() ?? "word"

                    // If we are here everything has worked, so we can exit
                    return
                }
            }

            // else if start.txt is not found
            fatalError("Could not load start.txt from bundle.")
        
        //notes
        // we use if let variable = try? so we can make a variable even if it does not exist.
    }

    func addNewWord(){
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        
       // exit if the remaining string is empty
        guard answer.count > 2  else {
            return
        }
        
        guard answer != rootWord else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        
        //update score
        addScore(word: answer)
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
        
        
        
        //note: guard when true goes in function
    }
    
    // --- Word Checker Methods --- //
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        //checker if the input is made up of the rootWord letters
        
        // put rootWord var in temp as we need to remove letters slowly if the
        // input has that letter
        var temp = rootWord
        
        // every letter in WORD will be matched to rootword's letters
        // .firstIndex(of: ) will return index of first appearance of the iterated letter from words
        // if that letter is found in the rootWord, it will save index and
        // tempWord.remove(at: int INDEX) will remove that index
        for letter in word {
            if let pos = temp.firstIndex(of: letter){
                temp.remove(at: pos)
            }else {
                //if there is no letter in input from rootWord
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func addScore(word: String){
        Score += word.count

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
