//
//  settingViewController.swift
//  Osero_App
//
//  Created by t032fj on 2022/02/06.
//

import UIKit
import SnapKit

class settingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let startTopView = StartTopView()
    let startTableView = StartTableView()
    
    let tableArray: [String] = ["取扱説明/プライバシーポリシー"]
    let sections: Array = ["設定"]
    //lazyでviewサイズ取得後に実施
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let baseStackView = UIStackView(arrangedSubviews: [startTopView, startTableView])
        baseStackView.axis = .vertical
        baseStackView.translatesAutoresizingMaskIntoConstraints = false
        //        baseStackView.distribution = .fillEqually
        
        self.view.addSubview(baseStackView)
        
        startTopView.snp.makeConstraints { make in
            make.height.equalTo(120)
        }
        
        baseStackView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
            make.right.equalTo(view.snp.right)
            make.left.equalTo(view.snp.left)
        }
        
        startTableView.tableView.delegate = self
        startTableView.tableView.dataSource = self
        startTableView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        startTopView.dismissButton.addTarget(self, action: #selector(dismissSetup(_ :)), for: .touchUpInside)
    }
    
    @objc func dismissSetup(_ sender: UIButton){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let url = NSURL(string: "http://takata1124-portfoliosite.com/views")
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
}
