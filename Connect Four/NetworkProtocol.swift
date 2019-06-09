//
//  NetworkProtocol.swift
//
//  Created by Erland Isaksson on 2019-05-15.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import Foundation

struct NetworkMarker : Codable {
    let x: Int
    let color: Int
    
    init(x: Int, state: Marker.State) {
        self.x = x
        if state == Marker.State.Black {
            self.color = 1
        }else {
            self.color = 2
        }
    }
    
    func asMarkerObj() -> Marker {
        let m = Marker(state: (color==1 ? Marker.State.Black: Marker.State.White))
        m.x = self.x
        return m
    }
}

struct NetworkGameResult : Codable {
    let won: Bool
    
    init(won: Bool) {
        self.won = won
    }
}

struct NetworkColor : Codable {
    let color: Int
    
    init(state: Marker.State) {
        if state == Marker.State.Black {
            self.color = 1
        }else {
            self.color = 2
        }
    }
    
    func asMarkerState() -> Marker.State {
        if color == 1 {
            return Marker.State.Black
        }else {
            return Marker.State.White
        }
    }
}


class NetworkProtocol : MessageProcessor, ConnectionManager {
    let gameDelegate : GameDelegate
    var localNetworking : LocalNetworking?
    var players: Set<String> = Set()
    var readyForMatchmaking: Bool = false
    
    init(gameDelegate: GameDelegate) {
        self.gameDelegate = gameDelegate
        self.localNetworking = LocalNetworking(serviceType: "ConnectFour", messageProcessor: self, connectionManager: self)
    }
    func addConnection(peer: String) {
        //TODO: Is this correct ???
        sendReadyForMatchmaking()
    }
    
    func removeConnection(peer: String) {
        players.remove(peer)
        gameDelegate.removeOpponent(player: peer)
    }
    
    func processMessage(peer: String, message: Message) {
        if message.message == "readyForMatchmaking" {
            print("Received readyForMatchmaking")
            players.insert(peer)
            self.gameDelegate.addOpponent(player: peer)
        }else if message.message == "finishedPlaying" {
            print("Received finishedPlaying")
            removeConnection(peer: peer)
        }else if message.message == "readyForMarkerPlacement" {
            print("Received readyForMarkerPlacement")
            self.gameDelegate.skipPlaceMarker(playerName: peer)
        }else if message.message == "readyToPlay" {
            let networkColor = try! JSONDecoder().decode(NetworkColor.self, from: message.data)
            print("Received readyToPlay")
            self.gameDelegate.readyToPlay(player: peer, state: networkColor.asMarkerState())
        }else if message.message == "placeMarker" {
            let networkMarker = try! JSONDecoder().decode(NetworkMarker.self, from: message.data)
            let marker = networkMarker.asMarkerObj()
            print("Received marker at \(networkMarker.x)")
            self.gameDelegate.placeMarker(playerName: peer, x: marker.x, state: marker.state)
        }else if message.message == "gameComplete" {
            print("Received gameComplete")
            self.gameDelegate.gameComplete(playerName: peer)
        }else if message.message == "placeMarkerConfirmed" {
            let networkMarkerResult = try! JSONDecoder().decode(NetworkMarker.self, from: message.data)
            let markerResult = networkMarkerResult.asMarkerObj()
            print("Received markerConfirmed at \(networkMarkerResult.x)")
            self.gameDelegate.placeMarkerConfirmed(playerName: peer, x: markerResult.x, state: markerResult.state)
        }else {
            print("Unknown message: \(message.message)")
        }
    }
    func sendPlaceMarker(player: String, marker: NetworkMarker) {
        let jsonData = try! JSONEncoder().encode(marker)
        localNetworking?.sendMessage(player: player, message: Message(message: "placeMarker", data: jsonData))
        
    }
    func sendPlaceMarkerConfirmed(player: String, marker: NetworkMarker) {
        print("Preparing placeMarkerConfirmed message to \(player)")
        let jsonData = try! JSONEncoder().encode(marker)
        localNetworking?.sendMessage(player: player, message: Message(message: "placeMarkerConfirmed", data: jsonData))
        
    }
    func sendReadyForMarkerPlacement(player: String) {
        localNetworking?.sendMessage(player: player, message: Message(message: "readyForMarkerPlacement", data: "{}".data(using: .utf8)!))
    }
    
    func sendGameComplete(player: String) {
        localNetworking?.sendMessage(player: player, message: Message(message: "gameComplete", data: "{}".data(using: .utf8)!))
    }
    
    func sendReadyToPlay(player: String?, color: NetworkColor) {
        let jsonData = try! JSONEncoder().encode(color)
        let message = Message(message: "readyToPlay", data: jsonData)
        localNetworking?.sendMessage(message: message)
    }
    
    func sendReadyForMatchmaking() {
        readyForMatchmaking = true
        let message = Message(message: "readyForMatchmaking", data: "{}".data(using: .utf8)!)
        localNetworking?.sendMessage(message: message)
    }
    
    func sendFinishedPlaying() {
        readyForMatchmaking = false
        let message = Message(message: "finishedPlaying", data: "{}".data(using: .utf8)!)
        localNetworking?.sendMessage(message: message)
    }
    
    
}
