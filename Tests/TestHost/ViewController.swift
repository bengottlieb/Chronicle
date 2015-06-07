//
//  ViewController.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 2/9/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import UIKit
import Chronicle

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func logit() {
		clog("new message \(NSDate())", tags: ["important", "debug"])
	}
	
	@IBAction func logStar() {
		if let image = UIImage(named: "star") {
			clog(image, text: "star")
		}
	}
	
	
	@IBAction func logCheck() {
		if let image = UIImage(named: "check") {
			clog(image, text: "check")
		}
	}
	
	

}

