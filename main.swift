// Started at 9:46 6-4-2022

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var playerPaddle : SKSpriteNode?
    var ball : SKSpriteNode?
    var label : SKLabelNode?
    
    var startImpulse : CGFloat = 50
    var isGameOver = false
    var brickCount = 9
    
    enum bitMasks : UInt32 {
        case edgeBitMask = 0b1
        case playerPaddleBitMask = 0b10
        case ballBitMask = 0b100
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        playerPaddle = self.childNode(withName: "playerPaddle") as? SKSpriteNode
        ball = self.childNode(withName: "ball") as? SKSpriteNode
        
        let edgePhysicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        edgePhysicsBody.categoryBitMask = bitMasks.edgeBitMask.rawValue
        edgePhysicsBody.contactTestBitMask = bitMasks.ballBitMask.rawValue
        edgePhysicsBody.collisionBitMask = bitMasks.ballBitMask.rawValue
        edgePhysicsBody.friction = 0
        edgePhysicsBody.restitution = 1
        edgePhysicsBody.isDynamic = false
        self.physicsBody = edgePhysicsBody
        self.name = "scene"
        
        ball?.physicsBody?.contactTestBitMask = bitMasks.edgeBitMask.rawValue | bitMasks.playerPaddleBitMask.rawValue
        ball?.physicsBody?.collisionBitMask = bitMasks.edgeBitMask.rawValue | bitMasks.playerPaddleBitMask.rawValue
        ball?.physicsBody?.applyImpulse(CGVector(dx: startImpulse, dy: startImpulse))
        
        label = SKLabelNode(fontNamed: "Game Over")
        label?.fontColor = UIColor.white
        label?.fontSize = 80
        label?.position = CGPoint(x: 0, y: 0)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.size = self.frame.size
                scene.scaleMode = self.scaleMode
                self.view?.presentScene(scene)
            }
        }
        
        for t in touches {
            let xLocation = t.location(in: self).x
            playerPaddle?.position = CGPoint(x: xLocation, y: (playerPaddle?.position.y)!)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let xLocation = t.location(in: self).x
            playerPaddle?.position = CGPoint(x: xLocation, y: (playerPaddle?.position.y)!)
        }
     }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var ballNode : SKNode!
        var otherNode : SKNode!
        
        let xPos = contact.contactPoint.x
        let yPos = contact.contactPoint.y
        
        if contact.bodyA.node?.name == "ball" {
            ballNode = contact.bodyA.node
            otherNode = contact.bodyB.node
        } else if contact.bodyB.node?.name == "ball" {
            ballNode = contact.bodyB.node
            otherNode = contact.bodyA.node
        }
        
        let dx = ballNode.physicsBody?.velocity.dx
        let dy = ballNode.physicsBody?.velocity.dy
        
        if otherNode.name == "brick" || otherNode.name == "playerPaddle" {
            if otherNode.name == "brick" {
                otherNode.removeFromParent()
                brickCount -= 1
                if brickCount == 0 {
                    isGameOver = true
                    label?.text = "You win!"
                    self.addChild(label!)
                }
            }
            
            if yPos <= otherNode.frame.minY + 2 {
                ballNode.physicsBody?.velocity.dy = 0
                ballNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -startImpulse))
            } else if yPos >= otherNode.frame.maxY - 2 {
                ballNode.physicsBody?.velocity.dy = 0
                ballNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: startImpulse))
            }
            
            if xPos <= otherNode.frame.minX + 2 {
                ballNode.physicsBody?.velocity.dx = 0
                ballNode.physicsBody?.applyImpulse(CGVector(dx: -startImpulse, dy: 0))
            } else if xPos >= otherNode.frame.maxX - 2 {
                ballNode.physicsBody?.velocity.dx = 0
                ballNode.physicsBody?.applyImpulse(CGVector(dx: startImpulse, dy: 0))
            }
            
        } else if otherNode.name == "scene" {
            if yPos <= self.frame.minY + 5 {
                isGameOver = true
                label?.text = "You lose!"
                self.addChild(label!)
            } else if yPos >= self.frame.maxY - 2 {
                ballNode.physicsBody?.velocity.dy = 0
                ballNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -startImpulse))
            }
            
            if xPos <= otherNode.frame.minX + 5 {
                ballNode.physicsBody?.velocity.dx = 0
                ballNode.physicsBody?.applyImpulse(CGVector(dx: startImpulse, dy: 0))
            } else if xPos >= otherNode.frame.maxX - 5 {
                ballNode.physicsBody?.velocity.dx = 0
                ballNode.physicsBody?.applyImpulse(CGVector(dx: -startImpulse, dy: 0))
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameOver {
            self.isPaused = true
        }
    }
}


import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var playerPaddle : SKSpriteNode?
    var opponentPaddle : SKSpriteNode?
    var ball : SKSpriteNode?
    var playerScoreLabel : SKLabelNode?
    var opponentScoreLabel : SKLabelNode?
    
    var startImpulse : CGFloat = 20
    var difficulty : TimeInterval = 1
    var playerScore = 0
    var opponentScore = 0
    var isBallResting = false
    var maxScore = 11
    var isGameOver = false
    var didPlayerScoreLast = false
    
    enum bitMasks : UInt32 {
        case edgeBitMask = 0b1
        case paddleBitMask = 0b10
        case ballBitMask = 0b100
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        playerPaddle = self.childNode(withName: "playerPaddle") as? SKSpriteNode
        opponentPaddle = self.childNode(withName: "opponentPaddle") as? SKSpriteNode
        ball = self.childNode(withName: "ball") as? SKSpriteNode
        playerScoreLabel = self.childNode(withName: "playerScoreLabel") as? SKLabelNode
        opponentScoreLabel = self.childNode(withName: "opponentScoreLabel") as? SKLabelNode
        
        let edgePhysicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        edgePhysicsBody.friction = 0
        edgePhysicsBody.restitution = 1
        edgePhysicsBody.categoryBitMask = bitMasks.edgeBitMask.rawValue
        edgePhysicsBody.collisionBitMask = bitMasks.ballBitMask.rawValue
        edgePhysicsBody.contactTestBitMask = bitMasks.ballBitMask.rawValue
        self.physicsBody = edgePhysicsBody
        self.name = "scene"
        
        ball?.physicsBody?.collisionBitMask = bitMasks.edgeBitMask.rawValue | bitMasks.paddleBitMask.rawValue
        ball?.physicsBody?.contactTestBitMask = bitMasks.edgeBitMask.rawValue | bitMasks.paddleBitMask.rawValue
        ball?.physicsBody?.applyImpulse(CGVector(dx: startImpulse, dy: startImpulse))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            
            if isGameOver {
                if let scene = SKScene(fileNamed: "GameScene") {
                    scene.size = self.size
                    scene.scaleMode = self.scaleMode
                    self.view?.presentScene(scene)
                }
            } else if isBallResting {
                ball?.position = CGPoint(x: 0, y: 0)
                if didPlayerScoreLast {
                    ball?.physicsBody?.applyImpulse(CGVector(dx: startImpulse, dy: startImpulse))
                } else if !didPlayerScoreLast {
                    ball?.physicsBody?.applyImpulse(CGVector(dx: -startImpulse, dy: -startImpulse))
                }
                
                isBallResting = false
            } else {
                let xlocation = t.location(in: self).x
                playerPaddle?.position = CGPoint(x: xlocation, y: (playerPaddle?.position.y)!)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let xlocation = t.location(in: self).x
            playerPaddle?.position = CGPoint(x: xlocation, y: (playerPaddle?.position.y)!)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var ballNode : SKNode!
        var otherNode : SKNode!
        
        if contact.bodyA.node?.name == "ball" {
            ballNode = contact.bodyA.node
            otherNode = contact.bodyB.node
        } else if contact.bodyB.node?.name == "ball" {
            ballNode = contact.bodyB.node
            otherNode = contact.bodyA.node
        }
        
        let xPos = contact.contactPoint.x
        let yPos = contact.contactPoint.y
        
        if otherNode.name == "scene" {
            if yPos >= otherNode.frame.maxY - 5 {
                playerScore += 1
                playerScoreLabel?.text = String(playerScore)
                ballNode.physicsBody?.isResting = true
                isBallResting = true
                
                didPlayerScoreLast = true
                
                if playerScore == maxScore {
                    isGameOver = true
                    playerScoreLabel?.text = "You win!"
                    self.isPaused = true
                }
            } else if yPos <= otherNode.frame.minY + 5 {
                opponentScore += 1
                opponentScoreLabel?.text = String(opponentScore)
                ballNode.physicsBody?.isResting = true
                isBallResting = true
                
                didPlayerScoreLast = false
                
                if opponentScore == maxScore {
                    isGameOver = true
                    playerScoreLabel?.text = "You lose!"
                    self.isPaused = true
                }
            }
            if xPos >= otherNode.frame.maxX - 2 {
                ballNode.physicsBody?.velocity.dx = 0
                ballNode?.physicsBody?.applyImpulse(CGVector(dx: -startImpulse, dy: 0))
            } else if xPos <= otherNode.frame.minX + 2 {
                ballNode.physicsBody?.velocity.dx = 0
                ballNode?.physicsBody?.applyImpulse(CGVector(dx: startImpulse, dy: 0))
            }
        } else if otherNode.name == "playerPaddle" || otherNode.name == "opponentPaddle" {
            if xPos >= otherNode.frame.maxX - 20 {
                ballNode.physicsBody?.velocity.dx = 0
                ballNode?.physicsBody?.applyImpulse(CGVector(dx: startImpulse, dy: 0))
            } else if xPos <= otherNode.frame.minX + 20 {
                ballNode.physicsBody?.velocity.dx = 0
                ballNode?.physicsBody?.applyImpulse(CGVector(dx: -startImpulse, dy: 0))
            } else if xPos > otherNode.frame.midX + 20 {
                ballNode.physicsBody?.velocity.dx = 0
                ballNode.physicsBody?.velocity.dy = 0
                ballNode?.physicsBody?.applyImpulse(CGVector(dx: startImpulse/2, dy: startImpulse * 1.5))
            }  else if xPos < otherNode.frame.midX - 20 {
                ballNode.physicsBody?.velocity.dx = 0
                ballNode.physicsBody?.velocity.dy = 0
                ballNode?.physicsBody?.applyImpulse(CGVector(dx: -startImpulse/2, dy: startImpulse * 1.5))
            } else if xPos <= otherNode.frame.midX + 20 || xPos >= otherNode.frame.midX - 20 {
                ballNode.physicsBody?.velocity.dx = 0
                ballNode.physicsBody?.velocity.dy = 0
                ballNode?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: startImpulse * 2))
            }
            if yPos <= otherNode.frame.minY + 2 {
                ballNode.physicsBody?.velocity.dy = -(ballNode.physicsBody?.velocity.dy)!
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        let paddleMoveAction = SKAction.moveTo(x: (ball?.position.x)!, duration: difficulty)
        opponentPaddle?.run(paddleMoveAction)
    }
}

// Ended at 1:06 6-3-2022
