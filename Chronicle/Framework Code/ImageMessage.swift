//
//  ImageMessage.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 6/6/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Foundation

public func clog(@autoclosure image: () -> UIImage, @autoclosure text: () -> String = { "" }(), priority: Message.Priority = DEFAULT_PRIORITY, tags: [String]? = nil, file: StaticString = __FILE__, function: StaticString = __FUNCTION__, line: Int = __LINE__, column: Int = __COLUMN__) -> Message? {
	
	if !isLoggingEnabled || priority.rawValue < Chronicle.instance.minimumVisiblePriority.rawValue { return nil }
	
	var message = ImageMessage(image: image(), text: text(), priority: priority, tags: tags, file: file, function: function, line: line, column: column)
	
	Chronicle.instance.logMessage(message)
	return message
}

public func clog(view: UIView, @autoclosure text: () -> String = { "" }(), priority: Message.Priority = DEFAULT_PRIORITY, tags: [String]? = nil, file: StaticString = __FILE__, function: StaticString = __FUNCTION__, line: Int = __LINE__, column: Int = __COLUMN__) -> Message? {
	
	if !isLoggingEnabled || priority.rawValue < Chronicle.instance.minimumVisiblePriority.rawValue { return nil }
	
	var snapped = view.snapshotViewAfterScreenUpdates(true)
	
	UIGraphicsBeginImageContextWithOptions(snapped.bounds.size, true, 0)
	snapped.drawViewHierarchyInRect(snapped.bounds, afterScreenUpdates: false)
	var image = UIGraphicsGetImageFromCurrentImageContext()
	UIGraphicsEndImageContext()
	
	return clog(image, text: text, priority: priority, tags: tags, file: file, function: function, line: line, column: column)
}

public func clog_screen(@autoclosure text: () -> String = { "" }(), priority: Message.Priority = DEFAULT_PRIORITY, tags: [String]? = nil, file: StaticString = __FILE__, function: StaticString = __FUNCTION__, line: Int = __LINE__, column: Int = __COLUMN__) -> Message? {
	
	if !isLoggingEnabled || priority.rawValue < Chronicle.instance.minimumVisiblePriority.rawValue { return nil }
	
	var snapped = UIScreen.mainScreen().snapshotViewAfterScreenUpdates(true)
	return clog(snapped, text: text, priority: priority, tags: tags, file: file, function: function, line: line, column: column)
}


public class ImageMessage: Message {
	let image: UIImage?
	public init(image img: UIImage, text t: String, priority p: Priority = DEFAULT_PRIORITY, tags tg: [String]? = nil, file: StaticString? = nil, function: StaticString? = nil, line: Int? = nil, column: Int? = nil) {
		
		image = img
		super.init(text: t, priority: p, tags: tg, file: file, function: function, line: line, column: column)
	}
	
	public required init(coder: NSCoder) {
		if let data = coder.decodeObjectForKey("img") as? NSData {
			image = UIImage(data: data)
		} else {
			image = nil
		}
		super.init(coder: coder)
	}
	
	public override func encodeWithCoder(aCoder: NSCoder) {
		super.encodeWithCoder(aCoder)
		if let image = self.image { aCoder.encodeObject(UIImageJPEGRepresentation(image, 0.85), forKey: "img") }
	}
	
	public override var description: String {
		var string = super.description
		
		if let image = self.image { string += " (image: \(Int(image.size.width)) x \(Int(image.size.height)))" }
		return string
	}
}
