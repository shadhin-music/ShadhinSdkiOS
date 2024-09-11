//
//  TopPlayerCell.swift
//  Shadhin_BL
//
//  Created by Joy on 11/1/23.
//

import UIKit




class TopPlayerCell: UICollectionViewCell {
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.main)
    }
    static var height : CGFloat{
        return 130
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    @IBOutlet weak var dailyButton: UIButton!
    @IBOutlet weak var weeklyButton: UIButton!
    @IBOutlet weak var monthlyButton: UIButton!
    
    private var campaign : [CampaignSegment] = []
    
    var onCampaign : (CampaignSegment)-> Void = {campaign in}
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let gray = UIColor(red: 0.592, green: 0.592, blue: 0.592,alpha: 1)
        dailyButton.setBackgroundColor(color: .tintColor, forState: .selected)
        dailyButton.setBackgroundColor(color: .clear, forState: .normal)
        weeklyButton.setBackgroundColor(color: .tintColor, forState: .selected)
        weeklyButton.setBackgroundColor(color: .clear, forState: .normal)
        monthlyButton.setBackgroundColor(color: .tintColor, forState: .selected)
        monthlyButton.setBackgroundColor(color: .clear, forState: .normal)
        
        dailyButton.setTitleColor(.white, for: .selected)
        weeklyButton.setTitleColor(.white, for: .selected)
        monthlyButton.setTitleColor(.white, for: .selected)

        dailyButton.setTitleColor(.black, for: .normal)
        weeklyButton.setTitleColor(.black, for: .normal)
        monthlyButton.setTitleColor(.black, for: .normal)
        
        dailyButton.isHidden = true
        weeklyButton.isHidden = true
        monthlyButton.isHidden = true
        
        dailyButton.isSelected = true
        
        titleLabel.text = "Top 20 Player"
    }
    

    func bind(with paymentMethod : PaymentMethod){
        self.campaign = paymentMethod.campaignSegments
        for item in campaign{
            if item.name == .daily{
                dailyButton.isHidden = false
            }
            if item.name == .monthLy{
                monthlyButton.isHidden = false
            }
            if item.name == .weekly{
                weeklyButton.isHidden = false
            }
        }
        //calculate date for remming time 2023-03-30
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd"
        if let endDate = formater.date(from: paymentMethod.endDate){
            let remain = endDate - Date()
            self.endLabel.text = remain
            
        }
    }
    
    
    @IBAction func onDailyPressedd(_ sender: Any) {
        guard let daily = campaign.first(where: { $0.name == .daily }) else {return}
        dailyButton.isSelected = true
        weeklyButton.isSelected = false
        monthlyButton.isSelected = false
        onCampaign(daily)
        //titleLabel.text = "Daily Top 20 Winners"
        
    }
    @IBAction func onWeeklyPressed(_ sender: Any) {
        guard let weekly = campaign.first(where: { $0.name == .weekly }) else {return}
        dailyButton.isSelected = false
        weeklyButton.isSelected = true
        monthlyButton.isSelected = false
        
        onCampaign(weekly)
        //titleLabel.text = "Weekly Top 20 Winners"
    }
    
    @IBAction func onMonthlyPressed(_ sender: Any) {
        guard let monthly = campaign.first(where: { $0.name == .monthLy }) else {return}
        dailyButton.isSelected = false
        weeklyButton.isSelected = false
        monthlyButton.isSelected = true
        
        onCampaign(monthly)
        //titleLabel.text = "Monthly Top 20 Winners"
    }
}
extension Date {

    static func -(recent: Date, previous: Date) -> String {
        let day = Calendar.current.dateComponents([.month,.day,.hour,.minute], from: previous, to: recent)
        var time = "Ends in "
        if let month = day.month, month > 0{
            time.append("\(month) Month, ")
        }
        if let day = day.day , day > 0{
            time.append("\(day) Day\(day>1 ? "s":""), ")
        }
        if let hour = day.hour, hour > 0{
            time.append("\(hour) Hour\(hour > 1 ? "s" : ""), ")
        }
        if let minute = day.minute{
            time.append("\(minute) Minute\(minute > 1 ? "s" : "")")
        }
        return time.appending(".")
    }

}
