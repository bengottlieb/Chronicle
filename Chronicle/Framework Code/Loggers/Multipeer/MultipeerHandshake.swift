//
//  MultipeerHandshake.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 6/5/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Foundation
#if os(iOS)
	import UIKit
#else
	import AppKit
#endif

public class MultipeerHandshake: NSObject, NSCoding {
	public var deviceName: String
	public var deviceType: String
	public var deviceIdentifier: String
	public var date = NSDate()
	
	override public init() {
		#if os(iOS)
			deviceName = UIDevice.currentDevice().name
			deviceType = UIDevice.currentDevice().model
			deviceIdentifier = UIDevice.currentDevice().identifierForVendor.UUIDString
		#else
			deviceName = NSHost.currentHost().localizedName ?? ""
			deviceType = ""
			deviceIdentifier = ""
		#endif
		super.init()
	}
	
	public required init(coder aDecoder: NSCoder) {
		deviceName = aDecoder.decodeObjectForKey("name") as? String ?? ""
		deviceType = aDecoder.decodeObjectForKey("type") as? String ?? ""
		deviceIdentifier = aDecoder.decodeObjectForKey("id") as? String ?? ""
		date = aDecoder.decodeObjectForKey("date") as? NSDate ?? NSDate()
		super.init()
	}
	
	public func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(self.deviceName, forKey: "name")
		aCoder.encodeObject(self.deviceType, forKey: "type")
		aCoder.encodeObject(self.deviceIdentifier, forKey: "id")
		aCoder.encodeObject(self.date, forKey: "date")
	}
	
	public override var description: String {
		var text = "\(self.deviceName) -- \(self.deviceType) -- \(self.deviceIdentifier)"
		
		return text
	}

	
	var data: NSData { return NSKeyedArchiver.archivedDataWithRootObject(self) }
}