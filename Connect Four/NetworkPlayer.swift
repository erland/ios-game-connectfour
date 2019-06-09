//
//  NetworkPlayer.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-04.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//
import Foundation

class NetworkPlayer : Player {
    
    var board : Board?
    let playerName: String
    let network : NetworkProtocol
    init(network: NetworkProtocol, name: String) {
        playerName = name
        self.network = network
        print("Creating NetworkPlayer for \(name)")
    }
    
    func placeMarker(delegate: GameDelegate, x: Int, state: Marker.State) {
        let marker = NetworkMarker(x: x, state: state)
        
        network.sendPlaceMarker(player: playerName, marker: marker)
        // TODO: Send our shoot to other player
    }
    
    func placeMarkerConfirmed(delegate: GameDelegate, x: Int, state: Marker.State) {
        let marker = NetworkMarker(x: x, state: state)
        network.sendPlaceMarkerConfirmed(player: playerName, marker: marker)
        // TODO: Pass result on opponent shot to other player
    }
    
    func gameComplete(delegate: GameDelegate) {
        
        network.sendGameComplete(player: playerName)
    }
    func readyForMarkerPlacement(delegate: GameDelegate) {
        network.sendReadyForMarkerPlacement(player: playerName)
    }
    func readyToPlay(delegate: GameDelegate, state: Marker.State) {
        network.sendReadyToPlay(player: playerName, color: NetworkColor(state: state))
    }
    
}
