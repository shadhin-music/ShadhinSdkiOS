//
//  WKCookieWebView.swift
//
//  Created by Jens Reynders on 30/03/2018.
//  Copyright (c) 2018 November Five
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import Foundation
import WebKit

class WKCookieWebView : WKWebView {

    var useRedirectCookieHandling: Bool = true

    init(frame: CGRect, configuration: WKWebViewConfiguration, useRedirectCookieHandling: Bool = false) {
        self.useRedirectCookieHandling = useRedirectCookieHandling
        super.init(frame: frame, configuration: configuration)
    }

    required init?(coder: NSCoder) {
        //self.useRedirectCookieHandling = false
        super.init(coder: coder)
    }

    override func load(_ request: URLRequest) -> WKNavigation? {
        guard useRedirectCookieHandling else {
            return super.load(request)
        }

        requestWithCookieHandling(request, success: { (newRequest , response, data) in
            DispatchQueue.main.async {
                self.syncCookiesInJS()
                if let data = data, let response = response {
                    let _ = self.webViewLoad(data: data, response: response)
                } else {
                    self.syncCookies(newRequest, nil, { (cookieRequest) in
                        let _ = super.load(cookieRequest)
                    })
                }
            }
        }, failure: {
            // let WKWebView handle the network error
            DispatchQueue.main.async {
                self.syncCookies(request, nil, { (newRequest) in
                    let _ = super.load(newRequest)
                })
            }
        })

        return nil
    }

    private func requestWithCookieHandling(_ request: URLRequest, success: @escaping (URLRequest, HTTPURLResponse?, Data?) -> Void, failure: @escaping () -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let _ = error {
                failure()
            } else {
                if let response = response as? HTTPURLResponse {

                    let code = response.statusCode
                    //print(code)
                    if code == 200 {
                        // for code 200 return data to load data directly
                        success(request, response, data)

                    } else if code >= 300 && code <  400  {
                        // for redirect get location in header,and make a new URLRequest
                        guard let location = response.allHeaderFields["Location"] as? String, let redirectURL = URL(string: location) else {
                            failure()
                            return
                        }
                        //print("Got Redirect -> \(location)")

                        let request = URLRequest(url: redirectURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
                        success(request, nil, nil)

                    } else {
                        success(request, response, data)
                    }
                }
            }
        }
        task.resume()
    }

    private func webViewLoad(data: Data, response: URLResponse) -> WKNavigation! {
        guard let url = response.url else {
            return nil
        }

        let encode = response.textEncodingName ?? "utf8"
        let mine = response.mimeType ?? "text/html"

        return self.load(data, mimeType: mine, characterEncodingName: encode, baseURL: url)
    }
}

extension WKCookieWebView {
    // sync HTTPCookieStorage cookies to URLRequest
    private func syncCookies(_ request: URLRequest, _ task: URLSessionTask? = nil, _ completion: @escaping (URLRequest) -> Void) {
        var request = request
        var cookiesArray = [HTTPCookie]()

        if let task = task {
            HTTPCookieStorage.shared.getCookiesFor(task, completionHandler: { (cookies) in
                if let cookies = cookies {
                    cookiesArray.append(contentsOf: cookies)

                    let cookieDict = HTTPCookie.requestHeaderFields(with: cookiesArray)
                    if let cookieStr = cookieDict["Cookie"] {
                        request.addValue(cookieStr, forHTTPHeaderField: "Cookie")
                    }
                }
                completion(request)
            })
        } else  if let url = request.url {
            if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
                cookiesArray.append(contentsOf: cookies)
            }
            let cookieDict = HTTPCookie.requestHeaderFields(with: cookiesArray)
            if let cookieStr = cookieDict["Cookie"] {
                request.addValue(cookieStr, forHTTPHeaderField: "Cookie")
            }
            completion(request)

        }
    }

    // MARK: - JS Cookie handling
    private func syncCookiesInJS(for request: URLRequest? = nil) {
        if let url = request?.url,
            let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            let script = jsCookiesString(for: cookies)
            let cookieScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            self.configuration.userContentController.addUserScript(cookieScript)

        } else if let cookies = HTTPCookieStorage.shared.cookies {
            let script = jsCookiesString(for: cookies)
            let cookieScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            self.configuration.userContentController.addUserScript(cookieScript)
        }
    }

    private func jsCookiesString(for cookies: [HTTPCookie]) -> String {
        var result = ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"

        for cookie in cookies {
            result += "document.cookie='\(cookie.name)=\(cookie.value); domain=\(cookie.domain); path=\(cookie.path); "
            if let date = cookie.expiresDate {
                result += "expires=\(dateFormatter.string(from: date)); "
            }
            if (cookie.isSecure) {
                result += "secure; "
            }
            result += "'; "
        }
        return result
    }
}

extension WKCookieWebView : URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {

        syncCookies(request) { (newRequest) in
            completionHandler(newRequest)
        }
    }
}
