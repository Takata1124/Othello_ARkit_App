//
//  TopView.swift
//  Osero_App
//
//  Created by t032fj on 2022/02/07.
//

import UIKit
import SnapKit

class StartTopView: UIView {
    
    let titleLabel: UILabel = {
        
        let label = UILabel()
        label.text = "設定"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var dismissButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 20
        button.setImage(UIImage(systemName: "arrowshape.turn.up.left")?.resize(size: .init(width: 50 * 0.5, height:  50 * 0.5)), for: .normal)
        button.backgroundColor = .lightGray
        button.setTitleColor(UIColor.black, for: .normal)
        //        button.addTarget(self, action: #selector(startViewController.settingSetup(_ :)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .rgba(red: 0, green: 128, blue: 0, alpha: 1)
        
        self.addSubview(dismissButton)
        self.addSubview(titleLabel)
        
        dismissButton.snp.makeConstraints { make in
            
            make.size.equalTo(50)
            make.top.equalTo(self.snp.top).offset(50)
            make.left.equalTo(self.snp.left).offset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            
            make.size.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.snp.top).offset(50)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
