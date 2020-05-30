//
//  CoreImageViewController.swift
//  ImageFilters
//
//  Created by dzq_mac on 2020/5/28.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit

class CoreImageViewController: UIViewController {

    let context :CIContext = CIContext()
    var imageView:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        imageView =  UIImageView(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.height - 100))
        
        view.addSubview(imageView)
        
        filterImage()
    }
    
    func filterImage() {
    
        let path = Bundle.main.path(forResource: "image", ofType: "jpg") ?? ""
        let imageURL = URL(fileURLWithPath: path)
        let originalCIImage = CIImage(contentsOf: imageURL)!
        
        self.imageView.image = UIImage(ciImage:scaleFilter(originalCIImage)!)
        self.imageView.image = createCode(codeType: "CIQRCodeGenerator", codeString: "hello", size: CGSize(width: 300, height: 300), qrColor: .black, bkColor: .white)
        
    }
    func sepiaFilter(_ input: CIImage, intensity: Double) -> CIImage?
    {
        let sepiaFilter = CIFilter(name:"CIColorControls")
        
        print(sepiaFilter!.attributes)
//        print(CIFilter.filterNames(inCategory: kCICategoryInterlaced))
        sepiaFilter?.setValue(input, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(NSNumber(1), forKey: "inputSaturation")//饱和度
        sepiaFilter?.setValue(NSNumber(1), forKey: "inputBrightness")//亮度
        return sepiaFilter?.outputImage
    }

    func scaleFilter(_ input: CIImage) ->  CIImage?{
        let scaleFilter = CIFilter(name: "CIBicubicScaleTransform")
        scaleFilter?.setValue(input, forKey: kCIInputImageKey)
//        print(scaleFilter!.attributes)
        scaleFilter?.setValue(NSNumber(0), forKey: "inputB")
        scaleFilter?.setValue(NSNumber(0), forKey: "inputC")
        scaleFilter?.setValue(NSNumber(30), forKey: "inputScale")
        return scaleFilter?.outputImage
    }
    
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
 // 将二维码转成高清的格式
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
 ["CIBumpDistortion", "CIBumpDistortionLinear", "CICameraCalibrationLensCorrection", "CICircleSplashDistortion", "CICircularWrap", "CIDisplacementDistortion", "CIDroste", "CIGlassDistortion", "CIGlassLozenge", "CIHoleDistortion", "CILightTunnel", "CINinePartStretched", "CINinePartTiled", "CIPinchDistortion", "CIStretchCrop", "CITorusLensDistortion", "CITwirlDistortion", "CIVortexDistortion"]
 kCICategoryGeometryAdjustment:  几何调整
 ["CIAffineTransform", "CIBicubicScaleTransform", "CICrop", "CIEdgePreserveUpsampleFilter", "CIKeystoneCorrectionCombined", "CIKeystoneCorrectionHorizontal", "CIKeystoneCorrectionVertical", "CILanczosScaleTransform", "CIPerspectiveCorrection", "CIPerspectiveRotate", "CIPerspectiveTransform", "CIPerspectiveTransformWithExtent", "CIStraightenFilter"]
 kCICategoryCompositeOperation:  复合操作
 ["CIAdditionCompositing", "CIColorBlendMode", "CIColorBurnBlendMode", "CIColorDodgeBlendMode", "CIDarkenBlendMode", "CIDifferenceBlendMode", "CIDivideBlendMode", "CIExclusionBlendMode", "CIHardLightBlendMode", "CIHueBlendMode", "CILightenBlendMode", "CILinearBurnBlendMode", "CILinearDodgeBlendMode", "CILuminosityBlendMode", "CIMaximumCompositing", "CIMinimumCompositing", "CIMultiplyBlendMode", "CIMultiplyCompositing", "CIOverlayBlendMode", "CIPinLightBlendMode", "CISaturationBlendMode", "CIScreenBlendMode", "CISoftLightBlendMode", "CISourceAtopCompositing", "CISourceInCompositing", "CISourceOutCompositing", "CISourceOverCompositing", "CISubtractBlendMode"]
 kCICategoryHalftoneEffect: String  半色调效果
 ["CICircularScreen", "CICMYKHalftone", "CIDotScreen", "CIHatchedScreen", "CILineScreen"]
 kCICategoryColorAdjustment: String  颜色调整
 ["CIColorClamp", "CIColorControls", "CIColorMatrix", "CIColorPolynomial", "CIDepthToDisparity", "CIDisparityToDepth", "CIExposureAdjust", "CIGammaAdjust", "CIHueAdjust", "CILinearToSRGBToneCurve", "CISRGBToneCurveToLinear", "CITemperatureAndTint", "CIToneCurve", "CIVibrance", "CIWhitePointAdjust"]
 kCICategoryColorEffect: String  色彩效果:
 ["CIColorCrossPolynomial", "CIColorCube", "CIColorCubesMixedWithMask", "CIColorCubeWithColorSpace", "CIColorCurves", "CIColorInvert", "CIColorMap", "CIColorMonochrome", "CIColorPosterize", "CIDither", "CIDocumentEnhancer", "CIFalseColor", "CILabDeltaE", "CIMaskToAlpha", "CIMaximumComponent", "CIMinimumComponent", "CIPaletteCentroid", "CIPalettize", "CIPhotoEffectChrome", "CIPhotoEffectFade", "CIPhotoEffectInstant", "CIPhotoEffectMono", "CIPhotoEffectNoir", "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer", "CISepiaTone", "CIThermal", "CIVignette", "CIVignetteEffect", "CIXRay"]
 kCICategoryTransition: String  转型:
 ["CIAccordionFoldTransition", "CIBarsSwipeTransition", "CICopyMachineTransition", "CIDisintegrateWithMaskTransition", "CIDissolveTransition", "CIFlashTransition", "CIModTransition", "CIPageCurlTransition", "CIPageCurlWithShadowTransition", "CIRippleTransition", "CISwipeTransition"]
 kCICategoryTileEffect: String  瓷砖的效果
 ["CIAffineClamp", "CIAffineTile", "CIClamp", "CIEightfoldReflectedTile", "CIFourfoldReflectedTile", "CIFourfoldRotatedTile", "CIFourfoldTranslatedTile", "CIGlideReflectedTile", "CIKaleidoscope", "CIOpTile", "CIParallelogramTile", "CIPerspectiveTile", "CISixfoldReflectedTile", "CISixfoldRotatedTile", "CITriangleKaleidoscope", "CITriangleTile", "CITwelvefoldReflectedTile"]
 kCICategoryGenerator: String  发电机
 ["CIAttributedTextImageGenerator", "CIAztecCodeGenerator", "CIBarcodeGenerator", "CICheckerboardGenerator", "CICode128BarcodeGenerator", "CIConstantColorGenerator", "CILenticularHaloGenerator", "CIMeshGenerator", "CIPDF417BarcodeGenerator", "CIQRCodeGenerator", "CIRandomGenerator", "CIRoundedRectangleGenerator", "CIStarShineGenerator", "CIStripesGenerator", "CISunbeamsGenerator", "CITextImageGenerator"]
 kCICategoryReduction: String  减少
 ["CIAreaAverage", "CIAreaHistogram", "CIAreaMaximum", "CIAreaMaximumAlpha", "CIAreaMinimum", "CIAreaMinimumAlpha", "CIAreaMinMax", "CIAreaMinMaxRed", "CIColumnAverage", "CIHistogramDisplayFilter", "CIKMeans", "CIRowAverage"]
 kCICategoryGradient: String  梯度
 ["CIGaussianGradient", "CIHueSaturationValueGradient", "CILinearGradient", "CIRadialGradient", "CISmoothLinearGradient"]
 kCICategoryStylize: String  使风格化
 ["CIBlendWithAlphaMask", "CIBlendWithBlueMask", "CIBlendWithMask", "CIBlendWithRedMask", "CIBloom", "CIComicEffect", "CIConvolution3X3", "CIConvolution5X5", "CIConvolution7X7", "CIConvolution9Horizontal", "CIConvolution9Vertical", "CICoreMLModelFilter", "CICrystallize", "CIDepthOfField", "CIEdges", "CIEdgeWork", "CIGaborGradients", "CIGloom", "CIHeightFieldFromMask", "CIHexagonalPixellate", "CIHighlightShadowAdjust", "CILineOverlay", "CIMix", "CIPixellate", "CIPointillize", "CISaliencyMapFilter", "CISampleNearest", "CIShadedMaterial", "CISpotColor", "CISpotLight"]
 kCICategorySharpen: String  锐化
 ["CISharpenLuminance", "CIUnsharpMask"]
 kCICategoryBlur: String  模糊
 ["CIBokehBlur", "CIBoxBlur", "CIDepthBlurEffect", "CIDiscBlur", "CIGaussianBlur", "CIMaskedVariableBlur", "CIMedianFilter", "CIMorphologyGradient", "CIMorphologyMaximum", "CIMorphologyMinimum", "CIMorphologyRectangleMaximum", "CIMorphologyRectangleMinimum", "CIMotionBlur", "CINoiseReduction", "CIZoomBlur"]
 kCICategoryVideo: String  视频
 kCICategoryStillImage: String  静态图像
 kCICategoryInterlaced: String  国际米兰的
 kCICategoryNonSquarePixels: String  非方形像素
 kCICategoryHighDynamicRange: String  高动态范围
 kCICategoryBuiltIn: String  内装式
 kCICategoryFilterGenerator: String  过滤器发电机

 ----filter-----
 CIAccordionFoldTransition  手风琴褶皱过渡
 CIAdditionCompositing 加法合成
 CIAffineClamp
 CIAffineTile
 CIAffineTransform  仿射变换
 CIAreaAverage
 CIAreaHistogram
 CIAreaMaximum
 CIAreaMaximumAlpha
 CIAreaMinimum
 CIAreaMinimumAlpha
 CIAreaMinMax
 CIAreaMinMaxRed
 CIAttributedTextImageGenerator
 CIAztecCodeGenerator
 CIBarcodeGenerator
 CIBarsSwipeTransition
 CIBicubicScaleTransform
 CIBlendWithAlphaMask
 CIBlendWithBlueMask
 CIBlendWithMask
 CIBlendWithRedMask
 CIBloom
 CIBokehBlur
 CIBoxBlur
 CIBumpDistortion
 CIBumpDistortionLinear
 CICameraCalibrationLensCorrection
 CICheckerboardGenerator
 CICircleSplashDistortion
 CICircularScreen
 CICircularWrap
 CIClamp
 CICMYKHalftone
 CICode128BarcodeGenerator
 CIColorBlendMode
 CIColorBurnBlendMode
 CIColorClamp
 CIColorControls
 CIColorCrossPolynomial
 CIColorCube
 CIColorCubesMixedWithMask
 CIColorCubeWithColorSpace
 CIColorCurves
 CIColorDodgeBlendMode
 CIColorInvert
 CIColorMap
 CIColorMatrix
 CIColorMonochrome
 CIColorPolynomial
 CIColorPosterize
 CIColumnAverage
 CIComicEffect
 CIConstantColorGenerator
 CIConvolution3X3
 CIConvolution5X5
 CIConvolution7X7
 CIConvolution9Horizontal
 CIConvolution9Vertical
 CICopyMachineTransition
 CICoreMLModelFilter
 CICrop
 CICrystallize
 CIDarkenBlendMode
 CIDepthBlurEffect
 CIDepthOfField
 CIDepthToDisparity
 CIDifferenceBlendMode
 CIDiscBlur
 CIDisintegrateWithMaskTransition
 CIDisparityToDepth
 CIDisplacementDistortion
 CIDissolveTransition
 CIDither
 CIDivideBlendMode
 CIDocumentEnhancer
 CIDotScreen
 CIDroste
 CIEdgePreserveUpsampleFilter
 CIEdges
 CIEdgeWork
 CIEightfoldReflectedTile
 CIExclusionBlendMode
 CIExposureAdjust
 CIFalseColor
 CIFlashTransition
 CIFourfoldReflectedTile
 CIFourfoldRotatedTile
 CIFourfoldTranslatedTile
 CIGaborGradients
 CIGammaAdjust
 CIGaussianBlur
 CIGaussianGradient
 CIGlassDistortion
 CIGlassLozenge
 CIGlideReflectedTile
 CIGloom
 CIGuidedFilter
 CIHardLightBlendMode
 CIHatchedScreen
 CIHeightFieldFromMask
 CIHexagonalPixellate
 CIHighlightShadowAdjust
 CIHistogramDisplayFilter
 CIHoleDistortion
 CIHueAdjust
 CIHueBlendMode
 CIHueSaturationValueGradient
 CIKaleidoscope
 CIKeystoneCorrectionCombined
 CIKeystoneCorrectionHorizontal
 CIKeystoneCorrectionVertical
 CIKMeans
 CILabDeltaE
 CILanczosScaleTransform
 CILenticularHaloGenerator
 CILightenBlendMode
 CILightTunnel
 CILinearBurnBlendMode
 CILinearDodgeBlendMode
 CILinearGradient
 CILinearToSRGBToneCurve
 CILineOverlay
 CILineScreen
 CILuminosityBlendMode
 CIMaskedVariableBlur
 CIMaskToAlpha
 CIMaximumComponent
 CIMaximumCompositing
 CIMedianFilter
 CIMeshGenerator
 CIMinimumComponent
 CIMinimumCompositing
 CIMix
 CIModTransition
 CIMorphologyGradient
 CIMorphologyMaximum
 CIMorphologyMinimum
 CIMorphologyRectangleMaximum
 CIMorphologyRectangleMinimum
 CIMotionBlur
 CIMultiplyBlendMode
 CIMultiplyCompositing
 CINinePartStretched
 CINinePartTiled
 CINoiseReduction
 CIOpTile
 CIOverlayBlendMode
 CIPageCurlTransition
 CIPageCurlWithShadowTransition
 CIPaletteCentroid
 CIPalettize
 CIParallelogramTile
 CIPDF417BarcodeGenerator
 CIPerspectiveCorrection
 CIPerspectiveRotate
 CIPerspectiveTile
 CIPerspectiveTransform
 CIPerspectiveTransformWithExtent
 CIPhotoEffectChrome
 CIPhotoEffectFade
 CIPhotoEffectInstant
 CIPhotoEffectMono
 CIPhotoEffectNoir
 CIPhotoEffectProcess
 CIPhotoEffectTonal
 CIPhotoEffectTransfer
 CIPinchDistortion
 CIPinLightBlendMode
 CIPixellate
 CIPointillize
 CIQRCodeGenerator
 CIRadialGradient
 CIRandomGenerator
 CIRippleTransition
 CIRoundedRectangleGenerator
 CIRowAverage
 CISaliencyMapFilter
 CISampleNearest
 CISaturationBlendMode
 CIScreenBlendMode
 CISepiaTone
 CIShadedMaterial
 CISharpenLuminance
 CISixfoldReflectedTile
 CISixfoldRotatedTile
 CISmoothLinearGradient
 CISoftLightBlendMode
 CISourceAtopCompositing
 CISourceInCompositing
 CISourceOutCompositing
 CISourceOverCompositing
 CISpotColor
 CISpotLight
 CISRGBToneCurveToLinear
 CIStarShineGenerator
 CIStraightenFilter
 CIStretchCrop
 CIStripesGenerator
 CISubtractBlendMode
 CISunbeamsGenerator
 CISwipeTransition
 CITemperatureAndTint
 CITextImageGenerator
 CIThermal
 CIToneCurve
 CITorusLensDistortion
 CITriangleKaleidoscope
 CITriangleTile
 CITwelvefoldReflectedTile
 CITwirlDistortion
 CIUnsharpMask
 CIVibrance
 CIVignette
 CIVignetteEffect
 CIVortexDistortion
 CIWhitePointAdjust
 CIXRay
 CIZoomBlur
 */
