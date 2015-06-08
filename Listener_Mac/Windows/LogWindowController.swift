//
//  LogWindowController.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 6/7/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Cocoa
import Chronicle

class LogWindowController: NSWindowController, LogHistoryViewer, NSTableViewDataSource {
	var history: LogHistory!
	
	@IBOutlet var tableView: NSTableView!
	
	convenience init(history h: LogHistory) {
		self.init(windowNibName: "LogWindowController")
		self.history = h
		self.history.viewer = self
		self.window?.title = history.appIdentifier + " - " + history.sessionStartedAt.description
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
    }
	
	func logHistoryDidChange() {
		dispatch_async(dispatch_get_main_queue()) {
			self.tableView?.reloadData()
		}
	}
	
	
	
	//=============================================================================================
	//MARK: TableView
	func numberOfRowsInTableView(tableView: NSTableView) -> Int { return self.history.logs.count }

	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		var view = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as? NSTableCellView
		var message = self.history.logs[row]
		
		view?.textField?.stringValue = message.text ?? ""
		return view

//		var label = NSTextField(frame: CGRect(x: 0, y: 0, width: 400, height: 20))
//		label.stringValue = self.history.logs[row].description
//		
//		return label
	}

}
