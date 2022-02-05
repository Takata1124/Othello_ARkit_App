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
    
    private let boardButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Setup", for: .normal)
        button.titleLabel?.tintColor = .black
        return button
    }()
    
    var boardButtonSelectBool: Bool? {
        didSet {
            if boardButtonSelectBool == true {
                boardButton.backgroundColor = .lightGray
                boardButton.isEnabled = true
            } else {
                boardButton.backgroundColor = .red
                boardButton.isEnabled = false
            }
        }
    }
    
    private let othelloButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.setTitle("othello", for: .normal)
        button.titleLabel?.tintColor = .black
        return button
    }()
    
    var othelloButtonSelectBool: Bool? {
        didSet {
            if othelloButtonSelectBool == true {
                othelloButton.backgroundColor = .lightGray
                othelloButton.isEnabled = true
            } else {
                othelloButton.backgroundColor = .red
                othelloButton.isEnabled = false
            }
        }
    }
    
    private let passButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.setTitle("pass", for: .normal)
        button.titleLabel?.tintColor = .black
        return button
    }()
    
    var passButtonSelectBool: Bool? {
        didSet {
            if passButtonSelectBool == true {
                passButton.backgroundColor = .lightGray
                passButton.isEnabled = true
            } else {
                passButton.backgroundColor = .red
                passButton.isEnabled = false
            }
        }
    }
    
    private let clearButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.setTitle("clear", for: .normal)
        button.titleLabel?.tintColor = .black
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.setTitle("back", for: .normal)
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
        plane.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.5)
        return plane
    }()
    
    let selectPlane: SCNPlane = {
        let plane = SCNPlane(width: 0.015, height: 0.015)
        plane.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(1)
        return plane
    }()
    
    var targetNode: SCNNode?
    var selectNode: SCNNode?
    var lineNode: SCNNode?
    var startPos = float3(0,0,0)
    var currentPos = float3(0, 0, 0)
    var boardPos = float3(Float(0), 0, 0)
    var selectPos = float3(0, 0, 0)
    var selectIndex: Int = 0
    var boardArray:[float3] = []
    var wboardArray:[[float3]] = []
    let derection_yx = [[-1, -1], [-1, +0], [-1, +1],
                        [+0, -1],           [+0, +1],
                        [+1, -1], [+1, +0], [+1, +1]]
    
    var boardSituation: [[Int]] = [[9, 9, 9, 9, 9, 9, 9, 9, 9, 9],
                                   [9, 0, 0, 0, 0, 0, 0, 0, 0, 9],
                                   [9, 0, 0, 0, 0, 0, 0, 0, 0, 9],
                                   [9, 0, 0, 0, 0, 0, 0, 0, 0, 9],
                                   [9, 0, 0, 0, 0, 0, 0, 0, 0, 9],
                                   [9, 0, 0, 0, 0, 0, 0, 0, 0, 9],
                                   [9, 0, 0, 0, 0, 0, 0, 0, 0, 9],
                                   [9, 0, 0, 0, 0, 0, 0, 0, 0, 9],
                                   [9, 0, 0, 0, 0, 0, 0, 0, 0, 9],
                                   [9, 9, 9, 9, 9, 9, 9, 9, 9, 9]]
    
    var proceedBoard: [[Int]] = [[0, 0, 0, 0, 0, 0, 0, 0],
                                 [0, 0, 0, 0, 0, 0, 0, 0],
                                 [0, 0, 0, 0, 0, 0, 0, 0],
                                 [0, 0, 0, 0, 0, 0, 0, 0],
                                 [0, 0, 0, 0, 0, 0, 0, 0],
                                 [0, 0, 0, 0, 0, 0, 0, 0],
                                 [0, 0, 0, 0, 0, 0, 0, 0],
                                 [0, 0, 0, 0, 0, 0, 0, 0]]
    
    var rotationCountBoard: [[Int]] = [[1, 1, 1, 1, 1, 1, 1, 1],
                                       [1, 1, 1, 1, 1, 1, 1, 1],
                                       [1, 1, 1, 1, 1, 1, 1, 1],
                                       [1, 1, 1, 1, 1, 1, 1, 1],
                                       [1, 1, 1, 1, 1, 1, 1, 1],
                                       [1, 1, 1, 1, 1, 1, 1, 1],
                                       [1, 1, 1, 1, 1, 1, 1, 1],
                                       [1, 1, 1, 1, 1, 1, 1, 1]]
    
    
    
    var boardBoolArray: [[Bool]] = []
    var boardReveseCountArray: [[Int]] = []
    var availablePointArray: [[Int]] = []
    
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    let boardscene = SCNScene(named: "art.scnassets/board.scn")
    var boardNode = SCNNode()
    let arrowScene = SCNScene(named: "art.scnassets/arrow.scn")
    var arrowNode = SCNNode()
    
    var turnCount: Int = 0
    
    var now_othelloType: Int? {
        didSet {
            let blackturnNode = sceneView.scene.rootNode.childNode(withName: "blackTurn", recursively: true)
            let whiteturnNode = sceneView.scene.rootNode.childNode(withName: "whiteTurn", recursively: true)
            
            switch now_othelloType{
                
            case othelloType.black.rawValue:
                whiteturnNode?.isHidden = true
                blackturnNode?.isHidden = false
            case othelloType.white.rawValue:
                whiteturnNode?.isHidden = false
                blackturnNode?.isHidden = true
                
            default:
                fatalError("print")
            }
        }
    }
    
    var straightArray: [[Int]] = []
    var setupPoint: [Int] = []
    var setupBoardPoint: [Int] = []
    //ゲームの一時中断
    var gameContnue: Bool?
    var availableAreaCount: Int = 64
    //ゲームモードの選択
    var gameMode: Int?
    var cpuOthelloType: Int = othelloType.white.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.scene.physicsWorld.contactDelegate = self
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        setupLayout()
    }
    
    private func setupLayout() {
        
        sceneView.addSubview(boardButton)
        sceneView.addSubview(othelloButton)
        sceneView.addSubview(passButton)
        sceneView.addSubview(clearButton)
        sceneView.addSubview(backButton)
        
        boardButton.addTarget(self, action: #selector(self.boardSetup(_ :)), for: .touchUpInside)
        boardButton.snp.makeConstraints { make in
            
            make.size.equalTo(100)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(sceneView.snp.bottom).offset(-50)
        }
        
        othelloButton.addTarget(self, action: #selector(self.othelloSetup(_ :)), for: .touchUpInside)
        othelloButton.snp.makeConstraints { make in
            
            make.size.equalTo(100)
            make.right.equalTo(boardButton.snp.left).offset(-30)
            make.bottom.equalTo(sceneView.snp.bottom).offset(-50)
        }
        
        passButton.addTarget(self, action: #selector(self.passSetup(_ :)), for: .touchUpInside)
        passButton.snp.makeConstraints { make in
            
            make.size.equalTo(100)
            make.left.equalTo(boardButton.snp.right).offset(30)
            make.bottom.equalTo(sceneView.snp.bottom).offset(-50)
        }
        
        clearButton.addTarget(self, action: #selector(self.clearSetup(_ :)), for: .touchUpInside)
        clearButton.snp.makeConstraints { make in
            
            make.size.equalTo(100)
            make.right.equalTo(sceneView.snp.right).offset(-10)
            make.top.equalTo(sceneView.snp.top).offset(50)
        }
        
        backButton.addTarget(self, action: #selector(self.dismissSetup(_ :)), for: .touchUpInside)
        backButton.snp.makeConstraints { make in
            
            make.size.equalTo(100)
            make.left.equalTo(sceneView.snp.left).offset(10)
            make.top.equalTo(sceneView.snp.top).offset(50)
        }
        
        boardNode = (self.boardscene?.rootNode.childNode(withName: "board", recursively: false))!
        boardNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        boardNode.name = "board"
        
        targetNode = SCNNode(geometry: tagetPlane)
        targetNode?.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        targetNode?.name = "target"
        targetNode?.isHidden = false
        targetNode?.eulerAngles.x = -Float.pi / 2
        
        selectNode = SCNNode(geometry: selectPlane)
        selectNode?.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        selectNode?.name = "target"
        selectNode?.isHidden = true
        selectNode?.eulerAngles.x = -Float.pi / 2
        
        arrowNode = (self.arrowScene?.rootNode.childNode(withName: "arrow", recursively: false))!
        arrowNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        arrowNode.name = "board"
        arrowNode.isHidden = true
        
        boardButtonSelectBool = true
        passButtonSelectBool = false
        othelloButtonSelectBool = false
        
        gameContnue = true
    }
    
    @objc func dismissSetup(_ sender: UIButton){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func clearSetup(_ sender: UIButton){
        
    }
    
    @objc func passSetup(_ sender: UIButton){
        
        passImplement()
    }
    //パスボタンを押した時の処理
    func passImplement() {
        
        if availableAreaCount < 1 { return } else { }
        setupNextTreatment()
        passButtonSelectBool = false
        othelloButtonSelectBool = true
        gameContnue = true
    }
    
    @objc func boardSetup(_ sender: UIButton){
        
        guard targetNode != nil else { return }
        guard boardPos == float3(0, 0, 0) else { return }
        
        boardNode.position = SCNVector3(self.currentPos.x, self.currentPos.y, self.currentPos.z)
        boardPos = currentPos
        boardNode.scale = SCNVector3(0.08, 0.005, 0.08)
        boardNode.eulerAngles.y = -Float.pi/2
        sceneView.scene.rootNode.addChildNode(boardNode)
        //ターンモデルの作成
        makeGameTurnModel(x: boardPos.x, y: boardPos.y + 0.08, z: boardPos.z - 0.07)
        
        setupBoardArray()
    }
    //ゲーム終了時の処理
    private func duelComplete() {
        
        passButtonSelectBool = false
        othelloButtonSelectBool = false
        boardButtonSelectBool = false
        targetNode?.isHidden = true
        selectNode?.isHidden = true
        arrowNode.isHidden = true
        let blackturnNode = sceneView.scene.rootNode.childNode(withName: "blackTurn", recursively: true)
        blackturnNode?.isHidden = true
        let whiteturnNode = sceneView.scene.rootNode.childNode(withName: "whiteTurn", recursively: true)
        whiteturnNode?.isHidden = true
        print("complete")
    }
    
    private func duelJudge() {
        
    }
    //ボードを置いた際の処理
    private func setupBoardArray() {
        
        let iniboardPos = float3(boardPos.x - 0.07, boardPos.y + 0.01, boardPos.z - 0.07)
        //board上のマス目の座標を配列で取得する
        for Z in 0...7 {
            for X in  0...7 {
                var tempPos = float3(0, 0, 0)
                tempPos =  float3(iniboardPos.x + 0.02 * Float(X), iniboardPos.y, iniboardPos.z + 0.02 * Float(Z))
                boardArray.append(tempPos)
                if boardArray.count == 8 {
                    
                    wboardArray.append(boardArray)
                    boardArray = []
                }
            }
        }
        let intArray: [[Int]] = [[3, 3], [3, 4], [4, 3], [4, 4]]
        let intCount = intArray.count
        for i in 0...intCount - 1 {
            
            turnCount += 1
            var stoneInt = othelloType.black.rawValue
            var othelloNode = SCNNode()
            let othelloScene = SCNScene(named: "art.scnassets/othello.scn")
            othelloNode = (othelloScene?.rootNode.childNode(withName: "othello", recursively: false))!
            othelloNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            othelloNode.name = "othello\(turnCount)"
            othelloNode.scale = SCNVector3(0.007, 0.0007, 0.007)
            //初期白設定
            if i == 0 || i == 3 {
                
                othelloNode.eulerAngles.z = -Float.pi
                stoneInt = othelloType.white.rawValue
            }
            let tempInt = intArray[i]
            
            proceedBoard[tempInt[0]][tempInt[1]] = turnCount
            boardSituation[tempInt[0] + 1][tempInt[1] + 1] = stoneInt
            
            othelloNode.position = SCNVector3(self.wboardArray[tempInt[0]][tempInt[1]].x,
                                              self.wboardArray[tempInt[0]][tempInt[1]].y,
                                              self.wboardArray[tempInt[0]][tempInt[1]].z)
            
            sceneView.scene.rootNode.addChildNode(othelloNode)
        }
        
        availableAreaCount -= 4
        boardButtonSelectBool = false
        othelloButtonSelectBool = true
        setupNextTreatment()
    }
    //各種オセロの数を返す
    private func stoneTypeCount() -> (Int, Int) {
        
        var black: Int = 0
        var white: Int = 0
        var none: Int = 0
        var wall: Int = 0
        for y in 0...9 {
            for x in 0...9 {
                
                switch boardSituation[y][x]{
                    
                case othelloType.black.rawValue:
                    black += 1
                case othelloType.white.rawValue:
                    white += 1
                case othelloType.none.rawValue:
                    none += 1
                case othelloType.wall.rawValue:
                    wall += 1
                default:
                    fatalError("print")
                }
            }
        }
        return (black, white)
    }
    //ターン表記のモデルの作成
    private func makeGameTurnModel(x: Float, y: Float, z: Float) {
        
        let textArray: [String] = ["黒のターンです", "白のターンです"]
        let nameArray: [String] = ["blackTurn", "whiteTurn"]
        
        for i in 0...1 {
            
            let sampleText = SCNText(string: textArray[i], extrusionDepth: 0)
            sampleText.flatness = 0.001
            let sampleMaterial = SCNMaterial()
            if i == 0 {
                sampleMaterial.diffuse.contents = UIColor.black
            } else {
                sampleMaterial.diffuse.contents = UIColor.white
            }
            sampleText.materials = [sampleMaterial]
            
            let sampleNode = SCNNode(geometry: sampleText)
            
            sampleNode.position = SCNVector3(x,y,z)
            sampleNode.scale = SCNVector3(0.001,0.001,0.001)
            sampleNode.name = nameArray[i]
            sceneView.scene.rootNode.addChildNode(sampleNode)
        }
    }
    //オセロ数のモデルを表示
    private func displayFigureModel(x: Float, y: Float, z: Float, stoneCount: Int, othelloText: String) {
        
        let sampleText = SCNText(string: "\(othelloText)\(stoneCount)", extrusionDepth: 0)
        sampleText.flatness = 0.001
        let sampleMaterial = SCNMaterial()
        
        switch othelloText {
        case "black":
            sampleMaterial.diffuse.contents = UIColor.black
        case "white":
            sampleMaterial.diffuse.contents = UIColor.white
        default:
            fatalError("error")
        }
        
        sampleText.materials = [sampleMaterial]
        let sampleNode = SCNNode(geometry: sampleText)
        sampleNode.position = SCNVector3(x,y,z)
        sampleNode.scale = SCNVector3(0.001,0.001,0.001)
        sampleNode.name = othelloText
        sceneView.scene.rootNode.addChildNode(sampleNode)
    }
    //オセロのカウントモデルを削除
    func deleteDisplayFigureModel() {
        
        let whiteNode = sceneView.scene.rootNode.childNode(withName: "white", recursively: true)
        let blackNode = sceneView.scene.rootNode.childNode(withName: "black", recursively: true)
        whiteNode?.removeFromParentNode()
        blackNode?.removeFromParentNode()
    }
    //オセロ置く動作
    @objc func othelloSetup(_ sender: UIButton){
        
        guard targetNode != nil else { return }
        guard boardPos != float3(0, 0, 0) else { return }
        
        //オセロモデルの作成
        makeOthelloModel(makePos: selectPos)
        //オセロを置いた処理
        availableAreaCount -= 1
        //オセロを置いた箇所の座標
        setupPoint = availablePointArray[selectIndex]
        //boardSituに座標を合わせる
        setupBoardPoint = setupPoint.map { $0 + 1 }
        reverseOthelo(_y_boardArray: setupBoardPoint[0], _x_boardArray: setupBoardPoint[1], stoneType: now_othelloType!)
        deleteAvailablePlane(_availablePointArray: availablePointArray)
        
        setupNextTreatment()
    }
    //オセロモデルの作成
    private func makeOthelloModel(makePos: float3) {
        
        now_othelloType = turnToOehtlloType(_turnCount: turnCount)
        
        var othelloNode = SCNNode()
        let othelloScene = SCNScene(named: "art.scnassets/othello.scn")
        othelloNode = (othelloScene?.rootNode.childNode(withName: "othello", recursively: false))!
        othelloNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        othelloNode.name = "othello\(turnCount)"
        othelloNode.scale = SCNVector3(0.007, 0.0007, 0.007)
        
        if now_othelloType == 2 {
            othelloNode.eulerAngles.z = -Float.pi
            //            print("オセロは白です")
        } else {
            //            print( "オセロは黒です")
        }
        othelloNode.position = SCNVector3(makePos.x, makePos.y, makePos.z)
        sceneView.scene.rootNode.addChildNode(othelloNode)
    }
    //次のオセロの準備
    func setupNextTreatment() {
        
        turnCount += 1
        now_othelloType = turnToOehtlloType(_turnCount: turnCount)
        availablePointArray = setupAvailable(selfOthello: now_othelloType!)
        //オセロを置ける場所がない場合
        guard availablePointArray != [] else { return passTreatment() }
        
        setupAvailablePlane(_availablePointArray: availablePointArray)
        //各種オセロの数をカウント
        deleteDisplayFigureModel()
        let othelloCount: (Int, Int) = stoneTypeCount()
        displayFigureModel(x: boardPos.x - 0.07, y: boardPos.y + 0.08, z: boardPos.z - 0.07, stoneCount: othelloCount.0, othelloText: "black")
        displayFigureModel(x: boardPos.x - 0.07, y: boardPos.y + 0.06, z: boardPos.z - 0.07, stoneCount: othelloCount.1, othelloText: "white")
        //CPUの処理
        now_othelloType = turnToOehtlloType(_turnCount: turnCount)
        
        if cpuOthelloType == now_othelloType {
            
            let enemyPlayer = EnemyPlayer(availableAreaArray: availablePointArray)
            let enemySetupPoint: [Int] = enemyPlayer.Random()
            
            let enemyPostion: float3 = wboardArray[enemySetupPoint[0]][enemySetupPoint[1]]
            
            makeOthelloModel(makePos: enemyPostion)
            //オセロを置いた処理
            availableAreaCount -= 1
            //オセロを置いた箇所の座標
            setupPoint = enemySetupPoint
            //boardSituに座標を合わせる
            setupBoardPoint = setupPoint.map { $0 + 1 }
            reverseOthelo(_y_boardArray: setupBoardPoint[0], _x_boardArray: setupBoardPoint[1], stoneType: now_othelloType!)
            deleteAvailablePlane(_availablePointArray: availablePointArray)
            
            setupNextTreatment()
        }
    }
    
    func passTreatment() {
        
        print("置く場所がありません")
        gameContnue = false
        othelloButtonSelectBool = false
        //まだ置ける場所があるか、なければパスボタンを無効にする
        if availableAreaCount != 0 {
            passButtonSelectBool = true
        } else {
            passButtonSelectBool = false
            duelComplete()
        }
        
        if now_othelloType == cpuOthelloType {
            passImplement()
        } else {
            
        }
    }
    //オセロを裏返す処理
    func reverseOthelo(_y_boardArray: Int, _x_boardArray: Int, stoneType: Int) {
        //straightArrayを取得するために実行
        var _: (Bool, Int) = getstraightArray(y: _y_boardArray, x: _x_boardArray, selfStone: stoneType)
        var reverseDerectionArray: [Int] = []
        var reverseDerectionIndex: Int = 0
        
        for array in straightArray {
            if array.count > 1 && array.contains(stoneType) && array[0] != stoneType {
                
                reverseDerectionArray.append(reverseDerectionIndex)
                reverseDerectionIndex += 1
            } else {
                
                reverseDerectionIndex += 1
            }
        }
        //置いたオセロと同じ石が見つかるまでオセロをひっくり返す
        for reverseDerect in reverseDerectionArray {
            var roop: Bool = true
            var reversedOthelloType: Int = 0
            var roopTimes: Int = 1
            var roopIndex: Int = 0
            
            while roop == true {
                //オセロを置いた位置に対する検索オセロの位置を計算
                var timesReverseDerect = derection_yx[reverseDerect].map { $0 * roopTimes }
                //検索するオセロの座標を求める
                var reversePoint = zip(setupBoardPoint, timesReverseDerect)
                    .map(+)
                reversedOthelloType = boardSituation[reversePoint[0]][reversePoint[1]]
                
                if reversedOthelloType != stoneType {
                    
                    switch stoneType {
                        
                    case othelloType.black.rawValue:
                        boardSituation[reversePoint[0]][reversePoint[1]] = 1
                        //proceedBoardの座上基準に直す
                        let reverseMinusPoint = reversePoint.map { $0 - 1 }
                        let boardCount = proceedBoard[reverseMinusPoint[0]][reverseMinusPoint[1]]
                        let rotationCount = rotationCountBoard[reverseMinusPoint[0]][reverseMinusPoint[1]]
                        var node = sceneView.scene.rootNode.childNode(withName: "othello\(boardCount)", recursively: true)
                        //ひっくり返した回数に応じてオセロオブジェクトの回転角度を決める
                        node?.eulerAngles.x = -Float.pi * Float(rotationCount)
                        //                        print("白をひっくり返しました")
                        rotationCountBoard[reverseMinusPoint[0]][reverseMinusPoint[1]] = rotationCount + 1
                        
                    case othelloType.white.rawValue:
                        boardSituation[reversePoint[0]][reversePoint[1]]  = 2
                        //proceedBoardの座上基準に直す
                        let reverseMinusPoint = reversePoint.map { $0 - 1 }
                        let boardCount = proceedBoard[reverseMinusPoint[0]][reverseMinusPoint[1]]
                        let rotationCount = rotationCountBoard[reverseMinusPoint[0]][reverseMinusPoint[1]]
                        var node = sceneView.scene.rootNode.childNode(withName: "othello\(boardCount)", recursively: true)
                        node?.eulerAngles.x = -Float.pi * Float(rotationCount)
                        //                        print("黒をひっくり返しました")
                        rotationCountBoard[reverseMinusPoint[0]][reverseMinusPoint[1]] = rotationCount + 1
                        
                    default:
                        fatalError("errorが発生しました")
                    }
                    roopIndex += 1
                    roopTimes += 1
                    roop = true
                } else {
                    roop = false
                }
            }
        }
        //boardに数字を設定
        boardSituation[setupBoardPoint[0]][setupBoardPoint[1]] = now_othelloType!
        //進捗状況を記録
        proceedBoard[setupPoint[0]][setupPoint[1]] = turnCount
    }
    //カーソルを合わせたポイントから最も近いオセロを置ける箇所の座標を返す
    private func selectSetupPoint(_currentPos: SCNVector3) -> float3 {
        
        guard targetNode != nil else { return float3(0, 0, 0) }
        guard boardPos != float3(0, 0, 0) else { return float3(0, 0, 0) }
        
        let current_x = _currentPos.x
        let current_y = _currentPos.y
        let current_z = _currentPos.z
        var tempAvailablePostion: [float3] = []
        
        for array in availablePointArray {
            
            tempAvailablePostion.append(self.wboardArray[array[0]][array[1]])
        }
        var distanceArray: [Double] = []
        //X軸、Z軸基準でオセロの位置を並び替え
        tempAvailablePostion = tempAvailablePostion.sorted {
            
            if $0.z < $1.z {
                return true
            } else if $0.z == $1.z && $0.x < $1.x {
                return true
            } else {
                return false
            }
        }
        for array in tempAvailablePostion {
            
            let array_x = array.x
            let array_y = array.y
            let array_z = array.z
            let dx = Double(current_x - array_x)
            let dy = Double(current_y - array_y)
            let dz = Double(current_z - array_z)
            let distance: Double = sqrt(dx*dx + dy*dy + dz*dz)
            distanceArray.append(distance)
        }
        //置ける場所があるかどうかを確認
        if distanceArray != [] { } else { return float3(0, 0, 0) }
        //一番距離の近いマスの距離を算出
        let minLength: Double = distanceArray.min()!
        
        selectIndex = distanceArray.firstIndex(of: minLength)!
        let selectPosition = tempAvailablePostion[selectIndex]
        return selectPosition
    }
    //前回作成した設置可能箇所のモデルを削除する
    private func deleteAvailablePlane(_availablePointArray: [[Int]]) {
        
        let planeCount = _availablePointArray.count
        for i in 1...planeCount {
            let node = sceneView.scene.rootNode.childNode(withName: "plane\(i)", recursively: true)
            node?.removeFromParentNode()
        }
    }
    //石を置ける箇所を3Dモデル上で表示
    private func setupAvailablePlane(_availablePointArray: [[Int]]) {
        
        var arrayCount: Int = 1
        for array in _availablePointArray {
            var availablePlaneNode = SCNNode()
            availablePlaneNode = SCNNode(geometry: availablePlane)
            availablePlaneNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            availablePlaneNode.eulerAngles.x = -Float.pi / 2
            availablePlaneNode.name = "plane\(arrayCount)"
            availablePlaneNode.position = SCNVector3(self.wboardArray[array[0]][array[1]].x,
                                                     self.wboardArray[array[0]][array[1]].y,
                                                     self.wboardArray[array[0]][array[1]].z)
            
            sceneView.scene.rootNode.addChildNode(availablePlaneNode)
            arrayCount += 1
        }
    }
    //ターン数からオセロの色を求める
    func turnToOehtlloType(_turnCount: Int) -> Int {
        
        var roop: Bool = true
        var turn = _turnCount
        
        while roop == true {
            
            turn -= 2
            if turn < 1 { roop = false } else { }
        }
        turn += 2
        return turn
    }
    //オセロを置ける箇所の座標を返す
    func setupAvailable(selfOthello: Int) -> [[Int]] {
        
        var tempBool: Bool = false
        var tempInt: Int = 0
        var tempBoolArray: [Bool] = []
        var tempReverseArray: [Int] = []
        //置ける箇所のbool初期化
        boardBoolArray = []
        boardReveseCountArray = []
        
        for _y in 1...8 {
            for _x in 1...8 {
                
                (tempBool, tempInt) = getstraightArray(y: _y, x: _x, selfStone: selfOthello)
                
                tempBoolArray.append(tempBool)
                //返す石の数の配列を作成
                tempReverseArray.append(tempInt)
                if tempBoolArray.count == 8 {
                    
                    boardBoolArray.append(tempBoolArray)
                    boardReveseCountArray.append(tempReverseArray)
                    tempBoolArray = []
                    tempReverseArray = []
                }
            }
        }
        print(boardReveseCountArray)
        
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
    func getstraightArray(y: Int, x: Int, selfStone: Int) -> (Bool, Int) {
        
        var reverseCount: Int = 0
        var reverseArray: [[Int]] = []
        //空いているますかチェック
        let stoneValue: Int = boardSituation[y][x]
        if stoneValue != 0 {
            
            return (false, 0)
        } else {
        }
        var available: Bool = false
        //配列の初期化
        straightArray = []
        
        for i in 0...7 {
            let derect = derection_yx[i]
            let dy: Int = derect[0]
            let dx: Int = derect[1]
            
            var roop: Bool = true
            var roopTime: Int = 1
            
            var tempStraighArray:[Int] = []
            
            while roop == true {
                
                let y_dy = y + dy * roopTime
                let x_dx = x + dx * roopTime
                let stoneInt: Int = boardSituation[y_dy][x_dx]
                
                tempStraighArray.append(stoneInt)
                
                if stoneInt == 0 || stoneInt == 9 {
                    
                    roop = false
                    straightArray.append(tempStraighArray)
                } else {
                    
                    roop = true
                    roopTime += 1
                }
            }
        }
        //置ける場所かどうかをboolで返す
        for array in straightArray {
            if array.count > 1 && array.contains(selfStone) && array[0] != selfStone {
                available = true
                //置ける場所の配列を挿入
                reverseArray.append(array)
            } else {
                continue
            }
        }
        //置ける箇所のひっくり返す石の数を算出
        for array in reverseArray {
            
            var i: Int = 0
            var roop: Bool = true
            
            switch now_othelloType {
            case othelloType.black.rawValue:
                while roop == true {
                    if array[i] == othelloType.white.rawValue {
                        reverseCount += 1
                        i += 1
                        roop = true
                    } else {
                        roop = false
                        break
                    }
                }
                
            case othelloType.white.rawValue:
                while roop == true {
                    if array[i] == othelloType.black.rawValue {
                        reverseCount += 1
                        i += 1
                        roop = true
                    } else {
                        roop = false
                        break
                    }
                }
            case .none:
                fatalError()
            case .some(_):
                fatalError()
            }
        }
        
        return (available, reverseCount)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //エリア全てにオセロが置かれた際の終了操作
        guard gameContnue == true else { return }
        if availableAreaCount > 0 {
        }
        else {
            //終了処理の際矢印が消えないことがあるため
            arrowNode.isHidden = true
            return
        }
        
        DispatchQueue.main.async {
            
            let results = self.sceneView.hitTest(self.screenCenter, types: [.existingPlaneUsingGeometry])
            if let exisitingPlaneUsingGeometryResult = results.first(where: {$0.type == .existingPlaneUsingGeometry}) {
                let result = exisitingPlaneUsingGeometryResult
                
                self.currentPos = float3(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
                if self.boardPos == float3(0, 0, 0) {
                    
                    self.targetNode?.position = SCNVector3(self.currentPos.x, self.currentPos.y, self.currentPos.z)
                    self.arrowNode.isHidden = false
                    self.arrowNode.position = SCNVector3(self.currentPos.x, self.currentPos.y + 0.04, self.currentPos.z)
                    self.arrowNode.scale = SCNVector3(0.0025, 0.0025, 0.0025)
                    self.arrowNode.eulerAngles.z = -Float.pi/2
                    self.sceneView.scene.rootNode.addChildNode(self.arrowNode)
                } else {
                    
                    self.targetNode?.position = SCNVector3(self.currentPos.x, self.boardPos.y, self.currentPos.z)
                    //arrowNodeをボード基準に変更
                    self.arrowNode.isHidden = false
                    self.arrowNode.position = SCNVector3(self.currentPos.x, self.boardPos.y + 0.04, self.currentPos.z)
                    self.arrowNode.scale = SCNVector3(0.0025, 0.0025, 0.0025)
                    self.arrowNode.eulerAngles.z = -Float.pi/2
                    self.sceneView.scene.rootNode.addChildNode(self.arrowNode)
                    
                    self.selectPos = self.selectSetupPoint(_currentPos: SCNVector3(self.currentPos))
                    //返ってきた値が初期値かどうかを判断
                    if self.selectPos == float3(0, 0, 0) { return } else {}
                    self.selectNode?.isHidden = false
                    self.selectNode?.position = SCNVector3(self.selectPos.x, self.selectPos.y, self.selectPos.z)
                    self.sceneView.scene.rootNode.addChildNode(self.selectNode!)
                }
                self.sceneView.scene.rootNode.addChildNode(self.targetNode!)
            }
        }
    }
}
