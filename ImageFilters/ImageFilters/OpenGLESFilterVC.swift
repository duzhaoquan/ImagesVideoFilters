//
//  OpenGLESFilterVC.swift
//  ImageFilters
//
//  Created by dzq_mac on 2020/5/28.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit
/*
 上篇介绍了常见的一些处理图片的滤镜，都是基于静态图片为基础做的，本篇介绍一些机遇视频的滤镜，引入一个时间变量time作为模拟视频中的时间参数。
 
 */
class OpenGLESFilterVC: UIViewController {

    var filterDatas = [FilterData]()
    var filterView :DQFilterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        /*
         1.分屏滤镜，二三四六九分屏，分屏滤镜主要是改变像素的纹素，通过坐标显示对应映射坐标的纹素
         */
        filterDatas.append(FilterData(name: "原图", verName: "Normal.vsh", fragName: "Normal.fsh",isselected: true))
        filterDatas.append(FilterData(name: "二分屏", verName: "SplitScreen_2.vsh", fragName: "SplitScreen_2.fsh"))
        /*
         分屏滤镜就是处理像素点映射到想要显示的像素点的纹素值，可以从顶点着色器处理也可以在片元着色器中处理
         //二分屏顶点着色器代码：
         attribute vec4 Position;
         attribute vec2 TextureCoords;
         varying vec2 TextureCoordsVarying;

         void main (void) {
             gl_Position = Position;
             TextureCoordsVarying = TextureCoords;
         }
         //二分屏片元着色器代码：
         precision highp float;
         uniform sampler2D Texture;
         varying highp vec2 TextureCoordsVarying;

         void main() {
             vec2 uv = TextureCoordsVarying.xy;
             float y;
             if (uv.y >= 0.0 && uv.y <= 0.5) {
                 y = uv.y + 0.25;
             } else {
                 y = uv.y - 0.25;
             }
             gl_FragColor = texture2D(Texture, vec2(uv.x, y));
         }
         
         */
        filterDatas.append(FilterData(name: "三分屏", verName: "ThreeScreen.sh", fragName: "ThreeScreen.fsh"))
        /*
         //三分屏顶点着色器代码
         attribute vec4 Position;
         attribute vec2 TextureCoords;
         varying vec2 TextureCoordsVarying;

         void main (void) {
             gl_Position = Position;
             TextureCoordsVarying = TextureCoords;
         }
         //三分屏片元着色器代码
         uniform sampler2D Texture;
         varying highp vec2 TextureCoordsVarying;

         void main() {
             vec2 uv = TextureCoordsVarying.xy;
             float y;
             if (uv.y >= 0.0 && uv.y <= 0.33) {
                 y = uv.y + 0.33;
             }else if (uv.y > 0.66 && uv.y <= 1.0){
                 y = uv.y - 0.33;
             }else{
                 y = uv.y;
             }
             gl_FragColor = texture2D(Texture, vec2(uv.x, y));
         }

         */
        //四分屏顶点着色器
        let verstr = """
             attribute vec4 Position;
             attribute vec2 TextureCoords;
             varying vec2 TextureCoordsVarying;
             void main (void) {
             gl_Position = Position;
             TextureCoordsVarying = TextureCoords;
             }
         """
        //四分屏片元着色器程序代码
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
        //六分屏片元着色器代码，顶点着色器和前面的一样
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
        filterDatas.append(FilterData(name: "六分屏",verString: verstr, fragString: fsh6))
        //九分屏片元着色器程序代码
        let fsh9 = """
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

        if (uv.y < 0.3333){
           uv.y = uv.y * 3.0;
        }else if(uv.y < 0.6666){
           uv.y = (uv.y - 0.3333) * 3.0;
        }else {
           uv.y = (uv.y - 0.6666) * 3.0;
        }
        gl_FragColor = texture2D(Texture, uv);
        }
        """
        filterDatas.append(FilterData(name: "九分屏",verString: verstr, fragString: fsh9))
        /*
         2.灰度滤镜，就是使rgb三色的平衡，0.2125, 0.7154, 0.0721，人眼对绿色比较敏感，所以绿色值更大一些
         灰度滤镜有多种实现方法：
         1.浮点算法:Gray=R*0.3+G*0.59+B*0.11
         2.整数⽅方法:Gray=(R*30+G*59+B*11)/100
         3.移位⽅方法:Gray =(R*76+G*151+B*28)>>8;
         4.平均值法:Gray=(R+G+B)/3;
         5.仅取绿⾊色:Gray=G
         */
        let maskFsh = """
        precision highp float;
        uniform sampler2D Texture;
        varying highp vec2 TextureCoordsVarying;
        const highp vec3 w = vec3(0.2125, 0.7154, 0.0721);

        void main(){
        vec4 color = texture2D(Texture,TextureCoordsVarying);
        float color1 = dot(color.rgb,w);
        gl_FragColor = vec4(vec3(color1),1.0);
        }
        """
       filterDatas.append(FilterData(name: "灰度",verString: verstr, fragString: maskFsh))
        /*
         2.漩涡滤镜，给定中心点、半径，旋转角度，距离中心点约近旋转角度越大，坐标某点的颜色值等于旋转之后的纹素颜色值
         图像漩涡主要是在某个半径范围里，把当前采样点旋转 ⼀定⻆角度，旋转以后当前点的颜色就被旋转后的点的颜色代替，因此整个半径范围里会有旋转的效果。如果旋 转的时候旋转⻆角度随着当前点离半径的距离递减，整个图像就会出现漩涡效果。这⾥使⽤了了抛物线递减因 子:(1.0-(r/Radius)*(r/Radius))。
         //漩涡滤镜片元着色器代码：
         precision mediump float; //PI
         const float PI = 3.14159265; //纹理理采样器器
         uniform sampler2D Texture; //旋转⻆角度
         const float uD = 80.0; //旋涡半径
         const float uR = 0.5;
         //纹理理坐标
         varying vec2 TextureCoordsVarying;
         void main() {
         //旋转正⽅方形范围:[512,512]
         ivec2 ires = ivec2(512, 512); //获取旋转的直径
         float Res = float(ires.s); //纹理理坐标[0,0],[1,0],[0,1],[1,1]...
         vec2 st = TextureCoordsVarying; //半径 = 直径 * 0.5;
         float Radius = Res * uR;
         //准备旋转处理理的纹理理坐标 = 纹理理坐标 * 直径 vec2 xy = Res * st;
         //纹理理坐标减去中点
         vec2 dxy = xy - vec2(Res/2., Res/2.);
         //r 半径 即跟中点的距离
         float r = length(dxy);
         //抛物线递减因⼦子:(1.0-(r/Radius)*(r/Radius) )  衰减因子为二次函数 
         float beta = atan(dxy.y, dxy.x) + radians(uD) * (1.0-(r/Radius)*(r/Radius));
         if(r<=Radius) {
         //获取的纹理理坐标旋转beta度.
         xy = Res/2.0 + r*vec2(cos(beta), sin(beta));
         }
         //st = 旋转后的纹理理坐标/旋转范围 st = xy/Res;
         //将旋转的纹理理坐标替换原始纹理理坐标TextureCoordsVarying 获取对应像素点的颜⾊色. vec3 irgb = texture2D(Texture, st).rgb;
         //将计算后的颜⾊色填充到像素点中 gl_FragColor
         gl_FragColor = vec4( irgb, 1.0 ); }
         */
        filterDatas.append(FilterData(name: "漩涡", verName: "Cirlce.vsh", fragName: "Cirlce.fsh"))
        /*
         3.马赛克滤镜，马赛克滤镜就是某一小半径大小的圆内的颜色值的相同，都取圆心的颜色值，马赛克效果就是把图片的一个相当⼤⼩的区域⽤同一个 点的颜色来表示.可以认为是大规模的降低图像的分辨 率,⽽而让图像的⼀一些细节隐藏起来。
         //马赛克滤镜片元着色器代码：
         on mediump float;
         //纹理理坐标
         varying vec2 TextureCoordsVarying; //纹理理采样器器
         uniform sampler2D Texture;
         //纹理理图⽚片size
         const vec2 TexSize = vec2(400.0, 400.0); //⻢马赛克Size
         const vec2 mosaicSize = vec2(16.0, 16.0);
         void main()
         {
         //计算实际图像位置
         vec2 intXY = vec2(TextureCoordsVarying.x*TexSize.x, TextureCoordsVarying.y*TexSize.y);
         // floor (x) 内建函数,返回⼩小于/等于X的最⼤大整数值.
         // 0123456789  假如m大小为3 ，floor（x/3）* 3，结果，012取0 345取3 678 取6，就形成了某一片是一个文素的颜色，形成马赛克
         // floor (intXY.x / mosaicSize.x) * mosaicSize.x 计算出⼀一个⼩小⻢马赛克的坐标.
         vec2 XYMosaic = vec2(floor(intXY.x/mosaicSize.x)*mosaicSize.x, floor(intXY.y/
         mosaicSize.y)*mosaicSize.y);
         //换算回纹理理坐标
         vec2 UVMosaic = vec2(XYMosaic.x/TexSize.x, XYMosaic.y/TexSize.y);
         //获取到⻢马赛克后的纹理理坐标的颜⾊色值
         vec4 color = texture2D(Texture, UVMosaic);
         //将⻢马赛克颜⾊色值赋值给gl_FragColor. gl_FragColor = color;
         }
         */
        filterDatas.append(FilterData(name: "马赛克", verName: "Mosaic.vsh", fragName: "Mosaic.fsh"))
        /*
         4.六边形马赛克
         滤镜实现思路: 我们要做的效果就是让一张图片，分割成由六边形组成，让每个六边形中的颜色相同(直接取六边形中⼼点像素RGB较⽅便，我们 这里采⽤的就是这种⽅方法)将它进⾏行行分割，取每个六边形的中⼼点画出⼀个六边形，如下图：
         
         如上图，画出很多长和宽比例为 2:√3 的的矩形阵。然后我们可以对每个点进行编号，如上图中，采⽤用坐标系标记.
         假如我们的屏幕的左上点为上图的(0,0)点，则屏幕上的任⼀点我们找到它所对应的那个矩形了了。
         假定我们设定的矩阵⽐例例为 2*LEN : √3*LEN ，那么屏幕上的任意 点(x, y)所对应的矩阵坐标为(int(x/(2*LEN)), int(y/ (√3*LEN)))。
         //wx,wy -> 表示纹理坐标在所对应的矩阵坐标为
         int wx = int(x /( 1.5 * length)); int wy = int(y /(TR * length));
         //六边形马赛克片元着色器代码
         precision highp float;
         uniform sampler2D Texture;
         varying vec2 TextureCoordsVarying;

         const float mosaicSize = 0.03;

         void main (void)
         {
             float length = mosaicSize;
             float TR = 0.866025;
             
             float x = TextureCoordsVarying.x;
             float y = TextureCoordsVarying.y;
             
             int wx = int(x / 1.5 / length);
             int wy = int(y / TR / length);
             vec2 v1, v2, vn;
             
             if (wx/2 * 2 == wx) {
                 if (wy/2 * 2 == wy) {
                     //(0,0),(1,1)
                     v1 = vec2(length * 1.5 * float(wx), length * TR * float(wy));
                     v2 = vec2(length * 1.5 * float(wx + 1), length * TR * float(wy + 1));
                 } else {
                     //(0,1),(1,0)
                     v1 = vec2(length * 1.5 * float(wx), length * TR * float(wy + 1));
                     v2 = vec2(length * 1.5 * float(wx + 1), length * TR * float(wy));
                 }
             }else {
                 if (wy/2 * 2 == wy) {
                     //(0,1),(1,0)
                     v1 = vec2(length * 1.5 * float(wx), length * TR * float(wy + 1));
                     v2 = vec2(length * 1.5 * float(wx + 1), length * TR * float(wy));
                 } else {
                     //(0,0),(1,1)
                     v1 = vec2(length * 1.5 * float(wx), length * TR * float(wy));
                     v2 = vec2(length * 1.5 * float(wx + 1), length * TR * float(wy + 1));
                 }
             }
             
             float s1 = sqrt(pow(v1.x - x, 2.0) + pow(v1.y - y, 2.0));
             float s2 = sqrt(pow(v2.x - x, 2.0) + pow(v2.y - y, 2.0));
             if (s1 < s2) {
                 vn = v1;
             } else {
                 vn = v2;
             }
             vec4 color = texture2D(Texture, vn);
             
             gl_FragColor = color;
             
         }
         5.三角形马赛克
         三角形马赛克和六边形马赛克原理类是，理解了六边形马赛克实现原理，三角形就是把六边形分成了六个三角形，每个三角形内的颜色值取同一个。
         //三角形马赛克的片元着色器代码：
         precision highp float;
         uniform sampler2D Texture;
         varying vec2 TextureCoordsVarying;

         float mosaicSize = 0.03;

         void main (void){
             const float TR = 0.866025;
             const float PI6 = 0.523599;
             
             float x = TextureCoordsVarying.x;
             float y = TextureCoordsVarying.y;
             
          
             int wx = int(x/(1.5 * mosaicSize));
             int wy = int(y/(TR * mosaicSize));
             
             vec2 v1, v2, vn;
             
             if (wx / 2 * 2 == wx) {
                 if (wy/2 * 2 == wy) {
                     v1 = vec2(mosaicSize * 1.5 * float(wx), mosaicSize * TR * float(wy));
                     v2 = vec2(mosaicSize * 1.5 * float(wx + 1), mosaicSize * TR * float(wy + 1));
                 } else {
                     v1 = vec2(mosaicSize * 1.5 * float(wx), mosaicSize * TR * float(wy + 1));
                     v2 = vec2(mosaicSize * 1.5 * float(wx + 1), mosaicSize * TR * float(wy));
                 }
             } else {
                 if (wy/2 * 2 == wy) {
                     v1 = vec2(mosaicSize * 1.5 * float(wx), mosaicSize * TR * float(wy + 1));
                     v2 = vec2(mosaicSize * 1.5 * float(wx+1), mosaicSize * TR * float(wy));
                 } else {
                     v1 = vec2(mosaicSize * 1.5 * float(wx), mosaicSize * TR * float(wy));
                     v2 = vec2(mosaicSize * 1.5 * float(wx + 1), mosaicSize * TR * float(wy+1));
                 }
             }

             float s1 = sqrt(pow(v1.x - x, 2.0) + pow(v1.y - y, 2.0));
             float s2 = sqrt(pow(v2.x - x, 2.0) + pow(v2.y - y, 2.0));

             if (s1 < s2) {
                 vn = v1;
             } else {
                 vn = v2;
             }
             
             vec4 mid = texture2D(Texture, vn);
             float a = atan((x - vn.x)/(y - vn.y));

             vec2 area1 = vec2(vn.x, vn.y - mosaicSize * TR / 2.0);
             vec2 area2 = vec2(vn.x + mosaicSize / 2.0, vn.y - mosaicSize * TR / 2.0);
             vec2 area3 = vec2(vn.x + mosaicSize / 2.0, vn.y + mosaicSize * TR / 2.0);
             vec2 area4 = vec2(vn.x, vn.y + mosaicSize * TR / 2.0);
             vec2 area5 = vec2(vn.x - mosaicSize / 2.0, vn.y + mosaicSize * TR / 2.0);
             vec2 area6 = vec2(vn.x - mosaicSize / 2.0, vn.y - mosaicSize * TR / 2.0);
             

             if (a >= PI6 && a < PI6 * 3.0) {
                 vn = area1;
             } else if (a >= PI6 * 3.0 && a < PI6 * 5.0) {
                 vn = area2;
             } else if ((a >= PI6 * 5.0 && a <= PI6 * 6.0) || (a < -PI6 * 5.0 && a > -PI6 * 6.0)) {
                 vn = area3;
             } else if (a < -PI6 * 3.0 && a >= -PI6 * 5.0) {
                 vn = area4;
             } else if(a <= -PI6 && a> -PI6 * 3.0) {
                 vn = area5;
             } else if (a > -PI6 && a < PI6) {
                 vn = area6;
             }
             
             vec4 color = texture2D(Texture, vn);
             gl_FragColor = color;
         }
         */
        filterDatas.append(FilterData(name: "六马赛克", verName: "HexagonMosaic.vsh", fragName: "HexagonMosaic.fsh"))
        filterDatas.append(FilterData(name: "三马赛克", verName: "TriangularMosaic.vsh", fragName: "TriangularMosaic.fsh"))
        /*
         1.缩放滤镜，一个时间循环中随时间放大缩小，通过修改顶点坐标和纹理坐标的映射关系来实现放大效果
         
         //放大过程.在顶点着色器完成.代码如下：

         //顶点坐标
         attribute vec4 Position;
         //纹理坐标
         attribute vec2 TextureCoords;
         //纹理坐标
         varying vec2 TextureCoordsVarying;
         //时间撮(及时更新)
         uniform float Time;
         //PI
         const float PI = 3.1415926;

         void main (void) {
            
             //一次缩放效果时长 0.6
             float duration = 0.6;
             //最大缩放幅度
             float maxAmplitude = 0.3;
             
             //表示时间周期.范围[0.0~0.6];
             float time = mod(Time, duration);
             
             //amplitude [1.0,1.3]
             float amplitude = 1.0 + maxAmplitude * abs(sin(time * (PI / duration)));
             
             // 顶点坐标x/y 分别乘以放大系数[1.0,1.3]
             gl_Position = vec4(Position.x * amplitude, Position.y * amplitude, Position.zw);
            
             // 纹理坐标
             TextureCoordsVarying = TextureCoords;
         }
         */
        filterDatas.append(FilterData(name: "scale", verName: "Scale.vsh", fragName: "Scale.fsh",needTime: true))
        /*
         //抖动滤镜: 颜色偏移 + 微弱的放大效果，某一区域内的颜色值取便宜之后对应的颜色值和放大效果叠加呈现出抖动的效果
         抖动滤镜的片元着色器代码：
         precision highp float;
         //纹理
         uniform sampler2D Texture;
         //纹理坐标
         varying vec2 TextureCoordsVarying;
         //时间撮
         uniform float Time;

         void main (void) {
             
             //一次抖动滤镜的时长 0.7
             float duration = 0.7;
             //放大图片上限
             float maxScale = 1.1;
             //颜色偏移步长
             float offset = 0.02;
             
             //进度[0,1]
             float progress = mod(Time, duration) / duration; // 0~1
             //颜色偏移值范围[0,0.02]
             vec2 offsetCoords = vec2(offset, offset) * progress;
             //缩放范围[1.0-1.1];
             float scale = 1.0 + (maxScale - 1.0) * progress;
             
             //放大纹理坐标.
             vec2 ScaleTextureCoords = vec2(0.5, 0.5) + (TextureCoordsVarying - vec2(0.5, 0.5)) / scale;
             
             //获取3组颜色rgb
             //+ offsetCoords 偏移后的坐标的纹素 比如点（0.3，0.3）去的是（0.4，0.4）处的颜色值
             vec4 maskR = texture2D(Texture, ScaleTextureCoords + offsetCoords);
             //-offsetCoords 偏移后的坐标的纹素 比如点（0.3，0.3）去的是（0.2，0.2）处的颜色值
             vec4 maskB = texture2D(Texture, ScaleTextureCoords - offsetCoords);
             //原始颜色
             vec4 mask = texture2D(Texture, ScaleTextureCoords);
             
             //从3组来获取颜色:
             //maskR.r,mask.g,maskB.b 注意这3种颜色取值可以打乱或者随意发挥.不一定写死.只是效果会有不一样.大家可以试试.
             //mask.a 获取原图的透明度
             gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
            
             
         }
         */
        filterDatas.append(FilterData(name: "shake", verName: "Shake.vsh", fragName: "Shake.fsh",needTime: true))
        /*
         
         //3.闪白滤镜: 添加白色图层 ,白色图层的透明度随着时间变化
         闪白滤镜片元着色器程序代码：
         precision highp float;
         //纹理采样器
         uniform sampler2D Texture;
         //纹理坐标
         varying vec2 TextureCoordsVarying;
         //时间撮
         uniform float Time;
         //PI 常量
         const float PI = 3.1415926;

         void main (void) {
             
             //一次闪白滤镜的时长 0.6
             float duration = 0.6;
             //表示时间周期[0.0,0.6]
             float time = mod(Time, duration);
             //白色颜色遮罩层
             vec4 whiteMask = vec4(1.0, 1.0, 1.0, 1.0);
             //振幅: (0.0,1.0)
             float amplitude = abs(sin(time * (PI / duration)));
             //纹理坐标对应的纹素(RGBA)
             vec4 mask = texture2D(Texture, TextureCoordsVarying);
             
             //利用混合方程式; 白色图层 + 原始纹理图片颜色 来进行混合
             gl_FragColor = mask * (1.0 - amplitude) + whiteMask * amplitude;
         }
         */
        filterDatas.append(FilterData(name: "闪白", verName: "ShineWhite.vsh", fragName: "ShineWhite.fsh",needTime: true))
        /*
         4.毛刺滤镜: 撕裂 + 微弱的颜色偏移
         具体的思路是，我们让每一行像素随机偏移 -1 ~ 1 的距离（这里的 -1 ~ 1 是对于纹理坐标来说的），但是如果整个画面都偏移比较大的值，那我们可能都看不出原来图像的样子。所以我们的逻辑是，设定一个阈值，小于这个阈值才进行偏移，超过这个阈值则乘上一个缩小系数。则最终呈现的效果是：绝大部分的行都会进行微小的偏移，只有少量的行会进行较大偏移
         片元着色器程序代码：
         precision highp float;
         //纹理
         uniform sampler2D Texture;
         //纹理坐标
         varying vec2 TextureCoordsVarying;
         //时间撮
         uniform float Time;
         //PI
         const float PI = 3.1415926;

         //随机数
         float rand(float n) {
             //fract(x),返回x的小数部分数据
             return fract(sin(n) * 43758.5453123);
         }

         void main (void) {
             
             //最大抖动
             float maxJitter = 0.06;
             //一次毛刺滤镜的时长
             float duration = 0.3;
             //红色颜色偏移量
             float colorROffset = 0.01;
             //绿色颜色偏移量
             float colorBOffset = -0.025;
             
             //时间周期[0.0,0.6];
             float time = mod(Time, duration * 2.0);
             //振幅:[0,1];
             float amplitude = max(sin(time * (PI / duration)), 0.0);
             
             //像素随机偏移[-1,1]
             float jitter = rand(TextureCoordsVarying.y) * 2.0 - 1.0; // -1~1
             
             //是否要做偏移.
             bool needOffset = abs(jitter) < maxJitter * amplitude;
             
             //获取纹理X值.根据needOffset,来计算它X撕裂.
             //needOffset = YES ,撕裂较大;
             //needOffset = NO,撕裂较小.
             float textureX = TextureCoordsVarying.x + (needOffset ? jitter : (jitter * amplitude * 0.006));
             
             //撕裂后的纹理坐标x,y
             vec2 textureCoords = vec2(textureX, TextureCoordsVarying.y);
             
             //颜色偏移3组颜色
             //根据撕裂后获取的纹理颜色值
             vec4 mask = texture2D(Texture, textureCoords);
             //撕裂后的纹理颜色偏移
             vec4 maskR = texture2D(Texture, textureCoords + vec2(colorROffset * amplitude, 0.0));
             //撕裂后的纹理颜色偏移
             vec4 maskB = texture2D(Texture, textureCoords + vec2(colorBOffset * amplitude, 0.0));
             
             //红色/蓝色部分发生撕裂.
             gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
         }
         */
        filterDatas.append(FilterData(name: "毛刺", verName: "Glitch.vsh", fragName: "Glitch.fsh",needTime: true))
        /*
         5.灵魂出窍滤镜: 是两个层的叠加，并且上面的那层随着时间的推移，会逐渐放大且不透明度逐渐降低。这里也用到了放大的效果，我们这次用片段着色器来实现
         灵魂出窍效果片元着色器代码：

         precision highp float;
         //纹理采样器
         uniform sampler2D Texture;
         //纹理坐标
         varying vec2 TextureCoordsVarying;
         //时间撮
         uniform float Time;

         void main (void) {
             
             //一次灵魂出窍效果的时长 0.7
             float duration = 0.7;
             //透明度上限
             float maxAlpha = 0.4;
             //放大图片上限
             float maxScale = 1.8;
             
             //进度值[0,1]
             float progress = mod(Time, duration) / duration; // 0~1
             //透明度[0,0.4]
             float alpha = maxAlpha * (1.0 - progress);
             //缩放比例[1.0,1.8]
             float scale = 1.0 + (maxScale - 1.0) * progress;
             
             //1.放大纹理坐标
             //根据放大笔记.得到放大纹理坐标 [0,0],[0,1],[1,1],[1,0]
             float weakX = 0.5 + (TextureCoordsVarying.x - 0.5) / scale;
             float weakY = 0.5 + (TextureCoordsVarying.y - 0.5) / scale;
             //放大纹理坐标
             vec2 weakTextureCoords = vec2(weakX, weakY);
             
             //获取对应放大纹理坐标下的纹素(颜色值rgba)
             vec4 weakMask = texture2D(Texture, weakTextureCoords);
            
             //原始的纹理坐标下的纹素(颜色值rgba)
             vec4 mask = texture2D(Texture, TextureCoordsVarying);
             
             //颜色混合 默认颜色混合方程式 = mask * (1.0-alpha) + weakMask * alpha;
             gl_FragColor = mask * (1.0 - alpha) + weakMask * alpha;

         }
         */
        filterDatas.append(FilterData(name: "灵魂出窍", verName: "SoulOut.vsh", fragName: "SoulOut.fsh",needTime: true))
        
        let CGAColorFragmentShader = """
            precision highp float;
            varying vec2 TextureCoordsVarying;
            uniform sampler2D Texture;

            void main()
            {
                vec2 sampleDivisor = vec2(1.0 / 200.0, 1.0 / 320.0);
                //highp vec4 colorDivisor = vec4(colorDepth);
                
                vec2 samplePos = TextureCoordsVarying - mod(TextureCoordsVarying, sampleDivisor);
                vec4 color = texture2D(Texture, samplePos );
                
                //gl_FragColor = texture2D(Texture, samplePos );
                vec4 colorCyan = vec4(85.0 / 255.0, 1.0, 1.0, 1.0);
                vec4 colorMagenta = vec4(1.0, 85.0 / 255.0, 1.0, 1.0);
                vec4 colorWhite = vec4(1.0, 1.0, 1.0, 1.0);
                vec4 colorBlack = vec4(0.0, 0.0, 0.0, 1.0);
                
                vec4 endColor;
                float blackDistance = distance(color, colorBlack);
                float whiteDistance = distance(color, colorWhite);
                float magentaDistance = distance(color, colorMagenta);
                float cyanDistance = distance(color, colorCyan);
                
                vec4 finalColor;
                
                float colorDistance = min(magentaDistance, cyanDistance);
                colorDistance = min(colorDistance, whiteDistance);
                colorDistance = min(colorDistance, blackDistance);
                
                if (colorDistance == blackDistance) {
                    finalColor = colorBlack;
                } else if (colorDistance == whiteDistance) {
                    finalColor = colorWhite;
                } else if (colorDistance == cyanDistance) {
                    finalColor = colorCyan;
                } else {
                    finalColor = colorMagenta;
                }
                
                gl_FragColor = finalColor;
            }
         """
        
        filterDatas.append(FilterData(name: "CGAColor",verString: verstr, fragString: CGAColorFragmentShader))
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        filterView = DQFilterView(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.height - 260), vertexShaderName: "Normal.vsh", fragmentShaderName: "Normal.fsh")
        filterView.imageName = "kunkun.jpg"
        view.addSubview(filterView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let bar = FIlterBar(frame: CGRect(x: 0, y: view.frame.size.height - 120, width: view.frame.size.width, height: 100))
        bar.datas = filterDatas
        bar.backgroundColor = .red
        bar.selectedBlock = { [weak self] (index ) in
            guard let filterData = self?.filterDatas[index.row] else {
                return
            }
            if filterData.fragString.count > 1{
                self?.filterView.vertexShaderString = filterData.verString
                self?.filterView.fragmentShaderString = filterData.fragString
                self?.filterView.vertexShaderName = nil
                self?.filterView.fragmentShaderName = nil
            }else{
                self?.filterView.vertexShaderName = filterData.verName
                self?.filterView.fragmentShaderName = filterData.fragName
                self?.filterView.vertexShaderString = nil
                self?.filterView.fragmentShaderString = nil
            }

            self?.filterView.updateRender(time: filterData.needTime)
        }
        view.addSubview(bar)
    }


}
