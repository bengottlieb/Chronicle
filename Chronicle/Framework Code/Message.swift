//
//  LogMessage.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 6/4/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Foundation


public class Message: NSObject {
	public enum Priority: Int { case None, Low, Medium, High, Critical }
	
	public var text = ""
	public var priority = Priority.Low
	public var error: NSError?
	public var tags: [String] = []
		
	public convenience init(text t: String, priority p: Priority = .Low, tags tg: [String] = []) {
		self.init()
		
		self.text = t
		self.priority = p
		self.tags = tg
	}
	
	public convenience init(error e: NSError, priority p: Priority = .Low) {
		self.init()
		self.error = e
		self.priority = p
	}
}