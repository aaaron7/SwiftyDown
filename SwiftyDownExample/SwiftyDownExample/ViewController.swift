//
//  ViewController.swift
//  SwiftyDownExample
//
//  Created by aaaron7 on 16/4/13.
//  Copyright © 2016年 aaaron7. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        label.lineBreakMode = .ByWordWrapping
        label.numberOfLines = 0
        // Do any additional setup after loading the view, typically from a nib.
        let str = "# Header1 \n plain text \n ##Header2 \n ###Header3 \n ####Header4  \n#####Header5  \n######Header6  \n#######Header7  \n########Header8  \n#########Header9  \n##########Header10  \n  Regular text. `inline code block` and some **bold**, *italics* \n  this is a [hyperlinks](http://www.yahoo.com)"
        let m = MarkdownParser()
        let result = m.markdowns().p(str)
        label.attributedText = m.render(result[0].0)
        print(result)
    }

    @IBOutlet weak var label: UILabel!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

