//
//  CoreImageViewController.swift
//  ImageFilters
//
//  Created by dzq_mac on 2020/5/28.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit
/*
 
 Core Image是一个很强大的框架。它可以让你简单地应用各种滤镜来处理图像，比如修改鲜艳程度, 色泽, 或者曝光，对图像进行滤镜操作，比如模糊、颜色改变、锐化、人脸识别等。 它利用GPU（或者CPU）来非常快速、甚至实时地处理图像数据和视频的帧。并且隐藏了底层图形处理的所有细节，通过提供的API就能简单的使用了，无须关心OpenGL或者OpenGL ES是如何充分利用GPU的能力的，也不需要你知道GCD在其中发挥了怎样的作用，Core Image处理了全部的细节
 
 一、 Core Image介绍
 我们可以将CIImage对象与其他核心图像类(如CIFilter、CIContext、CIVector和cicoll)结合使用，以便在处理图像时利用内置的核心图像滤镜。您可以使用各种来源提供的数据创建CIImage对象，包括Quartz 2D图像、核心视频图像缓冲区(CVImageBuffer)、基于url的对象和NSData对象
 尽管CIImage对象具有与其关联的图像数据，但它不是一个图像。您可以将CIImage对象看作映像“菜谱”。CIImage对象拥有生成图像所需的所有信息，但是Core image在被告知之前并不实际呈现图像。这种惰性计算允许Core Image尽可能高效地运行。
 CIContext 和 CIImage 对象是不可变的，这意味着它们可以在线程之间安全地共享。多线程可以使用相同的GPU或CPU CIContext 对象来渲染 CIImage 对象。但是，CIFilter 对象不是这样的，它是可变的。不能在线程之间安全地共享 CIFilter 对象。如果你的应用程序是多线程的，每个线程必须创建自己的CIFilter对象。否则，app可能会出现意外的表现。
 CoreImage还提供自动调整方法。这些方法分析图像的常见缺陷，并返回一组过滤器来纠正这些缺陷。滤镜预设了一些值，用于通过改变肤色、饱和度、对比度和阴影的值来改善图像质量，并用于消除由闪光灯引起的红眼或其他伪影。(参见获得自动调整滤镜。)
 1.框架介绍
 (1)CoreImage
 (2)是一个图片框架
 它基于OpenGL顶层创建
 底层则用着色器来处理图像
 (3)他利用了GPU基于硬件加速来处理图像
 (4）CoreImage中有很多滤镜
 （5）它们能够一次给予一张图像或者视频帧多种视觉效果 -> 滤镜链
 （6）而且滤镜可以连接起来组成一个滤镜链 把滤镜效果叠加起来处理图像

 2.类的介绍
 1.CIImage 保存图像数据的类
 CGImageRef->图像中的数据
 2.CIFilter 滤镜类
 图片属性进行细节处理的类
 它对所有的像素进行操作 用键-值(KVC)来设置
 3.CIContext 上下文是实现对图像处理的具体对象 用来把滤镜和图片合成成为一张图片 滤镜对象输出的图像并不是合成之后的图像，需要使用图片处理的上下文 合并输出图像
 接下来就是他系统内部的效果分类，效果分类就不在这里一一罗列出来了，因为这里根本写不下，可以点进CIFilter里，然后找到128行，从这里开始，可以一一了解一下这些效果。
 然后我们就可以做一个图片处理的效果，我们处理图片的原理上面给大家说过了，就是给他添加了一个滤镜，CIFilter，来使他的视图发生一些变化。
 在这里我们虽然展示在视图上的仍然是UIImageView上面的image，但是我们做处理的时候使用的是CIImage。然后我们需要找到我们需要的效果类，在CIFilter中查询我们需要的效果类，这里直接上代码给大家解释，因为在找效果类的时候比较复杂。
 
 二、使用CoreImage滤镜
 */
class CoreImageViewController: UIViewController {

    let context :CIContext = CIContext()
    var imageView:UIImageView!
    //1.创建CIImage，创建一个imageview接受处理后的图片
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        //创建一个imageview接受处理后的图片
        imageView =  UIImageView(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.height - 100))
        view.addSubview(imageView)
        
        filterImage()
    }
    
    func filterImage() {
    
        let path = Bundle.main.path(forResource: "image", ofType: "jpg") ?? ""
        let imageURL = URL(fileURLWithPath: path)
        let originalCIImage = CIImage(contentsOf: imageURL)!
        let filters = originalCIImage.autoAdjustmentFilters()//自动调整滤镜
        print(filters)
//        self.imageView.image = UIImage(ciImage:scaleFilter(originalCIImage)!)
//        self.imageView.image = createCode(codeType: "CIQRCodeGenerator", codeString: "hello", size: CGSize(width: 300, height: 300), qrColor: .black, bkColor: .white)
        self.imageView.image = UIImage(ciImage:colorCurvesFilter(originalCIImage)!)
//        self.imageView.image = UIImage(ciImage:colorControlFilter(originalCIImage)!)
    }
     //2.滤镜使用--高斯模糊滤镜
    func filterTest(_ input: CIImage)->CIImage? {
        //        CIFilter.filterNames(inCategory: "")//获取所有滤镜名
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(input, forKey: kCIInputImageKey)
        filter?.setValue(5, forKey: kCIInputRadiusKey)
        print(filter!.attributes)//获取某一滤镜的所有属性
        print(filter!.inputKeys)//获取某一属性的所有输入项
        
        return filter?.outputImage
    }
    //3.颜色控制滤镜
    func colorControlFilter(_ input: CIImage) -> CIImage?
    {
        let sepiaFilter = CIFilter(name:"CIColorControls")
        
//        print(sepiaFilter?.attributes)
        sepiaFilter?.setValue(input, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(NSNumber(1), forKey: "inputSaturation")//饱和度
        sepiaFilter?.setValue(NSNumber(1), forKey: "inputBrightness")//亮度
        sepiaFilter?.setValue(NSNumber(3), forKey: "inputContrast")//对比度
        return sepiaFilter?.outputImage
    }
    //4.线性凹凸效果滤镜
    func colorCurvesFilter(_ input: CIImage) ->  CIImage?{
        let scaleFilter = CIFilter(name: "CIVortexDistortion")
        scaleFilter?.setValue(input, forKey: kCIInputImageKey)
        print(scaleFilter!.attributes)
        
        scaleFilter?.setValue(NSNumber(100), forKey: "inputAngle")
        scaleFilter?.setValue(NSNumber(500), forKey: "inputRadius")
//        scaleFilter?.setValue(NSNumber(1), forKey: "inputScale")
        scaleFilter?.setValue(CIVector(x: 200, y: 400), forKey: "inputCenter")
        return scaleFilter?.outputImage
    }
    //4.生成二维码生成器，CoreImage可以生成二维码条形码棋盘等十多种特殊图像
    public func createCode( codeType:String, codeString:String, size:CGSize,qrColor:UIColor,bkColor:UIColor )->UIImage?
    {
        //if #available(iOS 8.0, *)
        
        let stringData = codeString.data(using: String.Encoding.utf8)
        
        
        //系统自带能生成的码
        //        CIAztecCodeGenerator
        //        CICode128BarcodeGenerator
        //        CIPDF417BarcodeGenerator
        //        CIQRCodeGenerator
        let qrFilter = CIFilter(name: codeType)
        
//        print(qrFilter?.attributes)
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
        
        
        //上色
        let colorFilter = CIFilter(name: "CIFalseColor", parameters: ["inputImage":qrFilter!.outputImage!,"inputColor0":CIColor(cgColor: qrColor.cgColor),"inputColor1":CIColor(cgColor: bkColor.cgColor)])
        
        
        let qrImage = colorFilter!.outputImage!;
        let logoImage = UIImage(named: "hulu.jpg")!
        
        //绘制
        let cgImage = CIContext().createCGImage(qrImage, from: qrImage.extent)!
        
        UIGraphicsBeginImageContext(size);
        let context = UIGraphicsGetCurrentContext()!;
        context.interpolationQuality = CGInterpolationQuality.none;
        context.scaleBy(x: 1.0, y: -1.0);
        context.draw(cgImage, in: context.boundingBoxOfClipPath)
        let codeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        

        return addlogo(logoImage: logoImage, to: codeImage!)
       
    }
   
    //添加logo
    func addlogo(logoImage:UIImage,to sourceImage:UIImage) -> UIImage? {
        let size = sourceImage.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        sourceImage.draw(at: CGPoint(x: 0, y: 0))
        
        let context1 = UIGraphicsGetCurrentContext()!
        context1.drawPath(using: .stroke)
        let rect = CGRect(x: size.width/2 - 25, y: size.height/2 - 25, width: 50, height: 50)
        context1.clip()
        logoImage.draw(in: rect)
        let codeImage1 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return codeImage1
    }
    /*
     5.人脸识别，CoreImage可以识别人脸，眼睛嘴巴鼻子等属性
    CIDetectorAccuracy适用于设置识别精度 CIDetecror 是 coreImage 框架中提供的一个识别类，包括人脸【CIDetectorTypeFace】，形状【CIDetectorTypeRectangle】，条码【CIDetectorTypeQRCode】，文本【CIDetectorTypeText】的识别
     具体人脸识别细节可参考https://www.jianshu.com/p/e371099f12bd
     */
    func faceFilter(_ input: CIImage){
        //detect face
        let personciImage = input
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: personciImage)
        
        print("------检测到\(faces!.count)张人脸-------")
        if(faces?.count ?? 0 > 0){
            let face = faces?.first as! CIFaceFeature
            if (face.hasSmile) {
                print("有微笑");
            }
            if (face.leftEyeClosed) {
                print("左眼闭着");
            }
            if (face.rightEyeClosed) {
                print("右眼闭着");
            }
            
            
           
        }
    }
    //
    func createNonInterpolatedUIImageFormCIImage(image:CIImage) ->UIImage? {
        let extent = image.extent
        let cs = CGColorSpaceCreateDeviceGray()
        let bitmap = CGContext.init(data: nil, width: Int(extent.width), height: Int(extent.height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo:CGImageAlphaInfo.none.rawValue)
        let context = CIContext(options: nil)
        
        let bitmapImage = context.createCGImage(image, from: extent)
        bitmap?.interpolationQuality = .none
        bitmap?.draw(bitmapImage!, in: extent)
        let cgimage = bitmap?.makeImage()

        return UIImage(cgImage: cgimage!)
        
    }
}
/*
 // 添加logo
 // 将二维码转成高清的格式。四、整理CoreImage分类滤镜
 - (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
     
     CGRect extent = CGRectIntegral(image.extent);
     CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
     
     // 1.创建bitmap;
     size_t width = CGRectGetWidth(extent) * scale;
     size_t height = CGRectGetHeight(extent) * scale;
     CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
     CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
     CIContext *context = [CIContext contextWithOptions:nil];
     CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
     CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
 
     CGContextScaleCTM(bitmapRef, scale, scale);
     CGContextDrawImage(bitmapRef, extent, bitmapImage);
     
     // 2.保存bitmap到图片
     CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
     CGContextRelease(bitmapRef);
     CGImageRelease(bitmapImage);
     return [UIImage imageWithCGImage:scaledImage];
 }
 */











/*
 -------Category------
 kCICategoryDistortionEffect: String  失真效应
 ["CIBumpDistortion"凹凸变形, "CIBumpDistortionLinear"线性凹凸变形, "CICameraCalibrationLensCorrection"摄像机标定镜头校正, "CICircleSplashDistortion"圆形飞溅效果, "CICircularWrap"圆形包装, "CIDisplacementDistortion"位移变形, "CIDroste", "CIGlassDistortion"玻璃变形, "CIGlassLozenge"菱形玻璃变形, "CIHoleDistortion"孔变形, "CILightTunnel"“光隧道”, "CINinePartStretched"九部分拉伸, "CINinePartTiled"九部分平铺, "CIPinchDistortion"缩放失真, "CIStretchCrop 拉伸剪裁", "CITorusLensDistortion 环面透镜失真", "CITwirlDistortion 旋转失真", "CIVortexDistortion 漩涡失真"]
 kCICategoryGeometryAdjustment:  几何调整
 ["CIAffineTransform 仿射变换", "CIBicubicScaleTransform 双三次尺度变换", "CICrop 裁剪", "CIEdgePreserveUpsampleFilter 边缘保留上样滤镜", "CIKeystoneCorrectionCombined 组合梯形校正", "CIKeystoneCorrectionHorizontal 水平梯形校正”", "CIKeystoneCorrectionVertical 垂直梯形校正", "CILanczosScaleTransform 兰佐斯比例变换", "CIPerspectiveCorrection 透视校正", "CIPerspectiveRotate 透视旋转", "CIPerspectiveTransform 透视变换", "CIPerspectiveTransformWithExtent 有度透视变换", "CIStraightenFilter 伸直滤镜"]
 kCICategoryCompositeOperation:  混合
 ["CIAdditionCompositing 加法合成", "CIColorBlendMode 颜色混合", "CIColorBurnBlendMode 颜色燃烧混合", "CIColorDodgeBlendMode 颜色减淡混合", "CIDarkenBlendMode 加深混合", "CIDifferenceBlendMode 差异混合", "CIDivideBlendMode 除法混合", "CIExclusionBlendMode 排斥混合", "CIHardLightBlendMode 强光混合", "CIHueBlendMode 色相混合", "CILightenBlendMode 亮度混合", "CILinearBurnBlendMode 线性燃烧混合", "CILinearDodgeBlendMode 线性减淡混合", "CILuminosityBlendMode 光度混合", "CIMaximumCompositing 最大合成", "CIMinimumCompositing最小合成", "CIMultiplyBlendMode 乘法混合", "CIMultiplyCompositing乘法合成", "CIOverlayBlendMode覆盖混合", "CIPinLightBlendMode 销光混合", "CISaturationBlendMode 饱和", "CIScreenBlendMode 屏幕混合", "CISoftLightBlendMode 柔光混合", "CISourceAtopCompositing顶部源合成", "CISourceInCompositing 底部源合成", "CISourceOutCompositing外部源合成", "CISourceOverCompositing内部源合成", "CISubtractBlendMode扣除混合"]
 kCICategoryHalftoneEffect: String  半色调效果
 ["CICircularScreen 圆网", "CICMYKHalftone CMYK 网调", "CIDotScreen 点网", "CIHatchedScreen 孵化网", "CILineScreen 线网"]
 kCICategoryColorAdjustment: String  颜色调整
 ["CIColorClamp", "CIColorControls", "CIColorMatrix", "CIColorPolynomial", "CIDepthToDisparity", "CIDisparityToDepth", "CIExposureAdjust", "CIGammaAdjust", "CIHueAdjust", "CILinearToSRGBToneCurve", "CISRGBToneCurveToLinear", "CITemperatureAndTint", "CIToneCurve", "CIVibrance", "CIWhitePointAdjust"]
 [“颜色夹”、“颜色控制”、“颜色矩阵”、“颜色多项式”、“深度到视差”、“视差到深度”、“曝光调整”、“伽马调整”、“色调调整”、“线性到SRGB色调曲线”、“SRGB色调曲线到线性”、“温度和色调”、“色调曲线”、“振动”、“白点调整”]
 kCICategoryColorEffect: String  色彩效果:
 [“颜色交叉多项式”、“颜色立方”、“颜色方块混合着面具”,“多维数据集与颜色空间”,“颜色曲线”、“颜色反转”,“彩色地图”、“颜色单色”、“颜色多色调分色印”、“犹豫”,“文档增强剂”,“假彩色”、“实验室DeltaE”,“阿尔法”面具,“最大组件”,“最小组件”、“调色板重心”,“Palettize”、“照片效果Chrome”,“照片效果消退”,“照片即时效果”,“照片效果Mono”,“黑色照片效果”,“照片效应过程”,“照片色调效果”,"光效应转移"，"棕褐色"，"热"，"晕"，"晕效应"，" x射线"]
 ["CIColorCrossPolynomial", "CIColorCube", "CIColorCubesMixedWithMask", "CIColorCubeWithColorSpace", "CIColorCurves", "CIColorInvert", "CIColorMap", "CIColorMonochrome", "CIColorPosterize", "CIDither", "CIDocumentEnhancer", "CIFalseColor", "CILabDeltaE", "CIMaskToAlpha", "CIMaximumComponent", "CIMinimumComponent", "CIPaletteCentroid", "CIPalettize", "CIPhotoEffectChrome", "CIPhotoEffectFade", "CIPhotoEffectInstant", "CIPhotoEffectMono", "CIPhotoEffectNoir", "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer", "CISepiaTone", "CIThermal", "CIVignette", "CIVignetteEffect", "CIXRay"]
 kCICategoryTransition: String  转型:
 [“手风琴折叠过渡”、“条形滑动过渡”、“复印机过渡”、“带蒙版过渡的瓦解”、“解散过渡”、“Flash过渡”、“Mod过渡”、“页面卷曲过渡”、“带阴影过渡的页面卷曲”、“波纹过渡”、“滑动过渡”]
 ["CIAccordionFoldTransition", "CIBarsSwipeTransition", "CICopyMachineTransition", "CIDisintegrateWithMaskTransition", "CIDissolveTransition", "CIFlashTransition", "CIModTransition", "CIPageCurlTransition", "CIPageCurlWithShadowTransition", "CIRippleTransition", "CISwipeTransition"]
 kCICategoryTileEffect: String  瓷砖的效果
 “仿射钳”、“仿射瓦”、“钳”、“八折反射瓦”、“四折反射瓦”、“四折旋转瓦”、“四折翻译瓦”、“滑动反射瓦”、“万花筒”、“Op瓦”、“平行四边形瓦”、“透视瓦”、“六折反射瓦”、“六折旋转瓦”、“三角万花筒”、“三角瓦”、“十二折反射瓦”】
 ["CIAffineClamp", "CIAffineTile", "CIClamp", "CIEightfoldReflectedTile", "CIFourfoldReflectedTile", "CIFourfoldRotatedTile", "CIFourfoldTranslatedTile", "CIGlideReflectedTile", "CIKaleidoscope", "CIOpTile", "CIParallelogramTile", "CIPerspectiveTile", "CISixfoldReflectedTile", "CISixfoldRotatedTile", "CITriangleKaleidoscope", "CITriangleTile", "CITwelvefoldReflectedTile"]
 kCICategoryGenerator: String  各种生成器
 【“带属性文本图像生成器”、“Aztec代码生成器”、“条码生成器”、“棋盘生成器”、“128条码生成器”、“恒色生成器”、“透镜晕生成器”、“网格生成器”、“PDF417条码生成器”、“二维码生成器”、“随机生成器”、“圆角矩形生成器”、“星光生成器”、“条纹生成器”、“阳光生成器”、“文本图像生成器”】
 ["CIAttributedTextImageGenerator", "CIAztecCodeGenerator", "CIBarcodeGenerator", "CICheckerboardGenerator", "CICode128BarcodeGenerator", "CIConstantColorGenerator", "CILenticularHaloGenerator", "CIMeshGenerator", "CIPDF417BarcodeGenerator", "CIQRCodeGenerator", "CIRandomGenerator", "CIRoundedRectangleGenerator", "CIStarShineGenerator", "CIStripesGenerator", "CISunbeamsGenerator", "CITextImageGenerator"]
 kCICategoryReduction: String  减少
 【“面积平均”、“面积直方图”、“面积最大”、“面积最大透明度”、“面积最小透明度”、“面积最小最大”、“面积最小M最大红色”、“列平均”、“直方图显示滤镜”、“K表示”、“行平均”】
 ["CIAreaAverage", "CIAreaHistogram", "CIAreaMaximum", "CIAreaMaximumAlpha", "CIAreaMinimum", "CIAreaMinimumAlpha", "CIAreaMinMax", "CIAreaMinMaxRed", "CIColumnAverage", "CIHistogramDisplayFilter", "CIKMeans", "CIRowAverage"]
 kCICategoryGradient: String  梯度
 [“高斯梯度”、“色相饱和度值梯度”、“线性梯度”、“径向梯度”、“平滑线性梯度”]
 ["CIGaussianGradient", "CIHueSaturationValueGradient", "CILinearGradient", "CIRadialGradient", "CISmoothLinearGradient"]
 kCICategoryStylize: String  使风格化
 ["混合与α面具”、“混合与蓝色的面具”,“面具”融合,“混合着红色面具”,“开花”,“喜剧效果”,“卷积3 x3”,“卷积5 x5”、“卷积7 x7”,“卷积9水平”,“卷积9垂直”,“核心毫升模型滤波器”,“结晶”、“景深”、“边缘”、“边缘”工作,“伽柏梯度”,“黑暗”,“高度字段从面具”、“六角像素化”、“突出影子调整”,“叠加”,“混合”,“像素化”、“点状华”、“卓越地图过滤器”,“最近的样本”、“阴影材质”、“彩色”、“聚光灯”]
 ["CIBlendWithAlphaMask", "CIBlendWithBlueMask", "CIBlendWithMask", "CIBlendWithRedMask", "CIBloom", "CIComicEffect", "CIConvolution3X3", "CIConvolution5X5", "CIConvolution7X7", "CIConvolution9Horizontal", "CIConvolution9Vertical", "CICoreMLModelFilter", "CICrystallize", "CIDepthOfField", "CIEdges", "CIEdgeWork", "CIGaborGradients", "CIGloom", "CIHeightFieldFromMask", "CIHexagonalPixellate", "CIHighlightShadowAdjust", "CILineOverlay", "CIMix", "CIPixellate", "CIPointillize", "CISaliencyMapFilter", "CISampleNearest", "CIShadedMaterial", "CISpotColor", "CISpotLight"]
 kCICategorySharpen: String  锐化
 ["CISharpenLuminance 锐化亮度", "CIUnsharpMask 锐化掩模"]
 kCICategoryBlur: String  模糊
 [“散焦模糊”、“盒模糊”、“深度模糊效果”、“圆盘模糊”、“高斯模糊”、“蒙面可变模糊”、“中值滤镜”、“形态梯度”、“形态最大”、“形态最小”、“形态矩形最大”、“形态矩形最小”、“运动模糊”、“降噪”、“变焦模糊”]
 ["CIBokehBlur", "CIBoxBlur", "CIDepthBlurEffect", "CIDiscBlur", "CIGaussianBlur", "CIMaskedVariableBlur", "CIMedianFilter", "CIMorphologyGradient", "CIMorphologyMaximum", "CIMorphologyMinimum", "CIMorphologyRectangleMaximum", "CIMorphologyRectangleMinimum", "CIMotionBlur", "CINoiseReduction", "CIZoomBlur"]
 kCICategoryVideo: String  视频
 kCICategoryStillImage: String  静态图像
 kCICategoryInterlaced: String  国际米兰的
 kCICategoryNonSquarePixels: String  非方形像素
 kCICategoryHighDynamicRange: String  高动态范围
 kCICategoryBuiltIn: String  内装式
 kCICategoryFilterGenerator: String  生成器

 ----filter-----
 */
