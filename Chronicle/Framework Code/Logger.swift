//
//  Logger.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 6/4/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Foundation

public class Logger: NSObject {
	public var queue: dispatch_queue_t
	public var sessionStartedAt = NSDate()

	public override init() {
		var attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0)
		queue = dispatch_queue_create("logger-queue", attr)
		
		super.init()
	}
	
	public func logMessage(message: Message) { }
	public func flush() { }
}