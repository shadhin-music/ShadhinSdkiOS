//
//  HomeVCv3.swift
//  Shadhin
//
//  Created by Joy on 10/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class HomeVCv3: UIViewController, NIBVCProtocol{
    
    @IBOutlet weak var proImg: UIImageView!
    var discoverModel: CommonContentProtocol!
    var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profileButton : UIButton?
    @IBOutlet weak var searchButton : UIButton?
    @IBOutlet weak var collectionView : UICollectionView?
    @IBOutlet weak var appBarView: UIView!
    @IBOutlet weak var darkModeBtn: UIButton!
    private var refreshControll : UIRefreshControl?
    var adapter : HomeAdapter!
    var vm : HomeVM!
    var appFirstOpen = true
    public var coordinator : HomeCoordinator? // made public for deeplink hack
    var mainNav : UINavigationController?
    override func viewDidLoad() {
        super.viewDidLoad()
        profileButton?.addTarget(self, action: #selector(onProfilePressed), for: .touchDown)
        searchButton?.addTarget(self, action: #selector(onSearchPressed), for: .touchDown)
        darkModeBtn.addTarget(self, action: #selector(toggleButtonPressed), for: .touchDown)
        vm = HomeVM(presenter: self)
        viewSetup()
        if let navVc = self.navigationController{
            coordinator = HomeCoordinator(navigationController: navVc, tabBar: self.tabBarController)
        }
    //    loadAd()
        vm.loadRecomanded()
        // AppDelegate.shared?.mainHome = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(performTaskAfterSubscriptionCheck), name: .didTapBackBkashPayment, object: nil)
        if !ShadhinCore.instance.isUserLoggedIn ||
            (ShadhinCore.instance.isUserLoggedIn){
            self.performTaskAfterSubscriptionCheck()
        }
        
        setupBottomLoadingIndicator()
        
        GPAudioViewModel.shared.areWeInsideSDK = true
        checkAndSetupGPAudioPlayer()
    }
    
    func checkAndSetupGPAudioPlayer() {
        let viewModel = GPAudioViewModel.shared
        AudioPlayer.shared.delegate = MusicPlayerV3.shared
        if !viewModel.gpMusicContents.isEmpty && viewModel.gpContentPlayingState != .neverPlayed {
            MusicPlayerV3.shared.musicdata = viewModel.gpMusicContents.compactMap({$0.toCommonContentV4()})
            MusicPlayerV3.shared.rootContent = viewModel.gpMusicContents.compactMap({$0.toCommonContentV4()}).first
            openGPMusicsInMiniPlayer()
        }
    }
    
    func setProfileImage() {
        if let profileImage = UserInfoViewModel.shared.userInfo?.userPic {
            proImg.kf.setImage(with: URL(string: profileImage.safeUrl()),placeholder: UIImage(named: "ic_profile_img",in: Bundle.ShadhinMusicSdk,with: nil))
        }
    }
    
    @objc func performTaskAfterSubscriptionCheck(){
        guard let vc = MainTabBar.shared, appFirstOpen else {return}
        appFirstOpen = false
        PopUpUtil().handelePopUpTasks(vc, self)
    }
    
    private func checkAndUpdateSubscription() {
        GPSDKSubscription.getNewUserSubscriptionDetails { isSubscribed in
            self.view.unlock()
            NotificationCenter.default.post(name: .newSubscriptionUpdate, object: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Log.info("HomeV3 : viewWillAppear")
        checkAndUpdateSubscription()
        setProfileImage()
//        let proPicUrl = ShadhinCore.instance.defaults.userProPicUrl
//        self.profileButton?.layer.cornerRadius = 14
//        self.profileButton?.clipsToBounds = true
//        if !proPicUrl.isEmpty, proPicUrl.contains("http"),let url = URL(string: proPicUrl.safeUrl()){
//
//            KingfisherManager.shared.retrieveImage(with: url) { result in
//                switch result{
//                case .success(let img):
//                    self.profileButton?.setImage(img.image, for: .normal)
//                case .failure(let error):
//                    Log.error(error.localizedDescription)
//                }
//            }
//        }
    }
    
    @objc
    func toggleButtonPressed(){
        ShadhinCore.instance.defaults.isLighTheam = !ShadhinCore.instance.defaults.isLighTheam
        toggleInterfaceStyle()
    }
    
    func toggleInterfaceStyle() {
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            _ = window?.overrideUserInterfaceStyle == .unspecified ? UIScreen.main.traitCollection.userInterfaceStyle : window?.overrideUserInterfaceStyle
            if !ShadhinCore.instance.defaults.isLighTheam{
                window?.overrideUserInterfaceStyle = .dark
                darkModeBtn.setImage(UIImage(named: "lightMode", in: Bundle.ShadhinMusicSdk,compatibleWith:nil))
            }else{
                window?.overrideUserInterfaceStyle = .light
                darkModeBtn.setImage(UIImage(named: "darkMode", in: Bundle.ShadhinMusicSdk,compatibleWith:nil))
            }
        }
    }
    
    
    func setupBottomLoadingIndicator() {
            // Initialize the activity indicator
            activityIndicator = UIActivityIndicatorView()
            
            // Set the position at the bottom of the view controller
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(activityIndicator)
            
            // Center the activity indicator horizontally
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            ])
            stopLoading()
        }
        
        // Function to start animating the activity indicator
        func startLoading() {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        }
        
        // Function to stop animating the activity indicator
        func stopLoading() {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    @objc
    private func onProfilePressed(){
        self.dismiss(animated: true)
        GPAudioViewModel.shared.areWeInsideSDK = false
    }

    @objc
    private func onSearchPressed(){
        //      coordinator?.gotoSearch()
        let searchVC = SearchMainV3.instantiateNib()
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    
//    func loadAd(){
//        if !ShadhinCore.instance.isUserPro, let nav = self.navigationController{
//            let nativeAdLoader = NativeAdLoader.shared(nav)
//            nativeAdLoader.isReadyToLoadAds { ready in
//                if(ready){
//                    self.collectionView?.reloadData()
//                }
//            }
//        }
//    }

}
//MARK: view setup
extension HomeVCv3{
    func viewSetup(){
        adapter = HomeAdapter(delegate: self)
        collectionView?.register(Billboard.nib, forCellWithReuseIdentifier: Billboard.identifier)
        collectionView?.register(TwoRowSqrWithDescLeft.nib, forCellWithReuseIdentifier: TwoRowSqrWithDescLeft.identifier)
        collectionView?.register(SingleItemWithSeeAll.nib, forCellWithReuseIdentifier: SingleItemWithSeeAll.identifier)
        collectionView?.register(CircularWithFavBtn.nib, forCellWithReuseIdentifier: CircularWithFavBtn.identifier)
        collectionView?.register(CircularWithDescBelow.nib, forCellWithReuseIdentifier: CircularWithDescBelow.identifier)
        collectionView?.register(PopularPlaylistCell.nib, forCellWithReuseIdentifier: PopularPlaylistCell.identifier)
        collectionView?.register(TwoRowSqrWithDescBelow.nib, forCellWithReuseIdentifier: TwoRowSqrWithDescBelow.identifier)
        collectionView?.register(TwoRowSqr.nib, forCellWithReuseIdentifier: TwoRowSqr.identifier)
        collectionView?.register(PatchDescTopWithSqrDescBelow.nib, forCellWithReuseIdentifier: PatchDescTopWithSqrDescBelow.identifier)
        collectionView?.register(SqrPagerWithDescBelow.nib, forCellWithReuseIdentifier: SqrPagerWithDescBelow.identifier)
        collectionView?.register(SqrWithDescBelow.nib, forCellWithReuseIdentifier: SqrWithDescBelow.identifier)
        collectionView?.register(TrendyPopCell.nib, forCellWithReuseIdentifier: TrendyPopCell.identifier)
        collectionView?.register(RecPagerWithDescInside.nib, forCellWithReuseIdentifier: RecPagerWithDescInside.identifier)
        collectionView?.register(TwoRowRecDescBelow.nib, forCellWithReuseIdentifier: TwoRowRecDescBelow.identifier)
        collectionView?.register(RadioV3Cell.nib, forCellWithReuseIdentifier: RadioV3Cell.identifier)
        collectionView?.register(PodcastsCell.nib, forCellWithReuseIdentifier: PodcastsCell.identifier)
        collectionView?.register(Teaser.nib, forCellWithReuseIdentifier: Teaser.identifier)
        collectionView?.register(PatchDescTopWithRecPortDescBelow.nib, forCellWithReuseIdentifier: PatchDescTopWithRecPortDescBelow.identifier)
        collectionView?.register(TomakeChaiCell.nib, forCellWithReuseIdentifier: TomakeChaiCell.identifier)
//        collectionView?.register(NativeAdLargeCell.nib, forCellWithReuseIdentifier: NativeAdLargeCell.identifier)
        //for recent played
        collectionView?.register(RecentlyPlayerCell.nib, forCellWithReuseIdentifier: RecentlyPlayerCell.identifier)
        //for Download
        collectionView?.register(DownloadsHomeCell.nib, forCellWithReuseIdentifier: DownloadsHomeCell.identifier)
        //for stream and win
        collectionView?.register(StreamNwinCollectionCell.nib, forCellWithReuseIdentifier: StreamNwinCollectionCell.identifier)
        //for rewind strory cell
        collectionView?.register(SquareImageCell.nib, forCellWithReuseIdentifier: SquareImageCell.identifier)
        collectionView?.register(SingleImageItemCell.nib, forCellWithReuseIdentifier: SingleImageItemCell.identifier)
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmptyCell")
        // cell for AI playList
        collectionView?.register(AIPlayList.nib, forCellWithReuseIdentifier: AIPlayList.identifier)
        // cell for AI playList
        collectionView?.register(AIPlaylistItemCell.nib, forCellWithReuseIdentifier: AIPlaylistItemCell.identifier)
        collectionView?.dataSource = adapter
        collectionView?.delegate = adapter
        
        refreshControll = UIRefreshControl()
        refreshControll?.tintColor = .appTintColor
        refreshControll?.attributedTitle = NSAttributedString(string: "Refresh")
        refreshControll?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView?.alwaysBounceVertical = true
        collectionView?.refreshControl = refreshControll
        if let refreshControll = refreshControll{
            refreshControll.frame = .init(origin: .init(x: 0, y: 100), size: .init(width: 40, height: 40))
            refreshControll.backgroundColor = UIColor(named: "background",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            collectionView?.addSubview(refreshControll)
        }
        loadMorePatchs()
    }
    @objc
    private func refresh(){
        Log.info("Refresh ")
        refreshControll?.beginRefreshing()
        self.adapter.reset()
        self.collectionView?.reloadData()
        self.vm.reset()
        self.refreshControll?.endRefreshing()
        
    }
    
    func refreshHome(){
        Log.info("Refresh ")
        refreshControll?.beginRefreshing()
        self.adapter.reset()
        self.collectionView?.reloadData()
        self.vm.reset()
        self.refreshControll?.endRefreshing()
    }
    
}

extension HomeVCv3 : HomeAdapterProtocol{
    var homeVM: HomeVM? {
        get {
            vm
        }
        set {
            
        }
    }
    
    var parentCollectionView: UICollectionView? {
        get {
            self.collectionView
        }
        set {

        }
    }
    
    var homeAdapter: HomeAdapter? {
        get {
            adapter
        }
        set {
            adapter = newValue
        }
    }
    
    func reloadView(indexPath: IndexPath) {
        collectionView?.reloadItems(at: [indexPath])
    }
    
    
    func onSubscription() {
        self.goSubscriptionTypeVC()
    }
    
    func onRewind(rewindData: [TopStreammingElementModel]) {
        coordinator?.gotoRewind(rewindData: rewindData)
    }
    
    func seeAllClick(patch: HomePatch) {
        coordinator?.gotoSeeAll(patch: patch)
    }
    
    func gotoLeaderBoard(method: PaymentMethod, campaignType: String) {
        self.coordinator?.gotoLeaderBoard(method: method, campaignType: campaignType)
        
    }
    
    func onItemClicked(patch: HomePatch, content: CommonContentProtocol) {
        coordinator?.routeToContent(content: content, patch)
    }
    
    func navigateToAIGeneratedContent(content: AIPlaylistResponseModel?, imageUrl: String = "", playlistName: String = "", playlistId: String = "") {
        coordinator?.routeToAIPlayList(content: content, imageUrl: imageUrl, playlistName: playlistName, playlistId: playlistId)
    }
    
    
    func loadMorePatchs() {
        vm.loadHomeContent()
    }
    
    func getNavController() -> UINavigationController {
        self.navigationController!
    }
    
    func onScroll(y: Double) {
        if appBarView.frame.origin.y >= -(SCREEN_SAFE_TOP + 56),
            appBarView.frame.origin.y <= 0 {
            appBarView.frame.origin.y = appBarView.frame.origin.y - y
        }
        if appBarView.frame.origin.y < -(SCREEN_SAFE_TOP + 56){
            appBarView.frame.origin.y = -(SCREEN_SAFE_TOP + 56)
        }
        if  appBarView.frame.origin.y > 0{
            appBarView.frame.origin.y = 0
        }
    }
    
    
}

extension HomeVCv3 : HomeVMProtocol{
    
    
//    func onFullScreen() {
//        DeviceOrientation.shared.set(orientation: .landscapeLeft)
//
//    }
//    func onExitFullScreen() {
//        DeviceOrientation.shared.set(orientation: .portrait)
//
//    }
    func rewindData(patches: [HomePatch], rewind: [TopStreammingElementModel]) {
        adapter.addRewind(rewind: rewind)
        adapter.addPatches(array: patches)
        collectionView?.reloadData()
    }
    
    func streamNwin(data: StreamNwinCampaignResponse) {
        adapter.addStreamNwin(stream: data)
    }
    
//    func concertData(data: ConcertEventObj) {
//        adapter.addTicket(ticket: data)
//    }
    
    func loading(isLoading: Bool, page: Int) {
        if page != 1{
            if isLoading{
                startLoading()
               // LoadingIndicator.startAnimation()
            }else{
                stopLoading()
               // LoadingIndicator.stopAnimation()
            }
            return
        }
    }
    
    func handle(patches: [HomePatch]) {
        adapter.addPatches(array: patches)
        collectionView?.reloadData()
    }
    
    func handleAIPlaylists(aiPlaylists: [NewContent]?) {
        adapter.aiPlaylists = aiPlaylists
        let aiIndexPath = indexPathForSpecificCellType(cellType: AIPlaylistItemCell.self)
        if let aiIndexPath {
            if let cell = collectionView?.cellForItem(at: aiIndexPath) as? AIPlaylistItemCell {
                if let aiPlay = adapter.aiPlaylists, !aiPlay.isEmpty {
                    cell.aiPlaylists = aiPlay
                    cell.collectionView.reloadData()
                  //  cell.collectionView.scrollToItem(at: .init(index: 0), at: .left, animated: true)
                    
                }
            }
            
        }
        
        
    }
    
    func indexPathForSpecificCellType<T: UICollectionViewCell>(cellType: T.Type) -> IndexPath? {
        if let collectionView {
            for cell in collectionView.visibleCells {
                if let specificCell = cell as? T {
                    if let indexPath = collectionView.indexPath(for: specificCell) {
                        return indexPath
                    }
                }
            }
        }
        return nil
    }
}

extension HomeVCv3{
    func particapetClick(payment : PaymentMethod){
        if !ShadhinCore.instance.isUserLoggedIn{
            //log in pop up show
          //  self.showNotUserPopUp(callingVC: self)
        }else if ShadhinCore.instance.isUserPro{
            if let telco = PaymentGetwayType(rawValue: payment.name.uppercased()){
                if telco == .ROBI{
                    ShadhinCore.instance.api.showAlert(title: "Stream and Win", msg: "This campaign only for Robi and Airtel subscribed users")
                }else{
                    ShadhinCore.instance.api.showAlert(title: "Stream and Win", msg: "This campaign only for \(telco.rawValue) subscribed users")
                }
                
            }
            
        }else if ShadhinDefaults().userMsisdn.count > 0{
            if let telco = PaymentGetwayType(rawValue: payment.name.uppercased()){
                if telco == .ROBI && ShadhinCore.instance.isRobi() || telco == .GP && ShadhinCore.instance.isGP() || telco == .BL && ShadhinCore.instance.isBanglalink(){
                    //subscription pop up show for telco
                    if telco == .ROBI{
                        self.goSubscriptionTypeVC(false,"robi_airtel")
                    }else if telco == .GP{
                        self.goSubscriptionTypeVC(false,"gp")
                    }else if telco == .BL{
                        self.goSubscriptionTypeVC(false,"banglalink")
                    }
                    
                }else if telco == .Bkash{
                    //subscription pop up show bkash
                    self.goSubscriptionTypeVC(false,"bkash")
                }else if telco == .SSL{
                    //subscription pop up ssl
                    self.goSubscriptionTypeVC(false,"ssl")
                }else if telco == .Nagad{
                    //subscription pop up show nagad
                    //self.goSubscriptionTypeVC(false,"gp")
                }else{
                    ShadhinCore.instance.api.showAlert(title: "Stream and Win", msg: "This campaign only for \(telco.rawValue) subscribed users")
                }
            }
        }else if ShadhinDefaults().userMsisdn.count == 0{
            //number input pop up show
            if let telco = PaymentGetwayType(rawValue: payment.name.uppercased()){
                if telco == .ROBI || telco == .GP  || telco == .BL {
                    //show number input field
                  //  LinkMsisdnVC.show("Phone number is required to proceed with BD subscriptions...")
                }
            }
        }
    }
}


