//
//  ViewController.swift
//  Osero_App
//
//  Created by t032fj on 2022/01/26.
//

import UIKit
import SceneKit
import ARKit
import SnapKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    enum BodyType: Int {
        case board = 1
        case othello = 2
        case target = 3
    }
    
    private let uiButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Setup", for: .normal)
        button.titleLabel?.tintColor = .black
        return button
    }()
    
    private let othelloButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.setTitle("othello", for: .normal)
        button.titleLabel?.tintColor = .black
        return button
    }()
    
    let tagetPlane: SCNPlane = {
        let plane = SCNPlane(width: 0.01, height: 0.01)
        plane.cornerRadius = 1
        plane.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.9)
        return plane
    }()
    
    var targetNode: SCNNode?
    var lineNode: SCNNode?
    var startPos = float3(0,0,0)
    var currentPos = float3(0, 0, 0)
    var boardPos = float3(Float(0), 0, 0)
    var boardArray:[float3] = []
    var wboardArray:[[float3]] = []
    
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    
    let boardscene = SCNScene(named: "art.scnassets/board.scn")
    var boardNode = SCNNode()
    var sphereNode: SCNNode?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.scene.physicsWorld.contactDelegate = self
        
        setupLayout()
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    private func setupLayout() {
        
        sceneView.addSubview(uiButton)
        sceneView.addSubview(othelloButton)
        
        uiButton.addTarget(self, action: #selector(self.tapButton(_ :)), for: .touchUpInside)
        uiButton.snp.makeConstraints { make in
            
            make.size.equalTo(100)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(sceneView.snp.bottom).offset(-100)
        }
        
        othelloButton.addTarget(self, action: #selector(self.othelloSetup(_ :)), for: .touchUpInside)
        othelloButton.snp.makeConstraints { make in
            
            make.size.equalTo(100)
            make.right.equalTo(uiButton.snp.left).offset(-30)
            make.bottom.equalTo(sceneView.snp.bottom).offset(-100)
        }
        
        boardNode = (self.boardscene?.rootNode.childNode(withName: "board", recursively: false))!
        boardNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        boardNode.physicsBody?.categoryBitMask = BodyType.board.rawValue
        boardNode.name = "board"
        boardNode.eulerAngles.y = -Float.pi / 2
        
        targetNode = SCNNode(geometry: tagetPlane)
        targetNode?.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        targetNode?.physicsBody?.categoryBitMask = BodyType.target.rawValue
        targetNode?.name = "target"
        targetNode?.isHidden = true
        targetNode?.eulerAngles.x = -Float.pi / 2
        
        lineNode?.isHidden = true
    }
    
    @objc func tapButton(_ sender: UIButton){
        
        guard boardPos == float3(0, 0, 0) else { return }
        
        boardNode.position = SCNVector3(self.currentPos.x, self.currentPos.y, self.currentPos.z)
        boardPos = currentPos
        print("board", self.boardPos.x, self.boardPos.y, self.boardPos.z)
        boardNode.scale = SCNVector3(0.08, 0.005, 0.08)
        sceneView.scene.rootNode.addChildNode(boardNode)
        
        setupBoardArray()
    }
    
    @objc func othelloSetup(_ sender: UIButton){
        
        guard boardPos != float3(0, 0, 0) else { return }
        
        var othelloNode = SCNNode()
        let othelloScene = SCNScene(named: "art.scnassets/othello.scn")
        othelloNode = (othelloScene?.rootNode.childNode(withName: "othello", recursively: false))!
        othelloNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        othelloNode.physicsBody?.categoryBitMask = BodyType.othello.rawValue
        othelloNode.name = "othello"
        othelloNode.scale = SCNVector3(0.007, 0.0007, 0.007)
        //        othelloNode.eulerAngles.z = -Float.pi
        othelloNode.position = SCNVector3(self.wboardArray[0][0].x, self.wboardArray[0][0].y, self.wboardArray[0][0].z)
        
        sceneView.scene.rootNode.addChildNode(othelloNode)
    }
    
    private func setupBoardArray() {
        
        var iniboardPos = float3(boardPos.x + 0.07, boardPos.y + 0.01, boardPos.z - 0.07)
        
        for X in 0...8 {
            for Z in  0...8 {
                
                var tempPos = float3(0, 0, 0)
                tempPos =  float3(iniboardPos.x - 0.02 * Float(X), iniboardPos.y, iniboardPos.z + 0.02 * Float(Z))
                boardArray.append(tempPos)
                
                if boardArray.count == 9 {
                    
                    wboardArray.append(boardArray)
                    boardArray = []
                }
            }
        }
        
        let intArray: [[Int]] = [[3, 3], [4, 4], [3, 4], [4, 3]]
        let intCount = intArray.count
        
        for i in 0...3 {
            
            var othelloNode = SCNNode()
            let othelloScene = SCNScene(named: "art.scnassets/othello.scn")
            othelloNode = (othelloScene?.rootNode.childNode(withName: "othello", recursively: false))!
            othelloNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            othelloNode.physicsBody?.categoryBitMask = BodyType.othello.rawValue
            othelloNode.name = "othello"
            othelloNode.scale = SCNVector3(0.007, 0.0007, 0.007)
            
            var tempInt = intArray[i]
            othelloNode.position = SCNVector3(self.wboardArray[tempInt[0]][tempInt[1]].x,
                                              self.wboardArray[tempInt[0]][tempInt[1]].y,
                                              self.wboardArray[tempInt[0]][tempInt[1]].z)
            
            sceneView.scene.rootNode.addChildNode(othelloNode)
        }
        
        print("hello")
        print(wboardArray)
        //        print(boardArray)
        //        print(boardArray.count)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        targetNode?.isHidden = false
        lineNode?.isHidden = false
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {
            
            let results = self.sceneView.hitTest(self.screenCenter, types: [.existingPlaneUsingGeometry])
            
            if let exisitingPlaneUsingGeometryResult = results.first(where: {$0.type == .existingPlaneUsingGeometry}) {
                let result = exisitingPlaneUsingGeometryResult
                
                self.currentPos = float3(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
                self.targetNode?.position = SCNVector3(self.currentPos.x, self.currentPos.y, self.currentPos.z)
                self.sceneView.scene.rootNode.addChildNode(self.targetNode!)
                
                //ポインタノードの削除
                if self.lineNode != nil { self.lineNode?.removeFromParentNode() } else { }
                
                self.lineNode = self.drawLine(from: SCNVector3(self.startPos), to: SCNVector3(self.currentPos))
                self.sceneView.scene.rootNode.addChildNode(self.lineNode!)
            }
        }
    }
    
    private func drawLine(from: SCNVector3, to: SCNVector3) -> SCNNode {
        
        let source = SCNGeometrySource(vertices: [from, to])
        let element = SCNGeometryElement(data: Data([0, 1]), primitiveType: .line, primitiveCount: 1, bytesPerIndex: 1)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        let node = SCNNode()
        node.geometry = geometry
        node.geometry?.materials.first?.diffuse.contents = UIColor.red
        return node
    }
}
