import AVFoundation

//音の生成
class SoundWave {
    
    let audioEngine = AVAudioEngine()
    let player = AVAudioPlayerNode()
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
    
    func soundSet() {
        let audioFormat = player.outputFormat(forBus: 0)
        let sampleRate: Float = 44100.0
        let length = UInt32(sampleRate)
        if let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: length) {
            buffer.frameLength = length
            for n in (0 ..< Int(length)) {
                
                var val : [Float] = [0.0 , 0.0]
                
                val[0] = sinf(Float(soundHz) * Float(n) * 2.0 * Float.pi / sampleRate)
                val[1] = sinf((Float(soundHz) + binoralHz) * Float(n) * 2.0 * Float.pi / sampleRate)
                                
                buffer.floatChannelData?.advanced(by: 0).pointee[n] = soundVolume / 5 * val[0]
                buffer.floatChannelData?.advanced(by: 1).pointee[n] = soundVolume / 5 * val[1]
                
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
