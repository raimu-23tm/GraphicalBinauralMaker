import UIKit
import AVFoundation
import Foundation
import Metal
import MetalKit

class ViewController: UIViewController, UITabBarDelegate {
    
    //ソルフェジオ周波数リスト
    let frequeList =
        [528,174,285,396,417,639,741,852,4096]
    
    //代表バイノーラル音リスト
    let binoralList : [Float] =
        [1.7, 5.5, 9.4, 20.0]
    
    //サンプル音リスト
    let sampleFrequeList =
        [83, 83, 116, 83, 110, 116, 110, 528]
    let sampleBinoralList : [Float] =
        [1.7, 0.5, 2.8, 3.5, 5.5, 9.4, 11.3, 7.83]
    
    // 動的変数
    var currentFrequency = 528
    var currentBinoralFrequency : Float = 0.0
    var currentSoundType = 0
    var soundVolume = 0.5
    var playFlg = false
    
    //コントローラー定義
    @IBOutlet weak var mainNavigation: UINavigationItem!
    @IBOutlet weak var navigation: UINavigationItem!
    @IBOutlet weak var maintab: UITabBar!
    @IBOutlet weak var contents: UIView!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var binoralLabel: UILabel!
    @IBOutlet weak var playBackButton: UIButton!
    @IBOutlet weak var slider1_1: UISlider!
    @IBOutlet weak var slider1_2: UISlider!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var typeSinOn: UIButton!
    @IBOutlet weak var typeSinOff: UIButton!
    @IBOutlet weak var powerModeOn: UIButton!
    @IBOutlet weak var powerModeOff: UIButton!
    @IBOutlet weak var typeTriangleOn: UIButton!
    @IBOutlet weak var typeTriangleOff: UIButton!
    @IBOutlet weak var typeSquareOn: UIButton!
    @IBOutlet weak var typeSquareOff: UIButton!
    @IBOutlet weak var typeSawtoothOn: UIButton!
    @IBOutlet weak var typeSawtoothOff: UIButton!
    
    //タブ遷移に使用
    var mainContentView: ViewController?
    var pageViewController: UIPageViewController?
    
    // 音データ
    var soundwave: SoundWave!
    
    //Metal描画関連
    private var renderer: Renderer!
    private let device = MTLCreateSystemDefaultDevice()!
    
    @IBOutlet var mtkViewDisplay: MTKView!
    
    //初期処理
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if maintab != nil
        {
            
            mainContentView = self
            
            //タブのデリゲート設定
            maintab.delegate = self
            //タブの位置を上に
            let navigationY = self.navigationController?.navigationBar.frame.origin.y  ?? 0
            let navigationHeight =  self.navigationController?.navigationBar.frame.size.height ?? 44
            
            maintab.frame = CGRect(x: 0.0,
                                   y: navigationY + (navigationHeight * 2),
                                   width: maintab.frame.width,
                                   height: maintab.frame.height)
            
            // PageViewControllerを取得
            for i in 0 ... self.children.count - 1 {
                if self.children[i] is UIPageViewController {
                    pageViewController = self.children[i] as? UIPageViewController
                }
            }
            
            //初期設定
            frequencyLabel.text = String(currentFrequency) + " Hz"
            plusLabel.isHidden = true
            binoralLabel.text = "0.0" + " Hz"
            binoralLabel.isHidden = true
            
            //サウンド初期設定
            soundwave = SoundWave()
            soundwave.soundHz = currentFrequency
            soundwave.soundVolume = Float(self.soundVolume)
            soundwave.soundSet()
            
            // Metalのセットアップ
            guard let mtlDevice = MTLCreateSystemDefaultDevice() else {
                print("Metal is not supported on this device")
                return
            }
            let mtkView = MTKView(frame: view.frame, device: mtlDevice)
            mtkView.device = mtlDevice
            mtkView.framebufferOnly = true
            mtkView.preferredFramesPerSecond = 60
            
            //mtkViewを画面に配置
            mtkView.frame = CGRect(x: 0, y: 0, width:  mtkViewDisplay.frame.size.width, height: mtkViewDisplay.frame.size.height)
                mtkViewDisplay.addSubview(mtkView)
            
            //rendererの設定
            renderer = Renderer(metalKitView: mtkView)
            renderer.setVertices([float3(-1.0,-1.0,0.0),
                                  float3(1.0,-1.0,0.0),
                                  float3(-1.0,1.0,0.0),
                                  float3(1.0,1.0,0.0)])
            renderer.setIndices([0,1,2,1,2,3])
            renderer.start()
            
            //初期ページ設定
            tabChange(tag: 1)
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //soundwave?.stopEngine() //Viewが消える前にaudioEngineを止める
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        tabChange(tag: item.tag)
        
    }
    
    func tabChange(tag : Int) {
        
        switch tag {
            
            case 1:
                mainNavigation.title = "単一周波数"
                
                if (soundwave.binoralHz == 0.0)
                {
                    plusLabel.isHidden = true
                    binoralLabel.isHidden = true
                }
                else
                {
                    plusLabel.isHidden = false
                    binoralLabel.isHidden = false
                }
                break;
            case 2:
                mainNavigation.title = "バイノーラル音"
                plusLabel.isHidden = false
                binoralLabel.isHidden = false
                break;
            case 3:
                mainNavigation.title = "波形"
                plusLabel.isHidden = false
                binoralLabel.isHidden = false
                break;
            case 4:
                mainNavigation.title = "サンプル音"
                plusLabel.isHidden = false
                binoralLabel.isHidden = false
                break;
            default:
                break;
                                    
        }
        
        let contentVC = storyboard?.instantiateViewController(withIdentifier: "contents" + String(tag)) as! ViewController
        contentVC.frequencyLabel = self.frequencyLabel
        contentVC.binoralLabel = self.binoralLabel
        contentVC.plusLabel = self.plusLabel
        contentVC.currentFrequency = self.currentFrequency
        contentVC.soundwave = self.soundwave
        self.pageViewController?.setViewControllers([contentVC], direction: .forward, animated: false,completion: nil)
        
    }
    
    @IBAction func handlePlayback(_ sender: Any) {
        
        if playFlg == true {
            // 停止
            soundwave.pause()
            playFlg = false
            playBackButton.setImage(UIImage(systemName: "play.circle"), for : .normal)
        }
        else
        {
            // 再生
            soundwave.reStart()
            playFlg = true
            playBackButton.setImage(UIImage(systemName: "pause.circle"), for : .normal)
        }
        
    }
    
    //===============================================
    // ■　単一周波数設定
    //===============================================
    
    @IBAction func handleSlider1_1(_ sender: UISlider) {
        
        currentFrequency = Int(slider1_1.value) + Int(slider1_2.value)
        changeFrequency()
        
    }
    
    @IBAction func handleSlider1_2(_ sender: UISlider) {
        
        currentFrequency = Int(slider1_1.value) + Int(slider1_2.value)
        changeFrequency()
        
    }
    
    @IBAction func handleMinusButton1(_ sender: Any) {
        
        if currentFrequency > 0 {
            currentFrequency -= 1
            
            if (slider1_2.value > 0)
            {
                slider1_2.value -= 1
            }
            else
            {
                slider1_1.value -= 1
            }
            
            changeFrequency()
        }
        
    }
    
    @IBAction func handlePlusButton1(_ sender: Any) {
        
        if currentFrequency < 4200 {
            currentFrequency += 1
            
            if (slider1_2.value < 200)
            {
                slider1_2.value += 1
            }
            else
            {
                slider1_1.value += 1
            }
            
            changeFrequency()
        }
        
    }
    
    func changeFrequency()
    {
        self.frequencyLabel.text = String(currentFrequency) + " Hz"
        soundwave.soundHz = currentFrequency
        
        if (soundwave.isPlay == true)
        {
            soundwave.reStart()
        }
    }
    
    @IBAction func handleFrequeButton1(_ sender: Any) {
        currentFrequency = frequeList[0]
        changeFrequency()
        adjustmentSlideber()
    }
    @IBAction func handleFrequeButton2(_ sender: Any) {
        currentFrequency = frequeList[1]
        changeFrequency()
        adjustmentSlideber()
    }
    @IBAction func handleFrequeButton3(_ sender: Any) {
        currentFrequency = frequeList[2]
        changeFrequency()
        adjustmentSlideber()
    }
    @IBAction func handleFrequeButton4(_ sender: Any) {
        currentFrequency = frequeList[3]
        changeFrequency()
        adjustmentSlideber()
    }
    @IBAction func handleFrequeButton5(_ sender: Any) {
        currentFrequency = frequeList[4]
        changeFrequency()
        adjustmentSlideber()
    }
    @IBAction func handleFrequeButton6(_ sender: Any) {
        currentFrequency = frequeList[5]
        changeFrequency()
        adjustmentSlideber()
    }
    @IBAction func handleFrequeButton7(_ sender: Any) {
        currentFrequency = frequeList[6]
        changeFrequency()
        adjustmentSlideber()
    }
    @IBAction func handleFrequeButton8(_ sender: Any) {
        currentFrequency = frequeList[7]
        changeFrequency()
        adjustmentSlideber()
    }
    @IBAction func handleFrequeButton9(_ sender: Any) {
        currentFrequency = frequeList[8]
        changeFrequency()
        adjustmentSlideber()
    }
    
    func adjustmentSlideber()
    {
        if (currentFrequency < 4000)
        {
            slider1_1.value = Float(currentFrequency) - slider1_2.value
        }
        else
        {
            slider1_1.value = 4000
            slider1_2.value = Float(currentFrequency) - 4000
        }
    }
    
    //===============================================
    // ■　バイノーラル音
    //===============================================
    
    @IBAction func handleSlider2(_ sender: UISlider) {
                
        currentBinoralFrequency = slider2.value
        changeBinoral()
        
    }
    
    @IBAction func handlePlusButton2(_ sender: Any) {

        if (currentBinoralFrequency <= 35)
        {
            currentBinoralFrequency += 1
            changeBinoral()
        }
        
    }
    
    @IBAction func handeMinusButton2(_ sender: Any) {
        
        if (currentBinoralFrequency >= 1)
        {
            currentBinoralFrequency -= 1
            changeBinoral()
        }
        
    }
    
    @IBAction func handlePlusButon2Mini(_ sender: Any) {
        
        if (currentBinoralFrequency < 36)
        {
            currentBinoralFrequency += 0.1
            changeBinoral()
        }
        
    }
    
    @IBAction func handleMinusButton2Mini(_ sender: Any) {
        
        if (currentBinoralFrequency > 0)
        {
            currentBinoralFrequency -= 0.1
            changeBinoral()
        }
        
    }
    
    func changeBinoral()
    {
        self.binoralLabel.text = String(round(currentBinoralFrequency * 10) / 10) + " Hz"
        soundwave.binoralHz = currentBinoralFrequency
        
        if (soundwave.isPlay == true)
        {
            soundwave.reStart()
        }
    }
    
    @IBAction func handleBinoralButton1(_ sender: Any) {
        currentBinoralFrequency = binoralList[0]
        changeBinoral()
        adjustmentBinoralSlideber()
    }
    @IBAction func handleBinoralButton2(_ sender: Any) {
        currentBinoralFrequency = binoralList[1]
        changeBinoral()
        adjustmentBinoralSlideber()
    }
    @IBAction func handleBinoralButton3(_ sender: Any) {
        currentBinoralFrequency = binoralList[2]
        changeBinoral()
        adjustmentBinoralSlideber()
    }
    @IBAction func handleBinoralButton4(_ sender: Any) {
        currentBinoralFrequency = binoralList[3]
        changeBinoral()
        adjustmentBinoralSlideber()
    }
    
    func adjustmentBinoralSlideber()
    {
        slider2.value = currentBinoralFrequency
    }
    
    @IBAction func handlePowerModeOn(_ sender: Any) {
        
        powerModeOn.isHidden = true
        powerModeOff.isHidden = false
        
    }

    @IBAction func handlePowerModeOff(_ sender: Any) {
        
        powerModeOn.isHidden = false
        powerModeOff.isHidden = true
        
    }
    
    
    //===============================================
    // ■　波形
    //===============================================
    
    @IBAction func handleSinTypeButton(_ sender: Any) {
        currentSoundType = 0
        soundwave.soundType = currentSoundType
        changeFrequency()
        typeSinOn.isHidden = false
        typeTriangleOn.isHidden = true
        typeSquareOn.isHidden = true
        typeSawtoothOn.isHidden = true
    }
    
    @IBAction func handleTriangleTypeButton(_ sender: Any) {
        currentSoundType = 1
        soundwave.soundType = currentSoundType
        changeFrequency()
        typeSinOn.isHidden = true
        typeTriangleOn.isHidden = false
        typeSquareOn.isHidden = true
        typeSawtoothOn.isHidden = true
    }
    
    @IBAction func handleSquareTypeButton(_ sender: Any) {
        currentSoundType = 2
        soundwave.soundType = currentSoundType
        changeFrequency()
        typeSinOn.isHidden = true
        typeTriangleOn.isHidden = true
        typeSquareOn.isHidden = false
        typeSawtoothOn.isHidden = true
    }
    
    @IBAction func handleSawtoothTypeButton(_ sender: Any) {
        currentSoundType = 3
        soundwave.soundType = currentSoundType
        changeFrequency()
        typeSinOn.isHidden = true
        typeTriangleOn.isHidden = true
        typeSquareOn.isHidden = true
        typeSawtoothOn.isHidden = false
    }
    
    //===============================================
    // ■　サンプル
    //===============================================
    
    @IBAction func handleSampleButton1(_ sender: Any) {
        currentFrequency = sampleFrequeList[0]
        currentBinoralFrequency = sampleBinoralList[0]
        changeFrequencyAndBinoral()
    }
    @IBAction func handleSampleButton2(_ sender: Any) {
        currentFrequency = sampleFrequeList[1]
        currentBinoralFrequency = sampleBinoralList[1]
        changeFrequencyAndBinoral()
    }
    @IBAction func handleSampleButton3(_ sender: Any) {
        currentFrequency = sampleFrequeList[2]
        currentBinoralFrequency = sampleBinoralList[2]
        changeFrequencyAndBinoral()
    }
    @IBAction func handleSampleButton4(_ sender: Any) {
        currentFrequency = sampleFrequeList[3]
        currentBinoralFrequency = sampleBinoralList[3]
        changeFrequencyAndBinoral()
    }
    @IBAction func handleSampleButton5(_ sender: Any) {
        currentFrequency = sampleFrequeList[4]
        currentBinoralFrequency = sampleBinoralList[4]
        changeFrequencyAndBinoral()
    }
    @IBAction func handleSampleButton6(_ sender: Any) {
        currentFrequency = sampleFrequeList[5]
        currentBinoralFrequency = sampleBinoralList[5]
        changeFrequencyAndBinoral()
    }
    @IBAction func handleSampleButton7(_ sender: Any) {
        currentFrequency = sampleFrequeList[6]
        currentBinoralFrequency = sampleBinoralList[6]
        changeFrequencyAndBinoral()
    }
    @IBAction func handleSampleButton8(_ sender: Any) {
        currentFrequency = sampleFrequeList[7]
        currentBinoralFrequency = sampleBinoralList[7]
        changeFrequencyAndBinoral()
    }
        
    func changeFrequencyAndBinoral()
    {
        self.frequencyLabel.text = String(currentFrequency) + " Hz"
        soundwave.soundHz = currentFrequency
        
        self.frequencyLabel.text = String(currentFrequency) + " Hz"
        soundwave.soundHz = currentFrequency
        
        self.binoralLabel.text = String(round(currentBinoralFrequency * 10) / 10) + " Hz"
        soundwave.binoralHz = currentBinoralFrequency
        
        if (soundwave.isPlay == true)
        {
            soundwave.reStart()
        }
    }
    
}

