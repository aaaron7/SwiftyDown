# SwiftyDown
SwiftyDown - Simple, Elegant, Powerful markdown parser written in swift. (still in dev

If you have any thoughts or needs about this project, file an issue immediately :)


## Install

- Use Cocoapods:

```
pod 'SwiftyDown'
```

- or just drag `Parser.swift`, `MarkdownParser.swift` and `Syntax.swift` to your project folder.

## Support format

```Markdown
# Heading1
## Heading2
### Heading3
#### Heading4
##### Heading5
###### Heading6
####### Heading7
...

**Bold**

*italics*

`inline code block`

[Hyperlink](github.com)

> refer text block        <-------- this one is not perfect due to NSAttributedString functionality.


and nested syntax like:

`**nested**`
*[italics links](yahoo.com)*
...

```

## Usage

```swift
import SwiftyDown

let str = "# Header1 \n plain text \n \n##Header2 \n\n ###Header3\n \n ####Header4 \n \n#####Header5  \n\n######Header6 \n\n\n\n\n \n#######Header7 > Test \n\n> Test2 \n > Test3, okay, this is a quote format test. Sure it can be `**nested**`, like [that](yahoo.com) \n\n ########Header8  \n\n#########Header9  \n\n\n\n##########Header10 \n\n \n  Regular text. `inline code block` and some **bold**, *[italics links](yahoo.com)* \n \n  this is a [hyperlinks](http://www.yahoo.com)"
        
let m = MarkdownParser()

label.attributedText = m.convert(str)

```


## Screenshots
![](https://raw.githubusercontent.com/aaaron7/SwiftyDown/master/SwiftyDownExample/screenshots.png)
