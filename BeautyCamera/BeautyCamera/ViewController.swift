//
//  ViewController.swift
//  BeautyCamera
//
//  Created by Ocean on 2018/4/17.
//  Copyright © 2018年 Ocean. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    /// 调节美颜效果页面底部控制约束
    @IBOutlet weak var beautyViewBottomCons: NSLayoutConstraint!
    fileprivate var selectedButton: UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK:- 控制器上按钮事件
extension ViewController {
    // 切换摄像头
    @IBAction func rotate(_ sender: UIButton) {
        print("rotate")
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
        print("stopRecording")
    }
    
    // 播放视频
    @IBAction func playVideo(_ sender: UIButton) {
        print("playVideo")
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
        print("switchBeautyEffect")
    }
    
    // 磨皮
    @IBAction func changeBilateral(_ sender: UISlider) {
        print("changeBilateral")
    }
    
    // 曝光
    @IBAction func changeExposure(_ sender: UISlider) {
        print("changeExposure")
    }
    
    // 美白
    @IBAction func changeBrightness(_ sender: UISlider) {
        print("changeBrightness")
    }
    
    // 饱和
    @IBAction func changeSaturation(_ sender: UISlider) {
        print("changeSaturation")
    }
    
}

