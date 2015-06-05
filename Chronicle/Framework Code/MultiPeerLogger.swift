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
	public var advertising = false
	public var connected: Bool { return self.session.connectedPeers.count > 0 }
	public var waiting: [Message] = []
	
	public override func logMessage(message: Message) {
		dispatch_async(self.queue, {
			if self.connected {
				self.sendMessage(message)
			} else {
				self.waiting.append(message)
			}
		})
	}
	
	func sendMessage(message: Message) {		//always called within the log's queue
		if self.connected {
			var error: NSError?
			self.session.sendData(message.data, toPeers: self.session.connectedPeers, withMode: .Reliable, error: &error)
			if let error = error {
				println("error while sending: \(error)")
			}
		}
	}
	
	public override func flush() {
		dispatch_async(self.queue) {
			var waiting = self.waiting
			self.waiting = []
			
			for message in waiting {
				self.sendMessage(message)
			}
		}
	}
	
	public override init() {
		#if os(iOS)
			localPeerID = MCPeerID(displayName: UIDevice.currentDevice().name)
		#else
			localPeerID = MCPeerID(displayName: NSHost.currentHost().localizedName)
		#endif
		session = MCSession(peer: localPeerID)
		
		super.init()
		self.session.delegate = self
		self.start()
	}

	public func stop() {
		if !self.advertising { return }
		self.advertising = false
		self.advertiser.stopAdvertisingPeer()
	}
	
	public func start() {
		
		if self.advertising { return }
		if self.advertiser == nil {
			self.advertiser = MCNearbyServiceAdvertiser(peer: self.localPeerID, discoveryInfo: nil, serviceType: MCSESSION_SERVICE_NAME)
			self.advertiser.delegate = self
		}
		
		self.advertising = true
		
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
		if let object: AnyObject = NSKeyedUnarchiver.unarchiveObjectWithData(data) {
			println("received \(object)")
		}
	}

	public func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
		switch state {
		case .Connected:
			self.connectedPeers.insert(peerID)
			self.flush()
			
		case .Connecting:
			self.connectedPeers.remove(peerID)

		case .NotConnected:
			self.connectedPeers.remove(peerID)
			if self.connectedPeers.count == 0 {
				self.stop()
				self.start()
			}
		}
	}
	
	public func session(session: MCSession!, didReceiveStream: NSInputStream!, withName: String!, fromPeer: MCPeerID!) {}
	public func session(session: MCSession!, didStartReceivingResourceWithName: String!, fromPeer: MCPeerID!, withProgress progress: NSProgress!) {}
	public func session(session: MCSession!, didFinishReceivingResourceWithName: String!, fromPeer: MCPeerID!, atURL: NSURL!, withError: NSError!) {}

}