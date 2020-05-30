//
//  DQShaderUtil.swift
//  GLKitTest
//
//  Created by dzq_mac on 2020/5/21.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit
import GLKit

@available(*, deprecated)
class DQShaderUtil: NSObject {
    
    /// 设置Attribute属性
    ///1.glGetAttribLocation,用来获取vertex attribute的入口的.
    ///2.告诉OpenGL ES,通过glEnableVertexAttribArray，打开开关
    ///3.最后数据是通过glVertexAttribPointer传递过去的。
    /// - Parameters:
    ///   - program: 着色器程序
    ///   - name: 属性名，字符串必须和shader代码中的输入变量保持一致
    ///   - size: size,每个顶点属性的组件数量，1，2，3，或者4.默认初始值是4.
    ///   - type: type,数据中的每个组件的类型，常用的有GL_FLOAT,GL_BYTE,GL_SHORT。默认初始值为GL_FLOAT
    ///   - normalized: normalized,固定点数据值是否应该归一化，或者直接转换为固定值。（GL_FALSE）
    ///   - stride: stride,连续顶点属性之间的偏移量，默认为0；
    ///   - ptr: 指定一个指针，指向数组中的第一个顶点属性的第一个组件。默认为0
    class func setVertexAttribute(program:GLuint,_ name:String,_ size:GLint,_ type:GLenum,
                            _ normalized:GLboolean,_ stride:GLsizei,_ ptr:UnsafeRawPointer!){
        let positon = glGetAttribLocation(program, name)
         //(2).设置合适的格式从buffer里面读取数据
        glEnableVertexAttribArray(GLuint(positon))
        //(3).设置读取方式
        //参数1：index,顶点数据的索引
        //参数2：size,每个顶点属性的组件数量，1，2，3，或者4.默认初始值是4.
        //参数3：type,数据中的每个组件的类型，常用的有GL_FLOAT,GL_BYTE,GL_SHORT。默认初始值为GL_FLOAT
        //参数4：normalized,固定点数据值是否应该归一化，或者直接转换为固定值。（GL_FALSE）
        //参数5：stride,连续顶点属性之间的偏移量，默认为0；
        //参数6：指定一个指针，指向数组中的第一个顶点属性的第一个组件。默认为0
        glVertexAttribPointer(GLuint(positon), size, type, normalized, stride, ptr)
    }
    
    //加载一张纹理图片
    class func setUpTextureImage(imageName:String,map:Bool = false,texture:GLenum? = nil) {
        guard let image = UIImage(named: imageName)?.cgImage else {
            return
        }
    
        let width = image.width
        let height = image.height
        
        //开辟内存，绘制到这个内存上去
        let spriteData: UnsafeMutablePointer = UnsafeMutablePointer<GLubyte>.allocate(capacity: MemoryLayout<GLubyte>.size * width * height * 4)
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        //获取context
        let spriteContext = CGContext(data: spriteData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: image.colorSpace!, bitmapInfo: image.bitmapInfo.rawValue)
        //2.图片反转2
        spriteContext?.translateBy(x: 0, y: CGFloat(height))//向下平移图片的高度
        spriteContext?.scaleBy(x: 1, y: -1)//反转图片
        
        spriteContext?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsEndImageContext()
        
        //绑定纹理
        if let tex = texture {
            var textureID = GLuint()
            glGenTextures(1, &textureID)
            glActiveTexture(tex)
            glBindTexture(GLenum(GL_TEXTURE_2D), textureID)
        }else{
            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        }
        
        //设置纹理参数
        //缩小/放大过滤器
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        //环绕方式
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        //载入纹理
        /*
        参数1：纹理模式，GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D
        参数2：加载的层次，一般设置为0
        参数3：纹理的颜色值GL_RGBA
        参数4：宽
        参数5：高
        参数6：border，边界宽度
        参数7：format
        参数8：type
        参数9：纹理数据
        */
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE),spriteData)
        
        if map {
            glGenerateMipmap(GLenum(GL_TEXTURE_2D))
        }
        //释放内存
        free(spriteData)
    }
    
    /// 封装加载着色器程序方法(字符串型)
    /// - Parameters:
    ///   - vertexShaderString: 顶点着色器字符串
    ///   - fragmentShaderString: 片元着色器字符串
    /// - Returns: 链接好的着色器程序program
    class func loadShader(vertexShaderString:String,fragmentShaderString:String) -> GLuint?{
        let program:GLuint = glCreateProgram()
        
        //vertex
        let verShader:GLuint = glCreateShader(GLenum(GL_VERTEX_SHADER))
        vertexShaderString.withCString { (pointer)  in
            var pon:UnsafePointer<GLchar>? = pointer
            glShaderSource(verShader, 1, &pon, nil)
        }
        glCompileShader(verShader)
        glAttachShader(program, verShader)
        glDeleteShader(verShader)
        //fragment
        let fragShader:GLuint = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        fragmentShaderString.withCString { (pointer)  in
            var pon:UnsafePointer<GLchar>? = pointer
            glShaderSource(fragShader, 1, &pon, nil)
        }
        glCompileShader(fragShader)
        glAttachShader(program, fragShader)
        glDeleteShader(fragShader)
        
        //
        glLinkProgram(program)
        var status:GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status)
        if status == GLenum(GL_FALSE){
            print("link Error")
            //打印错误信息
            let message = UnsafeMutablePointer<GLchar>.allocate(capacity: 512)
            glGetProgramInfoLog(program, GLsizei(MemoryLayout<GLchar>.size * 512), nil, message)
            let str = String.init(utf8String: message)
            print(str ?? "没有取到ProgramInfoLog")
            return nil
        }else{
            print("link sucess!")
            //链接成功，使用着色器程序
            glUseProgram(program)
            return program
        }
        
    }
    
    /// 封装加载着色器程序方法(文件型)
    /// - Parameters:
    ///   - vertexShaderName: 顶点着色器文件名
    ///   - fragmentShaderName: 片元着色器文件名
    /// - Returns:链接好的着色器程序program
    class func loadShader(vertexShaderName:String,fragmentShaderName:String) -> GLuint?{
        let program:GLuint = glCreateProgram()
        guard let sname = vertexShaderName.split(separator: ".").first,
              let stype = vertexShaderName.split(separator: ".").last,
              let fname = fragmentShaderName.split(separator: ".").first,
              let ftype = fragmentShaderName.split(separator: ".").last
        else {
            return nil
        }
        //读取并编译着色器程序
        func compileShader(type:GLenum,filePath:String) -> GLuint? {
            //创建一个空着色器
            let verShader:GLuint = glCreateShader(type)
            
            //获取源文件中的代码字符串
            guard let shaderString = try? String.init(contentsOfFile: filePath, encoding: String.Encoding.utf8)else    {
                return nil
            }
            //转成C字符串赋值给已创建的shader
            shaderString.withCString { (pointer) in
                var pon:UnsafePointer<GLchar>? = pointer
                glShaderSource(verShader, 1, &pon, nil)
            }
            
            //编译
            glCompileShader(verShader)
           
            return verShader
        }
        
        let spath = Bundle.main.path(forResource: String(sname), ofType: String(stype)) ?? ""
        let fpath = Bundle.main.path(forResource: String(fname), ofType: String(ftype)) ?? ""
        //vertexShader
        guard let verShader:GLuint = compileShader(type: GLenum(GL_VERTEX_SHADER), filePath: spath) else {
            return nil
            
        }
        //把编译后的着色器代码附着到最终的程序上
        glAttachShader(program, verShader)
        //释放不需要的shader
        glDeleteShader(verShader)
        
        //fragmentShader
        guard let fragShader = compileShader(type: GLenum(GL_FRAGMENT_SHADER), filePath: fpath)else{
            return nil
            
        }
        glAttachShader(program, fragShader)
        glDeleteShader(fragShader)
        
        //链接着色器代程序
        glLinkProgram(program)
        //获取链接状态
        var status:GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status)
        if status == GLenum(GL_FALSE){
            print("link Error")
            //打印错误信息
            let message = UnsafeMutablePointer<GLchar>.allocate(capacity: 512)
            glGetProgramInfoLog(program, GLsizei(MemoryLayout<GLchar>.size * 512), nil, message)
            let str = String.init(utf8String: message)
            print(str ?? "没有取到ProgramInfoLog")
            return nil
        }else{
            print("link sucess!")
            //链接成功，使用着色器程序
            glUseProgram(program)
            return program
        }
        
    }
    
}

extension GLKMatrix4 {
    
    /// 转成数组
    /// - Returns: 结果数组
    func getArray() ->[Float] {
         [
            m00,m01,m02,m03,
            m10,m11,m12,m13,
            m20,m21,m22,m23,
            m30,m31,m32,m33,
        ]
        
    }
    
}
