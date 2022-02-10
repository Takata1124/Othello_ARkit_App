//
//  StartViewController.swift
//  Osero_App
//
//  Created by t032fj on 2022/02/05.
//

import UIKit
import SnapKit

class startViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    enum gameModeType: Int {
        case enemyWeak = 0
        case enemyStrong = 1
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ARオセロ"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 40)
        return label
    }()
    
    private let singlWeakButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 20
        button.setTitle("シングルモード(弱い）", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(startViewController.singleWeakSetup(_ :)), for: .touchUpInside)
        return button
    }()
    
    private let singleStrongButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 20
        button.setTitle("シングルモード(少し強い）", for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(startViewController.singleStrongSetup(_ :)), for: .touchUpInside)
        return button
    }()
    
    private let duelButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 20
        button.setTitle("対戦モード(実装中)", for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.rgba(red: 0, green: 51, blue: 102, alpha: 1)
        return button
    }()
    
    private let settingButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 20
        button.setImage(UIImage(systemName: "gearshape")?.resize(size: .init(width: 50 * 0.5, height:  50 * 0.5)), for: .normal)
        button.backgroundColor = .lightGray
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(startViewController.settingSetup(_ :)), for: .touchUpInside)
        return button
    }()
    
    private let titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "titleImage")
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .rgba(red: 0, green: 128, blue: 0, alpha: 1)
        
        view.addSubview(titleLabel)
        view.addSubview(titleImageView)
        view.addSubview(settingButton)
        
        titleLabel.snp.makeConstraints { make in
            
            make.width.equalTo(300)
            make.height.equalTo(75)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.top).offset(75)
        }
        
        settingButton.snp.makeConstraints { make in
            
            make.size.equalTo(50)
            make.top.equalTo(view.snp.top).offset(50)
            make.right.equalTo(view.snp.right).offset(-20)
        }
        
        titleImageView.snp.makeConstraints { make in
            
            make.size.equalTo(300)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        singlWeakButton.snp.makeConstraints { make in
            make.size.equalTo(100)
        }
        
        singleStrongButton.snp.makeConstraints { make in
            make.size.equalTo(100)
        }
        
        duelButton.snp.makeConstraints { make in
            make.size.equalTo(100)
        }
        
        let baseStackView = UIStackView(arrangedSubviews: [singlWeakButton, singleStrongButton, duelButton])
        baseStackView.axis = .horizontal
        baseStackView.distribution = .fillEqually
        baseStackView.spacing = 20
        baseStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(baseStackView)
        
        baseStackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-50)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc func singleWeakSetup(_ sender: UIButton){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        //値渡し
        viewController.gameMode = gameModeType.enemyWeak.rawValue
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    @objc func singleStrongSetup(_ sender: UIButton){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        //値渡し
        viewController.gameMode = gameModeType.enemyStrong.rawValue
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    @objc func settingSetup(_ sender: UIButton){
        
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let settingviewController = storyboard.instantiateViewController(withIdentifier: "settingViewController") as! settingViewController
        settingviewController.modalPresentationStyle = .fullScreen
        self.present(settingviewController, animated: true, completion: nil)
    }
}

