//
//  BaseAIPlayer.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-16.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import Foundation

class RandomAIPlayer : Player {
    var board : Board?
    var myState : Marker.State?
    let playerName: String
    
    init(name: String) {
        playerName = name
    }
    
    struct Position {
        let x: Int
        let y: Int
        init(_ x: Int, _ y: Int) {
            self.x = x
            self.y = y;
        }
    }
    
    func getNextPosition() -> Int? {
        var potentialPositions : [Int] = []
        for x in 0..<board!.width {
            if board!.atPosition(x, 0) == nil {
                potentialPositions.append(x)
            }
        }
        if potentialPositions.count>0 {
            let selectedPos = Int.random(in: 0..<potentialPositions.count)
            return potentialPositions[selectedPos]
        }
        return nil
    }
    
    func readyToPlay(delegate: GameDelegate, state: Marker.State) {
        myState = state
        board = Board(name: playerName)
        delegate.readyToPlay(player: playerName,
                             state: (state == Marker.State.Black ? Marker.State.White : Marker.State.Black)
        )
    }
    func thinkTime() -> Double {
        return 1.0
    }
    
    func readyForMarkerPlacement(delegate: GameDelegate) {
        print("AI preparing to shoot")
        DispatchQueue.global().asyncAfter(deadline: .now() + thinkTime(), execute: {
            let position = self.getNextPosition()
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                if position != nil {
                    print("AI placing at \(position!)")
                    delegate.placeMarker(playerName: self.playerName, x: position!, state: self.myState!)
                }else {
                    print("No position found for \(self.myState!)")
                    print("AI can't move, skipping")
                    delegate.skipPlaceMarker(playerName: self.playerName)
                }
            })
        })
    }
    
    func placeMarkerConfirmed(delegate: GameDelegate, x: Int, state: Marker.State) {
        board?.addMarker(state: state, x: x)
        if board!.isAllMarkersPlaced(state: nil) {
            delegate.gameComplete(playerName: playerName)
        }
    }
    
    func placeMarker(delegate: GameDelegate, x: Int, state: Marker.State) {
        board?.addMarker(state: state, x: x)
        delegate.placeMarkerConfirmed(playerName: playerName, x: x, state: state)
    }
    func gameComplete(delegate: GameDelegate) {
        // Do nothing
    }
    
}
