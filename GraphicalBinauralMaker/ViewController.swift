import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController, UITabBarDelegate {
    
    //ソルフェジオ周波数リスト
    let frequeList =
    [528,174,285,396,417,639,741,852,4096]
    
    //コントローラー定義
    @IBOutlet weak var navigation: UINavigationItem!
    @IBOutlet weak var maintab: UITabBar!
    @IBOutlet weak var contents: UIView!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var binoralLabel: UILabel!
    @IBOutlet weak var playBackButton: UIButton!
    @IBOutlet weak var slider1_1: UISlider!
    @IBOutlet weak var slider1_2: UISlider!
    
    //タブ遷移に使用
    var mainContentView: ViewController?
    var pageViewController: UIPageViewController?
    
    // 音データ
    var soundwave: SoundWave!
    
    
    var currentFrequency = 528
    var soundVolume = 0.5
    var playFlg = false

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
        
        let contentVC = storyboard?.instantiateViewController(withIdentifier: "contents" + String(tag)) as! ViewController
        contentVC.frequencyLabel = self.frequencyLabel
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
    
}

