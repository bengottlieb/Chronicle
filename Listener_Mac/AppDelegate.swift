//
//  AppDelegate.swift
//  Listener_Mac
//
//  Created by Ben Gottlieb on 6/4/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Cocoa
import Chronicle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!
	var listener = LogListener()

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Insert code here to initialize your application
		
		LogWindowManager.instance.setup()
		self.listener.start()
	}
	
	@IBAction func connect(sender: AnyObject?) {
		self.listener.start()
	}
	
	@IBAction func disconnect(sender: AnyObject?) {
		self.listener.stop()
	}
	
	@IBAction func ping(sender: AnyObject?) {
		self.listener.sendObject("test")
	}
	
	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}


}

