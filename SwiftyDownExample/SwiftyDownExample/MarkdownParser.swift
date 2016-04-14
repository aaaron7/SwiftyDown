//
//  MarkdownParser.swift
//  SwiftyDown
//
//  Created by aaaron7 on 16/4/13.
//  Copyright © 2016年 aaaron7. All rights reserved.
//

import Foundation
import UIKit

class MarkdownParser{
    
    let reserved = "`*#[("
    var markdown : Parser<Markdown>?
    init(){
        setup()
    }
    
    func setup(){
        markdown = ita() +++ bold() +++ inlineCode() +++ header() +++ links() +++ plain()
            +++ refer()
            +++ newline() +++ fakeNewline()
    }
    
    func header()->Parser<Markdown>{
        return many1loop(parserChar("#")) >>= { cs in
            line() >>= { str in
                var tmds = self.pureStringParse(str)
                tmds.append(.Plain("\n"))
                return pure(.Header(cs.count,tmds))
            }
        }
    }

    func ita() -> Parser<Markdown>{
        return pair("*") >>= { str in
            let mds = self.pureStringParse(str)
            return pure(.Ita(mds))
        }
    }

    func bold() -> Parser<Markdown>{
        return pair("**") >>= { str in
            let mds = self.pureStringParse(str)
            return pure(.Bold(mds))
        }
    }

    func inlineCode() -> Parser<Markdown>{
        return pair("`") >>= { str in
            let mds = self.pureStringParse(str)
            return pure(.InlineCode(mds))
        }
    }

    func links() -> Parser<Markdown>{
        return pair("[", sepa2: "]") >>= { str in
            pair("(", sepa2: ")") >>= { str1 in
                let mds = self.pureStringParse(str)
                return pure(.Links(mds,str1))

            }
        }
    }

    func markdownNewLineBreak()->Parser<String>{
        let p = trimedSatisfy(isNewLine)
        return p >>= { _ in
            many1loop(p) >>= { _ in
                pure("\n")
            }
        }
    }
    
    func newline() -> Parser<Markdown>{
        return markdownNewLineBreak() >>= { str in
            pure(.Plain(str))
        }
    }
    
    func fakeNewline() -> Parser<Markdown>{
        return trimedSatisfy(isNewLine) >>= { _ in
            pure(.Plain(" "))
        }
    }
    
    func markdownLineStr() ->Parser<String>{
        return Parser{ str in
            var result = ""
            var rest = str
            while(true){
                var temp = lineStr().p(rest)
                guard temp.count > 0 else{
                    result.append(rest[rest.startIndex])
                    rest = String(rest.characters.dropFirst())
                    continue
                }
                
                result += temp[0].0
                rest = temp[0].1
                
                let linebreaks = self.markdownNewLineBreak().p(temp[0].1)
                if linebreaks.count > 0{
                    break
                }else{
                    continue
                }
            }
            
            return [(result,rest)]
        }
    }

    func plain() -> Parser<Markdown>{
        func pred(c : Character) -> Bool{
            
            if reserved.characters.indexOf(c) != nil{
                return false
            }
            return isNotNewLine(c)
        }

        return many1loop(satisfy(pred)) >>= { cs in
            pure(.Plain(String(cs)))
        }
    }
    
    func pureStringParse(string : String) -> [Markdown]{
        print("begin nesting : \(string)")
        let result = self.markdowns().p(string)
        if result.count > 0 {
            return result[0].0
        }else{
            return []
        }
    }
    
    func refer() -> Parser<Markdown>{
        return newline() >>= { _ in
            space(false) >>= { _ in
                symbol("> ") >>= { _ in
                    self.markdownLineStr() >>= { str in
                        let mds = self.pureStringParse(str)
                        return pure(.Refer(mds))
                    }
                }
            }
        }
    }

    func markdowns() -> Parser<[Markdown]>{
        let m = space(false) >>= {_ in self.markdown!}
        let mm = many1loop(m)
        return Parser{ str in
            print(str)
            return mm.p(str)
        }
    }
}

extension MarkdownParser{
    func render(arr : [Markdown]) -> NSAttributedString{
        return renderHelper(arr, parentAttribute: nil)
    }
    
    func renderHelper(arr : [Markdown], parentAttribute : [String : AnyObject]?) -> NSAttributedString{
        let attributedString : NSMutableAttributedString = NSMutableAttributedString()


        
        for m in arr{
            
            var baseAttribute:[String : AnyObject] = [:]
            
            if let _ = parentAttribute{
                for att in parentAttribute!{
                    baseAttribute[att.0] = att.1
                }
            }
            
            switch m{
            case .Bold(let mds):
                var tAttr:[String:AnyObject] = baseAttribute
                tAttr[NSFontAttributeName] = UIFont.boldSystemFontOfSize(18)

                let subAttrString = renderHelper(mds, parentAttribute: tAttr)
                attributedString.appendAttributedString(subAttrString)
 
            case .Ita(let mds):
                var tAttr:[String:AnyObject] = baseAttribute
                tAttr[NSFontAttributeName] =  UIFont.italicSystemFontOfSize(17)
                let subAttrString = renderHelper(mds, parentAttribute: tAttr)

                attributedString.appendAttributedString(subAttrString)
            case .Header(let level, let mds):
                let fontSize = 18 + (6 - level)
                var tAttr:[String:AnyObject] = baseAttribute
                tAttr[NSFontAttributeName] =  UIFont.boldSystemFontOfSize(CGFloat(fontSize))
                
                let subAttrString = renderHelper(mds, parentAttribute: tAttr)
                attributedString.appendAttributedString(subAttrString)

            case .InlineCode(let mds):
                
                var tAttr:[String:AnyObject] = baseAttribute
                
                tAttr[NSFontAttributeName] = UIFont.systemFontOfSize(16)
                tAttr[NSBackgroundColorAttributeName] = hexColor(0xdddddd)

                let subAttrString = renderHelper(mds, parentAttribute: tAttr)

                attributedString.appendAttributedString(subAttrString)
            case .Links(let mds, let links):
                var tAttr:[String:AnyObject] = baseAttribute

                tAttr[NSLinkAttributeName] = links
                tAttr[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
                tAttr[NSForegroundColorAttributeName] = UIColor.blueColor()
                let subAttrString = renderHelper(mds, parentAttribute: tAttr)

                attributedString.appendAttributedString(subAttrString)
            case .Plain(let str):
                if baseAttribute[NSFontAttributeName] == nil{
                    baseAttribute[NSFontAttributeName] = UIFont.systemFontOfSize(17)
                }
                
                attributedString.appendAttributedString(NSAttributedString(string: str, attributes: baseAttribute))
            case .Refer(let mds):
                var tAttr:[String:AnyObject] = baseAttribute
                tAttr[NSBackgroundColorAttributeName] = hexColor(0xeff5fe)
                let subAttrString = renderHelper(mds, parentAttribute: tAttr)
                attributedString.appendAttributedString(subAttrString)
            default:
                break
            }
        }
        
        return attributedString
    }
    
    func hexColor(value : Int) -> UIColor{
        return UIColor(red: CGFloat((value & 0xFF0000) >> 16) / 255.0, green: CGFloat((value & 0xFF00) >> 8)/255.0, blue: CGFloat(value & 0xFF)/255.0, alpha: 1.0)
        
    }
}

