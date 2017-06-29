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
    
    // make singleton to prevent multiple connections
    static let sharedInstance = SocketIOManager()
    private init() {}
    
    // init client
    private let socket = SocketIOClient(socketURL: URL(string: "http://app.thomaskamps.nl:8080")!, config: [.log(false), .forcePolling(true)])
    
    // init vars
    var rooms: [String:[String:Any]] = [:]
    var currentRoom: Slide?
    var currentStudentCount: Int?
    
    func establishConnection() {
        
        socket.on(clientEvent: .connect) {data, ack in
            
            print("socket connected")
            
            // when connected get current rooms
            self.getRooms()
            
            // when connected and room is set, join this room again on server (occurs on reconnects)
            if self.currentRoom != nil {
                
                self.joinRoom(room: (self.currentRoom?.dirName)!)
            }
        }
        
        socket.on(clientEvent: .error) {data, ack in
            
            // send out alert if connection fails
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
        
        // ask server for current rooms
        socket.emit("sendrooms")
        
        socket.on("rooms") {data, ack in
            
            // process data
            if let temp = data as? [[String: Any]] {
                
                // set data for rooms and notify
                self.rooms = (temp[0] as? [String : [String : Any]])!
                NotificationCenter.default.post(name: Notification.Name("newRooms"), object: nil)
            }
        }
    }
    
    func joinRoom(room: String) {
        
        // set the current room and ask server to join
        self.currentRoom = Slide(data: rooms[room]!)
        socket.emit("join", room)
        
        // attach listener to the changePage event
        socket.on("changePage") {data, ack in
            
            // if data is valid
            if let temp = data as? [Int] {
                
                // update currentPage and send out notification
                self.rooms[room]?["currentPage"] = temp[0]
                self.currentRoom?.currentPage = temp[0]
                NotificationCenter.default.post(name: Notification.Name("changePage"), object: nil)
            }
        }
        
        // attach listener for endLecture event
        socket.on("endLecture") {data, ack in
            
            // send out notification
            NotificationCenter.default.post(name: Notification.Name("endSlides"), object: nil)
        }

    }
    
    func leaveRoom() {
        
        // leave room on server, detach listeners and clear vars
        socket.emit("leave", (currentRoom?.dirName)!)
        self.currentRoom = nil
        socket.off("changePage")
        socket.off("endLecture")
    }
    
    func sendFeedback(feedback: String) {
        
        // emit feedback to server
        socket.emit("feedback", ["feedback": feedback, "room": self.currentRoom?.dirName])
    }
    
    func pageUp() {
        
        // change page and emit to server
        self.currentRoom?.currentPage += 1
        socket.emit("changePage", (currentRoom?.currentPage)!)
    }
    
    func pageDown() {
        
        // change page and emit to server
        self.currentRoom?.currentPage -= 1
        socket.emit("changePage", (currentRoom?.currentPage)!)
    }
    
    func claimLecture() {
        
        // emit to server that you want to claim the lecture
        socket.emit("claimLecture", (currentRoom?.dirName)!)
        
        // attach listener for feedback
        socket.on("feedback") {data, ack in
            
            // process feedback and send notification
            let newData = data[0] as! [String: Any]
            
            if let studentCount = newData["studentCount"] as? Int {
                self.currentStudentCount = studentCount
            }
            
            if newData["feedback"] as! String == "negative" {
                NotificationCenter.default.post(name: Notification.Name("receiveNegativeFeedback"), object: nil)
            }
            
            if newData["feedback"] as! String == "positive" {
                NotificationCenter.default.post(name: Notification.Name("receivePositiveFeedback"), object: nil)
            }
        }
    }
    
    func endLecture() {
        
        // emit to server and detach listener for feedback
        socket.emit("endLecture")
        socket.off("feedback")
    }
}
