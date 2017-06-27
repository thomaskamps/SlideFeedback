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
    private let socket = SocketIOClient(socketURL: URL(string: "http://app.thomaskamps.nl:8080")!, config: [.log(false), .forcePolling(true)])
    
    var rooms: [String:[String:Any]] = [:]
    var currentRoom: Slide?
    
    private init() {}
    
    func establishConnection() {
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            self.getRooms()
        }
        
        socket.on(clientEvent: .error) {data, ack in
            NotificationCenter.default.post(name: Notification.Name("alertConnection"), object: nil)
            self.socket.reconnect()
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

        socket.emit("sendrooms")
        
        socket.on("rooms") {data, ack in
            
            if let temp = data as? [[String: Any]] {
                
                self.rooms = (temp[0] as? [String : [String : Any]])!
                NotificationCenter.default.post(name: Notification.Name("newRooms"), object: nil)
            }
        }
    }
    
    func joinRoom(room: String) {
        self.currentRoom = Slide(data: rooms[room]!)
        socket.emit("join", room)
        
        socket.on("changePage") {data, ack in
            
            if let temp = data as? [Int] {
                
                self.rooms[room]?["currentPage"] = temp[0]
                self.currentRoom?.currentPage = temp[0]
                NotificationCenter.default.post(name: Notification.Name("changePage"), object: nil)
            }
        }
        
        socket.on("endLecture") {data, ack in
            NotificationCenter.default.post(name: Notification.Name("endSlides"), object: nil)
        }
    }
    
    func leaveRoom() {
        
        socket.emit("leave", (currentRoom?.dirName)!)
        self.currentRoom = nil
        socket.off("changePage")
        socket.off("endLecture")
    }
    
    func sendFeedback(feedback: String) {
        
        socket.emit("feedback", ["feedback": feedback, "room": self.currentRoom?.dirName])
    }
    
    func pageUp() {
        
        self.currentRoom?.currentPage += 1
        socket.emit("changePage", (currentRoom?.currentPage)!)
    }
    
    func pageDown() {
        
        self.currentRoom?.currentPage -= 1
        socket.emit("changePage", (currentRoom?.currentPage)!)
    }
    
    func claimLecture() {
        socket.emit("claimLecture", (currentRoom?.dirName)!)
        
        socket.on("feedback") {data, ack in
            
            if data[0] as! String == "negative" {
                NotificationCenter.default.post(name: Notification.Name("receiveNegativeFeedback"), object: nil)
            }
            
            if data[0] as! String == "positive" {
                NotificationCenter.default.post(name: Notification.Name("receivePositiveFeedback"), object: nil)
            }
        }
    }
    
    func endLecture() {
        
        socket.emit("endLecture")
        socket.off("feedback")
    }
}
