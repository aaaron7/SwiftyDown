//
//  ViewController.swift
//  SwiftyDownExample
//
//  Created by aaaron7 on 16/4/13.
//  Copyright © 2016年 aaaron7. All rights reserved.
//

import UIKit


prefix operator <- {}

prefix func <- (p : ()->Void){
    dispatch_async(dispatch_get_main_queue()) {
        p()
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        let str = "# Header1 \n plain text \n \n##Header2 \n\n ###Header3\n \n ####Header4 \n \n#####Header5  \n\n######Header6 \n\n\n\n\n \n#######Header7 > Test \n\n> Test2 * \n  > Test3, okay, this is a quote format test. Sure it can be `**ne*sted**`, like [that](yahoo.com) \n\n ########Header8  \n\n#########Header9  \n\n\n\n##########Header10 \n\n \n  Regular text. `inline code block` and some **bold**, *[italics links](yahoo.com)* \n \n  this is a [hyperlinks](http://www.yahoo.com)"
        
        let str1 = "Swift 2.0 中，引入了可用性的概念。对于函数，类，协议等，可以使用`@available`声明8fd9些类型的生命周期依赖于特定的平台和操作系统版本。而`#available`用在判断语句中（if, guard, while等），在不同的平台4e0a做不同的逻辑。\n\n\n\n\n## @available\n\n### 用法\n\n`@available`放在函数（方法），类或者协议前面。表明这些类型适用的平台和操作系统。看下面一个例子：\n\n```\n@available(iOS 9, *)\nfunc myMethod() {\n    // do something\n}\n```\n`@available(iOS 9, *)`必须包含至少24e2a特性参数，其中`iOS 9`表示必须在 iOS 9 版本以上才可用。如果你部署的平台包括 iOS 8 , 在调用此方法后，编译器会报错。\n53e6外一个特性参数：星号（*），表示包含了所有平台，目前有以下几个平台：\n\n* iOS\n* iOSApplicationExtension\n* OSX\n* OSXApplicationExtension\n* watchOS\n* watchOSApplicationExtension\n* tvOS\n* tvOSApplicationExtension\n\n一822c来讲，如果没有特殊的情况，都使用`*`表示全平台。\n\n`@available(iOS 9, *)`是一种简写形式。全写形式是`@available(iOS, introduced=9.0)`。`introduced=9.0`参6570表示指定平台(iOS)从 9.0 开始引入该声明。为什么可以采用简写形式呢？当只有`introduced`这样一种参数时，就可以简写成以上简写形式。同理：@available(iOS 8.0, OSX 10.10, *) 这样也是可以的。表示同时在多个平台上（iOS 8.0 及其以上；OSX 10.10及其以上）的可用性。\n\n另外，`@available`还有其他一些参数可以使用，分别是：\n\n* `deprecated=版本号`：从指定平台某个版本开始过期该声明\n* `obsoleted=版本号`：从指定平台某个版本开始废弃（注意弃用的区别，`deprecated`是还可以继续使用，只不过是不推荐了，`obsoleted`是调用就会编译错误）该声明\n* `message=信息内容`：给出一些附加信息\n* `unavailable`：指定平台上是无效的\n* `renamed=新名字`：重命名声明\n\n以上参数具体可以参考[官方文档](http://wiki.jikexueyuan.com/project/swift/chapter3/06_Attributes.html)\n\n\n\n\n\n## #available\n\n`#available` 用在条件语句代码块中，判断不同的平台下，做不同的逻辑处理，比如：\n\n```\nif #available(iOS 8, *) {\n        // iOS 8 及其以上系统运行\n}\n\n\nguard #available(iOS 8, *) else {\n    return //iOS 8 以下系统就直接返回\n}\n\n```\n\n### stackoverflow 相关问题整理\n\n* [Difference between @available and #available in swift 2.0](http://stackoverflow.com/questions/32761511/difference-between-available-and-available-in-swift-2-0): @available 和 #available\n帖子里面还提到一个问题：`@available`是编译期间判断的吗？而`#available`是运行时行为吗？\n\n\n\n\n### 参考资料\n* [API Availability Checking in Swift 2](http://www.codingexplorer.com/api-availability-checking-in-swift-2/)\n* [Availability checking in Swift 2: backwards compatibility the smart way](https://www.hackingwithswift.com/new-syntax-swift-2-availability-checking)\n\n\n\n\n\n\n"
        
        
//        aht.shareInstance.fetch("v1/article/detail").paras(["articleId":196]).go { (j) in
//            print(j.description)
//            <-{
//                let m = MarkdownParser()
//                
//                self.textView.attributedText = m.convert(j["data"]["content"].stringValue)
//            }
//        }
//        
        

        let m = MarkdownParser()
        
        self.textView.attributedText = m.convert(str)

    }

    @IBOutlet weak var label: UILabel!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

