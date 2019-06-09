//
//  OthelloDelegate.swift
//  Othello
//
//  Created by Erland Isaksson on 2019-05-31.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

protocol GameDelegate {
    func addOpponent(player: String)
    func removeOpponent(player: String)
    func selectedOpponent(player: String, state: Marker.State)
    func readyToPlay(player: String, state: Marker.State)
    func gameComplete(playerName: String)
    func finishedGame()
    func skipPlaceMarker(playerName: String)
    func placeMarker(playerName: String, x: Int, state: Marker.State)
    func placeMarkerConfirmed(playerName: String, x: Int, state: Marker.State)
}
