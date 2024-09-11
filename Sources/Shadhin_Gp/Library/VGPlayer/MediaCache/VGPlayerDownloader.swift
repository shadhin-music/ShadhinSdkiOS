//
//  VGPlayerDownloader.swift
//  Pods
//
//  Created by Vein on 2017/6/23.
//
//

import Foundation
import MobileCoreServices

// MARK: - VGPlayerDownloaderStatus
 struct VGPlayerDownloaderStatus {
    
    static let shared = VGPlayerDownloaderStatus()
    fileprivate var downloadingURLs: NSMutableSet
    fileprivate let downloaderStatusQueue = DispatchQueue(label: "com.vgplayer.downloaderStatusQueue")
    
    init() {
        downloadingURLs = NSMutableSet()
    }
    
     func add(URL: URL) {
        downloaderStatusQueue.sync {
            downloadingURLs.add(URL)
        }
    }
    
     func remove(URL: URL) {
        downloaderStatusQueue.sync {
            downloadingURLs.remove(URL)
        }
    }
    
     func contains(URL: URL) -> Bool{
        return downloadingURLs.contains(URL)
    }
    
     func urls() -> NSSet {
        return downloadingURLs.copy() as! NSSet
    }
}

 protocol VGPlayerDownloaderDelegate: AnyObject {
    func downloader(_ downloader: VGPlayerDownloader, didReceiveResponse response: URLResponse)
    func downloader(_ downloader: VGPlayerDownloader, didReceiveData data: Data)
    func downloader(_ downloader: VGPlayerDownloader, didFinishedWithError error: Error?)
}


extension VGPlayerDownloaderDelegate {
     func downloader(_ downloader: VGPlayerDownloader, didReceiveResponse response: URLResponse) { }
     func downloader(_ downloader: VGPlayerDownloader, didReceiveData data: Data) { }
     func downloader(_ downloader: VGPlayerDownloader, didFinishedWithError error: Error?) { }
}

// MARK: - VGPlayerDownloader
 class VGPlayerDownloader: NSObject {
     fileprivate(set) var url: URL
     weak var delegate: VGPlayerDownloaderDelegate?
     var cacheMedia: VGPlayerCacheMedia?
     var cacheMediaWorker: VGPlayerCacheMediaWorker
    
    fileprivate var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }()
    fileprivate var isDownloadToEnd: Bool = false
    fileprivate var actionWorker: VGPlayerDownloadActionWorker?
    
    deinit {
        VGPlayerDownloaderStatus.shared.remove(URL: url)
    }
    
     init(url: URL) {
        self.url = url
        cacheMediaWorker = VGPlayerCacheMediaWorker(url: url)
        cacheMedia = cacheMediaWorker.cacheConfiguration?.cacheMedia
        super.init()
    }
    
     func dowloaderTask(_ fromOffset: Int64, _ length: Int, _ isEnd: Bool) {
        if isCurrentURLDownloading() {
            handleCurrentURLDownloadingError()
            return
        }
        VGPlayerDownloaderStatus.shared.add(URL: self.url)
        
        var range = NSRange(location: Int(fromOffset), length: length)
        if isEnd {
            if let contentLength = cacheMediaWorker.cacheConfiguration?.cacheMedia?.contentLength {
                range.length = Int(contentLength) - range.location
            } else {
                range.length = 0 - range.location
            }
            
        }
        let actions = cacheMediaWorker.cachedDataActions(forRange: range)
        actionWorker = VGPlayerDownloadActionWorker(actions: actions, url: url, cacheMediaWorker: cacheMediaWorker)
        actionWorker?.delegate = self
        actionWorker?.start()
    }
     func dowloadFrameStartToEnd() {
        if isCurrentURLDownloading() {
            handleCurrentURLDownloadingError()
            return
        }
        VGPlayerDownloaderStatus.shared.add(URL: url)
        
        isDownloadToEnd = true
        let range = NSRange(location: 0, length: 2)
        let actions = cacheMediaWorker.cachedDataActions(forRange: range)
        actionWorker = VGPlayerDownloadActionWorker(actions: actions, url: url, cacheMediaWorker: cacheMediaWorker)
        actionWorker?.delegate = self
        actionWorker?.start()
        
        
    }
     func cancel() {
        VGPlayerDownloaderStatus.shared.remove(URL: url)
        actionWorker?.cancel()
        actionWorker?.delegate = nil
        actionWorker = nil
    }
    
     func invalidateAndCancel() {
        VGPlayerDownloaderStatus.shared.remove(URL: url)
        actionWorker?.cancel()
        actionWorker?.delegate = nil
        actionWorker = nil
    }
    
    // check
    internal func isCurrentURLDownloading() -> Bool {
        return VGPlayerDownloaderStatus.shared.contains(URL: url)
    }
    
    internal func handleCurrentURLDownloadingError() {
        
        if isCurrentURLDownloading() {
            let userInfo = [NSLocalizedDescriptionKey: "URL: \(url) alreay in downloading queue."]
            let error = NSError(domain: "com.vgplayer.download", code: -1, userInfo: userInfo)
            delegate?.downloader(self, didFinishedWithError: error as Error)
        }
    }
}

// MARK: - VGPlayerDownloadActionWorkerDelegate
extension VGPlayerDownloader: VGPlayerDownloadActionWorkerDelegate {
    
     func downloadActionWorker(_ actionWorker: VGPlayerDownloadActionWorker, didFinishWithError error: Error?) {
        VGPlayerDownloaderStatus.shared.remove(URL: url)
        if error == nil && isDownloadToEnd {
            isDownloadToEnd = false
            let length = (cacheMediaWorker.cacheConfiguration?.cacheMedia?.contentLength)! - 2
            dowloaderTask(2, Int(length), true)
        } else {
            delegate?.downloader(self, didFinishedWithError: error)
        }
    }
    
     func downloadActionWorker(_ actionWorker: VGPlayerDownloadActionWorker, didReceive data: Data, isLocal: Bool) {
        delegate?.downloader(self, didReceiveData: data)
    }
    
     func downloadActionWorker(_ actionWorker: VGPlayerDownloadActionWorker, didReceive response: URLResponse) {
        if cacheMedia == nil {
            let cacheMedia = VGPlayerCacheMedia()
            if response.isKind(of: HTTPURLResponse.classForCoder()) {
                
                let HTTPurlResponse = response as! HTTPURLResponse                                  // set header
                let acceptRange = HTTPurlResponse.allHeaderFields["Accept-Ranges"] as? String
                if let bytes = acceptRange?.isEqual("bytes") {
                    cacheMedia.isByteRangeAccessSupported = bytes
                }
                // fix swift allHeaderFields NO! case insensitive
                let contentRange = HTTPurlResponse.allHeaderFields["content-range"] as? String
                let contentRang = HTTPurlResponse.allHeaderFields["Content-Range"] as? String
                if let last = contentRange?.components(separatedBy: "/").last {
                    cacheMedia.contentLength = Int64(last)!
                }
                if let last = contentRang?.components(separatedBy: "/").last {
                    cacheMedia.contentLength = Int64(last)!
                }
                
            }
            if let mimeType = response.mimeType {
                let contentType =  UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)
                if let takeUnretainedValue = contentType?.takeUnretainedValue() {
                    cacheMedia.contentType = takeUnretainedValue as String
                }
            }
            self.cacheMedia = cacheMedia
            let isSetCacheMedia = cacheMediaWorker.set(cacheMedia: cacheMedia)
            if !isSetCacheMedia {
                let nsError = NSError(domain: "com.vgplayer.cacheMedia", code: -1, userInfo: [NSLocalizedDescriptionKey:"Set cache media failed."])
                delegate?.downloader(self, didFinishedWithError: nsError as Error)
                return
            }
        }
        delegate?.downloader(self, didReceiveResponse: response)
    }
    
    
}
