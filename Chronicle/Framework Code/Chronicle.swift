//
//  Chronicle.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 2/9/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Foundation

public class Chronicle: NSObject {
	public class var defaultManager: Chronicle { struct s { static let manager = Chronicle() }; return s.manager }
	
	
}