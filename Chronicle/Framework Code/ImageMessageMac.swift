//
//  ImageMessage.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 6/6/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Foundation
import AppKit


public func clog(@autoclosure image: () -> NSImage, @autoclosure text: () -> String = { "" }(), priority: Message.Priority = DEFAULT_PRIORITY, tags: [String]? = nil, file: StaticString = __FILE__, function: StaticString = __FUNCTION__, line: Int = __LINE__, column: Int = __COLUMN__) -> Message? {
	
	if !isLoggingEnabled || priority.rawValue < Chronicle.instance.minimumVisiblePriority.rawValue { return nil }
	
	var message = ImageMessage(image: image(), text: text(), priority: priority, tags: tags, file: file, function: function, line: line, column: column)
	
	Chronicle.instance.logMessage(message)
	return message
}

public func clog(image: NSImage, text: String = "", priority: Message.Priority = DEFAULT_PRIORITY, tags: [String]? = nil, file: StaticString = __FILE__, function: StaticString = __FUNCTION__, line: Int = __LINE__, column: Int = __COLUMN__) {
	var message = ImageMessage(image: image, text: text, priority: priority, tags: tags, file: file, function: function, line: line, column: column)
	
	Chronicle.instance.logMessage(message)
}


public class ImageMessage: Message {
	let image: NSImage?
	public init(image img: NSImage, text t: String, priority p: Priority = DEFAULT_PRIORITY, tags tg: [String]? = nil, file: StaticString? = nil, function: StaticString? = nil, line: Int? = nil, column: Int? = nil) {
		
		image = img
		super.init(text: t, priority: p, tags: tg, file: file, function: function, line: line, column: column)
	}
	
	public required init(coder: NSCoder) {
		if let data = coder.decodeObjectForKey("img") as? NSData {
			image = NSImage(data: data)
		} else {
			image = nil
		}
		super.init(coder: coder)
	}
	
	public override func encodeWithCoder(aCoder: NSCoder) {
		super.encodeWithCoder(aCoder)
		if let image = self.image {
			var reps = image.representations
			var props = [NSImageCompressionFactor: 0.85]
			if let imageData = NSBitmapImageRep.representationOfImageRepsInArray(reps, usingType: .NSJPEGFileType, properties: props) {
				aCoder.encodeObject(imageData, forKey: "img")
			}
		}
	}
	
	public override var description: String {
		var string = super.description
		
		if let image = self.image { string += " (image: \(Int(image.size.width)) x \(Int(image.size.height)))" }
		return string
	}
}
