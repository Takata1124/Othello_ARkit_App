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
    
    enum othelloType: Int {
        
        case none = 0
        case black = 1
        case white = 2
        case wall = 9
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
    
    let availablePlane: SCNPlane = {
        
        let plane = SCNPlane(width: 0.015, height: 0.015)
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
    let DIRECTIONS_YX = [[-1, -1], [+0, -1], [+1, -1],
                         [-1, +0],           [+1, +0],
                         [-1, +1], [+0, +1], [+1, +1]]
    
    var boardsitu: [[Int]] = [[9, 9, 9, 9, 9, 9, 9, 9, 9, 9],
                              [9, 0, 0, 0, 0, 0, 0, 0, 0, 9],
                              [9, 0, 0, 0, 0, 0, 0, 0, 0, 9],
                              [9, 0, 0, 0, 0, 0, 0, 0, 0, 9],
                              [9, 0, 0, 0, 2, 1, 0, 0, 0, 9],
                              [9, 0, 0, 0, 1, 2, 0, 0, 0, 9],
                              [9, 0, 0, 0, 0, 0, 0, 0, 0, 9],
                              [9, 0, 0, 0, 0, 0, 0, 0, 0, 9],
                              [9, 0, 0, 0, 0, 0, 0, 0, 0, 9],
                              [9, 9, 9, 9, 9, 9, 9, 9, 9, 9]]
    
    var boardBoolArray: [[Bool]] = []
    
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    let boardscene = SCNScene(named: "art.scnassets/board.scn")
    var boardNode = SCNNode()
    var sphereNode: SCNNode?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
        let scene = SCNScene()
        
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
        boardNode.name = "board"
        
        targetNode = SCNNode(geometry: tagetPlane)
        targetNode?.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        targetNode?.name = "target"
        targetNode?.isHidden = true
        targetNode?.eulerAngles.x = -Float.pi / 2

        lineNode?.isHidden = true
    }
    
    @objc func tapButton(_ sender: UIButton){
        
        guard targetNode != nil else { return }
        guard boardPos == float3(0, 0, 0) else { return }
        
        boardNode.position = SCNVector3(self.currentPos.x, self.currentPos.y, self.currentPos.z)
        boardPos = currentPos
        boardNode.scale = SCNVector3(0.08, 0.005, 0.08)
        boardNode.eulerAngles.y = -Float.pi/2
        sceneView.scene.rootNode.addChildNode(boardNode)
        
        setupBoardArray()
    }
    
    @objc func othelloSetup(_ sender: UIButton){
        
        guard targetNode != nil else { return }
        guard boardPos != float3(0, 0, 0) else { return }
        
        var othelloNode = SCNNode()
        let othelloScene = SCNScene(named: "art.scnassets/othello.scn")
        othelloNode = (othelloScene?.rootNode.childNode(withName: "othello", recursively: false))!
        othelloNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        othelloNode.name = "othello"
        othelloNode.scale = SCNVector3(0.007, 0.0007, 0.007)
        othelloNode.position = SCNVector3(self.wboardArray[0][0].x, self.wboardArray[0][0].y, self.wboardArray[0][0].z)
        
        sceneView.scene.rootNode.addChildNode(othelloNode)
    }
    
    private func setupBoardArray() {
        
        var iniboardPos = float3(boardPos.x - 0.07, boardPos.y + 0.01, boardPos.z - 0.07)
        
        for X in 0...7 {
            for Z in  0...7 {
                
                var tempPos = float3(0, 0, 0)
                tempPos =  float3(iniboardPos.x + 0.02 * Float(X), iniboardPos.y, iniboardPos.z + 0.02 * Float(Z))
                boardArray.append(tempPos)
                
                if boardArray.count == 8 {
                    
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
            othelloNode.name = "othello"
            othelloNode.scale = SCNVector3(0.007, 0.0007, 0.007)
            
            //初期白設定
            if i == 0 || i == 1 {
                
                othelloNode.eulerAngles.z = -Float.pi
            }
            
            var tempInt = intArray[i]
            
            othelloNode.position = SCNVector3(self.wboardArray[tempInt[0]][tempInt[1]].x,
                                              self.wboardArray[tempInt[0]][tempInt[1]].y,
                                              self.wboardArray[tempInt[0]][tempInt[1]].z)
            
            sceneView.scene.rootNode.addChildNode(othelloNode)
        }
        
        
        let availablePointArray = setupAvailable(selfOthello: othelloType.black.rawValue)
        setupAvailablePlane(_availablePointArray: availablePointArray)
    }
    
    //石を置ける箇所を3Dモデル上で表示
    func setupAvailablePlane(_availablePointArray: [[Int]]) {
        
        for array in _availablePointArray {
            
            var availablePlaneNode = SCNNode()
            availablePlaneNode = SCNNode(geometry: availablePlane)
            availablePlaneNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            availablePlaneNode.eulerAngles.x = -Float.pi / 2
            
            availablePlaneNode.position = SCNVector3(self.wboardArray[array[0]][array[1]].x,
                                                     self.wboardArray[array[0]][array[1]].y,
                                                     self.wboardArray[array[0]][array[1]].z)
            
            sceneView.scene.rootNode.addChildNode(availablePlaneNode)
        }
    }
    
    //オセロを置ける箇所の座標を返す
    func setupAvailable(selfOthello: Int) -> [[Int]] {
        
        var tempBool: Bool = false
        var tempBoolArray: [Bool] = []
        
        for _y in 1...8 {
            for _x in 1...8 {
                
                tempBool = getstraightArray(y: _y, x: _x, selfStone: selfOthello)
                tempBoolArray.append(tempBool)
                
                if tempBoolArray.count == 8 {
                    
                    boardBoolArray.append(tempBoolArray)
                    tempBoolArray = []
                }
            }
        }
        
        var tempArray_x: Int = 0
        var tempArray_y: Int = 0
        var tempArray_xy: [[Int]] = []
        
        //石を置ける場所の配列を求める
        for array in boardBoolArray {

            var _arrayCount = array.count - 1
            
            if !array.contains(true) {
                
                tempArray_y += 1
                continue
            } else {
                
                for i in 0..._arrayCount {
                    
                    if array[i] == true {
                        var tempXY:[Int] = []
                        tempXY.append(tempArray_y)
                        tempXY.append(i)
                        tempArray_xy.append(tempXY)
                    }
                }
                
                tempArray_y += 1
            }
        }
        
        return tempArray_xy
    }
    
    //座標から放射線状に存在する石を返す
    func getstraightArray(y: Int, x: Int, selfStone: Int) -> Bool {
        
        //stoneのnoneチェック
        let stoneValue: Int = boardsitu[y][x]
        if stoneValue != 0 {
//            print("石が置かれています")
            return false
            
        } else {
//            print("石を置けます")
        }
        
        var straighArray: [[Int]] = []
        var available: Bool = false
        
        for i in 0...7 {
            
            let derect = DIRECTIONS_YX[i]
            let dx: Int = derect[0]
            let dy: Int = derect[1]
 
            var roop: Bool = true
            var roopTime: Int = 1
            
            var tempStraighArray:[Int] = []
            
            while roop == true {
                
                let x_dx = x + dx * roopTime
                let y_dy = y + dy * roopTime
                let stoneInt: Int = boardsitu[y_dy][x_dx]
                
                tempStraighArray.append(stoneInt)
                
                if stoneInt == 0 || stoneInt == 9 {
                    
                    roop = false
                    straighArray.append(tempStraighArray)
                    
                } else {
                    
                    roop = true
                    roopTime += 1
                }
            }
        }
        
        for array in straighArray {
            
            if array.count > 1 && array.contains(selfStone) && array[0] != selfStone {
                available = true
            } else {
                continue
            }
        }
        
        return available
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
