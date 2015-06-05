//
//  Chronicle.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 2/9/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Foundation

public class Chronicle: NSObject {
	public static var instance = Chronicle()
	
	
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
	
	
}