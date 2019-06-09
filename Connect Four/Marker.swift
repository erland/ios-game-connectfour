//
//  Ship.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-04-30.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

protocol MarkerObserver {
    func markerUpdated(marker: Marker)
}
class Marker : Hashable, NSCopying {
    var observers: [MarkerObserver] = []
    
    enum State {
        case Black
        case White
    }
    
    init(state: State) {
        self.state = state
        self.x = 0
        self.y = 0
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Marker(state: self.state)
        copy.x = self.x
        copy.y = self.y
        return copy
    }
    
    func attachObserver(observer: MarkerObserver) {
        observers.append(observer)
    }
    
    func change(to state: State) {
        self.state = state
    }
    
    private func notifyObservers() {
        for observer in observers {
            observer.markerUpdated(marker: self)
        }
    }
    var x: Int {
        didSet {
            notifyObservers()
        }
    }
    var y: Int {
        didSet {
            notifyObservers()
        }
    }
    var state: State {
        didSet {
            notifyObservers()
        }
    }
    static func == (lhs: Marker, rhs: Marker) -> Bool {
        return lhs === rhs
    }
    var hashValue: Int {
        return x.hashValue ^ y.hashValue
    }
}

