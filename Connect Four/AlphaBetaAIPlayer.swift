//
//  WeightedAIPlayer.swift
//  Othello
//
//  Created by Erland Isaksson on 2019-06-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import Foundation

//
//  MostWinsAIPlayer.swift
//  Othello
//
//  Created by Erland Isaksson on 2019-06-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import Foundation

class AlphaBetaAIPlayer : RandomAIPlayer {
    
    let depth: Int
    let delay: Double
    
    struct WeightedPosition {
        let count: Int
        let position: Int
        
        init(count: Int, position: Int) {
            self.count = count
            self.position = position
        }
    }
    
    init(name: String, depth: Int, delay: Double = 0.0) {
        self.depth = depth
        self.delay = delay
        super.init(name: name)
    }
    
    override func thinkTime() -> Double {
        return delay
    }
    
    override func getNextPosition() -> Int? {
        let potentialPositions = findPotentialPositions(board: board!, state: myState!)
        
        var bestScore = -10
        var bestPosition : Int?
        for pos in potentialPositions {
            let copyOfBoard = Board(name: board!.name, board: board!.board.copy() as! Array2D<Marker>)
            copyOfBoard.addMarker(state: myState!, x: pos)
            print("Evaluating \(myState!) at \(pos)")
            let score = minMax(board: copyOfBoard, depth: 0, isMax: false, alpha: -10, beta: 10)
            if score > bestScore {
                bestScore = score
                bestPosition = pos
            }
        }
        return bestPosition
        
    }
    
    func minMax(board: Board, depth: Int, isMax: Bool, alpha: Int, beta: Int) -> Int {
        let opponentState = (myState == Marker.State.White ? Marker.State.Black : Marker.State.White)
        if depth>self.depth || board.isAllMarkersPlaced(state: nil) {
            let result = evaluateBoard(board: board, state: myState!)
            //print ("Got \(result) with board:")
            board.debugBoard()
            return result
        }
        
        if isMax {
            let possiblePositions = findPotentialPositions(board: board, state: myState!)
            if possiblePositions.count > 0 {
                var best = -10
                var alphaScore = alpha
                for pos in possiblePositions {
                    if depth == 0 {
                        print("Evaluating \(myState!) at \(pos)")
                    }
                    let copyOfBoard = Board(name: board.name, board: board.board.copy() as! Array2D<Marker>)
                    copyOfBoard.addMarker(state: myState!, x: pos)
                    let minMaxScore = minMax(board: copyOfBoard, depth: depth+1, isMax: !isMax, alpha: alphaScore, beta: beta)
                    best = max(best, minMaxScore)
                    alphaScore = max(alphaScore, best)
                    if beta<=alphaScore {
                        break
                    }
                }
                return best
            }else {
                return 0
            }
        }else {
            //board.debugBoard(debug: true)
            let possiblePositions = findPotentialPositions(board: board, state: opponentState)
            if possiblePositions.count > 0 {
                var best = 10
                var betaScore = beta
                for pos in possiblePositions {
                    if depth == 0 {
                        print("Evaluating \(opponentState) at \(pos)")
                    }
                    let copyOfBoard = Board(name: board.name, board: board.board.copy() as! Array2D<Marker>)
                    copyOfBoard.addMarker(state: opponentState, x: pos)
                    let minMaxScore = minMax(board: copyOfBoard, depth: depth+1, isMax: !isMax, alpha: alpha, beta: betaScore)
                    best = min(best, minMaxScore)
                    betaScore = min(betaScore, best)
                    if betaScore<=alpha {
                        break
                    }
                }
                return best
            }else {
                return 0
            }
        }
        
    }
    
    func boardAsString(board: Board) -> String {
        var white = ""
        var black = ""
        for y in 0..<board.height {
            for x in 0..<board.width {
                let cell = board.atPosition(x,y)
                if cell == nil {
                    white = white + "_"
                    black = black + "_"
                }else if cell!.state == Marker.State.White {
                    white = white + "1"
                    black = black + "_"
                }else {
                    white = white + "_"
                    black = black + "1"
                }
            }
        }
        return white+black
    }
    
    func evaluateBoard(board: Board, state: Marker.State) -> Int {
        let opponentState = (state == Marker.State.White ? Marker.State.Black : Marker.State.White)
        var myCount = board.findMaxPotential(state: state)
        var opponentCount = board.findMaxPotential(state: opponentState)
        if myCount>=4 {
            myCount = 10
        }else if opponentCount>=4 {
            opponentCount = 10
        }
        return myCount - opponentCount
    }
    
    func findPotentialPositions(board: Board, state: Marker.State) -> [Int] {
        var potentialPositions : [WeightedPosition] = []
        for x in 0..<board.width {
            if board.atPosition(x, 0) == nil {
                let potentialWins = board.findMaxPotential(state: state, x: x)
                if potentialWins > 0 {
                    let pos = WeightedPosition(count: potentialWins, position: x)
                    potentialPositions.append(pos)
                }
            }
        }

        potentialPositions  = potentialPositions.sorted(by: {$0.count>$1.count})
        var result : [Int] = []
        for pos in potentialPositions {
            result.append(pos.position)
        }
        return result
    }
    
    
    func bestPosition(potentialPos: [WeightedPosition]) -> Int {
        var maxCount = 0
        var selectedPotentialPos: [Int] = []
        for pos in potentialPos {
            if pos.count==maxCount {
                selectedPotentialPos = selectedPotentialPos + [pos.position]
            }else if pos.count>maxCount {
                maxCount = pos.count
                selectedPotentialPos = [pos.position]
            }
        }
        let selectedPos = Int.random(in: 0..<selectedPotentialPos.count)
        return selectedPotentialPos[selectedPos]
    }
    
}
