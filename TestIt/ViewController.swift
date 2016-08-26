//
//  ViewController.swift
//  TestIt
//
//  Created by Chris Prince on 8/26/16.
//  Copyright © 2016 Angies List. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //var x:Int?
        var x:Int? = nil
        
        if x == 1 {
            
        }
        
        var capital = ["US":"Washington", "France" :"Paris"]
        if capital["US"] == "Washington" {
            
        }
        
        // var x:[Class1: Class2]
        
        if capital["Foo"] == nil {
            
        }
        
        capital["Foo"] = "Washington"
        
        if capital["Foo"] == "Washington" {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

