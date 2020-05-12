//
//  CollectionViewChatVC.swift
//  SimpleChat
//
//  Created by Manvir Singh on 06/05/20.
//  Copyright © 2020 Manvir Singh. All rights reserved.
//

import UIKit
import AVFoundation

class CollectionViewChatVC: UIViewController {
    
    var arrayChat = [Chat]()
    var imagePicker: ImagePicker!

    @IBOutlet weak var collectionView :UICollectionView!
    @IBOutlet weak var lblUserName :UILabel!
    @IBOutlet weak var imgViewUser :UIImageView!
    var oldKeyboardHeight :CGFloat = 0.0
    
    var userInfo :User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        addDummyMessages()
        setUserInfo()
        setHeaderView()
        setPickerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNoti()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    func setUserInfo(){
        
           lblUserName.text = userInfo?.name
           imgViewUser.image = userInfo?.image
        
    }
    
    func setPickerView(){
        self.imagePicker = ImagePicker(presentationController: self, delegate: self, allowEdit: true)
    }
    
    func setHeaderView(){
        let headerNib = UINib.init(nibName: "CollectionViewHeader", bundle: Bundle.main)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader")
    }
    
    //call this function if you want header view sticky
    func makeHeaderSticky(){
          let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout //
          layout?.sectionHeadersPinToVisibleBounds = true
    }
    
    func addDummyMessages(){
        
        var arrayMessages = [Messages]()
        
        for i in 0...20 {
            
            arrayMessages.append(Messages(type: .text,
                                          message: "Hey There this is the Dummy Text Message",
                                          image: nil,
                                          time: Date.randomDate(range: 5),
                                          senderID: i % 2 == 0 ? "my" : "other"))
            
            
        }
        
        let cal = Calendar.current
        
        let grouped = Dictionary(grouping: arrayMessages, by: {cal.startOfDay(for: $0.time)})
        
        grouped.forEach { (key,value) in
            
            arrayChat.append(Chat(date: key, messages: value))
            
        }
        
        arrayChat = arrayChat.sorted(by: {$0.date < $1.date})
        
        collectionView.reloadData()
        
    }
    
    
    
    //MARK: Bottom Bar Setup
    override public var inputAccessoryView: UIView? {
        get {
            return newInputContainerView//inputContainerView
        }
    }
    
    override public var canBecomeFirstResponder: Bool{
        get {
            return true
        }
    }
    
    lazy var newInputContainerView: Empty = {
        if let rootView = Bundle.main.loadNibNamed("Empty", owner: self, options: nil) {
            if let view = rootView.first as? Empty {
                view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
                view.btnSend.addTarget(self, action: #selector(btnSendAct(_:)), for: UIControl.Event.touchUpInside)
                view.btnAttachnent.addTarget(self, action: #selector(btnAttachment), for: UIControl.Event.touchUpInside)
                return view
            }
        }
        return Empty()
    }()
    
    @objc func btnSendAct(_ sender: UIButton){
        
        
        let data = Messages(type: .text,
                            message: newInputContainerView.txtView.text,
                            image: nil,
                            time: Date(),
                            senderID: "my")
        
        self.addRow(withData: data)
    }
    
    
    
    @objc func btnAttachment(_ sender: UIButton){
        
        newInputContainerView.txtView.resignFirstResponder()
        imagePicker.present(from: sender)
    }
    
    
    func addRow(withData data:Messages){
        
        guard let row = self.arrayChat.last?.messages else {return}
        self.arrayChat[self.arrayChat.count - 1].messages.append(data)
        let indexPath = IndexPath(row: row.count, section: self.arrayChat.count - 1)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.collectionView.performBatchUpdates({
            
            self.collectionView.insertItems(at: [indexPath])
            
        }) { (Finished) in
            
            self.scrollWithDelay(time: 0, indexPath: indexPath)
            AudioServicesPlaySystemSound (1004)
            self.newInputContainerView.txtView.text = ""
            self.newInputContainerView.txtView.textDidChange()
        }
        
        CATransaction.commit()
        
        
    }
    
    
    func scrollWithDelay(time :Double,indexPath:IndexPath) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            self.collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.bottom, animated: true)
        }
        
    }
    
    func registerKeyboardNoti(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrames),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
    }
    
    @objc func keyboardWillChangeFrames(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let insets = UIEdgeInsets( top: 0, left: 0, bottom: keyboardHeight, right: 0 )
            collectionView.contentInset = insets
            collectionView.scrollIndicatorInsets = insets
            let difference = keyboardHeight - oldKeyboardHeight
            if difference > 0 {
                //Helps to maintain scroll position when keyboard height change
                self.collectionView.contentOffset = CGPoint.init(x: 0, y: self.collectionView.contentOffset.y + difference)
                
            }
            
            oldKeyboardHeight = keyboardHeight
        }
        
        
    }
}


//MARK: Tableview Datasource Methods

extension CollectionViewChatVC :UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return arrayChat.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayChat[section].messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let info = arrayChat[indexPath.section].messages[indexPath.row]
        
        switch info.type {
            
        case .text:
            
            return TextCell(data: info, indexPath: indexPath)
            
        case .image:
            
            return ImageCell(data: info, indexPath: indexPath)
            
        }
        
    }
    
    
    func TextCell(data:Messages,indexPath:IndexPath)->UICollectionViewCell{
        
        if data.senderID == "my"{
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myTextMessage", for: indexPath) as? TextMessageCell {
                cell.configMyCell(data: data)
                return cell
            }
            
        }else{
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "otherTextMessage", for: indexPath) as? TextMessageCell {
                cell.configOtherCell(data: data)
                return cell
            }
            
        }
        
        
        return UICollectionViewCell()
    }
    
    func ImageCell(data:Messages,indexPath:IndexPath)->UICollectionViewCell{
        
        if data.senderID == "my"{
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myImage", for: indexPath) as? ImageMessageCell {
                cell.configMyCell(data: data)
                return cell
            }
            
        }else{
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "otherImage", for: indexPath) as? ImageMessageCell {
                cell.configMyCell(data: data)
                return cell
            }
            
        }
        
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionViewHeader", for: indexPath) as? CollectionViewHeader else {
            return CollectionViewHeader()
        }
        
        headerView.lblDate.text = "  \(dateCoveter(date: arrayChat[indexPath.section].date) ?? "")  "
        return headerView
        
    }
    
    
    func dateCoveter(date:Date) -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        if Calendar.autoupdatingCurrent.isDateInToday(date){
            return "Today"
        }else if Calendar.autoupdatingCurrent.isDateInYesterday(date){
            return "Yesterday"
        }else{
            return dateFormatter.string(from: date)
            
        }
        
    }
    
    
}


//MARK: Tableview Delegate Methods
extension CollectionViewChatVC :UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 26.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let data = arrayChat[indexPath.section].messages[indexPath.row]
        
        
        if data.type == .text {
            
            return textMessagesSize(message:data.message)
            
        }else{
            
            return CGSize(width: self.view.frame.size.width, height: 250)
        }
        
        
    }
    
    
    func textMessagesSize(message:String)->CGSize {
                
        let height = heightForTextView(text: message, font: UIFont.systemFont(ofSize: 15), width: view.frame.size.width - 110)
        
        return CGSize(width: view.frame.width, height: height + 10)
        
    }
    
    func heightForTextView(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: width, height: 0), textContainer: nil)
        textView.text = text
        textView.font = font
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.sizeToFit()
        textView.isScrollEnabled = false
        return textView.frame.height
        
        
    }
    
}

//MARK: Image Picker
extension CollectionViewChatVC :ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
       
        if let img = image {
            
            let data = Messages(type: .image,
                                message: "",
                                image: img,
                                time: Date(),
                                senderID: "my")
            
            addRow(withData: data)

        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.sendDummyImageMessage()
        }
    
        
    }
    
    
    func sendDummyImageMessage(){
        
        
        if let img = UIImage(named: "dummyUser") {
            
            let data = Messages(type: .image,
                                message: "",
                                image: img,
                                time: Date(),
                                senderID: "other")
            
            addRow(withData: data)

        }
        
        
    }
    
    
}


class TextMessageCell: UICollectionViewCell {
    
    @IBOutlet weak var txtView :UITextView!
    @IBOutlet weak var bgView :UIView!
    @IBOutlet weak var imgViewBubble :UIImageView!
    
    func configMyCell(data:Messages) {
        
        txtView.text = data.message
        guard let image = UIImage(named: "chat_bubble_sent") else { return }
        imgViewBubble.image = image
            .resizableImage(withCapInsets:
                UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),
                            resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
    }
    
    func configOtherCell(data:Messages) {
        
        txtView.text = data.message
        guard let image = UIImage(named: "chat_bubble_received") else { return }
        imgViewBubble.image = image
            .resizableImage(withCapInsets:
                UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),
                            resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
    }
    
    
}

class ImageMessageCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView :UIImageView!
    @IBOutlet weak var bgView :UIView!
    
    func configMyCell(data:Messages){
        
        imgView.image = data.image
        
    }
    
}
