//
//  MultiPeerLogger.swift
//  Chronicle
//
//  Created by Ben Gottlieb on 6/4/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import Foundation
import MultipeerConnectivity

#if os(iOS)
	import UIKit
#endif

public let MCSESSION_SERVICE_NAME = "chronicle-log"

public class MultiPeerLogger: Logger, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
	public var session: MCSession
	public var localPeerID: MCPeerID
	public var advertiser: MCNearbyServiceAdvertiser!
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
		self.advertiser.stopAdvertisingPeer()
	}
	
	public func start() {
		if self.advertiser == nil {
			self.advertiser = MCNearbyServiceAdvertiser(peer: self.localPeerID, discoveryInfo: nil, serviceType: MCSESSION_SERVICE_NAME)
			self.advertiser.delegate = self
		}
		
		println("starting")
		
		self.advertiser.startAdvertisingPeer()
	}

	//=============================================================================================
	//MARK: Advertiser Delegate
	
	public func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
		
		dispatch_async(self.queue) {
			if peerID == self.localPeerID { return }
			
			invitationHandler(true, self.session)
		}
	}

	public func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
		error.display()
	}

	//=============================================================================================
	//MARK: Session Delegate

	public func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
		
	}

	public func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
		switch state {
		case .Connected: self.connectedPeers.insert(peerID)
		case .Connecting:
			self.connectedPeers.remove(peerID)

		case .NotConnected:
			self.connectedPeers.remove(peerID)
			if self.connectedPeers.count == 0 {
				self.stop()
				self.start()
			}
		}
		
		println("peer \(peerID) changed state: \(state.rawValue)")
	}
	
	public func session(session: MCSession!, didReceiveStream: NSInputStream!, withName: String!, fromPeer: MCPeerID!) {}
	public func session(session: MCSession!, didStartReceivingResourceWithName: String!, fromPeer: MCPeerID!, withProgress progress: NSProgress!) {}
	public func session(session: MCSession!, didFinishReceivingResourceWithName: String!, fromPeer: MCPeerID!, atURL: NSURL!, withError: NSError!) {}

}