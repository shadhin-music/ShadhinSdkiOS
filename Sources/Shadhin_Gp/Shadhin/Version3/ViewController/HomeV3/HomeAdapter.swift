//
//  HomeAdapter.swift
//  Shadhin
//
//  Created by Joy on 10/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserr.
//

import UIKit

enum HomePatchType : Int{
    case BILLBOARD                                  = 1
    case TWO_ROW_SQR_WITH_DESC_LEFT                 = 2
    case SINGLE_ITEM_WITH_SEE_ALL                   = -8
    case CIRCULAR_WITH_FAV_BTN                      = 4
    case RECENTLY_PLAYED                            = 5
    case DOWNLOADED                                 = 6
    case TWO_ROW_SQR                                = 7
    case PATCH_DESC_TOP_WITH_SQR_DESC_BELOW         = 8
  //  case SQR_PAGER_WITH_DESC_BELOW                  = 9
    case TWO_ROW_SQR_WITH_DESC_BELOW                = 10
    case CIRCULAR_WITH_DESC_BELOW                   = 11
    case REC_PAGER_WITH_DESC_INSIDE                 = 12
   // case TWO_ROW_REC_DESC_BELOW                     = 13
  //  case TEASER                                     = 14
    case PATCH_DESC_TOP_WITH_REC_PORT_DESC_BELOW    = 15
    case SINGLE_LINE_WITH_DESCRIPTION               = 16
    case SQR_WITH_DESC_BELOW                        = 17
    case SQR                                        = -3 // missing in cms
    case TICKET                                     = -5
    case AI_PLAYLIST                                = 18
    case UNKNOWN                                    = -1
    
}

protocol HomeAdapterProtocol : NSObjectProtocol{
    // Read-write property
    var parentCollectionView: UICollectionView? {get set}
    var homeAdapter: HomeAdapter? { get set }
    var homeVM: HomeVM? {get set}
    func loadMorePatchs()
    func onScroll(y: Double)
    func onItemClicked(patch: HomePatch, content: CommonContentProtocol)
    func getNavController() -> UINavigationController
    func particapetClick(payment : PaymentMethod)
    func seeAllClick(patch : HomePatch)
    func onSubscription()
    func navigateToAIGeneratedContent(content: AIPlaylistResponseModel?, imageUrl: String, playlistName: String, playlistId: String)
    func reloadView(indexPath: IndexPath)
    func refreshHome()
}

class HomeAdapter: NSObject {

    private var delegate : HomeAdapterProtocol
    private var dataSource : [HomePatch] = []
    var aiPlaylists: [NewContent]?
    private var weekTenDataSourse : [CommonContentProtocol] = []
    private var recentPlayList : [CommonContentProtocol] {
        do{
            return try RecentlyPlayedDatabase.instance.getDataFromDatabase(fetchLimit: 10)
        }catch{
            Log.error(error.localizedDescription)
        }
        return []
        
    }
    private var downloadList : [CommonContentProtocol] {
        return DatabaseContext.shared.getRecentlyDownloadList()
    }
    
    private var streamNwinCampaignResponse : StreamNwinCampaignResponse?
  //  private var concertEventObj : ConcertEventObj?
    private var rewindData : [TopStreammingElementModel] = []
    
    var lastContentOffset = SCREEN_SAFE_TOP + 56
    var page : Int = 0
    init(delegate: HomeAdapterProtocol) {
        self.delegate = delegate
        super.init()
    }
    func reset(){
        dataSource.removeAll()
        page = 0
    }
    func addPatches(array: [HomePatch]){
        dataSource.append(contentsOf: array)
        dataSource = dataSource.sorted(by: {$0.sort < $1.sort})
        page = page + 1
        debugPrint("page : ",page)
    }
    func addStreamNwin(stream : StreamNwinCampaignResponse){
        self.streamNwinCampaignResponse = stream
    }
//    func addTicket(ticket : ConcertEventObj){
//        self.concertEventObj = ticket
//    }
    func addRewind(rewind : [TopStreammingElementModel]){
        self.rewindData = rewind
    }
//    private func getAdsCount() -> Int{
//        if !NativeAdLoader.shared(delegate.getNavController()).isReadyToLoadAd{
//            return 0
//        }
//        return ShadhinCore.instance.isUserPro ?  0 : dataSource.count / 3
//    }
    
    private func isIndexOfAnAd(index : Int) -> Bool{
        if ShadhinCore.instance.isUserPro{
            return false
        }
        let n = ((Double(index) + 1.0) / 4.0) - Double(getMultiplier(index: index+1))
        return (index > 2) && (n == 0)
    }
    
    private func getMultiplier(index: Int) -> Int{
        let n = (Double(index) - 3) / 4.0
        return Int((floor(n) + 1))
    }
    
    private func getAdsAdjustedIndex(index: Int) -> Int{
        if ShadhinCore.instance.isUserPro{
            return index
        }
        let n = getMultiplier(index: index)
        let adjustedIndex = n > 0 ? index - n : index
        return adjustedIndex
    }
}

extension HomeAdapter : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        let patchType = dataSource[index].getDesign()
        let obj = dataSource[index]
        switch patchType{
        case .BILLBOARD:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Billboard.identifier, for: indexPath) as? Billboard else{
                fatalError()
            }
            cell.configureCell(patch: obj)
            cell.onClick = {[weak self ] item in
                guard let self = self else {return}
                Log.info("\(item)")
                self.delegate.onItemClicked(patch: obj, content: item)
            }
            return cell
        case .TWO_ROW_SQR_WITH_DESC_LEFT:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TwoRowSqrWithDescLeft.identifier, for: indexPath) as? TwoRowSqrWithDescLeft else{
                fatalError()
            }
            cell.bind(with: obj)
            cell.onItemClick = {[weak self ] item in
                guard let self = self else {return}
                self.delegate.onItemClicked(patch: obj, content: item)
            }
            cell.onSeeAllClick = {[weak self] in
                guard let self = self else {return}
                self.delegate.seeAllClick(patch: obj)
            }
            return cell
        case .CIRCULAR_WITH_FAV_BTN:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CircularWithFavBtn.identifier, for: indexPath) as? CircularWithFavBtn else{
                fatalError()
            }
            cell.bind(title: obj.title ?? "", data: obj.contents,isSeeAll: obj.isSeeAllActive ?? false)
            
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate.onItemClicked(patch: obj, content: content)
            }
            cell.onFollow = {[weak self] content in
                guard let self = self else {return}
            }
            cell.onSeeAllClick = {[weak self] in
                guard let self = self else {return}
                self.delegate.seeAllClick(patch: obj)
            }
            return cell
            
        case .RECENTLY_PLAYED:
            if ShadhinCore.instance.isUserLoggedIn{
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentlyPlayerCell.identifier, for: indexPath) as? RecentlyPlayerCell else {
                    fatalError()
                }
                cell.bind(with: obj.title ?? "", dataSource: self.recentPlayList, isSeeAll: obj.isSeeAllActive ?? false)
                cell.onItemClick = {[weak self] content in
                    guard let self = self else {return}
                    self.delegate.onItemClicked(patch: obj, content: content)
                }
                cell.onSeeAllClick = {[weak self] in
                    guard let self = self else {return}
                    self.delegate.seeAllClick(patch: obj)
                }
                return cell
            }
            return  collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
            
        case .DOWNLOADED:
            if !ShadhinCore.instance.isUserPro || downloadList.isEmpty{
                return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
            }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DownloadsHomeCell.identifier, for: indexPath) as? DownloadsHomeCell else {fatalError()}
            cell.bind(with: obj.title ?? "", subtitle: obj.description ?? "", dataSource: downloadList, isSeeAll: obj.isSeeAllActive ?? false)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate.onItemClicked(patch: obj, content: content)
            }
            cell.onSeeAll = { [weak self] in
                guard let self = self else {return}
                self.delegate.seeAllClick(patch: obj)
                
            }
            return cell
        case .TWO_ROW_SQR:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TwoRowSqr.identifier, for: indexPath) as? TwoRowSqr else{
                fatalError()
            }
            
            cell.bind(with: obj)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate.onItemClicked(patch: obj, content: content)
            }
            cell.onSeeAllClick = { [weak self] in
                guard let self = self else {return}
                self.delegate.seeAllClick(patch: obj)
                
            }
            return cell
        case .PATCH_DESC_TOP_WITH_SQR_DESC_BELOW:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PatchDescTopWithSqrDescBelow.identifier, for: indexPath) as? PatchDescTopWithSqrDescBelow else{
                fatalError()
            }
            cell.bind(with: obj)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate.onItemClicked(patch: obj, content: content)
            }
            
            return cell
//        case .SQR_PAGER_WITH_DESC_BELOW:
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SqrPagerWithDescBelow.identifier, for: indexPath) as? SqrPagerWithDescBelow else{
//                fatalError()
//            }
//            cell.bind(with: obj.contents)
//            cell.onItemClick = {[weak self] content in
//                guard let self = self else {return}
//                self.delegate.onItemClicked(patch: obj, content: content)
//            }
//            cell.seeAllClick = {[weak self] in
//                guard let self = self else {return}
//                self.delegate.seeAllClick(patch: obj)
//            }
//            return cell
        case .TWO_ROW_SQR_WITH_DESC_BELOW:
guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TwoRowSqrWithDescBelow.identifier, for: indexPath) as? TwoRowSqrWithDescBelow else{
                fatalError()
            }
            cell.bind(with: obj.title ?? "", dataSource: obj.contents)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate.onItemClicked(patch: obj, content: content)
            }
            cell.onSeeAll = {[weak self] in
                guard let self = self else {return}
                self.delegate.seeAllClick(patch: obj)
            }
            return cell
        case .CIRCULAR_WITH_DESC_BELOW:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CircularWithDescBelow.identifier, for: indexPath) as? CircularWithDescBelow else{
                fatalError()
            }
            cell.bind(with: obj.title ?? "", obj.contents,isSeeAll: obj.isSeeAllActive ?? false)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate.onItemClicked(patch: obj, content: content)
            }
            cell.onSeeAll = {[weak self] in
                guard let self = self else {return}
                self.delegate.seeAllClick(patch: obj)
            }
            return cell
        case .SINGLE_LINE_WITH_DESCRIPTION:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SqrWithDescBelow.identifier, for: indexPath) as? SqrWithDescBelow else{
                fatalError()
            }
            cell.bind(with: obj)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate.onItemClicked(patch: obj, content: content)
            }
            cell.onSeeAll = {[weak self] in
                guard let self = self else {return}
                self.delegate.seeAllClick(patch: obj)
            }
            return cell
        case .SQR_WITH_DESC_BELOW:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleImageItemCell.identifier, for: indexPath) as? SingleImageItemCell else{
                fatalError()
            }
            cell.bind(with: obj)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate.onItemClicked(patch: obj, content: content)
            }
            cell.onSeeAll = {[weak self] in
                guard let self = self else {return}
                self.delegate.seeAllClick(patch: obj)
            }
            return cell
        case .REC_PAGER_WITH_DESC_INSIDE:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecPagerWithDescInside.identifier, for: indexPath) as? RecPagerWithDescInside else{
                fatalError()
            }
            cell.bind(with: obj.contents)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate.onItemClicked(patch: obj, content: content)
            }
            return cell
//        case .TWO_ROW_REC_DESC_BELOW:
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TwoRowRecDescBelow.identifier, for: indexPath) as? TwoRowRecDescBelow else{
//                fatalError()
//            }
//            cell.configureCell(with: dataSource[index])
//            cell.onItemClick = {[weak self] content in
//                guard let self = self else {return}
//                self.delegate.onItemClicked(patch: obj, content: content)
//            }
//            cell.onSeeAll = {[weak self] in
//                guard let self = self else {return}
//                self.delegate.seeAllClick(patch: obj)
//            }
//            return cell
//        case .TEASER:
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Teaser.identifier, for: indexPath) as? Teaser else{
//                fatalError()
//            }
//            if let content = obj.contents.first{
//                cell.bind(with: content)
//            }
//            cell.onPaidContent = delegate.onSubscription
//            
//            return cell
        case .PATCH_DESC_TOP_WITH_REC_PORT_DESC_BELOW:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PatchDescTopWithRecPortDescBelow.identifier, for: indexPath) as? PatchDescTopWithRecPortDescBelow else{
                fatalError()
            }
            cell.bind(with: obj)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate.onItemClicked(patch: obj, content: content)
            }
            cell.onSeeAll = {[weak self] in
                guard let self = self else {return}
                self.delegate.seeAllClick(patch: obj)
            }
            return cell
        case .SINGLE_ITEM_WITH_SEE_ALL:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleItemWithSeeAll.identifier, for: indexPath) as? SingleItemWithSeeAll else{
                fatalError()
            }
            cell.bind(with: obj.contents)
            
            cell.onSeeAll = {[weak self] in
                guard let self = self else {return}
                self.delegate.seeAllClick(patch: obj)
            }
            return cell
        case .SQR:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
        case .UNKNOWN:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
 
//        case .WIN_AND_STREAM:
//            guard let stream = streamNwinCampaignResponse else {
//                return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
//            }
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StreamNwinCollectionCell.identifier, for: indexPath) as? StreamNwinCollectionCell else {
//                fatalError()
//            }
//            cell.onParticipant  = {[weak self] paymentMethods in
//                guard let self = self else {return}
//                self.delegate.particapetClick(payment: paymentMethods)
//
//            }
//            cell.gotoLeaderboard = {[weak self] camapign in
//                guard let self = self else {return}
//                self.delegate.gotoLeaderBoard(method: camapign, campaignType: self.streamNwinCampaignResponse?.name ?? "Stream_N_Win")
//            }
//
//            if let data = stream.data.first?.paymentMethods {
//                cell.bind(with: data)
//            }
//            return cell
        case .TICKET:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
        case .AI_PLAYLIST :
            if let aiPlaylists {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AIPlaylistItemCell.identifier, for: indexPath) as? AIPlaylistItemCell else {
                    fatalError()
                }
                cell.vc = delegate
                cell.aiPlaylists = aiPlaylists
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AIPlayList.identifier, for: indexPath) as? AIPlayList else {
                    fatalError()
                }
                cell.vc = delegate
                return cell
            }
            
           
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row >= collectionView.numberOfItems(inSection: 0) - 2{
            delegate.loadMorePatchs()
        }
        if let cell = cell as? Teaser{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute:{
                cell.startVideo()
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? Teaser, !cell.isFullScreenTapped {
            cell.clearPlayer()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let index = indexPath.item
        let patchType = dataSource[index].getDesign()
        let width = SCREEN_WIDTH - 32
        switch patchType{
        case .BILLBOARD:
            return .init(width: width, height: Billboard.height)
        case .TWO_ROW_SQR_WITH_DESC_LEFT:
            return .init(width: width, height: TwoRowSqrWithDescLeft.height)
        case .SINGLE_ITEM_WITH_SEE_ALL:
            return .init(width: width, height:SingleItemWithSeeAll.height)
        case .CIRCULAR_WITH_FAV_BTN:
            return .init(width: width, height: CircularWithFavBtn.height)
        case .RECENTLY_PLAYED:
            if ShadhinCore.instance.isUserLoggedIn && !recentPlayList.isEmpty{
                return .init(width: width, height: RecentlyPlayerCell.height)
            }
            return .zero
        case .DOWNLOADED:
            if ShadhinCore.instance.isUserPro && !downloadList.isEmpty{
                return .init(width: width, height: DownloadsHomeCell.height)
            }
            return .zero
        case .TWO_ROW_SQR:
            return .init(width: width, height: TwoRowSqr.height)
        case .PATCH_DESC_TOP_WITH_SQR_DESC_BELOW:
            return .init(width: width, height: PatchDescTopWithSqrDescBelow.height)
//        case .SQR_PAGER_WITH_DESC_BELOW:
//            return .init(width: width, height: SqrPagerWithDescBelow.height)
        case .TWO_ROW_SQR_WITH_DESC_BELOW:
            return .init(width: width, height: TwoRowSqrWithDescBelow.height)
        case .CIRCULAR_WITH_DESC_BELOW:
            return .init(width: width, height: CircularWithDescBelow.height)
        case .SINGLE_LINE_WITH_DESCRIPTION:
            return .init(width: width, height: SqrWithDescBelow.height)
        case .SQR_WITH_DESC_BELOW:
            return .init(width: width, height: SingleImageItemCell.height)
        case .REC_PAGER_WITH_DESC_INSIDE:
            return .init(width: width, height: RecPagerWithDescInside.height)
//        case .TWO_ROW_REC_DESC_BELOW:
//            return .init(width: width, height: TwoRowRecDescBelow.height)
//        case .TEASER:
//            return .init(width: width, height: Teaser.height)
        case .PATCH_DESC_TOP_WITH_REC_PORT_DESC_BELOW:
            let obj = dataSource[index]
            if obj.description == nil{
                return .init(width: width, height: PatchDescTopWithRecPortDescBelow.height - 30)
            }
            return .init(width: width, height: PatchDescTopWithRecPortDescBelow.height)
        case .SQR:
            return .zero
//        case .WIN_AND_STREAM:
//            guard let stream = streamNwinCampaignResponse else {
//                return .zero
//            }
//            let subCellHeight : CGFloat = stream.data.first?.paymentMethods.count == 1 ? 80 : 144
//            let h = width + subCellHeight + 32.0
//            return .init(width: width, height: h)
        case .UNKNOWN:
            return .zero
        case .TICKET:
            return .zero
        case .AI_PLAYLIST :
            let aspectRatio = 328.0/220.0
            let h  = (SCREEN_WIDTH - 16)/aspectRatio + 10
            return .init(width: width, height: h)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: SCREEN_SAFE_TOP + 56 + 16, left: 16, bottom: 16, right: 16)
    }
    
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 ||  scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height{
            return
        }
        let deltaY =  scrollView.contentOffset.y - lastContentOffset
        lastContentOffset = scrollView.contentOffset.y
        delegate.onScroll(y: deltaY)
    }

    
}
