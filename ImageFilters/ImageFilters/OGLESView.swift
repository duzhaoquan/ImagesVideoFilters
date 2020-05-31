//
//  OGLESView.swift
//  GLKitTest
//
//  Created by dzq_mac on 2020/5/21.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit

@available(*, deprecated)
class OGLESView: UIView {

    var glLayer:CAEAGLLayer!
    var context :EAGLContext!
    var colorRederBuffer = GLuint()
    var colorFrameBuffer = GLuint()
    var vertexbuffer = GLuint()
    
    override func layoutSubviews() {
       
        //1设置图层
        createGLLayer()
        
        //2.设置图形上下文
        setUpContext()
        
        //3.清除缓冲区
        clearRenderBufferAndFrameBuffer()
        
        //4.设置着色器缓冲器
        setUpRenderBuffer()
        
        //5.设置框架缓冲器（管理RenderBuffer）
        setUpFrameBuffer()
        //6.
        //1.设置背景颜色
        glClearColor(0.8, 1, 1, 1)
        //2.清除缓冲区
        glClear(GLbitfield(GL_DEPTH_BUFFER_BIT) | GLbitfield(GL_COLOR_BUFFER_BIT))
        //3.设置视口
        let scale = UIScreen.main.scale
        glViewport(GLint(frame.origin.x * scale), GLint(frame.origin.y * scale), GLsizei(frame.size.width * scale), GLsizei(frame.size.height * scale))
        //开辟顶点缓冲区
        glDeleteBuffers(1, &vertexbuffer)
        vertexbuffer = 0
        glGenBuffers(1, &vertexbuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexbuffer)
        
    }


    //1.设置图层
    /*
    kEAGLDrawablePropertyRetainedBacking  表示绘图表面显示后，是否保留其内容。
    kEAGLDrawablePropertyColorFormat
        可绘制表面的内部颜色缓存区格式，这个key对应的值是一个NSString指定特定颜色缓存区对象。默认是kEAGLColorFormatRGBA8；
    
        kEAGLColorFormatRGBA8：32位RGBA的颜色，4*8=32位
        kEAGLColorFormatRGB565：16位RGB的颜色，
        kEAGLColorFormatSRGBA8：sRGB代表了标准的红、绿、蓝，即CRT显示器、LCD显示器、投影机、打印机以及其他设备中色彩再现所使用的三个基本色素。sRGB的色彩空间基于独立的色彩坐标，可以使色彩在不同的设备使用传输中对应于同一个色彩坐标体系，而不受这些设备各自具有的不同色彩坐标的影响。
    */
    func createGLLayer() {
        glLayer = (self.layer as! CAEAGLLayer)

        self.contentScaleFactor = UIScreen.main.scale
        
        glLayer.drawableProperties = [kEAGLDrawablePropertyRetainedBacking : false,kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8]
        
    }
    //重写父类类属性layerClass，将View返回的图层从CALayer替换成CAEAGLLayer
    override class var layerClass: AnyClass{
        return CAEAGLLayer.self
    }
    //2.设置图形上下文
    /*
     1).指定OpenGL ES 渲染API版本，我们使用3.0，2.0和3.0差不多
     2).创建图形上下文
     3).判断是否创建成功
     4).设置图形上下文
     */
    func setUpContext(){
        if let con = EAGLContext(api: EAGLRenderingAPI.openGLES3){
            EAGLContext.setCurrent(con)
            self.context = con
        }else{
            print("创建context失败")
        }
    }
    /*
    3.清除缓冲区
    buffer分为frame buffer 和 render buffer2个大类。
    其中frame buffer 相当于render buffer的管理者。
    frame buffer object即称FBO。
    render buffer则又可分为3类。colorBuffer、depthBuffer、stencilBuffer。
    */
    func clearRenderBufferAndFrameBuffer() {
        glDeleteBuffers(1, &colorRederBuffer)
        colorRederBuffer = 0
        
        glDeleteBuffers(1, &colorFrameBuffer)
        colorFrameBuffer = 0
    }
    //4.设置渲染缓冲区
    func setUpRenderBuffer() {
        //申请一个缓冲区标志
        glGenRenderbuffers(1, &colorRederBuffer)
        //将标识符绑定到GL_RENDERBUFFER
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRederBuffer)
        //将可绘制对象drawable object's  CAEAGLLayer的存储绑定到OpenGL ES renderBuffer对象
        context.renderbufferStorage(Int(GLenum(GL_RENDERBUFFER)), from: glLayer)
        
    }
    /*
    5.设置帧缓冲区
    生成帧缓存区之后，则需要将renderbuffer跟framebuffer进行绑定，
    调用glFramebufferRenderbuffer函数进行绑定到对应的附着点上，后面的绘制才能起作用
    */
    func setUpFrameBuffer() {
        //申请一个缓冲区标志
        glGenRenderbuffers(1, &colorFrameBuffer)
        //将标识符绑定到GL_FRAMEBUFFER
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), colorFrameBuffer)
        //将渲染缓存区myColorRenderBuffer 通过glFramebufferRenderbuffer函数绑定到 GL_COLOR_ATTACHMENT0上。
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRederBuffer)
    }
    
    //稀构方法中清空缓冲区
    deinit {
        glDeleteBuffers(1, &colorFrameBuffer)
        glDeleteBuffers(1, &colorRederBuffer)
        glDeleteBuffers(1, &vertexbuffer)
        
        if ((EAGLContext.current()) != nil) {
            EAGLContext.setCurrent(nil)
        }
    }
}
