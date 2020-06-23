//
//  FIlterBar.swift
//  ImageFilters
//
//  Created by dzq_mac on 2020/5/28.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit

struct FilterData {
    var name:String
    var verName:String = ""
    var fragName:String = ""
    var verString:String = ""
    var fragString:String = ""
    var needTime = false
    
    var isselected = false
    
    
}

/// 创建滤镜选择条，某一滤镜点击后切换成该滤镜效果处理后的图像显示
class FIlterBar: UIView {

    var selectedBlock:((_ index:IndexPath) -> Void)?
    
    var scrollView:UICollectionView!
    var datas:[FilterData] = [FilterData]() {
        didSet{
            self.scrollView.reloadData()
        }
    }
    //修改SearchAnyFilterCardCell布局
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .horizontal
        
        scrollView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        addSubview(scrollView)
        scrollView.backgroundColor = .purple
        scrollView.delegate = self
        scrollView.dataSource = self
        scrollView.register(UINib(nibName: "FilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "filterCell")
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension FIlterBar:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 0, bottom: 0, right:0)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:FilterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! FilterCollectionViewCell
        
        cell.nameLabel.text = datas[indexPath.row].name
        if datas[indexPath.row].isselected  {
            cell.backgroundColor = .gray
        }else{
            cell.backgroundColor = .white
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let index = datas.firstIndex(where: { $0.isselected}){
            datas[index].isselected = false
        }
        datas[indexPath.row].isselected = !datas[indexPath.row].isselected
        
        if let block = selectedBlock{
            block(indexPath)
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        CGSize(width: 100, height: 90)
    }
    
    
   
    
    
}
