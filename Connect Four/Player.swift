//
//  Player.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

protocol Player {
    func readyToPlay(delegate: GameDelegate, state: Marker.State)
    func readyForMarkerPlacement(delegate: GameDelegate)
    func placeMarker(delegate: GameDelegate, x: Int, state: Marker.State)
    func placeMarkerConfirmed(delegate: GameDelegate, x: Int, state: Marker.State)
    func gameComplete(delegate: GameDelegate)
}
