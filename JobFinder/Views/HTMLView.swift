import SwiftUI
import WebKit

struct HTMLView: UIViewRepresentable {
    let html: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let htmlString = """
            <html>
              <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style> body { font-family: -apple-system; padding: 0 16px; } </style>
              </head>
              <body>
                \(html)
              </body>
            </html>
        """
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}
