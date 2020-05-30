//
//  FliterView.swift
//  ImageFilters
//
//  Created by dzq_mac on 2020/5/28.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit


@available(*, deprecated)
class DQFilterView: UIView {
    var vertexShaderName :String?
    var fragmentShaderName : String?
    var vertexShaderString : String?
    var fragmentShaderString :String?
    
    var imageName = "image.jpg"
    private var filter : FilterView!
    init(frame: CGRect,imageName:String,vertexShaderName:String,fragmentShaderName:String) {
        super.init(frame: frame)
        self.imageName = imageName
        self.vertexShaderName = vertexShaderName
        self.fragmentShaderName = fragmentShaderName
        
        self.filter = FilterView(frame: bounds, imageName: imageName, vertexShaderName: vertexShaderName, fragmentShaderName: fragmentShaderName)
        self.addSubview(filter)
        
    }
    func updateRender(){
        filter.vertexShaderName = vertexShaderName
        filter.fragmentShaderName = fragmentShaderName
        filter.imageName = imageName
        filter.vertexShaderString = vertexShaderString
        filter.fragmentShaderString = fragmentShaderString
        filter.renderLayer()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
@available(*, deprecated)
private class FilterView: OGLESView {
    
    var vertexs:[GLfloat]  = [
        1, -1,0,     1.0, 0.0,
        -1, 1, 0,     0.0, 1.0,
        -1, -1,0,    0.0, 0.0,
        
        1, 1, 0,      1.0, 1.0,
        -1, 1,0,     0.0, 1.0,
        1, -1,0,     1.0, 0.0,
    ]

    var imageName = "image.jpg"{
        didSet{
            if oldValue == imageName {
                return
            }
            var imageScale:(CGFloat,CGFloat) = (1,1)
            if let image = UIImage(named: imageName)?.cgImage {
                let width = image.width
                let height = image.height

                let scaleF = CGFloat(frame.height)/CGFloat(frame.width)
                let scaleI = CGFloat(height)/CGFloat(width)

                imageScale = scaleF>scaleI ? (1,scaleI/scaleF) : (scaleI/scaleF,1)
            }
            for (i,v) in vertexs.enumerated(){
                if i % 5 == 0 {
                    vertexs[i] = v * Float(imageScale.0)
                }
                if i % 5 == 1{
                    vertexs[i] = v * Float(imageScale.1)
                }

            }
        }
    }
    var vertexShaderName :String?
    var fragmentShaderName : String?
    var vertexShaderString : String?
    var fragmentShaderString :String?
    
    init(frame: CGRect,imageName:String,vertexShaderName:String,fragmentShaderName:String) {
        super.init(frame: frame)
        self.imageName = imageName
        self.vertexShaderName = vertexShaderName
        self.fragmentShaderName = fragmentShaderName
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        renderLayer()
    }
    
    func renderLayer() {
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        var pro:GLuint?
        //
        if let vn = vertexShaderName,let fn = fragmentShaderName{
            pro = DQShaderUtil.loadShader(vertexShaderName: vn, fragmentShaderName: fn)
        }
        if let vstr = vertexShaderString,let fstr = fragmentShaderString{
            pro = DQShaderUtil.loadShader(vertexShaderString: vstr, fragmentShaderString: fstr)
        }
        guard let program = pro else {
            return
        }
        
        //6.处理定点数据（copy到缓冲区）
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.size * 30, vertexs, GLenum(GL_DYNAMIC_DRAW))
        
        //7.将顶点数据通过Programe传递到顶点着色程序的position属性上
        DQShaderUtil.setVertexAttribute(program: program, "Position", 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 5), UnsafeRawPointer(bitPattern: 0))
        
        //8.纹理坐标数据通过Programe传递到顶点着色程序的textCoordinate属性上
        DQShaderUtil.setVertexAttribute(program: program,"TextureCoords", 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 5), UnsafeRawPointer(bitPattern:MemoryLayout<GLfloat>.size * 3))
        
        //9.加载纹理图片
        DQShaderUtil.setUpTextureImage(imageName: imageName)
        //10.设置纹理采样器
        glUniform1i(glGetUniformLocation(program, "TextureCoordsVarying"), 0)
        //11.绘制
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        //12.提交
        context.presentRenderbuffer(Int(GL_RENDERBUFFER))
        
    }

}
