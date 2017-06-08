//
//  SocketModel.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 08-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import Foundation
import SocketIO

class SocketIOManager {
    
    static let sharedInstance = SocketIOManager()
    let socket = SocketIOClient(socketURL: URL(string: "http://app.thomaskamps.nl:8080")!, config: [.log(true), .forcePolling(true)])
    
    private init() {}
    
    func establishConnection() {
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        socket.connect()
    }
    
    func closeConnection() {
        
        socket.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnected")
        }
    }
    
}
