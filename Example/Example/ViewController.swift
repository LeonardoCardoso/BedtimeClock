//
//  ViewController.swift
//  Example
//
//  Created by Leonardo Cardoso on 23/03/2017.
//  Copyright © 2017 leocardz.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let bedtimeClockView: BedtimeClockView = BedtimeClockView(
            frame: CGRect(x: 0, y: 0, width: 320, height: 320),
            startHour: 3600000,
            endHour: 7200
        )
        bedtimeClockView.observer = { start, end, durationInMillis in

            print(start, end, durationInMillis)

        }

        self.view.addSubview(bedtimeClockView)

//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0, execute: {
//
//            print("Called")
//            bedtimeClockView.dayRotation = 200
//            
//        })

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0, execute: {

//            print("Called 2")
            bedtimeClockView.changePalette(
                centerBackgroundColor: UIColor.white,
                centerLabelColor: UIColor.red
            )
            
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

