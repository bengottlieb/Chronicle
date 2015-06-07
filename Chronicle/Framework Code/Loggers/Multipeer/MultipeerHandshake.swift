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
	public var uuid: NSUUID? = NSUUID()
	public var appIdentifier: String
	public var appName: String
	
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
		
		appIdentifier = NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as? String ?? ""
		appName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String ?? ""
		
		super.init()
	}
	
	public required init(coder aDecoder: NSCoder) {
		deviceName = aDecoder.decodeObjectForKey("dev-name") as? String ?? ""
		deviceType = aDecoder.decodeObjectForKey("type") as? String ?? ""
		deviceIdentifier = aDecoder.decodeObjectForKey("dev-id") as? String ?? ""
		appIdentifier = aDecoder.decodeObjectForKey("app-id") as? String ?? ""
		appName = aDecoder.decodeObjectForKey("app-name") as? String ?? ""
		date = aDecoder.decodeObjectForKey("date") as? NSDate ?? NSDate()
		if let string = aDecoder.decodeObjectForKey("uuid") as? String { uuid = NSUUID(UUIDString: string) }
		super.init()
	}
	
	public func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(self.deviceName, forKey: "dev-name")
		aCoder.encodeObject(self.deviceType, forKey: "type")
		aCoder.encodeObject(self.deviceIdentifier, forKey: "dev-id")
		aCoder.encodeObject(self.date, forKey: "date")
		aCoder.encodeObject(self.appIdentifier, forKey: "app-id")
		aCoder.encodeObject(self.appName, forKey: "app-name")
		if let uuid = self.uuid { aCoder.encodeObject(uuid.UUIDString, forKey: "uuid") }
	}
	
	public override var description: String {
		var formatter = NSDateFormatter()
		formatter.timeStyle = .MediumStyle
		formatter.dateStyle = .ShortStyle
		var dateString = formatter.stringFromDate(self.date)
		var text = "\(dateString): \(self.deviceName) -- \(self.deviceType) -- \(self.deviceIdentifier)"
		
		return text
	}

	
	var data: NSData { return NSKeyedArchiver.archivedDataWithRootObject(self) }
}