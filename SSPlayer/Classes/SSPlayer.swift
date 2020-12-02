//MIT License
//
//Copyright (c) 2020 lai001
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import AVFoundation

open class SSPlayer: AVPlayer {
    
    public var isPlaying: Bool {
        if #available(iOS 10.0, *) {
            return timeControlStatus == .playing
        } else {
            if currentItem == nil {
                return false
            }
            return rate != 0 && error == nil
        }
    }
    
    private var timeObserverToken: Any?
    
    private lazy var seeker: SSPlayerSeeker = {
        var seeker: SSPlayerSeeker = .init(player: self)
//        seeker.seekSmoothly(to: .zero)
        return seeker
    }()
    
    deinit {
        if let timeObserverToken = timeObserverToken {
            removeTimeObserver(timeObserverToken)
        }
        timeObserverToken = nil
    }
    
    open override func replaceCurrentItem(with item: AVPlayerItem?) {
        super.replaceCurrentItem(with: item)
        seeker.reset()
    }
    
    open override func seek(to time: CMTime) {
        if canSeekTo(time: time) {
            super.seek(to: time)
        }
    }
    
    open override func seek(to time: CMTime, completionHandler: @escaping (Bool) -> Void) {
        if canSeekTo(time: time) {
            super.seek(to: time, completionHandler: completionHandler)
        }
    }
    
    open override func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) {
        if canSeekTo(time: time) {
            super.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter)
        }
    }
    
    open override func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        if canSeekTo(time: time) {
            super.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
        }
    }
    
    open override func play() {
        guard let currentItem = self.currentItem else {
            super.play()
            return
        }
        if CMTimeCompare(currentTime(), currentItem.duration) > -1 {
            self.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                super.play()
            }
        } else {
            super.play()
        }
    }
    
}

// MARK: - observe
public extension SSPlayer {
    
    func observePlayingTime(forInterval interval: CMTime = CMTime(value: 30, timescale: 600), queue: DispatchQueue = .main, block: @escaping (_ time: CMTime) -> Void) {
//        let interval = CMTime(value: 30, timescale: 600)
        if let timeObserverToken = timeObserverToken {
            removeTimeObserver(timeObserverToken)
        }
        
        timeObserverToken = addPeriodicTimeObserver(forInterval: interval, queue: queue) { time in
            block(time)
        }
    }
    
    func removePlayingTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            removeTimeObserver(timeObserverToken)
        }
        timeObserverToken = nil
    }

}

public extension SSPlayer {
    
    private func canSeekTo(time: CMTime) -> Bool {
        if time.isIndefinite || time.isValid == false {
            debugPrint("time is not valid, seek to play time \(time.seconds) fail")
            return false
        }
        guard let currentItem = currentItem else {
            debugPrint("no playerItem, seek to play time \(time.seconds) fail")
            return false
        }
        
        if currentItem.status == .readyToPlay {
            return true
        }
        debugPrint("playerItem(\(currentItem.status.rawValue)) not ready to play, seek to play time \(time.seconds) fail")
        return false
    }
    
    public func seekSmoothly(to newChaseTime: CMTime, completionSeekBlock: SSPlayerSeeker.CompletionSeekBlock? = nil) {
        if canSeekTo(time: newChaseTime) {
            seeker.seekSmoothly(to: newChaseTime, completionSeekBlock: completionSeekBlock)
        }
    }
    
    func resetToBeginTime(autoPlay: Bool, resultHandler: @escaping (Bool) -> Void) {
        guard let item = currentItem else {
            resultHandler(false)
            return
        }
        if item.status == .readyToPlay {
            self.pause()
            self.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] (success: Bool) in
                guard let self = self else {
                    return
                }
                if success {
                    if autoPlay {
                        self.play()
                    }
                    resultHandler(true)
                } else {
                    resultHandler(false)
                }
            }
        } else {
            resultHandler(false)
        }
    }
    
    func reset(to time: CMTime, autoPlay: Bool, resultHandler: @escaping (Bool) -> Void) {
        guard let item = currentItem else {
            resultHandler(false)
            return
        }
        if item.status == .readyToPlay {
            self.pause()
            self.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] (success: Bool) in
                guard let self = self else {
                    return
                }
                if success {
                    if autoPlay {
                        self.play()
                    }
                    resultHandler(true)
                } else {
                    resultHandler(false)
                }
            }
        } else {
            resultHandler(false)
        }
    }
    
}
