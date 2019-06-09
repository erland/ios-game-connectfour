//
//  BoardView.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class BoardView : SKSpriteNode, BoardObserver {
    
    var board: Board?
    var cellSize: CGFloat?
    var scale: CGFloat?
    var lastMarker : SKShapeNode?
    var lastMarkersChanged : [SKShapeNode] = []
    var animations : Bool = false
    
    func setup(board: Board, animations: Bool? = true) {
        if animations != nil {
            self.animations = animations!
        }
        self.cellSize = size.width/CGFloat(board.width)
        print("\(size.width) with \(board.width) gives cellSize=\(cellSize!)")
        self.board = board
        self.scale = cellSize!/50.0
        let gridTexture = BoardView.createBoardGridTexture(x: board.width, y: board.height, cellSize: cellSize!)
        
        let gridSprite = SKSpriteNode(texture: gridTexture)
        gridSprite.anchorPoint = CGPoint(x: 0.0,y: 1.0)
        gridSprite.position = CGPoint(x: -1.0, y: 1.0)
        gridSprite.zPosition = 15
        addChild(gridSprite)
        
        /*
         for y in 0..<board.height {
         for x in 0..<board.width {
         if board.shoots[x,y] != nil {
         shootAt(x: x, y: y, hit: board.shoots[x,y]!)
         }
         }
         }
         */
        board.attachObserver(self)
    }
    
    private class func createBoardGridTexture(x: Int, y: Int, cellSize: CGFloat) -> SKTexture? {
        let boardWidth = CGFloat(x)*cellSize
        let boardHeight = CGFloat(y)*cellSize
        let border = SKShapeNode.init(rectOf: CGSize(width: boardWidth,
                                                     height: boardHeight))
        border.strokeColor = UIColor.white
        border.fillColor = .blue
        
        for row in 1..<(y) {
            let line = BoardView.createLine(anchor: CGPoint(x: -boardWidth/2, y: -boardHeight/2),
                                            from: CGPoint(x: 0.0, y: CGFloat(row)*cellSize),
                                            to: CGPoint(x: boardWidth, y: CGFloat(row)*cellSize))
            line.strokeColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.8)
            border.addChild(line)
        }
        for column in 1..<(x) {
            let line = BoardView.createLine(anchor: CGPoint(x: -boardWidth/2, y: -boardHeight/2),
                                            from: CGPoint(x: CGFloat(column)*cellSize, y: 0),
                                            to: CGPoint(x: CGFloat(column)*cellSize, y: boardHeight))
            line.strokeColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.8)
            border.addChild(line)
        }
        let mask = SKSpriteNode(color: .black, size: CGSize(width: boardWidth,height: boardHeight))
        for column in 0..<(y) {
            for row in 0..<(x) {
                let circle = SKShapeNode(circleOfRadius: cellSize/2-cellSize/10)
                circle.fillColor = .white
                circle.lineWidth = 0
                circle.alpha = 0.001
                circle.blendMode = .replace
                
                circle.position = CGPoint(x: -boardWidth/2+CGFloat(column)*cellSize+cellSize/2,
                                          y: -boardHeight/2+CGFloat(row)*cellSize+cellSize/2)
                mask.addChild(circle)
            }
        }
        let crop = SKCropNode()
        crop.maskNode = mask
        crop.addChild(border)
        let view = SKView(frame: CGRect(x: 0, y: 0, width: boardWidth, height: boardHeight))
        return view.texture(from: crop)
    }
    
    private class func createLine(anchor: CGPoint, from:CGPoint, to: CGPoint) -> SKShapeNode {
        let lineShape = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: anchor.x+from.x, y: anchor.y+from.y))
        path.addLine(to: CGPoint(x: anchor.x+to.x, y: anchor.y+to.y))
        lineShape.path = path
        return lineShape
    }
    
    func markerAdded(marker: Marker) {
        let markerView = MarkerView(marker: marker, cellSize: cellSize!)
        markerView.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        markerView.name = "marker"
        markerView.zPosition = 10
        let endPosition = markerView.position.y
        if animations {
            markerView.position.y = cellSize!/2
        }
        addChild(markerView)
        if animations {
            markerView.run(SKAction.move(to: CGPoint(x: markerView.position.x, y: endPosition), duration: 1))
        }
    }
    
    func viewForMarker(marker: Marker) -> MarkerView? {
        var result: MarkerView?
        enumerateChildNodes(withName: "marker") {
            (node, stop) in
            if node is MarkerView {
                let markerView  = node as! MarkerView
                if markerView.marker === marker {
                    result = markerView
                }
            }
        }
        return result
    }
}

