//
//  Chronicle.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 2/9/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Foundation

let CHRONICLE_VERSION = 1
let DEFAULT_PRIORITY = Message.Priority.Low

var isLoggingEnabled = true

public func clog(@autoclosure text: () -> String, priority: Message.Priority = Chronicle.instance.defaultPriority, tags: [String]? = nil, file: StaticString = __FILE__, function: StaticString = __FUNCTION__, line: Int = __LINE__, column: Int = __COLUMN__) -> Message? {
	
	if !isLoggingEnabled || priority.rawValue < Chronicle.instance.minimumVisiblePriority.rawValue { return nil }
	
	var message = Message(text: text(), priority: priority, tags: tags, file: file, function: function, line: line, column: column)
	
	Chronicle.instance.logMessage(message)
	return message
}

public func clog(@autoclosure data: () -> NSData, @autoclosure text: () -> String, priority: Message.Priority = Chronicle.instance.defaultPriority, tags: [String]? = nil, file: StaticString = __FILE__, function: StaticString = __FUNCTION__, line: Int = __LINE__, column: Int = __COLUMN__) -> Message? {
	
	if !isLoggingEnabled || priority.rawValue < Chronicle.instance.minimumVisiblePriority.rawValue { return nil }
	
	var message = Message(text: text(), priority: priority, tags: tags, file: file, function: function, line: line, column: column)
	message.payload = data()
	
	Chronicle.instance.logMessage(message)
	return message
}



public class Chronicle: NSObject {
	public static var instance = Chronicle()
	
	public var minimumVisiblePriority = Message.Priority.Low
	public var defaultPriority = Message.Priority.Low
	
	public class var loggingEnabled: Bool {
		get { return isLoggingEnabled }
		set { isLoggingEnabled = newValue }
	}
	
	var queue: dispatch_queue_t
	var activeLoggers: [Logger] = []
	
	public func addLogger(logger: Logger) {
		dispatch_async(self.queue) {
			self.activeLoggers.append(logger)
		}
	}
	
	override init() {
		var attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0)
		queue = dispatch_queue_create("chronicle-queue", attr)
		
		super.init()
	}
	
	public func logMessage(message: Message) {
		for logger in self.activeLoggers {
			logger.logMessage(message)
		}
	}
	
	public func setConsoleURL(url: NSURL?) {
		if let path = url?.path {
			if isatty(STDERR_FILENO) != 0 {		//if we're not hooked up to debugger, let's log to a file
				
			}
			
			freopen(path.fileSystemRepresentation(), "a+", stderr)
		}
	}
}