//
//  ViewController.swift
//  Example
//
//  Created by Leonardo Cardoso on 23/03/2017.
//  Copyright © 2017 leocardz.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var active: UIView!
    @IBOutlet var wake: UILabel!
    @IBOutlet var sleep: UILabel!
    @IBOutlet var centerView: UIView!

    var bedtimeClockView: BedtimeClockView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.bedtimeClockView = BedtimeClockView(
            frame: CGRect(x: 0, y: 0, width: 320, height: 320)
        )

        self.bedtimeClockView.observer = { start, end, durationInMinutes in

            print(start, end, durationInMinutes)
            self.sleep.text = start
            self.wake.text = end

        }

        self.centerView.addSubview(self.bedtimeClockView)

    }

    @IBAction func enableBedtime(_ sender: UISwitch) {

        let disabledColor: UIColor = .darkGray

        let wakeColor: UIColor = UIColor(red: 0.976, green: 0.645, blue: 0.068, alpha: 1.000)
        let sleepColor: UIColor = UIColor(red: 0.976, green: 0.645, blue: 0.068, alpha: 1.000)
        let circleStartOriginalColor: UIColor = UIColor(red: 0.976, green: 0.645, blue: 0.068, alpha: 1.000)
        let circleEndOriginalColor: UIColor = UIColor(red: 0.976, green: 0.645, blue: 0.068, alpha: 1.000)
        let numberColor: UIColor = UIColor(red: 0.557, green: 0.554, blue: 0.576, alpha: 1.000)
        let thickPointerColor: UIColor = UIColor(red: 0.557, green: 0.554, blue: 0.576, alpha: 1.000)
        let thinPointerColor: UIColor = UIColor(red: 0.329, green: 0.329, blue: 0.329, alpha: 1.000)
        let centerLabelColor: UIColor = .white

        self.bedtimeClockView.changePalette(
            wakeColor: !sender.isOn ? disabledColor : wakeColor,
            sleepColor: !sender.isOn ? disabledColor : sleepColor,
            trackStartColor: !sender.isOn ? disabledColor : circleStartOriginalColor,
            trackEndColor: !sender.isOn ? disabledColor : circleEndOriginalColor,
            numberColor: !sender.isOn ? disabledColor : numberColor,
            thickPointerColor: !sender.isOn ? disabledColor : thickPointerColor,
            thinPointerColor: !sender.isOn ? disabledColor : thinPointerColor,
            centerLabelColor: !sender.isOn ? disabledColor : centerLabelColor
        )

    }

}

