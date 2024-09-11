//
//  PodcastExploreVC.swift
//  Shadhin
//
//  Created by Rezwan on 8/3/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PodcastExploreVC: UIViewController {
    
    @IBOutlet weak var noInternetView: NoInternetView!
    @IBOutlet weak var tableView: UITableView!
    
    var willLoadAds = false
    
    var podcastExplore : PodcastExploreObj?{
        didSet{
            if podcastExplore != nil{
                tableView.reloadData()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PodcastCollectionCell.nib, forCellReuseIdentifier: PodcastCollectionCell.identifier)
        tableView.register(PodcastTrendingCell.nib, forCellReuseIdentifier: PodcastTrendingCell.identifier)
//        tableView.register(NavtiveLargeAdTCell.nib, forCellReuseIdentifier: NavtiveLargeAdTCell.identifier)
//        tableView.register(NativeAdMax.nib, forCellReuseIdentifier: NativeAdMax.identifier)
        tableView.contentInset = UIEdgeInsets(top: 20,left: 0,bottom: 0,right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        
        
        
        noInternetView.retry = {[weak self] in
            guard let self = self else {return}
            if ConnectionManager.shared.isNetworkAvailable{
                LoadingIndicator.startAnimation()
                ShadhinCore.instance.api.getPodcastExplore { (exploreModel, errStr) in
                    LoadingIndicator.stopAnimation()
                    if exploreModel != nil{
                        self.podcastExplore = exploreModel
                        self.noInternetView.isHidden = true
                        self.tableView.isHidden = false
                    }
                    if let _errStr = errStr{
                        self.view.makeToast(_errStr)
                    }
                }
                
            }
        }
        noInternetView.gotoDownload = {[weak self] in
            guard let self = self else {return}
            if checkProUser(){
                let vc = DownloadVC.instantiateNib()
                vc.selectedDownloadSeg = .init(title: ^String.Downloads.audioPodcast, type: .PodCast)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ConnectionManager.shared.isNetworkAvailable{
            guard self.podcastExplore == nil else {return}
            LoadingIndicator.initLoadingIndicator(view: self.view)
            LoadingIndicator.startAnimation()
            ShadhinCore.instance.api.getPodcastExplore { (exploreModel, errStr) in
                LoadingIndicator.stopAnimation()
                if exploreModel != nil{
                    self.podcastExplore = exploreModel
                    self.noInternetView.isHidden = true
                    self.tableView.isHidden = false
                }
                if let _errStr = errStr{
                    self.view.makeToast(_errStr)
                }
            }
            
        }else{
            guard self.podcastExplore == nil else {return}
            tableView.isHidden = true
            noInternetView.isHidden = false
        }
    }
    
    func openPodcast(patchItem : PatchItem){
        
//        if !LoginService.instance.isLoggedIn{
//            guard let mainVc = AppDelegate.shared?.mainHome else {return}
//            mainVc.showNotUserPopUp(callingVC: mainVc)
//            return
//        }
        
        if let podcastVC = self.storyboard?.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC{
            
            podcastVC.podcastCode = patchItem.contentType
            podcastVC.selectedEpisodeID = Int(patchItem.episodeID) ?? 0
            self.navigationController?.pushViewController(podcastVC, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
      //  loadAds()
    }
//    
//    private func loadAds(){
//        guard let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String,
//        !ShadhinCore.instance.isUserPro else {
//            removeAd()
//            return
//        }
//        if useAdProvider == "google"{
//            loadGoogleAd()
//        }else if(useAdProvider == "applovin"){
//            loadApplovinAd()
//        }else{
//            removeAd()
//        }
//    }
//    
//    private func removeAd(){
//        if willLoadAds{
//            willLoadAds = false
//            tableView.reloadData()
//        }
//    }
//    
//    private func loadGoogleAd(){
//        if !willLoadAds{
//            NativeAdLoader.shared(self.navigationController!).isReadyToLoadAds { success in
//                if success{
//                    self.willLoadAds = true
//                    self.tableView.reloadData()
//                }
//            }
//        }
//    }
//    
//    private func loadApplovinAd(){
//        if !willLoadAds{
//            willLoadAds = true
//            tableView.reloadData()
//
//        }
//    }

}

extension PodcastExploreVC : UITableViewDelegate,UITableViewDataSource{
    
    func isIndexAnAd(index : Int) -> Bool{
        if !willLoadAds{
            return false
        }
        return index % 4 == 0
    }
    
    func getAdAdjustedRow(row: Int) -> Int{
        if !willLoadAds{
            return row
        }
        let n = Double(row) / 4.0
        let _n = Int(n.rounded(.up))
        let adjustedSection = row - (1 * _n)
        return adjustedSection
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print(podcastExplore?.data.count)
        return podcastExplore?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if podcastExplore?.data[section].patchType.lowercased() == "tn" {
            var count = podcastExplore?.data[section].data.count ?? 0
            if willLoadAds{
                let adsCountDouble = Double(count) / 3.0
                let adsCountInt = Int(adsCountDouble.rounded(.up))
                //print("count += adsCountInt -> \(count) \(adsCountInt)")
                count += adsCountInt
            }
            return count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let patchData = podcastExplore?.data[indexPath.section] else{
            return UITableViewCell()
        }
        
        switch patchData.patchType.lowercased() {
        case "ss", "ps", "pp", "le", "news", "vp", "vl", "tpc":
            let cell = tableView.dequeueReusableCell(withIdentifier: PodcastCollectionCell.identifier, for: indexPath) as! PodcastCollectionCell
            cell.bind(patchData, indexPath)
            cell.podcastExploreVC = self
            return cell
        case "tn":
//            if isIndexAnAd(index: indexPath.row){
//                let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String
//                if useAdProvider == "google"{
//                    let cell =  tableView.dequeueReusableCell(withIdentifier: NavtiveLargeAdTCell.identifier, for: indexPath) as! NavtiveLargeAdTCell
//                    if let nav = self.navigationController, let ad = NativeAdLoader.shared(nav).getNativeAd(){
//                        cell.loadAd(nativeAd: ad)
//                    }
//                    return cell
//
//                }else if useAdProvider == "applovin"{
//                    let cell =  tableView.dequeueReusableCell(withIdentifier: NativeAdMaxSmall.identifier, for: indexPath) as! NativeAdMaxSmall
//                    cell.tableview = self.tableView
//                    return cell
//                }
//            }
            
            let adjustedRow = getAdAdjustedRow(row: indexPath.row)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: PodcastTrendingCell.identifier, for: indexPath) as! PodcastTrendingCell
            cell.bind(patchItem: patchData.data[adjustedRow])
            cell.podcastExploreVC = self
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let patchData = podcastExplore?.data[indexPath.section] else{
            return 0
        }
        
        switch patchData.patchType.lowercased() {
        case "le":
            return PodcastCollectionCell.size(.SquareSmallWithLabel)
        case "vl":
            return PodcastCollectionCell.size(.VideoLandscape)
        case "pp", "news":
            return PodcastCollectionCell.size(.SquareBig)
//        case "vp":
//            return PodcastCollectionCell.size(.VideoPortrait)
        case "vp":
            return PodcastCollectionCell.size(.VideoLandscapeV2)
        case "ps":
            return PodcastCollectionCell.size(.LandscapeWithLabel)
        case "ss", "tpc":
            return PodcastCollectionCell.size(.Portrait)
        case "tn":
//            if isIndexAnAd(index: indexPath.row){
//                let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String
//                if useAdProvider == "google"{
//                    return NavtiveLargeAdTCell.size
//                }else if useAdProvider == "applovin"{
//                    return NativeAdMaxSmall.size
//                }else{
//                    return .leastNormalMagnitude
//                }
//            }
            return PodcastTrendingCell.size
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let patchData = podcastExplore?.data[section] else{
            return nil
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width, height: 30))
        label.text = patchData.patchName
        label.backgroundColor = UIColor.clear
        label.font = UIFont.init(name: "OpenSans-SemiBold", size: 20)
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNonzeroMagnitude
    }
    
    
    
    
}
