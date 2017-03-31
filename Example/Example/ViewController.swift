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
            startHour: 0,
            endHour: 0
        )
        self.view.addSubview(bedtimeClockView)


        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0, execute: {

//            bedtimeClockView.dayRotation = 200

        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

