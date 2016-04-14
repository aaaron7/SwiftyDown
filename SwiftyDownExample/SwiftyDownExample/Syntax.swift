//
//  Syntax.swift
//  ParserCombinator
//
//  Created by aaaron7 on 16/3/16.
//  Copyright © 2016年 wenjin. All rights reserved.
//

import Foundation

indirect enum Markdown{
    case Ita(String)
    case Bold(String)
    case Header(Int,String)
    case InlineCode(String)
    case CodeBlock(String)
    case Links(String,String)
    case Plain(String)
    case Refer(Markdown)
}