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
	
	var controllers: [NSUUID: LogWindowController] = [:]
	
	func historyRegistered(note: NSNotification) {
		if let history = note.object as? LogHistory {
			var controller = LogWindowController(history: history)
			self.controllers[history.sessionUUID] = controller
			
			controller.showWindow(nil)
		}
	}
}
