import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController, UITabBarDelegate {
    
    @IBOutlet weak var navigation: UINavigationItem!
    @IBOutlet weak var maintab: UITabBar!
    @IBOutlet weak var contents: UIView!
    @IBOutlet weak var frequencyLabel: UILabel!
        
    var mainContentView: ViewController?
    
    var pageViewController: UIPageViewController?
    
    var currentFrequency = 0
    var playFlg = true
    var running = true
    
    //■サウンド関係
    let audioEngine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    var audioFormat = AVAudioFormat()
    var fs = 0.0
    var length = 0.0
    let soundspan = 3.0

    // 音データ
    var buffer = AVAudioPCMBuffer()
    
    var f0: Float = 0.0 // 周波数
    
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
            
            //初期ページ設定
            let contentVC = storyboard?.instantiateViewController(withIdentifier: "contents1") as! ViewController
            contentVC.frequencyLabel = self.frequencyLabel
            self.pageViewController?.setViewControllers([contentVC], direction: .forward, animated: true,completion: nil)
      
            //初期設定
            frequencyLabel.text = String(currentFrequency) + " Hz"
            
            //サウンド初期設定
            audioFormat = player.outputFormat(forBus: 0)
            fs = audioFormat.sampleRate // 標本化周波数: 44.1K Hz
            length = audioFormat.sampleRate * soundspan // 音データの長さ
            print(length)
            buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity:UInt32(length))!
            buffer.frameLength = UInt32(length)
            
            f0 = 528
            
            playSound()
            
         }
      
    }
    
    func playSound() {
        
        // オーディオエンジンにプレイヤーをアタッチ
        audioEngine.attach(player)
        // プレイヤーノードとミキサーノードを接続
        audioEngine.connect(player, to: audioEngine.mainMixerNode, format: audioFormat)
        // 再生の開始を設定
        player.scheduleBuffer(buffer)

        // エンジンを開始
        try! audioEngine.start()

        // 音波のセット
//        self.setSoundWave(type : 1)
        
        let queue = OperationQueue()
        queue.addOperation{ () -> Void in

            while (self.running) {

                // 音波のセット
                self.setSoundWave(type : 1)

            }

        }
        
        // 再生
        player.play()
                    
    }
    
    func setSoundWave(type : Int) {
        
        let a: Float = 0.1 // 振幅

        if (playFlg)
        {
             switch type
             {
             
                 case 1:
                 // サイン波
                 for ch in (0..<Int(audioFormat.channelCount)) {
                     // オーディオのチャンネル数だけ繰り返す 7088
                     let samples = buffer.floatChannelData![ch]
                     var c = 0
                     for n in 0..<Int(buffer.frameLength) {
                         samples[n] = a * sinf(Float(2.0 * .pi) * f0 * Float(c) /      Float(fs))
                        
                         c += 1
                        
                         if c >= Int(fs)
                         {
                            c = 0
                         }
                                             
                     }
                 }
                 break;
     
                 case 2:
             
                 break;
     
                 case 3:
             
                 break;
     
                 case 4:
             
                 break;
             
                 default:
             
                 break;
             
                 
            }
        }
        else
        {
            for ch in (0..<Int(audioFormat.channelCount)) {
                let samples = buffer.floatChannelData![ch]
                for n in 0..<Int(buffer.frameLength) {
                    samples[n] = 0
                }
            }
        }
            
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        switch item.tag
        {
            case 1:

                let contentVC = storyboard?.instantiateViewController(withIdentifier: "contents1") as! ViewController
                contentVC.frequencyLabel = self.frequencyLabel
                self.pageViewController?.setViewControllers([contentVC], direction: .forward, animated: true,completion: nil)
                break
           
            case 2:
                
                let contentVC = storyboard?.instantiateViewController(withIdentifier: "contents2") as! ViewController
                self.pageViewController?.setViewControllers([contentVC], direction: .forward, animated: true,completion: nil)
                break
           
            case 3:
                
                let contentVC = storyboard?.instantiateViewController(withIdentifier: "contents3") as! ViewController
                self.pageViewController?.setViewControllers([contentVC], direction: .forward, animated: true,completion: nil)
                break
           
            case 4:
                
                let contentVC = storyboard?.instantiateViewController(withIdentifier: "contents4") as! ViewController
                self.pageViewController?.setViewControllers([contentVC], direction: .forward, animated: true,completion: nil)
                break
           
            default:
                break
           
        }
        
    }
    
    @IBAction func HandlePlayback(_ sender: Any) {
        
        if playFlg == true {
            // 停止
            player.pause()
            playFlg = true
        }
        else
        {
            // 再生
            player.play()
            playFlg = false
        }
                
    }
    
    @IBAction func handleSlider1_1(_ sender: Any) {
    }
    
    @IBAction func handleSlider1_2(_ sender: Any) {
    }
    
    @IBAction func handleMinusButton1(_ sender: Any) {
        
        currentFrequency -= 1
        self.frequencyLabel.text = String(currentFrequency) + " Hz"
        
    }
    
    @IBAction func handlePlusButton1(_ sender: Any) {
        
        currentFrequency += 1
        self.frequencyLabel.text = String(currentFrequency) + " Hz"

    }
    
}

