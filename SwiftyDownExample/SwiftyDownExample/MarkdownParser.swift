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
    func header()->Parser<Markdown>{
        return many1loop(parserChar("#")) >>= { cs in
            line() >>= { str in
                pure(.Header(cs.count,str + "\n"))
            }
        }
    }

    func ita() -> Parser<Markdown>{
        return pair("*") >>= { str in
            pure(.Ita(str))
        }
    }

    func bold() -> Parser<Markdown>{
        return pair("**") >>= { str in
            pure(.Bold(str))
        }
    }

    func inlineCode() -> Parser<Markdown>{
        return pair("`") >>= { str in
            pure(.InlineCode(str))
        }
    }

    func links() -> Parser<Markdown>{
        return pair("[", sepa2: "]") >>= { str in
            pair("(", sepa2: ")") >>= { str1 in
                pure(.Links(str,str1))
            }
        }
    }

    func newline() -> Parser<Markdown>{
        let p = trimedSatisfy(isNewLine)
        return p >>= { _ in
            many1loop(p) >>= { _ in
                pure(.Plain("\n"))
            }
        }
    }
    
    func fakeNewline() -> Parser<Markdown>{
        return trimedSatisfy(isNewLine) >>= { _ in
            pure(.Plain(" "))
        }
    }

    func plain() -> Parser<Markdown>{
        func pred(c : Character) -> Bool{
            let allStr = "`*#[("
            if allStr.characters.indexOf(c) != nil{
                return false
            }
            return isNotNewLine(c)
        }

        return many1loop(satisfy(pred)) >>= { cs in
            pure(.Plain(String(cs)))
        }
    }
    
//    func refer() -> Parser<Markdown>{
//        return symbol("> ") >>= { _ in
//            
//        }
//    }

    func markdown() -> Parser<Markdown>{
        return  ita() +++ bold() +++ inlineCode() +++ header() +++ links() +++ plain() +++ newline() +++ fakeNewline()
    }

    func markdowns() -> Parser<[Markdown]>{
        let m = space(false) >>= {_ in self.markdown()}
        return many1loop(m)
    }
}

extension MarkdownParser{
    func render(arr : [Markdown]) -> NSAttributedString{
        let attributedString : NSMutableAttributedString = NSMutableAttributedString()
        for m in arr{
            switch m{
            case .Bold(let str):
                attributedString.appendAttributedString(NSAttributedString(string: str, attributes: [NSFontAttributeName:UIFont.boldSystemFontOfSize(18)]))
            case .Ita(let str):
                attributedString.appendAttributedString(NSAttributedString(string: str,attributes: [NSFontAttributeName:UIFont.italicSystemFontOfSize(17)]))
            case .Header(let level, let str):
                let fontSize = 18 + (6 - level)
                attributedString.appendAttributedString(NSAttributedString(string: str, attributes: [NSFontAttributeName:UIFont.boldSystemFontOfSize(CGFloat(fontSize))]))
            case .InlineCode(let str):
                attributedString.appendAttributedString(NSAttributedString(string: str,attributes: [NSFontAttributeName:UIFont.systemFontOfSize(16), NSBackgroundColorAttributeName : UIColor.brownColor()]))
            case .Links(let name, let links):
                attributedString.appendAttributedString(NSAttributedString(string: name, attributes: [NSLinkAttributeName : links, NSUnderlineStyleAttributeName : NSUnderlineStyle.ByWord.rawValue, NSForegroundColorAttributeName : UIColor.blueColor()]))
            case .Plain(let str):
                attributedString.appendAttributedString(NSAttributedString(string: str, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(17)]))
            default:
                break
            }
        }

        return attributedString
    }
}

