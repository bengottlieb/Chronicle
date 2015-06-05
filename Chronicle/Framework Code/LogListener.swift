//
//  LogListener.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 6/4/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Foundation
import MultipeerConnectivity


public class LogListener: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate {
	public var session: MCSession
	public var localPeerID: MCPeerID
	public var browser: MCNearbyServiceBrowser!
	
	public var connectedPeers = Set<MCPeerID>()

	public override init() {		
		#if os(iOS)
			localPeerID = MCPeerID(displayName: UIDevice.currentDevice().name)
		#else
			localPeerID = MCPeerID(displayName: NSHost.currentHost().localizedName)
		#endif
		session = MCSession(peer: localPeerID)
		
		super.init()
		self.session.delegate = self
	}
	
	public func stop() {
		println("stopping")
		self.browser.stopBrowsingForPeers()
	}
	
	public func start() {
		if self.browser == nil {
			self.browser = MCNearbyServiceBrowser(peer: self.localPeerID, serviceType: MCSESSION_SERVICE_NAME)
			self.browser.delegate = self
		}
		
		println("starting")
		self.browser.startBrowsingForPeers()
	}


	//=============================================================================================
	//MARK: Browser Delegate

	public func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
		
		self.connectedPeers.insert(peerID)
		println("Connecting to \(peerID)")
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
		
	}
	
	public func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
		switch state {
		case .Connected: self.connectedPeers.insert(peerID)
		case .Connecting: fallthrough
		case .NotConnected:
			self.connectedPeers.remove(peerID)
		}
		
		println("peer \(peerID) changed state: \(state.rawValue)")
	}
	
	public func session(session: MCSession!, didReceiveStream: NSInputStream!, withName: String!, fromPeer: MCPeerID!) {}
	public func session(session: MCSession!, didStartReceivingResourceWithName: String!, fromPeer: MCPeerID!, withProgress progress: NSProgress!) {}
	public func session(session: MCSession!, didFinishReceivingResourceWithName: String!, fromPeer: MCPeerID!, atURL: NSURL!, withError: NSError!) {}
}