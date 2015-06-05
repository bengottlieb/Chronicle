//
//  LogListener.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 6/4/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import Chronicle

public class LogListener: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate {
	public var session: MCSession
	public var localPeerID: MCPeerID
	public var browser: MCNearbyServiceBrowser!
	public var queue: dispatch_queue_t
	
	public var browsing = false
	public var connectedPeers = Set<MCPeerID>()

	public override init() {		
		#if os(iOS)
			localPeerID = MCPeerID(displayName: UIDevice.currentDevice().name)
		#else
			localPeerID = MCPeerID(displayName: NSHost.currentHost().localizedName)
		#endif

		var attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0)
		queue = dispatch_queue_create("listener-queue", attr)
		
		session = MCSession(peer: localPeerID)
		
		super.init()
		self.session.delegate = self
	}
	
	public func stop() {
		dispatch_async(self.queue) {
			if !self.browsing { return }
			self.browsing = false
			self.browser.stopBrowsingForPeers()
		}
	}
	
	public func start() {
		dispatch_async(self.queue) {
			if self.browsing { return }
			if self.browser == nil {
				self.browser = MCNearbyServiceBrowser(peer: self.localPeerID, serviceType: MCSESSION_SERVICE_NAME)
				self.browser.delegate = self
			}
			
			self.browsing = true
			self.browser.startBrowsingForPeers()
		}
	}

	public func disconnectAllLoggers() {
		self.session.disconnect()
	}
	
	public func sendObject(object: AnyObject) {
		var error: NSError?
		
		self.session.sendData(NSKeyedArchiver.archivedDataWithRootObject(object), toPeers: self.session.connectedPeers, withMode: .Reliable, error: &error)
	}

	//=============================================================================================
	//MARK: Browser Delegate

	public func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
		
		self.connectedPeers.insert(peerID)
		self.browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 20.0)
	}

	public func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
		self.connectedPeers.remove(peerID)
	}
	
	public func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
		error.display()
	}


	//=============================================================================================
	//MARK: Session Delegate
	
	public func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
		if let object: AnyObject = NSKeyedUnarchiver.unarchiveObjectWithData(data) {
			println("received \(object)")
		}
	}
	
	public func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
		if peerID.displayName.rangeOfString("iPhone Simulator") != nil { return }
		
		dispatch_async(self.queue) {
			switch state {
			case .Connected: self.connectedPeers.insert(peerID)
			case .Connecting: break
			case .NotConnected:
				self.connectedPeers.remove(peerID)
				self.stop()
				self.session.disconnect()
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), self.queue, { self.start() })
			}
		}
	}
	
	public func session(session: MCSession!, didReceiveStream: NSInputStream!, withName: String!, fromPeer: MCPeerID!) {}
	public func session(session: MCSession!, didStartReceivingResourceWithName: String!, fromPeer: MCPeerID!, withProgress progress: NSProgress!) {}
	public func session(session: MCSession!, didFinishReceivingResourceWithName: String!, fromPeer: MCPeerID!, atURL: NSURL!, withError: NSError!) {}
}