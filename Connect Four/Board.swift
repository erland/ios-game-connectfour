//
//  Board.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-04-29.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

protocol BoardObserver : class {
    func markerAdded(marker: Marker)
}
class Board {
    let name: String
    let width: Int = 7
    let height: Int = 7
    let board: Array2D<Marker>
    var markers: Set<Marker> = Set()
    var observers: [BoardObserver] = []
    let debug = false
    
    init(name: String) {
        self.name = name
        self.board = Array2D<Marker>(columns: width, rows: height)
    }
    
    init(name: String, board: Array2D<Marker>) {
        self.name = name
        self.board = board
    }
    
    func attachObserver(_ observer: BoardObserver) {
        for marker in markers {
            observer.markerAdded(marker: marker)
        }
        observers.append(observer)
    }
    
    func detachObserver(_ observer: BoardObserver) {
        if let index = (self.observers.firstIndex(where: { $0 === observer })) {
            self.observers.remove(at: index)
        }
    }
    
    func atPosition(_ x: Int, _ y: Int) -> Marker? {
        if x>=0 && x<width && y>=0 && y<height {
            return board[x, y]
        }else {
            return nil
        }
    }
    
    func addMarker(state: Marker.State, x: Int) {
        if debug {
            print("Board(\(name)): Trying to add \(state) at: \(x)")
        }
        if x<0 || x >= width {
            // Outside board
            if debug {
                print("Outside board")
            }
            return
        }
        if board[x,0] != nil {
            // Already occupied
            if debug {
                print("Already occupied")
            }
            return
        }
        var y = 0
        while y<7 && board[x,y] == nil {
            y = y + 1
        }
        y = y - 1
        
        let m = Marker(state: state)
        m.x = x
        m.y = y
        board[x,y] = m
        markers.insert(m)
        for observer in observers {
            observer.markerAdded(marker: m)
        }
        if debug {
            print("Board(\(name)): Added \(state) at: \(x),\(y)")
            debugBoard()
        }
    }
    

    private func findInDirection(state: Marker.State, x: Int, y: Int, offsetX: Int, offsetY: Int) -> [Marker] {
        if x+offsetX < 0 || x+offsetX >= width || y+offsetY < 0 || y+offsetY >= height {
            // Reached end of board
            return []
        }
        if board[x+offsetX,y+offsetY] == nil {
            // Reached empty position
            return []
        }else if board[x+offsetX,y+offsetY]!.state != state {
            // Found marker with other state
            return []
        }else {
            // Reversed marker, keep searching
            let result = [board[x+offsetX,y+offsetY]!]
            let markers = findInDirection(state:state, x:x+offsetX, y:y+offsetY, offsetX:offsetX, offsetY:offsetY)
            return result + markers
        }
    }
    
    func isAllMarkersPlaced(state: Marker.State?) -> Bool {
        var result = true
        for y in 0..<height {
            for x in 0..<width {
                if board[x,y] == nil {
                    result = false
                    break
                }
            }
            if !result {
                break
            }
        }
        if !result && findWinner() != nil {
            result = true
        }
        return result
    }
    
    func findWinner() -> Marker.State? {
        var result : Marker.State?
        for y in 0..<height {
            for x in 0..<width {
                if board[x,y] != nil {
                    let m = board[x,y]!
                    var markers = findInDirection(state: m.state, x: x, y: y, offsetX: 0, offsetY: -1) + [m] + findInDirection(state: m.state, x: x, y: y, offsetX: 0, offsetY: 1)
                    if markers.count>=4 {
                        result = m.state
                        break
                    }
                    markers = findInDirection(state: m.state, x: x, y: y, offsetX: -1, offsetY: 0) + [m] + findInDirection(state: m.state, x: x, y: y, offsetX: 1, offsetY: 0)
                    if markers.count>=4 {
                        result = m.state
                        break
                    }
                    markers = findInDirection(state: m.state, x: x, y: y, offsetX: -1, offsetY: -1) + [m] + findInDirection(state: m.state, x: x, y: y, offsetX: 1, offsetY: 1)
                    if markers.count>=4 {
                        result = m.state
                        break
                    }
                    markers = findInDirection(state: m.state, x: x, y: y, offsetX: 1, offsetY: -1) + [m] + findInDirection(state: m.state, x: x, y: y, offsetX: -1, offsetY: 1)
                    if markers.count>=4 {
                        result = m.state
                        break
                    }
                }
            }
            if result != nil {
                break
            }
        }
        return result
    }
    
    func debugBoard(debug: Bool? = nil) {
        if self.debug || (debug != nil && debug!) {
            
            print("Board contents")
            for y in 0..<height {
                for x in 0..<width {
                    if board[x,y] != nil {
                        if board[x,y]?.state == Marker.State.Black {
                            print("X", terminator: "")
                        }else {
                            print("O", terminator: "")
                        }
                    }else {
                        print("_", terminator: "")
                    }
                }
                print()
            }
        }
    }
    
}
