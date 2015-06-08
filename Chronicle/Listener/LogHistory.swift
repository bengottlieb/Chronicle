//
//  LogHistory.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 6/7/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Foundation

public protocol LogHistoryViewer {
	func logHistoryDidChange()
}

public class LogHistory: NSObject {
	public let appIdentifier: String
	public let sessionUUID: NSUUID
	public let sessionStartedAt: NSDate
	
	public var logs: [Message] = []
	public var queue: dispatch_queue_t
	
	public var viewer: LogHistoryViewer?
	
	public init(id: String, uuid: NSUUID, started: NSDate) {
		var attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0)
		queue = dispatch_queue_create("logger-queue", attr)

		appIdentifier = id
		sessionUUID = uuid
		sessionStartedAt = started
		
		super.init()
	}
	
	
	func recordMessage(message: Message) {
		dispatch_async(self.queue) {
			self.logs.append(message)
			self.viewer?.logHistoryDidChange()
			
			if let messageURL = self.storageURL?.URLByAppendingPathComponent(String(format: "%10d", self.logs.count)) {
				message.data.writeToURL(messageURL, atomically: true)
			}
		}
	}
	
	public var storageURL: NSURL? {
		didSet {
			var error: NSError?
			if let url = self.storageURL {
				if !NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil, error: &error) { println("error creating directory at \(url.absoluteString): \(error!)") }
				self.loadLogs()
			}
		}
	}
	
	func loadLogs() {
		dispatch_async(self.queue) {
			self.logs = []
			
			if let url = self.storageURL {
				var error: NSError?
				var names = NSFileManager.defaultManager().contentsOfDirectoryAtPath(url.path!, error: &error) as! [String]
				
				for name in sorted(names, <) {
					var fileURL = url.URLByAppendingPathComponent(name)
					if let data = NSData(contentsOfURL: fileURL), message = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Message {
						self.logs.append(message)
					}
				}
				
				dispatch_async(dispatch_get_main_queue()) {
					self.viewer?.logHistoryDidChange()
				}
			}
		}
	}
}

class MultiPeerLogHistory: LogHistory {
	init(handshake: MultiPeerHandshake) {
		super.init(id: handshake.appIdentifier, uuid: handshake.sessionUUID!, started: handshake.sessionStartedAt)
	}
}