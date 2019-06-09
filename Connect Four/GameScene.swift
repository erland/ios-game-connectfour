//
//  GameScene.swift
//  Othello
//
//  Created by Erland Isaksson on 2019-05-31.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, BoardObserver {
    var gameDelegate: GameDelegate?
    var boardView : BoardView?
    var instructionText : SKLabelNode?
    var waitingForOpponent: Bool = true
    var playerState : Marker.State?
    var marker : Marker?
    var markerView : MarkerView?
    
    func setup(delegate: GameDelegate, board: Board, playerState: Marker.State) {
        self.gameDelegate = delegate
        self.playerState = playerState
        
        self.boardView = childNode(withName: "board") as? BoardView
        print("Setup board view for \(board.name)")
        self.boardView?.setup(board: board)
        
        instructionText = childNode(withName: "instructionText") as? SKLabelNode
        
        boardView?.board?.attachObserver(self)
        marker = Marker(state: playerState)
        marker?.y = -1
        markerView = MarkerView(marker: marker!, cellSize: boardView!.cellSize!)
        markerView!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        markerView!.name = "placementmarker"
        markerView!.zPosition = 10
        self.boardView?.addChild(markerView!)
    }
    deinit {
        boardView?.board?.detachObserver(self)
    }
    
    override func didMove(to view: SKView) {
        print("Moved to game scene")
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        adjustMarker(position: touchLocation)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        adjustMarker(position: touchLocation)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        placeMarker(position: touchLocation)
    }

    func adjustMarker(position: CGPoint) {
        if waitingForOpponent {
            return
        }
        let cellX = Int((position.x-boardView!.position.x)/boardView!.cellSize!)
        if cellX>=0 && cellX<boardView!.board!.width {
            setupMarker(x: cellX)
        }
    }

    func placeMarker(position: CGPoint) {
        if waitingForOpponent {
            return
        }
        let cellX = Int((position.x-boardView!.position.x)/boardView!.cellSize!)
        if cellX>=0 && cellX<boardView!.board!.width {
            if boardView!.board!.board[cellX,0] == nil {
                waitingForOpponent = true
                instructionText?.text = "Waiting for opponent"
                gameDelegate?.placeMarker(playerName: boardView!.board!.name, x: cellX, state: playerState!)
            }
        }
    }
    func opponentPlaceMarker(x: Int, state: Marker.State) {
        waitingForOpponent = false
        instructionText?.text = "Place your marker"
        boardView!.board?.addMarker(state: state, x: x)
        gameDelegate?.placeMarkerConfirmed(playerName: boardView!.board!.name, x: x, state: state)
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0, execute: {
            self.setupMarker(x: 3)
        })
    }
    
    private func setupMarker(x: Int) {
        markerView?.alpha = 1.0
        marker?.x = x
    }
    
    private func hideMarker() {
        markerView?.alpha = 0.0
    }

    func readyForMarkerPlacement() {
        waitingForOpponent = false
        instructionText?.text = "Place your marker"
        setupMarker(x: 3)
    }
    
    func placeMarkerConfirmed(x: Int, state: Marker.State) {
        boardView!.board?.addMarker(state: state, x: x)
        hideMarker()
        checkAndProcessGameEnding()
    }
    
    func checkAndProcessGameEnding() {
        if boardView!.board!.isAllMarkersPlaced(state: nil) {
            gameDelegate?.gameComplete(playerName: boardView!.board!.name)
        }
        
    }
    
    func markerAdded(marker: Marker) {
        // TODO: Calculate game over
    }
    
}
