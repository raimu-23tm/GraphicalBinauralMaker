import AVFoundation

//音の生成
class SoundWave {
    
    let audioEngine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    var timeIndex: Int = 0
    var cnt: Int = 0
    var timer: Timer?
    
    var soundHz = 0
    var soundType = 0
    var soundVolume: Float = 0.5
    var binoralHz: Float = 0.0
    var isPlay = false

    init() {
    }

    deinit {
        stopEngine()
    }
    
    //音情報の設定
    func soundSet() {
        let audioFormat = player.outputFormat(forBus: 0)
        let sampleRate: Float = 44100.0
        let length = UInt32(sampleRate * 1.0)
        if let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: length) {
            buffer.frameLength = length
            for n in (0 ..< Int(length)) {
                
                var val : [Float] = [0.0 , 0.0]
                
                switch soundType
                {
                case 0: //サイン波
                
                    val[0] = sinf(2.0 * Float.pi * (Float(soundHz)) * Float(n) /     sampleRate)
                    val[1] = sinf(2.0 * Float.pi * (Float(soundHz) + binoralHz) *     Float(n) / sampleRate)
                    
                    break;
                    
                case 1: //三角波
                    
                    val[0] = ((abs(((2.0 * Float.pi * Float(n) * ((Float(soundHz)) / 4) / sampleRate).truncatingRemainder(dividingBy: 1) - 0.5)) * 4) - 1)
                    val[1] = ((abs(((2.0 * Float.pi * Float(n) * ((Float(soundHz) + binoralHz) / 4) / sampleRate).truncatingRemainder(dividingBy: 1) - 0.5)) * 4) - 1)
                    
                    break;
                    
                case 2: //短形波
                    
                    val[0] = ceil(sinf((Float(soundHz)) * Float(n) * 2.0 * Float.pi / sampleRate)) - 0.5
                    val[1] = ((abs(((2.0 * Float.pi * Float(n) * ((Float(soundHz) + binoralHz) / 4) / sampleRate).truncatingRemainder(dividingBy: 1) - 0.5)) * 4) - 1)
                    
                    break;
                    
                case 3: //ノコギリ波
                    
                    val[0] = ((2.0 * Float.pi * Float(n) * ((Float(soundHz)) / 4) / sampleRate).truncatingRemainder(dividingBy: 1) * (-1) * 2) - 0.5
                    val[1] = ((2.0 * Float.pi * Float(n) * ((Float(soundHz) + binoralHz) / 4) / sampleRate).truncatingRemainder(dividingBy: 1) * (-1) * 2) - 0.5
                    
                    break;
                    
                default:
                    break;
                    
                }
                
                buffer.floatChannelData?.advanced(by: 0).pointee[n] = soundVolume * 0.2 * val[0]
                buffer.floatChannelData?.advanced(by: 1).pointee[n] = soundVolume * 0.2 * val[1]
                
            }
            audioEngine.attach(player)
            audioEngine.connect(player, to: audioEngine.mainMixerNode, format: audioFormat)
            player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            do {
                try audioEngine.start()
            } catch {
                Swift.print(error.localizedDescription)
            }
        }
    }

    //再設定。周波数が変わったら呼び出し
    func reStart() {
        soundSet()
        play()
    }

    func play() {
        if audioEngine.isRunning {
            Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true, block: { (t) in
                if self.timer == nil || !self.timer!.isValid {
                    t.invalidate()
                    self.cnt = 0
                    self.player.prepare(withFrameCount: 0)
                    self.player.volume = 1.0
                    self.audioEngine.mainMixerNode.outputVolume = 1.0
                    self.player.play()
                }
            })
        }
        isPlay = true
    }

    func pause() {
        if player.isPlaying {
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (t) in
                self.cnt += 1
                if self.player.volume > 0 {
                    self.player.volume -= 0.33
                    self.audioEngine.mainMixerNode.outputVolume -= 0.33
                } else if self.cnt > 5 {
                    self.player.volume = 0
                    self.audioEngine.mainMixerNode.outputVolume = 0
                    t.invalidate()
                    self.player.pause()
                }
            })
        }
        isPlay = false
    }

    func stop() {
        if player.isPlaying {
            timer = Timer.scheduledTimer(withTimeInterval: 0.008, repeats: true, block: { (t) in
                self.cnt += 1
                if self.player.volume > 0 {
                    self.player.volume -= 0.33
                    self.audioEngine.mainMixerNode.outputVolume -= 0.33
                } else if self.cnt > 5 {
                    self.player.volume = 0
                    self.audioEngine.mainMixerNode.outputVolume = 0
                    t.invalidate()
                    self.player.stop()
                }
            })
        }
        isPlay = false
    }

    func stopEngine() {
        stop()
        if audioEngine.isRunning {
            audioEngine.stop()
        }
    }
}
