import UIKit
import WebKit
import SafariServices

final class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private let homeURL = URL(string: "https://gorzow.biz/")!
    private let allowedHost = "gorzow.biz"

    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.navigationDelegate = self
        view.uiDelegate = self
        view.allowsBackForwardNavigationGestures = true
        view.scrollView.keyboardDismissMode = .interactive
        view.scrollView.contentInsetAdjustmentBehavior = .automatic
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .bar)
        view.progressTintColor = UIColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0)
        view.trackTintColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let toolbar: UIToolbar = {
        let bar = UIToolbar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()

    private var progressObservation: NSKeyValueObservation?
    private var backButton: UIBarButtonItem!
    private var forwardButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureLayout()
        configureRefreshControl()
        configureProgress()
        load(homeURL)
    }

    deinit { progressObservation?.invalidate() }

    private func configureLayout() {
        view.addSubview(webView)
        view.addSubview(progressView)
        view.addSubview(toolbar)
        backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(goBack))
        forwardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.forward"), style: .plain, target: self, action: #selector(goForward))
        let homeButton = UIBarButtonItem(image: UIImage(systemName: "house"), style: .plain, target: self, action: #selector(goHome))
        let reloadButton = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(reloadPage))
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(sharePage))
        let flexible = UIBarButtonItem(systemItem: .flexibleSpace)
        toolbar.items = [backButton, flexible, forwardButton, flexible, homeButton, flexible, reloadButton, flexible, shareButton]
        toolbar.tintColor = UIColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0)
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
        updateNavigationButtons()
    }

    private func configureRefreshControl() {
        let refresh = UIRefreshControl()
        refresh.tintColor = UIColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0)
        refresh.addTarget(self, action: #selector(refreshPulled(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refresh
    }

    private func configureProgress() {
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            DispatchQueue.main.async {
                self?.progressView.progress = Float(webView.estimatedProgress)
                self?.progressView.isHidden = webView.estimatedProgress >= 1.0
            }
        }
    }

    private func load(_ url: URL) {
        var request = URLRequest(url: url)
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 30
        webView.load(request)
    }

    func openDeepLink(_ url: URL) { isInternal(url) ? load(url) : openExternal(url) }

    private func isInternal(_ url: URL) -> Bool {
        guard url.scheme?.lowercased() == "https", let host = url.host?.lowercased() else { return false }
        return host == allowedHost || host.hasSuffix("." + allowedHost)
    }

    private func openExternal(_ url: URL) {
        let scheme = url.scheme?.lowercased() ?? ""
        if ["tel", "mailto", "sms", "facetime", "facetime-audio", "whatsapp", "fb-messenger"].contains(scheme) {
            UIApplication.shared.open(url)
            return
        }
        if ["http", "https"].contains(scheme) {
            let safari = SFSafariViewController(url: url)
            safari.preferredControlTintColor = UIColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0)
            present(safari, animated: true)
            return
        }
        UIApplication.shared.open(url)
    }

    @objc private func goBack() { if webView.canGoBack { webView.goBack() } }
    @objc private func goForward() { if webView.canGoForward { webView.goForward() } }
    @objc private func goHome() { load(homeURL) }
    @objc private func reloadPage() { webView.reload() }

    @objc private func sharePage() {
        guard let url = webView.url else { return }
        let controller = UIActivityViewController(activityItems: [webView.title ?? "gorzow.biz", url], applicationActivities: nil)
        if let popover = controller.popoverPresentationController { popover.barButtonItem = toolbar.items?.last }
        present(controller, animated: true)
    }

    @objc private func refreshPulled(_ sender: UIRefreshControl) {
        webView.reload()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { sender.endRefreshing() }
    }

    private func updateNavigationButtons() {
        backButton?.isEnabled = webView.canGoBack
        forwardButton?.isEnabled = webView.canGoForward
    }

    private func injectMobileTweaks() {
        let script = """
        (function(){
          var m=document.querySelector('meta[name=viewport]');
          if(!m){m=document.createElement('meta');m.name='viewport';document.head.appendChild(m);}
          m.content='width=device-width, initial-scale=1, maximum-scale=5, viewport-fit=cover';
          document.documentElement.classList.add('gorzow-ios-app');
          var s=document.getElementById('gorzow-ios-style');
          if(!s){s=document.createElement('style');s.id='gorzow-ios-style';s.textContent='html,body{max-width:100%;overflow-x:hidden;-webkit-text-size-adjust:100%} input,select,textarea,button{font-size:max(16px,1em)} img{max-width:100%;height:auto}';document.head.appendChild(s);}
        })();
        """
        webView.evaluateJavaScript(script)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { decisionHandler(.cancel); return }
        if isInternal(url) { decisionHandler(.allow) } else { decisionHandler(.cancel); openExternal(url) }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.scrollView.refreshControl?.endRefreshing()
        updateNavigationButtons()
        injectMobileTweaks()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.scrollView.refreshControl?.endRefreshing(); showNetworkError(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webView.scrollView.refreshControl?.endRefreshing(); showNetworkError(error)
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else { return nil }
        isInternal(url) ? load(url) : openExternal(url)
        return nil
    }

    private func showNetworkError(_ error: Error) {
        let nsError = error as NSError
        if nsError.code == NSURLErrorCancelled { return }
        let alert = UIAlertController(title: "Brak połączenia", message: "Nie udało się otworzyć gorzow.biz. Sprawdź połączenie z Internetem i spróbuj ponownie.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ponów", style: .default) { [weak self] _ in self?.webView.reload() })
        alert.addAction(UIAlertAction(title: "Anuluj", style: .cancel))
        if presentedViewController == nil { present(alert, animated: true) }
    }
}
