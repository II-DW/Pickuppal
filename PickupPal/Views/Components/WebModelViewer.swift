// MARK: - WebModelViewer.swift

import SwiftUI
import WebKit

struct WebModelViewer: UIViewRepresentable {
    let src: String
    let animationName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false // 모델 조작과 스크롤 충돌 방지
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
            <script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/3.5.0/model-viewer.min.js"></script>
            <style>
                body { margin: 0; padding: 0; background: transparent; overflow: hidden; }
                model-viewer { width: 100vw; height: 100vh; --poster-color: transparent; }
            </style>
        </head>
        <body>
            <model-viewer
                src="\(src)"
                camera-controls
                auto-rotate
                shadow-intensity="1"
                animation-name="\(animationName)"
                autoplay
                ar
            >
            </model-viewer>
        </body>
        </html>
        """
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
