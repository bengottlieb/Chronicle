//
//  NSErrorAdditions.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 6/4/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Foundation
#if os(iOS)
	import UIKit
#else
	import AppKit
#endif

extension NSError {
	#if os(iOS)
	func display() {
		dispatch_async(dispatch_get_main_queue()) {
			var alert = UIAlertController(title: self.localizedDescription, message: nil, preferredStyle: .Alert)
			
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
				alert.dismissViewControllerAnimated(true, completion: nil)
			}))
			
			var windows = UIApplication.sharedApplication().windows
			if windows.count == 0 { return }
			
			if let window = windows[0] as? UIWindow {
				window.rootViewController?.presentViewController(alert, animated: true, completion: nil)
			}
		}
	}
	
	#else
	func display() {
		dispatch_async(dispatch_get_main_queue()) {
			var alert = NSAlert(error: self)
			alert.runModal()
		}
	}
	#endif
	
}