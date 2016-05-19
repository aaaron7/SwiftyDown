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
//        let str = "# Header1 \n plain text \n \n##Header2  \n\n###Header3\n \n####Header4 \n \n#####Header5  \n\n######Header6 \n\n\n\n\n \n#######Header7 > Test \n\n> Test2 * \n  > Test3, okay, this is a quote format test. Sure #it can be `**ne*sted**`, like [that](yahoo.com) \n\n ########Header8  \n\n#########Header9  \n\n\n\n##########Header10 \n\n \n  Regular text. `inline code block` and some **bold**, *[italics links](yahoo.com)* \n \n  this is a [hyperlinks](http://www.yahoo.com)"


        
        aht.shareInstance.fetch("v1/article/detail").paras(["articleId":93]).go { (j) in
            print(j.description)
            <-{
                let m = MarkdownParser()
                m.linksStyle.foregroundColor = UIColor.redColor()
                let finalStr = j["data"]["content"].stringValue

                print("begin")
                self.textView.attributedText = m.convert(finalStr)
            }
        }
    }

    @IBOutlet weak var label: UILabel!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

