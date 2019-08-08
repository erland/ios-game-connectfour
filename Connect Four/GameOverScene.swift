//
//  GameOverScene.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameOverScene: SKScene {
    var gameDelegate: GameDelegate?
    var boardView: BoardView?
    var playerState: Marker.State?
    var openedTime: TimeInterval?
    
    override func sceneDidLoad() {
        localize()
    }
    
    func setup(delegate: GameDelegate, board: Board, playerState: Marker.State) {
        self.gameDelegate = delegate
        self.playerState = playerState
        
        self.boardView = childNode(withName:"board") as? BoardView
        self.boardView?.setup(board: board, animations: false)
    }
    
    override func didMove(to view: SKView) {
        let winnerText = childNode(withName: "winnerText") as? SKLabelNode
        openedTime = NSDate().timeIntervalSince1970
        let winner = boardView!.board!.findWinner()
        if winner == nil {
            winnerText?.text = NSLocalizedString("itIsADraw", comment: "itIsADraw")
        }else if winner == playerState {
            winnerText?.text = NSLocalizedString("youWon", comment: "youWon")
        }else {
            winnerText?.text = NSLocalizedString("youLost", comment: "youLost")
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // We need to ensure the sceen is shown for 2 seconds before we allow player to continue
        if openedTime!<NSDate().timeIntervalSince1970-2 {
            gameDelegate?.finishedGame()
        }
    }
}
