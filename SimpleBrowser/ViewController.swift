//
//  ViewController.swift
//  SimpleBrowser
//
//  Created by 市原悠理 on 2018/09/14.
//  Copyright © 2018年 Sample Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIWebViewDelegate,UISearchBarDelegate {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let homeUrlString = "http://www.yahoo.co.jp"
    let searchUrlString = "http://search.yahoo.co.jp/search?p="
    
    let whiteList = [
    "https?://.*\\.yahoo\\.co\\.jp",
    "https?://.*\\yahoo\\.com",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        open(urlString: homeUrlString)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func open(urlString: String){
        let url = URL(string: urlString)
        let urlRequest = URLRequest(url: url!)
        webView.loadRequest(urlRequest)
    }
    
    func openInSafari(urlString: String){
        if let nsUrl = URL(string: urlString){
            UIApplication.shared.open(nsUrl)
        }
    }
    
    func stopLoading(){
        activityIndicator.alpha = 0
        activityIndicator.stopAnimating()
        backButton.isEnabled = self.webView.canGoBack
        reloadButton.isEnabled = true
        stopButton.isEnabled = false
    }
    
    func webViewDidStartLoad(_ webView: UIWebView){
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()
        backButton.isEnabled = false
        reloadButton.isEnabled = false
        stopButton.isEnabled = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        stopLoading()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request:URLRequest, navigationType:UIWebViewNavigationType) ->Bool{
        // ユーザの操作によるリクエストでなければ表示許可
        if navigationType == UIWebViewNavigationType
            .other{
            return true;
        }
        //現在表示中のURLをしゅとく
        var theUrl: String
        if let unwrappedUrl = request.url?.absoluteString{
        theUrl = unwrappedUrl
        }else {
            stopLoading()
            return false;
        }
        
        //ホワイトリストでループしてURLがホワイトリスト内にあるかチェック
        var canStayInApp = false;
        for url in whiteList{
            if theUrl.range(of: url, options: NSString.CompareOptions.regularExpression) != nil {
                canStayInApp = true;
                break;
            }
        }
        // ホワイトリスト内になければSafariで開く
        if !canStayInApp{
            openInSafari(urlString: theUrl)
            stopLoading()
            return false;
        }
        return true
    }
    //　Mark: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        guard let searchText = searchBar.text else { return}
        guard let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)else {return}
        
        let urlString = searchUrlString + encodedText
        open(urlString: urlString)
        searchBar.resignFirstResponder()
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    @IBAction func reloadButtonTapped(_ sender: UIBarButtonItem) {
        webView.reload()
    }
    @IBAction func stopButtonTapped(_ sender: UIBarButtonItem) {
        webView.stopLoading()
    }


}

