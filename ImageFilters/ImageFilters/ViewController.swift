//
//  ViewController.swift
//  ImageFilters
//
//  Created by dzq_mac on 2020/5/28.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit

/*

 
 */
class ViewController: UIViewController {
    var tableView:UITableView?
    var titles = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTableView()
        
    }

    func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), style: UITableView.Style.plain)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView!)
        
        titles = ["Core Image","filter"];
    }

}

extension ViewController :UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
               return titles.count
       }
       
       func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

           cell.accessoryType = .disclosureIndicator
           cell.selectionStyle = .none
          
           cell.textLabel?.text = titles[indexPath.row]

           
           return cell
         
       }

       
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 50
       }
       func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
           return 0.00001
       }
       @available(*, deprecated, message: "ios13")
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)
           
           var twoVC : UIViewController = UIViewController()
           
           
           switch indexPath.row {
           case 0:
               twoVC = CoreImageViewController()
               
           case 1:
               twoVC = OpenGLESFilterVC()
//
//           case 2:
//               twoVC = CACubeViewController()
//           case 3:
//               twoVC = GLKViewController()
//           case 4:
//               twoVC = GLKViewController()
//               (twoVC as! GLKViewController).type = .rectangulr
//           case 5:
//               twoVC = GLKNormalViewController()
//           case 6:
//               twoVC = GLKViewController()
//               (twoVC as! GLKViewController).type = .light
//           case 7:
//               twoVC = EmitterViewController()
               
           default:
               twoVC = CoreImageViewController()
           
           }
           self.navigationController?.pushViewController(twoVC, animated: true)
       }
}
