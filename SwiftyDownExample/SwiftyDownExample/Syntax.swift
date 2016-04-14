//
//  Syntax.swift
//  ParserCombinator
//
//  Created by aaaron7 on 16/3/16.
//  Copyright © 2016年 wenjin. All rights reserved.
//

import Foundation

indirect enum Markdown{
    case Ita([Markdown])
    case Bold([Markdown])
    case Header(Int,[Markdown])
    case InlineCode([Markdown])
    case CodeBlock(String)
    case Links([Markdown],String)
    case Plain(String)
    case Refer([Markdown])
}