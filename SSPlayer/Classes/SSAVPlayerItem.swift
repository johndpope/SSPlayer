//MIT License
//
//Copyright (c) 2020 lai001
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import AVFoundation
import UIKit

open class SSAVPlayerItem: AVPlayerItem {
    
    private var playerItemContext = 0
    
    public var statusChangeAction: (( _ item: SSAVPlayerItem, _ status: AVPlayerItem.Status, _ isReadToPlay: Bool ) -> Void)?
    private var _statusChangeAction: (( _ item: SSAVPlayerItem, _ status: AVPlayerItem.Status, _ isReadToPlay: Bool ) -> Void)?
    
    override init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]?) {
        super.init(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
        self.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: .new, context: &playerItemContext)
    }
    
    deinit {
        removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &playerItemContext)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            if UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .inactive {
                
            } else {
                statusChangeAction?(self, status, status == .readyToPlay)
                _statusChangeAction?(self, status, status == .readyToPlay)
            }
        }
    }
    
    public func requestWhenReady(closure: @escaping () -> Void) {
        if self.status == .readyToPlay {
            closure()
        } else {
            _statusChangeAction = { item, status, isReadToPlay in
                if isReadToPlay {
                    closure()
                }
            }
        }
    }
    
}
