//
//  InputViewController.swift
//  ChipInCalculator
//
//  Created by igor Kovrizhkin on 6/16/14.
//  Copyright (c) 2014 IgorKovrizhkin. All rights reserved.
//

import Foundation
import Crashlytics

import UIKit

var  isInDeleteMode  = false
var  keyboardIsShown = false

class InputViewController: UIViewController {
    @IBOutlet weak var fieldPerHour: UITextField!
    @IBOutlet weak var fieldPerson: UITextField!
    @IBOutlet weak var fieldTimeLast: UITextField!
    @IBOutlet weak var finalTextField: UILabel!
    @IBOutlet weak var segmentControl : UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func calculateButtonTap(sender: UIButton) {
        var time = NSString(string: fieldTimeLast.text)
        var cost = NSString(string: fieldPerHour.text)
        var person = NSString(string: fieldPerson.text)
        if (time.doubleValue.isZero || cost.doubleValue.isZero || person.doubleValue.isZero){
            NSLog("bad values");
            let alert = UIAlertView()
            alert.title = NSLocalizedString("Погоди", comment: "Погоди")
            alert.message = NSLocalizedString("чет с цифрами не то", comment: "чет с цифрами не то")
            alert.addButtonWithTitle(NSLocalizedString("А, ок", comment: "А, ок"))
            alert.show()
            return
        }
        
        let chipInCalc = ChipInModel(time: time.doubleValue , hourCost: cost.doubleValue)
        let amountPerPerson = chipInCalc.splitFor(person.integerValue)
        let amountPerPersonStr = NSString(format:"%.2f", amountPerPerson)
        let totalAmountStr =  NSString(format:"%.2f", chipInCalc.total)
        
        var text = String(format: NSLocalizedString("Скидываемся по %@. Всего %@", comment: "standard greeting"), arguments: [amountPerPersonStr, totalAmountStr])
        finalTextField.text = text;
    }
    
    @IBAction func didSelectSegment(sender: UISegmentedControl, forEvent event: UIEvent) {
        var selectedSegment = segmentControl.selectedSegmentIndex
        switch sender.selectedSegmentIndex {
        case 0 :
            if (!isInDeleteMode) {
                isInDeleteMode = true
                segmentControl.tintColor = UIColor.redColor()
            } else {
                isInDeleteMode = false
                segmentControl.tintColor = UIColor.whiteColor()
            }
            return;
        case sender.numberOfSegments-1 :
            addSegment();
            archiveSegments()
            archiveFields()
        break;
        default  : ()
            fieldPerHour.text = sender.titleForSegmentAtIndex(selectedSegment)
        }
        
        if (isInDeleteMode){
            segmentControl.removeSegmentAtIndex(selectedSegment, animated: true);
            segmentControl.tintColor = UIColor.whiteColor()
            delay(0.3) {
                self.segmentControl.tintColor = UIColor.whiteColor()
            }
            isInDeleteMode = false;
            archiveSegments()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        finalTextField.text = ""
        var array : NSArray = [];
        
        if let tempArray: NSArray = NSUserDefaults.standardUserDefaults().arrayForKey("keySave") {
            array = tempArray.mutableCopy() as NSMutableArray
        }
        
        if let hour = NSUserDefaults.standardUserDefaults().stringForKey("hour"){
            fieldPerHour.text = hour;
        }
        
        if let person = NSUserDefaults.standardUserDefaults().stringForKey("person"){
            fieldPerson.text = person;
        }
        
        if let timeLast = NSUserDefaults.standardUserDefaults().stringForKey("timeLast"){
            fieldTimeLast.text = timeLast;
        }
        
        if Bool(array.count){
            segmentControl.removeAllSegments();
        }
        
        let str : NSString = ""
        var i = 0
        for  str  in  array {
            segmentControl.insertSegmentWithTitle(String(str as NSString),
                atIndex: i++, animated: true)
        }
    }
    
    func addSegment() {
        segmentControl.insertSegmentWithTitle(fieldPerHour.text,
            atIndex: segmentControl.numberOfSegments-1, animated: false)
        Crashlytics.sharedInstance().setObjectValue(fieldPerHour.text, forKey: "+");
        iRate.sharedInstance().promptIfAllCriteriaMet()
    }
    
    func archiveSegments() {
        let def = NSUserDefaults.standardUserDefaults()
        var key = "keySave"
        
        var array: [NSString] = [NSString]()
        
        for var i = 0; i < segmentControl.numberOfSegments; i++ {
            array.append(segmentControl.titleForSegmentAtIndex(i)!)
        }
        
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(array, forKey: key)
        defaults.synchronize()
    }
    
    func archiveFields() {
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(fieldPerHour.text, forKey:  "hour")
        defaults.setObject(fieldPerson.text,  forKey:  "person")
        defaults.setObject(fieldTimeLast.text, forKey: "timeLast")
        defaults.synchronize()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField){
        finalTextField.text = ""
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
}