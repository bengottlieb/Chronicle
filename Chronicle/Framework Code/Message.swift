//
//  LogMessage.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 6/4/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Foundation

let DEFAULT_PRIORITY = Message.Priority.Low

public class Message: NSObject, NSCoding, Printable {
	public enum Priority: Int { case None, Low, Medium, High, Critical }
	
	public var text: String?
	public var priority = DEFAULT_PRIORITY
	public var error: NSError?
	public var tags: [String]?
	public var line: Int?
	public var column: Int?
	public var file: String?
	public var function: String?
	
	override init() {
		super.init()
	}
	
	public convenience init(text t: String, priority p: Priority = DEFAULT_PRIORITY, tags tg: [String]? = nil, file: StaticString? = nil, function: StaticString? = nil, line: Int? = nil, column: Int? = nil) {
		self.init()
		
		self.text = t
		self.priority = p
		self.tags = tg
		self.file = "\(function)"
		self.function = "\(function)"
		self.line = line
		self.column = column
	}
	
	public convenience init(error e: NSError, text t: String? = nil, priority p: Priority = DEFAULT_PRIORITY, tags tg: [String]? = nil, file: StaticString? = nil, function: StaticString? = nil, line: Int? = nil, column: Int? = nil) {
		self.init()
		
		self.error = e
		self.text = t
		self.priority = p
		self.tags = tg
		self.file = "\(function)"
		self.function = "\(function)"
		self.line = line
		self.column = column
	}
	
	public func encodeWithCoder(aCoder: NSCoder) {
		if let error = self.error { aCoder.encodeObject(error, forKey: "error") }
		if let text = self.text { aCoder.encodeObject(text, forKey: "text") }
		if let tags = self.tags { aCoder.encodeObject(tags, forKey: "tags") }

		if let file = self.file { aCoder.encodeObject("\(file)", forKey: "file") }
		if let function = self.function { aCoder.encodeObject("\(function)", forKey: "function") }

		if self.priority != DEFAULT_PRIORITY { aCoder.encodeInteger(self.priority.rawValue, forKey: "priority") }
		if let line = self.line { aCoder.encodeInteger(line, forKey: "line") }
		if let column = self.column { aCoder.encodeInteger(column, forKey: "column") }
	}
	
	public required init(coder aDecoder: NSCoder) {
		if let error = aDecoder.decodeObjectForKey("error") as? NSError { self.error = error }
		if let text = aDecoder.decodeObjectForKey("text") as? String { self.text = text }
		if let tags = aDecoder.decodeObjectForKey("tags") as? [String] { self.tags = tags }

		if aDecoder.containsValueForKey("priority") { self.priority = Priority(rawValue: aDecoder.decodeIntegerForKey("priority")) ?? DEFAULT_PRIORITY }
		if let file = aDecoder.decodeObjectForKey("file") as? String { self.file = file }
		if let function = aDecoder.decodeObjectForKey("function") as? String { self.function = function }
		if aDecoder.containsValueForKey("line") { self.line = aDecoder.decodeIntegerForKey("line") }
		if aDecoder.containsValueForKey("column") { self.column = aDecoder.decodeIntegerForKey("column") }
	}
	
	public override var description: String {
		var text = "\(self.priority.rawValue + 1): " + (self.text ?? "")
		if let error = self.error { text = text + "; \(error.localizedDescription)" }
		
		if let file = self.file { text = text + "; \(file)" }
		if let function = self.function { text = text + ": \(function)" }
		if let line = self.line, column = self.column { text = text + " [\(line):\(column)]" }
		if let tags = self.tags where tags.count > 0 {
			let tagString = join(", ", tags)
			text = text + " (\(tagString))"
		}
		
		return text
	}
}