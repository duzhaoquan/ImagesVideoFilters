//
//  OpenGLESFilterVC.swift
//  ImageFilters
//
//  Created by dzq_mac on 2020/5/28.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit

class OpenGLESFilterVC: UIViewController {

    var filterDatas = [FilterData]()
    var filterView :DQFilterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        filterDatas.append(FilterData(name: "原图", verName: "Normal.vsh", fragName: "Normal.fsh",isselected: true))
        filterDatas.append(FilterData(name: "二分屏", verName: "SplitScreen_2.vsh", fragName: "SplitScreen_2.fsh"))
        filterDatas.append(FilterData(name: "三分屏", verName: "ThreeScreen.sh", fragName: "ThreeScreen.fsh"))
//        filterDatas.append(FilterData(name: "四分屏", verName: "fourScreen.vsh", fragName: "fourScreen.fsh"))
        
        
        let verstr = """
             attribute vec4 Position;
             attribute vec2 TextureCoords;
             varying vec2 TextureCoordsVarying;
             void main (void) {
             gl_Position = Position;
             TextureCoordsVarying = TextureCoords;
             }
         """
        let fragStr = """
            precision highp float;
            uniform sampler2D Texture;
            varying highp vec2 TextureCoordsVarying;

            void main() {
            vec2 uv = TextureCoordsVarying.xy;
            float y;
            float x;
            if (uv.y >= 0.0 && uv.y <= 0.5) {
                y = uv.y * 2.0;
            } else {
                y = (uv.y - 0.5) * 2.0;
            }
            if (uv.x >= 0.0 && uv.x <= 0.5) {
                x = uv.x * 2.0;
            } else {
                x = (uv.x - 0.5) * 2.0;
            }
            
            gl_FragColor = texture2D(Texture, vec2(x, y));
            }
       """
        filterDatas.append(FilterData(name: "四分屏",verString: verstr, fragString: fragStr))
        
        let vs6 = """
            attribute vec4 Position;
            attribute vec2 TextureCoords;
            varying vec2 TextureCoordsVarying;
            void main (void) {
            gl_Position = Position;
            TextureCoordsVarying = TextureCoords;
         }
         """
        let fsh6 = """
          precision highp float;
          uniform sampler2D Texture;
          varying highp vec2 TextureCoordsVarying;

         void main(){
         vec2 uv = TextureCoordsVarying.xy;
          if (uv.x < 0.3333) {
          uv.x = uv.x * 3.0;
         }else if(uv.x > 0.6666){
          uv.x = (uv.x - 0.6666) * 3.0;
         }else{
          uv.x = (uv.x - 0.3333) * 3.0;
         }

         if (uv.y < 0.5){

            uv.y = uv.y * 2.0;
         }else{
            uv.y = (uv.y - 0.5) * 2.0;
         }
         gl_FragColor = texture2D(Texture, uv);

         }
         """
        
        
        
        
        
        filterDatas.append(FilterData(name: "六分屏",verString: vs6, fragString: fsh6))
        
        
       
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        filterView = DQFilterView(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.height - 260), imageName: "image.jpg", vertexShaderName: "Normal.vsh", fragmentShaderName: "Normal.fsh")
        view.addSubview(filterView)
    }

    override func viewWillAppear(_ animated: Bool) {
        let bar = FIlterBar(frame: CGRect(x: 0, y: view.frame.size.height - 120, width: view.frame.size.width, height: 100))
        bar.datas = filterDatas
        bar.backgroundColor = .red
        bar.selectedBlock = { index in
            let filterData = self.filterDatas[index.row]
            if filterData.fragString.count > 1{
                self.filterView.vertexShaderString = filterData.verString
                self.filterView.fragmentShaderString = filterData.fragString
            }else{
                self.filterView.vertexShaderName = filterData.verName
                self.filterView.fragmentShaderName = filterData.fragName
            }
            
            self.filterView.updateRender()
            
            
        }
        view.addSubview(bar)
    }


}
