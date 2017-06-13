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
    
    var rooms: [String:[String:Any]]?
    
    private init() {}
    
    func establishConnection() {
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            self.getRooms()
        }
        
        socket.connect()
    }
    
    func closeConnection() {
        
        socket.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnected")
        }
        
        socket.disconnect()
    }
    
    func getRooms() {
        
        print("getrooms")
        
        socket.emit("sendrooms")
        
        socket.on("rooms") {data, ack in
            
            if let temp = data as? [[String: Any]] {
                self.rooms = temp[0] as? [String : [String : Any]]
                print(self.rooms)
                NotificationCenter.default.post(name: Notification.Name("newRooms"), object: nil)
            }
        }
    }
    
    func joinRoom(room: String) {
        print("joinroom")
        socket.emit("join", room)
        
        socket.on("changePage") {data, ack in
            if let temp = data as? [Int] {
                print(data)
                self.rooms?[room]?["currentPage"] = temp[0]
                NotificationCenter.default.post(name: Notification.Name("changePage"), object: nil)
            }
        }
    }
    
    func leaveRoom(room: String) {
        print("leaveroom")
        socket.emit("leave", room)
    }
        
    
}
