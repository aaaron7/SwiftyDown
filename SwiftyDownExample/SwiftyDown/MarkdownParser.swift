//
//  MarkdownParser.swift
//  SwiftyDown
//
//  Created by aaaron7 on 16/4/13.
//  Copyright © 2016年 aaaron7. All rights reserved.
//

import Foundation
import UIKit

indirect enum Markdown{
    case Ita([Markdown])
    case Bold([Markdown])
    case Header(Int,[Markdown])
    case InlineCode([Markdown])
    case CodeBlock(String)
    case Links([Markdown],String)
    case Plain(String)
    case Refer([Markdown])
    case Delete([Markdown])
}



public protocol MarkdownConfigurable{
    var fontName : UIFont {get set}
    var foregroundColor : UIColor? {get set}
    var backgroundColor : UIColor? {get set}
}

public protocol HeaderStyleConfigurable{
    var fontSize : (Int -> Int)? {get set}
}

public struct TrivialStyle : MarkdownConfigurable{
    public var fontName: UIFont
    public var foregroundColor: UIColor?
    public var backgroundColor: UIColor?
}

public struct HeaderStyle : HeaderStyleConfigurable{
    public var fontName: UIFont
    public var foregroundColor: UIColor?
    public var backgroundColor: UIColor?
    public var fontSize : (Int -> Int)?
}

typealias MD = MarkdownParser
public class MarkdownParser{
    
    let reserved = "`*#[(~"

    public var boldStyle : MarkdownConfigurable =
        TrivialStyle(fontName: UIFont.boldSystemFontOfSize(18), foregroundColor: nil, backgroundColor: nil)
    public var italicsStyle : MarkdownConfigurable =
        TrivialStyle(fontName: UIFont.italicSystemFontOfSize(17), foregroundColor: nil, backgroundColor: nil)
    public var inlineCodeStyle : MarkdownConfigurable =
        TrivialStyle(fontName: UIFont.systemFontOfSize(17), foregroundColor: nil, backgroundColor: MD.hexColor(0xdddddd))

    public var linksStyle : MarkdownConfigurable =
        TrivialStyle(fontName: UIFont.systemFontOfSize(17), foregroundColor: UIColor.blueColor(), backgroundColor: nil)

    public var plainTextStyle : MarkdownConfigurable =
        TrivialStyle(fontName: UIFont.systemFontOfSize(17), foregroundColor: nil, backgroundColor: nil)

    public var referTextStyle : MarkdownConfigurable =
        TrivialStyle(fontName: UIFont.systemFontOfSize(17), foregroundColor: nil, backgroundColor: MD.hexColor(0xeff5fe))


    public var codeBlockStyle : MarkdownConfigurable =
        TrivialStyle(fontName: UIFont.systemFontOfSize(17), foregroundColor: UIColor.whiteColor(), backgroundColor:MD.quickRGB(33, g: 37, b: 43))

    public var deleteStyle : MarkdownConfigurable =
        TrivialStyle(fontName: UIFont.systemFontOfSize(17), foregroundColor: nil, backgroundColor: nil)

    public var headerStyle : HeaderStyleConfigurable = HeaderStyle(fontName: UIFont.boldSystemFontOfSize(18), foregroundColor: nil, backgroundColor: nil) { (NthHeader) -> Int in
        return 28 + (6 - 2 * NthHeader)
    }

    public init(){

    }

    public func convert(string : String) -> NSAttributedString{
        let result = self.parserEntry().p(string)
        if result.count <= 0{
            return NSAttributedString(string: "Parsing failed")
        }else{
            return render(result[0].0)
        }
    }

    func markdown() -> Parser<Markdown>{
        return refer() +++ bold() +++ ita() +++ codeblock() +++ delete()  +++ inlineCode() +++ header() +++ links() +++ plain()
            +++ newline() +++ fakeNewline() +++ reservedHandler()
    }
    

    func markdowns() -> Parser<[Markdown]>{
        let m = space(false) >>= {_ in self.markdown()}
        let mm = many1loop(m)
        return Parser{ str in
            return mm.p(str)
        }
    }

    func parserEntry() -> Parser<[Markdown]>{
        return (pureHeader() >>= { h in
            self.markdowns() >>= { mds in
                var tmds:[Markdown] = mds
                tmds.insert(h, atIndex: 0)
                return pure(tmds)
            }
        }) +++ markdowns()
    }
}

extension MarkdownParser{

    private func reservedHandler() -> Parser<Markdown>{
        func pred(c : Character) -> Bool{
            return reserved.characters.indexOf(c) != nil
        }

        return satisfy(pred) >>= { c in
            pure(.Plain(String(c)))
        }
    }

    private func header()->Parser<Markdown>{
        return many1loop(self.fakeNewline()) >>= { _ in
            self.pureHeader()
        }
    }

    private func pureHeader()->Parser<Markdown>{
        return many1loop(parserChar("#")) >>= { cs in
            line() >>= { str in
                var tmds:[Markdown] = self.pureStringParse(str)
                tmds.insert(.Plain("\n"), atIndex: 0)
                tmds.append(.Plain("\n"))
                return pure(.Header(cs.count,tmds))
            }
        }
    }

    private func ita() -> Parser<Markdown>{
        return pair("*") >>= { str in
            let mds = self.pureStringParse(str)
            return pure(.Ita(mds))
        }
    }

    private func delete() -> Parser<Markdown>{
        return pair("~~") >>= { str in
            let mds = self.pureStringParse(str)
            return pure(.Delete(mds))
        }
    }

    private func bold() -> Parser<Markdown>{
        return pair("**") >>= { str in
            let mds = self.pureStringParse(str)
            return pure(.Bold(mds))
        }
    }

    private func inlineCode() -> Parser<Markdown>{
        return pair("`") >>= { str in
            let mds = self.pureStringParse(str)
            return pure(.InlineCode(mds))
        }
    }

    private func links() -> Parser<Markdown>{
        return pair("[", sepa2: "]") >>= { str in
            pair("(", sepa2: ")") >>= { str1 in
                let mds = self.pureStringParse(str)
                return pure(.Links(mds,str1))

            }
        }
    }

    private func markdownNewLineBreak()->Parser<String>{
        let p = trimedSatisfy(isNewLine)
        return p >>= { _ in
            many1loop(p) >>= { _ in
                pure("\n")
            }
        }
    }

    private func newline() -> Parser<Markdown>{
        return markdownNewLineBreak() >>= { str in
            pure(.Plain(str))
        }
    }

    private func fakeNewline() -> Parser<Markdown>{
        return trimedSatisfy(isNewLine) >>= { _ in
            pure(.Plain(" "))
        }
    }

    private func markdownLineStr() ->Parser<String>{
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
                
                if rest == "" {
                    break
                }

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

    private func plain() -> Parser<Markdown>{
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

    private func pureStringParse(string : String) -> [Markdown]{
        let result = self.markdowns().p(string)
        if result.count > 0 {
            return result[0].0
        }else{
            return []
        }
    }

    private func refer() -> Parser<Markdown>{
        return many1loop(self.fakeNewline()) >>= { _ in
            space(false) >>= { _ in
                symbol(">") >>= { _ in
                    self.markdownLineStr() >>= { str in
                        var mds:[Markdown] = self.pureStringParse(str)
                        //mds.insert(.Plain("\n"), atIndex: 0)
                        mds.append(.Plain("\n"))
                        return pure(.Refer(mds))
                    }
                }
            }
        }
    }
    
    private func codeblock() -> Parser<Markdown>{
        return symbol("```") >>= { _ in
            ((lineStr() >>= {_ in space(true)} )  +++ space(true)) >>= { _ in
                until("```") >>= { str in
                    symbol("```") >>= {_ in pure(.CodeBlock(str))}
                }
            }
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
                if tAttr[NSFontAttributeName]  != nil{
                    let font = tAttr[NSFontAttributeName]!.pointSize
                    tAttr[NSFontAttributeName] = UIFont.boldSystemFontOfSize(font)

                }else{
                    tAttr[NSFontAttributeName] = boldStyle.fontName
                }

                let subAttrString = renderHelper(mds, parentAttribute: tAttr)
                attributedString.appendAttributedString(subAttrString)
 
            case .Ita(let mds):
                var tAttr:[String:AnyObject] = baseAttribute

                if tAttr[NSFontAttributeName]  != nil{
                    let font = tAttr[NSFontAttributeName]!.pointSize
                    tAttr[NSFontAttributeName] = UIFont.italicSystemFontOfSize(font)

                }else{
                    tAttr[NSFontAttributeName] = italicsStyle.fontName
                }

                let subAttrString = renderHelper(mds, parentAttribute: tAttr)
                attributedString.appendAttributedString(subAttrString)


            case .Header(let level, let mds):
                var tAttr:[String:AnyObject] = baseAttribute
                tAttr[NSFontAttributeName] =  UIFont.boldSystemFontOfSize(CGFloat(headerStyle.fontSize!(level)))
                let subAttrString = renderHelper(mds, parentAttribute: tAttr)
                attributedString.appendAttributedString(subAttrString)

            case .InlineCode(let mds):
                
                var tAttr:[String:AnyObject] = baseAttribute
                
                tAttr[NSFontAttributeName] = inlineCodeStyle.fontName
                tAttr[NSBackgroundColorAttributeName] = inlineCodeStyle.backgroundColor
                tAttr[NSForegroundColorAttributeName] = inlineCodeStyle.foregroundColor

                let subAttrString = renderHelper(mds, parentAttribute: tAttr)

                attributedString.appendAttributedString(subAttrString)
            case .Links(let mds, let links):
                var tAttr:[String:AnyObject] = baseAttribute

                tAttr[NSLinkAttributeName] = links
                tAttr[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
                tAttr[NSForegroundColorAttributeName] = linksStyle.foregroundColor
                tAttr[NSBackgroundColorAttributeName] = linksStyle.backgroundColor
                let subAttrString = renderHelper(mds, parentAttribute: tAttr)

                attributedString.appendAttributedString(subAttrString)
            case .Plain(let str):
                if baseAttribute[NSFontAttributeName] == nil{
                    baseAttribute[NSFontAttributeName] = plainTextStyle.fontName
                }
                
                attributedString.appendAttributedString(NSAttributedString(string: str, attributes: baseAttribute))
            case .Refer(let mds):
                attributedString.appendAttributedString(NSAttributedString(string: "\n\n"))

                var tAttr:[String:AnyObject] = baseAttribute
                tAttr[NSBackgroundColorAttributeName] = referTextStyle.backgroundColor

                let paras = NSMutableParagraphStyle()
                paras.paragraphSpacing = 10
                let subAttrString = renderHelper(mds, parentAttribute: tAttr)
                attributedString.appendAttributedString(subAttrString)
            case .CodeBlock(let code):
                attributedString.appendAttributedString(NSAttributedString(string: "\n"))
                let backgroundColor = codeBlockStyle.backgroundColor
                let foregroundColor = codeBlockStyle.foregroundColor
                let paras = NSMutableParagraphStyle()
                paras.paragraphSpacing = 0
                attributedString.appendAttributedString(NSAttributedString(string: code, attributes: [NSBackgroundColorAttributeName:backgroundColor!, NSForegroundColorAttributeName:foregroundColor!,NSParagraphStyleAttributeName:paras]))
            case .Delete(let mds):
                var tAttr:[String:AnyObject] = baseAttribute
                if tAttr[NSFontAttributeName] == nil{
                    tAttr[NSFontAttributeName] = deleteStyle.fontName
                }
                tAttr[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.StyleDouble.rawValue
                let subAttrString = renderHelper(mds, parentAttribute: tAttr)
                attributedString.appendAttributedString(subAttrString)
            }
        }
        
        return attributedString
    }
    
    static func hexColor(value : Int) -> UIColor{
        return UIColor(red: CGFloat((value & 0xFF0000) >> 16) / 255.0, green: CGFloat((value & 0xFF00) >> 8)/255.0, blue: CGFloat(value & 0xFF)/255.0, alpha: 1.0)
        
    }

    static func quickRGB(r : CGFloat, g : CGFloat, b : CGFloat) -> UIColor{
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b/255.0, alpha: 1.0)
    }
}

