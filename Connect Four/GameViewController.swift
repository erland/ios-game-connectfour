//
//  GameViewController.swift
//  Connect Four
//
//  Created by Erland Isaksson on 2019-06-09.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, GameDelegate {
    var board : Board?
    var network : NetworkProtocol?
    var matchMakingScene : MatchMakingScene?
    var opponentPlayer : Player?
    var randomAIPlayer : RandomAIPlayer?
    var playerState: Marker.State?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        network = NetworkProtocol(gameDelegate: self)
        startMatchMaking()
    }

    func finishedGame() {
        startMatchMaking()
    }
    
    func startMatchMaking() {
        opponentPlayer = nil
        board = nil
        playerState = nil
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        // Create and configure the scene.
        let scene = MatchMakingScene(fileNamed: "MatchMakingScene")
        scene?.setup(delegate: self)
        scene?.scaleMode = .aspectFit
        matchMakingScene = scene
        // Present the scene.
        skView.presentScene(scene)
        randomAIPlayer = RandomAIPlayer(name: "AI (very easy)")
        matchMakingScene?.addOpponent(name: "AI (very easy)")
        
        if let network = network {
            for player in network.players {
                matchMakingScene?.addOpponent(name: player)
            }
        }
        network?.sendReadyForMatchmaking()
    }
    
    func addOpponent(player: String) {
        matchMakingScene?.addOpponent(name: player)
    }
    func removeOpponent(player: String) {
        matchMakingScene?.removeOpponent(name: player)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func selectedOpponent(player: String, state: Marker.State) {
        matchMakingScene = nil
        if player == "AI (very easy)" {
            opponentPlayer = randomAIPlayer
        }else {
            opponentPlayer = NetworkPlayer(network: network!, name: player)
        }
        print("Telling opponent it can start place ships")
        playerState = state
        opponentPlayer?.readyToPlay(delegate: self,
                                    state: (state == Marker.State.Black ? Marker.State.White : Marker.State.Black))
        showGameScene()
    }
    
    func readyToPlay(player: String, state: Marker.State) {
        print("Got readyToPlay with \(state)")
        if playerState == nil {
            playerState = state
        }
        if opponentPlayer == nil {
            opponentPlayer = NetworkPlayer(network: network!, name: player)
        }
        showGameScene()
    }
    func showGameScene() {
        // Create and configure the scene.
        if let scene = GameScene(fileNamed: "GameScene") {
            let skView = view as! SKView
            board = Board(name: "Player")
            scene.setup(delegate: self, board: board!, playerState: playerState!)
            if playerState == Marker.State.White {
                scene.readyForMarkerPlacement()
            }
            scene.scaleMode = .aspectFit
            
            // Present the scene.
            skView.presentScene(scene)
        }
    }
    
    func skipPlaceMarker(playerName: String) {
        print("Skip place marker \(playerName)")
        if playerName == board?.name {
            print("Telling opponent to place marker")
            opponentPlayer?.readyForMarkerPlacement(delegate: self)
        }else {
            let skView = view as! SKView
            if skView.scene is GameScene {
                let gameScene = skView.scene as! GameScene
                print("Telling player to place marker")
                gameScene.readyForMarkerPlacement()
            }
        }
    }
    
    func placeMarker(playerName: String, x: Int, state: Marker.State) {
        print("Shot from \(playerName)")
        if playerName == board?.name {
            print("Forwarding placed marker to opponent at \(x)")
            opponentPlayer?.placeMarker(delegate: self, x: x, state: state)
        }else {
            let skView = view as! SKView
            if skView.scene is GameScene {
                let gameScene = skView.scene as! GameScene
                print("Forwarding opponent placed marker at \(x) to scene")
                gameScene.opponentPlaceMarker(x: x, state: state)
            }
        }
    }
    
    func placeMarkerConfirmed(playerName: String, x: Int, state: Marker.State) {
        print("Confirmation from \(playerName)")
        if playerName == board?.name {
            print("Forwarding placement confirmation to opponent at \(x)")
            opponentPlayer?.placeMarkerConfirmed(delegate: self, x: x, state: state)
        }else {
            let skView = view as! SKView
            if skView.scene is GameScene {
                let gameScene = skView.scene as! GameScene
                print("Forwarding opponent placement confirmation at \(x) to scene")
                gameScene.placeMarkerConfirmed(x: x, state: state)
                DispatchQueue.global().asyncAfter(deadline: .now() + 1.0, execute: {
                    self.opponentPlayer?.readyForMarkerPlacement(delegate: self)
                })
            }
        }
    }
    
    func gameComplete(playerName: String) {
        if playerName == board?.name {
            opponentPlayer?.gameComplete(delegate: self)
        }
        let skView = view as! SKView
        
        // Create and configure the scene.
        let scene = GameOverScene(fileNamed: "GameOverScene")
        scene?.setup(delegate: self, board: board!, playerState: playerState!)
        scene?.scaleMode = .aspectFit
        
        // Present the scene.
        skView.presentScene(scene)
        network?.sendFinishedPlaying()
    }
    
    
}
