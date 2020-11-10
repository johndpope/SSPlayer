//MIT License
//
//Copyright (c) 2020 lai001
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit
import AVFoundation

// https://developer.apple.com/library/archive/qa/qa1820/_index.html
public class SSPlayerSeeker {
    
    public typealias CompletionSeekBlock = () -> Void
    
    private var isSeekInProgress = false
    
    private weak var player: AVPlayer?
    
    private var chaseTime = CMTime.zero

    internal init(player: AVPlayer) {
        self.player = player
    }
    
    internal func seekSmoothly(to newChaseTime: CMTime, completionSeekBlock: CompletionSeekBlock? = nil) {
        player?.pause()
        if CMTimeCompare(newChaseTime, chaseTime) != 0 {
            chaseTime = newChaseTime;
            if !isSeekInProgress {
                trySeekToChaseTime(completionSeekBlock: completionSeekBlock)
            }
        }
    }
 
    private func trySeekToChaseTime(completionSeekBlock: CompletionSeekBlock? = nil) {
        if player?.currentItem?.status == .readyToPlay {
            actuallySeekToTime(completionSeekBlock: completionSeekBlock)
        }
    }
 
    private func actuallySeekToTime(completionSeekBlock: CompletionSeekBlock? = nil) {
        isSeekInProgress = true
        let seekTimeInProgress = chaseTime
        player?.seek(to: seekTimeInProgress, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { (isFinished:Bool) -> Void in
            if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                self.isSeekInProgress = false
                completionSeekBlock?()
            } else {
                self.trySeekToChaseTime()
            }
        })
    }
 
}
