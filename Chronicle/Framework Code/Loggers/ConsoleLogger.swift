//
//  ConsoleLogger.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 6/5/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Foundation

public class ConsoleLogger: Logger {
	public override func logMessage(message: Message) {
		println("\(message)")
	}
	
	public override init() {
		super.init()
	}
}