//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

struct Parser<a>{
    let p : String -> [(a,String)]

}
func until(word : String, terminator : (Character -> Bool) = {_ in false}) -> Parser<String>{
    return Parser{ x in
        var str = x
        var result = ""
        var endIdx = 0
        while(true){
            if endIdx >= str.characters.count{
                break
            }
            let curIndex = str.characters.startIndex.advancedBy(endIdx)
            let curc = str[curIndex]
            if terminator(curc){
                return []
            }else if curc != word.characters.first!{
                endIdx += 1
            }else{
                var startIdx = endIdx + 1
                var wordIdx = 1
                while(startIdx < str.characters.count &&
                    wordIdx < word.characters.count &&
                    str[str.startIndex.advancedBy(startIdx)] == word[word.startIndex.advancedBy(wordIdx)]
                    ){
                        startIdx += 1
                        wordIdx += 1
                }

                if wordIdx == word.characters.count {
                    break
                }else{
                    endIdx += 1
                }
            }
        }
        result = str.substringToIndex(str.startIndex.advancedBy(endIdx))
        str = str.substringFromIndex(str.startIndex.advancedBy(endIdx))
        return [(result,str)]
    }
}

func lineUntil(word : String) -> Parser<String>{
    return until(word, terminator: { (c) -> Bool in
        c == "\n"
    })
}
until("test3").p("swfwefiuhuitest3fewef")
lineUntil("test3").p("swfwefiuhuitest3fewef")
