//
//  LogHistoryManager.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 6/7/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Foundation

public class LogHistoryManager {
	public static var instance = LogHistoryManager()
	
	public struct notifications {
		public static let historyRegistered = "com.standalone.historyRegistered"
	}
	
	public var histories: [NSUUID: LogHistory] = [:]
	var queue: dispatch_queue_t
	
	init() {
		var attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0)
		queue = dispatch_queue_create("logger-queue", attr)
		
	}
	
	func routeMessage(message: Message) {
		if let uuid = message.senderUUID, history = self.histories[uuid] {
			history.recordMessage(message)
		}
	}
	
	func registerLogHistory(history: LogHistory) {
		dispatch_async(self.queue) {
			if self.histories[history.sessionUUID] == nil {
				println("registering history for \(history.appIdentifier)")
				
				self.histories[history.sessionUUID] = history
				history.storageURL = self.baseLogsDirectoryURL.URLByAppendingPathComponent(history.appIdentifier).URLByAppendingPathComponent(history.sessionUUID.UUIDString)
				
				dispatch_async(dispatch_get_main_queue()) {
					NSNotificationCenter.defaultCenter().postNotificationName(LogHistoryManager.notifications.historyRegistered, object: history)
				}
			}
		}
	}
	
	var baseLogsDirectoryURL: NSURL {
		#if os(iOS)
			var base = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
			return NSURL(string: base)!
		#else
			var base = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0] as! String
			var url = NSURL(fileURLWithPath: base)
			return url!.URLByAppendingPathComponent(NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String)
		#endif
	
	}
}