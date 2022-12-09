//
//  ViewController.swift
//  NavegadorChapys
//
//  Created by BRS101325 on 08/12/22.
//

import UIKit
import WebKit

final class ViewController: UIViewController {
    //Botones
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    private var webView : WKWebView!
    private let searchBar = UISearchBar()
    private let baseUrl = "http://www.google.com" //variable por defecto
    private let searchPath = "/search?q=" //url para buscar dentro de google
    
    private let refreshControl = UIRefreshControl() //control para refrescar pagina
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        //Botones de navegacion
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        //Barra de busqueda
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        
        // web view
        let webViewPrefs = WKPreferences()
        
        //webViewPrefs.javaScriptEnabled = true //Soporta javaScrip pero por default ya lo hace, se puede habilitar si hay problemas
        
        webViewPrefs.javaScriptCanOpenWindowsAutomatically = true
        let webViewConf = WKWebViewConfiguration()
        webViewConf.preferences = webViewPrefs
        
        webView = WKWebView(frame : view.frame, configuration : webViewConf)
        
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.keyboardDismissMode = .onDrag

        view.addSubview(webView)
        webView.navigationDelegate = self

        
                
        
        //refrescar pagina deslizando hacia arriba xd
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
        view.bringSubviewToFront(refreshControl)
        //cargar google
        
        load(url: baseUrl)


    }


    @IBAction func forwardButtonAction(_ sender: Any) {
        webView.goForward()
    }
    @IBAction func backButtonAction(_ sender: Any) {
        webView.goBack()
    }
    
    //operacionees privada
    private func load(url: String) {
        
        var urlToLoad: URL!
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            urlToLoad = url
        } else {
            urlToLoad = URL(string: "\(baseUrl)\(searchPath)\(url)")!
        }
        webView.load(URLRequest(url: urlToLoad))
    }
    //funcion para recargar hacia arriba
    @objc private func reload(){
        
        webView.reload()
    }
}
//



extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
        load(url: searchBar.text ?? "") //carga cualquier pagina desde el buscador
    }
    
}


extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        refreshControl.endRefreshing() //refresca pagina
        backButton.isEnabled = webView.canGoBack //habilita boton atras
        forwardButton.isEnabled = webView.canGoForward //habilita boton delantero
        view.bringSubviewToFront(refreshControl) //refresca
        
    }
    

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        refreshControl.beginRefreshing()
        searchBar.text = webView.url?.absoluteString //busca cualquier texto en navegador
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        refreshControl.beginRefreshing()
        view.bringSubviewToFront(refreshControl)
    }
    
}
