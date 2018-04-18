//
//  ViewController.swift
//  BeautyCamera
//
//  Created by Ocean on 2018/4/17.
//  Copyright © 2018年 Ocean. All rights reserved.
//

import UIKit
import AVKit
import GPUImage

class ViewController: UIViewController {

    /// 调节美颜效果页面底部控制约束
    @IBOutlet weak var beautyViewBottomCons: NSLayoutConstraint!
    /// 记录切换美颜效果调节页面按钮
    fileprivate var selectedButton: UIButton?
    
    // MARK: 懒加载
    // 视频源
    fileprivate lazy var camera: GPUImageVideoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: AVCaptureDevice.Position.front)
    
    //预览图层
    fileprivate lazy var preview: GPUImageView = GPUImageView(frame: view.bounds)
    
    // MARK: 初始化滤镜
    // 磨皮
    let bilateralFilter = GPUImageBilateralFilter()
    // 曝光
    let exposureFilter = GPUImageExposureFilter()
    // 美白
    let brightnessFilter = GPUImageBrightnessFilter()
    // 饱和
    let saturationFilter = GPUImageSaturationFilter()
    
    var currentUrl: URL?
    
    // 创建写入对象
    fileprivate lazy var movieWriter: GPUImageMovieWriter = { [unowned self] in
        // 创建写入对象
        currentUrl = self.fileUrl
        let writer = GPUImageMovieWriter(movieURL: currentUrl, size: self.view.bounds.size)
        print(self.fileUrl.absoluteString)
        print(currentUrl!.absoluteString)
        return writer!
    }()
    
    // MARK: 计算属性
    var fileUrl: URL {
        let date = NSDate()
        let timestamp = date.timeIntervalSince1970
        return URL(fileURLWithPath: "\(NSTemporaryDirectory())" + "\(timestamp)" + ".mp4")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置camera的方向
        camera.outputImageOrientation = .portrait
        // 设置是否为滤镜
        camera.horizontallyMirrorFrontFacingCamera = true
        
        // 创建预览的View
        view.insertSubview(preview, at: 0)
        
        // 获取滤镜组
        let filterGroup = getGroupFilters()
        
        // 设置GPUImage的响应链
        camera.addTarget(filterGroup)           // 相机添加滤镜
        filterGroup.addTarget(preview)          // 滤镜添加预览图层
        
        // 开始采集视频
        camera.startCapture()
        
        // 设置movieWriter属性
        // 1)是否对视频进行编码
        movieWriter.encodingLiveVideo = true
        
        // 2)将movieWriter设置成滤镜的target
        filterGroup.addTarget(movieWriter)      // 滤镜组添加写入对象
        
        // 3)设置camera的编码
        camera.delegate = self
        
        // 录制视频
        camera.audioEncodingTarget = movieWriter
        movieWriter.startRecording()
    }
    
    private func getGroupFilters() -> GPUImageFilterGroup {
        // 创建滤镜组(存放各种滤镜)
        let filterGroup = GPUImageFilterGroup()
        
        // 创建滤镜(设置滤镜的引来关系)
        bilateralFilter.addTarget(exposureFilter)
        exposureFilter.addTarget(brightnessFilter)
        brightnessFilter.addTarget(saturationFilter)
        
        // 设置滤镜组链初始&终点的filter
        filterGroup.initialFilters = [bilateralFilter]
        filterGroup.terminalFilter = saturationFilter
        
        return filterGroup
    }
}

// MARK:- <GPUImageVideoCameraDelegate>
extension ViewController : GPUImageVideoCameraDelegate {
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        
    }
}

// MARK:- 控制器上按钮事件
extension ViewController {
    // 切换摄像头
    @IBAction func rotate(_ sender: UIButton) {
        camera.rotateCamera()
    }
    
    // 调出&收起控制面板
    @IBAction func switchBeautyView(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        selectedButton = sender
        if sender.isSelected {
            changeBeautyViewConstant(constant: 0)
        } else {
            changeBeautyViewConstant(constant: -250)
        }
    }
    
    // 结束直播
    @IBAction func stopRecording(_ sender: UIButton) {
        camera.stopCapture()
        preview.removeFromSuperview()
        movieWriter.finishRecording()
    }
    
    // 播放视频
    @IBAction func playVideo(_ sender: UIButton) {
        let playerVc = AVPlayerViewController()
        playerVc.player = AVPlayer(url: currentUrl!)
        present(playerVc, animated: true, completion: nil)
    }
    
    fileprivate func changeBeautyViewConstant(constant: CGFloat) {
        beautyViewBottomCons.constant = constant
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK:- 美颜控制面板
extension ViewController {
    // 收起控制面板(完成按钮)
    @IBAction func hiddenBeautyView(_ sender: UIButton) {
        selectedButton?.isSelected = !selectedButton!.isSelected
        changeBeautyViewConstant(constant: -250)
    }
    
    // 切换是否开启美颜
    @IBAction func switchBeautyEffect(_ sender: UISwitch) {
        if sender.isOn {
            camera.removeAllTargets()
            let filterGroup = getGroupFilters()
            camera.addTarget(filterGroup)
            filterGroup.addTarget(preview)
        } else {
            camera.removeAllTargets()
            camera.addTarget(preview)
        }
    }
    
    // 磨皮
    @IBAction func changeBilateral(_ sender: UISlider) {
        bilateralFilter.distanceNormalizationFactor = CGFloat(sender.value) * 8
    }
    
    // 曝光
    @IBAction func changeExposure(_ sender: UISlider) {
        // -10 ~ 10
        exposureFilter.exposure = CGFloat(sender.value) * 20 - 10
    }
    
    // 美白
    @IBAction func changeBrightness(_ sender: UISlider) {
        // -1 ~ 1
        brightnessFilter.brightness = CGFloat(sender.value) * 2 - 1
    }
    
    // 饱和
    @IBAction func changeSaturation(_ sender: UISlider) {
        saturationFilter.saturation = CGFloat(sender.value) * 2
    }
    
}

