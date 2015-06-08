//
//  LogWindowManager.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 6/7/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import AppKit
import Chronicle

class LogWindowManager: NSObject {
	static var instance = LogWindowManager()
	
	override init() {
		super.init()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "historyRegistered:", name: LogHistoryManager.notifications.historyRegistered, object: nil)
	}
	
	func setup() {
		
	}
	
	
	func historyRegistered(note: NSNotification) {
		
	}
}
