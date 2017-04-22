//
//  BedtimeClockView.swift
//  BedtimeClockView
//
//  Created by Leonardo Cardoso on 27/03/2017.
//  Copyright © 2017 leocardz.com. All rights reserved.
//

import UIKit

fileprivate enum ResizingBehavior: Int {

    case aspectFit
    case aspectFill
    case stretch
    case center

    public func apply(rect: CGRect, target: CGRect) -> CGRect {

        if rect == target || target == CGRect.zero { return rect }

        var scales = CGSize.zero
        scales.width = abs(target.width / rect.width)
        scales.height = abs(target.height / rect.height)

        switch self {
        case .aspectFit:

            scales.width = min(scales.width, scales.height)
            scales.height = scales.width

        case .aspectFill:

            scales.width = max(scales.width, scales.height)
            scales.height = scales.width

        case .stretch:

            break

        case .center:

            scales.width = 1
            scales.height = 1

        }

        var result = rect.standardized
        result.size.width *= scales.width
        result.size.height *= scales.height
        result.origin.x = target.minX + (target.width - result.width) / 2
        result.origin.y = target.minY + (target.height - result.height) / 2

        return result

    }
}

public class BedtimeClockView: UIView {

    // MARK: - Accessible properties
    var observer: (String, String, Int) -> (Void) = { _, _, _ in } { didSet { updateLayout() } }
    var isEnabled: Bool = true {
        didSet {

            if isEnabled == false {

                isAnimatingWake = false
                isAnimatingSleep = false
                isAnimatingTrack = false

            }

        }

    }

    // MARK: - Paths
    private var wakePointPath: UIBezierPath?
    private var sleepPointPath: UIBezierPath?
    private var trackBackgroundPath: UIBezierPath?

    // MARK: - Position properties
    private let pointersY: CGFloat = 50
    private let pointers2Y: CGFloat = -54
    private let pointers3Y: CGFloat = 51
    private let pointers4Y: CGFloat = -55
    private let pointer6Y: CGFloat = 51
    private let pointer12Y: CGFloat = -54
    private let rotation: CGFloat = 0

    // MARK: - Properties
    private var isAnimatingWake: Bool = false
    private var isAnimatingSleep: Bool = false
    private var isAnimatingTrack: Bool = false

    // MARK: - Position variable properties
    private var dayRotation: CGFloat = 0 { didSet { updateLayout() } }
    private var nightRotation: CGFloat = 0 { didSet { updateLayout() } }

    // MARK: - Layout properties
    private let stateCircleDimension: CGFloat = 18
    private let hourPointerWidth: CGFloat = 1
    private let hourPointerHeight: CGFloat = 3
    private let minutePointerWidth: CGFloat = 0.5

    // MARK: - Color properties
    private var trackBackgroundColor = UIColor(red: 0.087, green: 0.088, blue: 0.087, alpha: 1.000)
    private var centerBackgroundColor = UIColor(red: 0.049, green: 0.049, blue: 0.049, alpha: 1.000)
    private var wakeBackgroundColor = UIColor(red: 0.049, green: 0.049, blue: 0.049, alpha: 1.000)
    private var wakeColor = UIColor(red: 0.976, green: 0.645, blue: 0.068, alpha: 1.000)
    private var sleepBackgroundColor = UIColor(red: 0.049, green: 0.049, blue: 0.049, alpha: 1.000)
    private var sleepColor = UIColor(red: 0.976, green: 0.645, blue: 0.068, alpha: 1.000)
    private var trackStartColor = UIColor(red: 0.976, green: 0.645, blue: 0.068, alpha: 1.000)
    private var trackEndColor: UIColor { return trackStartColor }
    private var numberColor = UIColor(red: 0.557, green: 0.554, blue: 0.576, alpha: 1.000)
    private var thickPointerColor = UIColor(red: 0.557, green: 0.554, blue: 0.576, alpha: 1.000)
    private var thinPointerColor = UIColor(red: 0.329, green: 0.329, blue: 0.329, alpha: 1.000)
    private var centerLabelColor = UIColor.white

    // MARK: - Fixed properties
    private let minutesPerHour: CGFloat = 60
    private let degreesPerHour: CGFloat = 30
    private let minutesInTwoHours: CGFloat = 720
    private let degreesInCircle: CGFloat = 360

    private let watchDimension = CGRect(x: -74.28, y: -74.28, width: 148.5, height: 148.5)

    private var angle: CGFloat { return -minutesInTwoHours * rotation }

    private var dayRotationModulus: CGFloat { return fmod(dayRotation, minutesInTwoHours) }
    private var nightRotationModulus: CGFloat { return fmod(nightRotation, minutesInTwoHours) }

    private var trackEndAngle: CGFloat { return abs(dayRotationModulus + 540) }
    private var trackStartAngle: CGFloat { return nightRotationModulus }
    private var fixedTrackBackgroundColor: UIColor { return equalPositionInCircle ? trackStartColor : trackBackgroundColor }

    private var startPosition: CGFloat { return fmod((minutesInTwoHours - fmod((180 + dayRotationModulus), minutesInTwoHours)), minutesInTwoHours) }
    private var endPosition: CGFloat { return fmod((minutesInTwoHours - nightRotationModulus), minutesInTwoHours) }

    private var startPositionHour: CGFloat { return floor(startPosition / degreesPerHour) }
    private var endPositionHour: CGFloat { return floor(endPosition / degreesPerHour) }

    private var startPositionMinute: CGFloat { return floor(fmod(floor(startPosition), degreesPerHour) * 2 / 5.0) * 5 }
    private var endPositionMinute: CGFloat { return ceil(fmod(floor(endPosition), degreesPerHour) * 2 / 5.0) * 5 }

    private var startInMinutes: CGFloat { return startPositionHour * minutesPerHour + startPositionMinute }
    private var endInMinutes: CGFloat { return endPositionHour * minutesPerHour + endPositionMinute }

    private var dayFrameAngle: CGFloat { return dayRotation - 27 }
    private var nightFrameAngle: CGFloat { return nightRotation + 210 }

    private var dayIconAngle: CGFloat { return -(dayRotation + 64.5) }
    private var nightIconAngle: CGFloat { return -(nightRotation + 220) }

    private var difference: CGFloat { return endInMinutes > startInMinutes ? 1440 - endInMinutes + startInMinutes : abs(endInMinutes - startInMinutes) }

    private var minuteDifference: CGFloat { return fmod(difference, minutesPerHour) }
    private var hourDifference: CGFloat { return startPosition == endPosition ? 0 : floor(fmod(difference / minutesPerHour, minutesPerHour)) }
    private var sleepHour: String { return "\(String(format: "%02d", Int(endInMinutes / minutesPerHour))):\(String(format: "%02d", Int(fmod(endInMinutes, minutesPerHour))))" }
    private var wakeHour: String { return "\(String(format: "%02d", Int(startInMinutes / minutesPerHour))):\(String(format: "%02d", Int(fmod(startInMinutes, minutesPerHour))))" }

    private var timeDifference: String {

        return (hourDifference > 0 ? "\(Int(round(hourDifference)))" + "h " :
            (minuteDifference > 0 ? "" : "24h")) + (minuteDifference > 0 ? "\(Int(round(minuteDifference)))" + "min" : "")

    }

    private var equalPositionInCircle: Bool { return fmod(startPosition, degreesInCircle) == fmod(endPosition, degreesInCircle) }

    // MARK: - Properties
    var context: CGContext?
    var targetFrame: CGRect = .zero

    init(frame: CGRect, sleepTimeInMinutes: TimeInterval = 0, wakeTimeInMinutes: TimeInterval = 480) {

        if sleepTimeInMinutes < 0 || sleepTimeInMinutes > 1440 { fatalError("sleepTimeInMinutes must be between 0 and 1440, which is 24:00.") }
        if wakeTimeInMinutes < 0 || wakeTimeInMinutes > 1440 { fatalError("wakeTimeInMinutes must be between 0 and 1440, which is 24:00.") }

        super.init(frame: frame)

        nightRotation = calculateNightRotation(CGFloat(sleepTimeInMinutes))
        dayRotation = calculateDayRotation(CGFloat(wakeTimeInMinutes))

        targetFrame = frame

        backgroundColor = .clear

        setNeedsDisplay()

    }

    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func draw(_ rect: CGRect) { drawActivity() }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        super.touchesBegan(touches, with: event)

        if isEnabled {

            guard let touch = touches.first else { return }

            let location = touch.location(in: self)

            let degrees = calculateDegrees(by: location, counterclockwise: false)
            var degreesInMinutes = calculateFullTimeFromDegrees(degrees)

            let startInMinutes = fmod(self.startInMinutes, minutesInTwoHours)
            let endInMinutes = fmod(self.endInMinutes, minutesInTwoHours)

            if degreesInMinutes >= 700 { degreesInMinutes = degreesInMinutes - minutesInTwoHours }

            isAnimatingSleep = endInMinutes - self.frame.width / 20 <= degreesInMinutes && endInMinutes + 20 >= degreesInMinutes
            if !isAnimatingSleep { isAnimatingWake = startInMinutes - 20 <= degreesInMinutes && startInMinutes + 20 >= degreesInMinutes }
            else if !isAnimatingWake {

                // calculate clicked time and check if it's > sleep and < wake

                /* isAnimatingTrack = true */

            }

        }

    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        super.touchesMoved(touches, with: event)

        guard let touch = touches.first else { return }

        let degrees = calculateDegrees(by: touch.location(in: self), counterclockwise: false)
        let degreesInMinutes = calculateFullTimeFromDegrees(degrees)

        if isAnimatingSleep { nightRotation = calculateNightRotation(degreesInMinutes) }
        if isAnimatingWake { dayRotation = calculateDayRotation(degreesInMinutes) }

        updateLayout()

    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        super.touchesEnded(touches, with: event)

        isAnimatingWake = false
        isAnimatingSleep = false
        isAnimatingTrack = false

    }

    // MARK: - Functions
    private func calculateFullTimeFromDegrees(_ degrees: CGFloat) -> CGFloat {

        let degreesHours = floor(degrees / degreesPerHour)
        let degreesMinutes = floor(fmod(floor(degrees), degreesPerHour) * 2 / 5.0) * 5
        return degreesHours * minutesPerHour + degreesMinutes

    }

    private func calculateNightRotation(_ number: CGFloat) -> CGFloat {

        let modNight = fmod(number, 10)
        return CGFloat(minutesInTwoHours - (modNight > 5 ? ceil(number / 2) : floor(number / 2)))

    }

    private func calculateDayRotation(_ number: CGFloat) -> CGFloat {

        let modDay = fmod(number, 10)
        return CGFloat(540 - (modDay > 5 ? floor(number / 2) : ceil(number / 2)))

    }

    private func calculateDegrees(by location: CGPoint, counterclockwise: Bool) -> CGFloat {

        let diffX = location.x - self.frame.width / 2
        let diffY = location.y - self.frame.height / 2
        let radians = counterclockwise ? atan2(diffY, diffX) : atan2(-diffX, -diffY) // clockwise and shift 90 degrees from left to right

        let degrees = radians.degrees

        return abs(-degrees < 0 ? degreesInCircle - degrees : -degrees)

    }

    private func drawActivity(resizing: ResizingBehavior = .aspectFill) {

        // General Declarations
        if context == nil { context = UIGraphicsGetCurrentContext() }

        if let context: CGContext = context {

            // Resize to target frame
            context.saveGState()
            let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 156, height: 195), target: targetFrame)
            context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
            context.scaleBy(x: resizedFrame.width / 156, y: resizedFrame.height / 195)

            drawForms()

            restoreState(times: 2)

            drawWakePoint()

            restoreState()

            drawBellPath()

            restoreState(times: 2)

            drawSleepPoint()

            drawStarsPath()

            drawMoonPath()

            restoreState(times: 4)

            drawHourPointers()

            restoreState(times: 3)

            drawMinutePointers()

            restoreState(times: 3)

            drawNumbers()

            drawCenterLabel()

        }

    }

    private func updateLayout() {

        setNeedsDisplay()

        observer(sleepHour, wakeHour, Int(difference))

    }

    // MARK: - Drawing functions
    private func drawCenterLabel() {

        let durationRect: CGRect = CGRect(x: 44, y: 82, width: 69, height: degreesPerHour)
        let durationStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        durationStyle.alignment = .center

        let durationFontAttributes: [String : Any] = [
            NSFontAttributeName: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize, weight: UIFontWeightLight),
            NSForegroundColorAttributeName: centerLabelColor,
            NSParagraphStyleAttributeName: durationStyle
        ]

        let durationTextHeight: CGFloat = timeDifference.boundingRect(
            with: CGSize(width: durationRect.width, height: CGFloat.infinity),
            options: .usesLineFragmentOrigin,
            attributes: durationFontAttributes,
            context: nil).height

        context?.saveGState()
        context?.clip(to: durationRect)

        timeDifference.draw(
            in: CGRect(
                x: durationRect.minX,
                y: durationRect.minY + (durationRect.height - durationTextHeight) / 2,
                width: durationRect.width,
                height: durationTextHeight
            ),
            withAttributes: durationFontAttributes
        )

        restoreState(times: 2)

    }

    private func drawNumbers() {

        context?.saveGState()
        context?.translateBy(x: 78, y: 97)
        context?.rotate(by: -360.0.radians)

        drawNumber(text: "12", position: CGPoint(x: -5, y: -47.5))

        restoreState()

        drawNumber(text: "2", position: CGPoint(x: 34, y: -26))

        restoreState()

        drawNumber(text: "3", position: CGPoint(x: 40, y: -5))

        restoreState()

        drawNumber(text: "4", position: CGPoint(x: 34, y: 16))

        restoreState()

        drawNumber(text: "5", position: CGPoint(x: 18, y: 32))

        restoreState()

        drawNumber(text: "6", position: CGPoint(x: -5, y: 39))

        restoreState()

        drawNumber(text: "7", position: CGPoint(x: -26, y: 32))

        restoreState()

        drawNumber(text: "8", position: CGPoint(x: -43, y: 16))

        restoreState()

        drawNumber(text: "9", position: CGPoint(x: -50, y: -5))

        restoreState()

        drawNumber(text: "10", position: CGPoint(x: -42, y: -26))

        restoreState()

        drawNumber(text: "1", position: CGPoint(x: 16, y: -43))

        restoreState()

        drawNumber(text: "11", position: CGPoint(x: -24, y: -43))

        restoreState(times: 2)

    }

    private func drawNumber(text: String, position: CGPoint) {

        let rect = CGRect(x: position.x, y: position.y, width: 10, height: 10)

        let style: NSMutableParagraphStyle = NSMutableParagraphStyle()
        style.alignment = .center

        let fontAttributes: [String : Any] = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 8),
            NSForegroundColorAttributeName: numberColor,
            NSParagraphStyleAttributeName: style
        ]

        let height: CGFloat = text.boundingRect(
            with: CGSize(width: rect.width, height: CGFloat.infinity),
            options: .usesLineFragmentOrigin,
            attributes: fontAttributes,
            context: nil).height

        context?.saveGState()
        context?.clip(to: rect)

        text.draw(in: CGRect(x: rect.minX, y: rect.minY + (rect.height - height) / 2, width: rect.width, height: height), withAttributes: fontAttributes)

    }

    private func drawForms() {

        // BackgroundsGroup
        context?.saveGState()
        context?.translateBy(x: 78, y: 97)
        context?.rotate(by: -90.0.radians)

        // OffsetBackground drawing
        let offsetBackgroundPath = UIBezierPath(ovalIn: watchDimension)
        fixedTrackBackgroundColor.setFill()
        offsetBackgroundPath.fill()

        // TrackBackground drawing
        context?.saveGState()
        context?.rotate(by: -angle.radians)

        let trackBackgroundRect = watchDimension
        trackBackgroundPath = UIBezierPath()
        trackBackgroundPath?.addArc(
            withCenter: CGPoint(x: trackBackgroundRect.midX, y: trackBackgroundRect.midY),
            radius: trackBackgroundRect.width / 2,
            startAngle: -trackStartAngle.radians,
            endAngle: -trackEndAngle.radians,
            clockwise: true
        )
        trackBackgroundPath?.addLine(to: CGPoint(x: trackBackgroundRect.midX, y: trackBackgroundRect.midY))
        trackBackgroundPath?.close()

        context?.saveGState()

        trackBackgroundPath?.addClip()

        let colors: CFArray = [trackStartColor.cgColor, trackEndColor.cgColor] as CFArray

        if let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: [0, 1]) {

            let sleepAngle = fmod(fmod(trackStartAngle, degreesInCircle) + 90, degreesInCircle).radians
            let wakeAngle = fmod(fmod(trackEndAngle, degreesInCircle) + 90, degreesInCircle).radians

            let radius: CGFloat = self.frame.width / 2
            let adjust: CGFloat = 0.60

            let wakeAngleX = (radius * adjust) * sin(wakeAngle)
            let wakeAngleY = (radius * adjust) * cos(wakeAngle)

            let sleepAngleX = (radius * adjust) * sin(sleepAngle)
            let sleepAngleY = (radius * adjust) * cos(sleepAngle)

            let wakePoint = CGPoint(x: wakeAngleX, y: wakeAngleY)
            let sleepPoint = CGPoint(x: sleepAngleX, y: sleepAngleY)

            context?.drawLinearGradient(gradient, start: wakePoint, end: sleepPoint, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])

        }

        context?.restoreGState()

        // TimeBackground drawing
        let timeBackgroundPath = UIBezierPath(ovalIn: CGRect(x: -55, y: -55, width: 110, height: 110))
        centerBackgroundColor.setFill()
        timeBackgroundPath.fill()
        centerBackgroundColor.setStroke()
        timeBackgroundPath.lineWidth = 1.5
        timeBackgroundPath.stroke()

    }

    private func drawStarsPath() {

        let starsPath: UIBezierPath = UIBezierPath()
        starsPath.move(to: CGPoint(x: 2.19, y: -3.11))
        starsPath.addCurve(to: CGPoint(x: 1.6, y: -3.7), controlPoint1: CGPoint(x: 2.09, y: -3.35), controlPoint2: CGPoint(x: 1.83, y: -3.61))
        starsPath.addLine(to: CGPoint(x: 1.29, y: -3.82))
        starsPath.addLine(to: CGPoint(x: 1.6, y: -3.95))
        starsPath.addCurve(to: CGPoint(x: 2.19, y: -4.53), controlPoint1: CGPoint(x: 1.83, y: -4.04), controlPoint2: CGPoint(x: 2.09, y: -4.3))
        starsPath.addLine(to: CGPoint(x: 2.31, y: -4.85))
        starsPath.addLine(to: CGPoint(x: 2.43, y: -4.53))
        starsPath.addCurve(to: CGPoint(x: 3.02, y: -3.95), controlPoint1: CGPoint(x: 2.52, y: -4.3), controlPoint2: CGPoint(x: 2.78, y: -4.04))
        starsPath.addLine(to: CGPoint(x: 3.33, y: -3.82))
        starsPath.addLine(to: CGPoint(x: 3.02, y: -3.7))
        starsPath.addCurve(to: CGPoint(x: 2.43, y: -3.11), controlPoint1: CGPoint(x: 2.78, y: -3.61), controlPoint2: CGPoint(x: 2.52, y: -3.35))
        starsPath.addLine(to: CGPoint(x: 2.31, y: -2.8))
        starsPath.addLine(to: CGPoint(x: 2.19, y: -3.11))
        starsPath.close()
        starsPath.move(to: CGPoint(x: 3.28, y: -1.27))
        starsPath.addCurve(to: CGPoint(x: 2.92, y: -1.64), controlPoint1: CGPoint(x: 3.23, y: -1.42), controlPoint2: CGPoint(x: 3.07, y: -1.58))
        starsPath.addLine(to: CGPoint(x: 2.9, y: -1.65))
        starsPath.addLine(to: CGPoint(x: 2.92, y: -1.66))
        starsPath.addCurve(to: CGPoint(x: 3.28, y: -2.02), controlPoint1: CGPoint(x: 3.06, y: -1.71), controlPoint2: CGPoint(x: 3.23, y: -1.88))
        starsPath.addLine(to: CGPoint(x: 3.29, y: -2.04))
        starsPath.addLine(to: CGPoint(x: 3.3, y: -2.02))
        starsPath.addCurve(to: CGPoint(x: 3.67, y: -1.66), controlPoint1: CGPoint(x: 3.36, y: -1.88), controlPoint2: CGPoint(x: 3.52, y: -1.71))
        starsPath.addLine(to: CGPoint(x: 3.69, y: -1.65))
        starsPath.addLine(to: CGPoint(x: 3.67, y: -1.64))
        starsPath.addCurve(to: CGPoint(x: 3.3, y: -1.27), controlPoint1: CGPoint(x: 3.52, y: -1.58), controlPoint2: CGPoint(x: 3.36, y: -1.42))
        starsPath.addLine(to: CGPoint(x: 3.29, y: -1.25))
        starsPath.addLine(to: CGPoint(x: 3.28, y: -1.27))
        starsPath.close()
        starsPath.move(to: CGPoint(x: 1.3, y: -0.14))
        starsPath.addCurve(to: CGPoint(x: 0.93, y: -0.5), controlPoint1: CGPoint(x: 1.24, y: -0.28), controlPoint2: CGPoint(x: 1.08, y: -0.45))
        starsPath.addLine(to: CGPoint(x: 0.91, y: -0.51))
        starsPath.addLine(to: CGPoint(x: 0.93, y: -0.52))
        starsPath.addCurve(to: CGPoint(x: 1.3, y: -0.89), controlPoint1: CGPoint(x: 1.08, y: -0.58), controlPoint2: CGPoint(x: 1.24, y: -0.74))
        starsPath.addLine(to: CGPoint(x: 1.31, y: -0.91))
        starsPath.addLine(to: CGPoint(x: 1.32, y: -0.89))
        starsPath.addCurve(to: CGPoint(x: 1.68, y: -0.52), controlPoint1: CGPoint(x: 1.37, y: -0.74), controlPoint2: CGPoint(x: 1.53, y: -0.58))
        starsPath.addLine(to: CGPoint(x: 1.7, y: -0.51))
        starsPath.addLine(to: CGPoint(x: 1.68, y: -0.5))
        starsPath.addCurve(to: CGPoint(x: 1.32, y: -0.14), controlPoint1: CGPoint(x: 1.54, y: -0.45), controlPoint2: CGPoint(x: 1.37, y: -0.29))
        starsPath.addLine(to: CGPoint(x: 1.31, y: -0.12))
        starsPath.addLine(to: CGPoint(x: 1.3, y: -0.14))
        starsPath.close()
        starsPath.usesEvenOddFillRule = true
        sleepColor.setFill()
        starsPath.fill()

    }

    private func drawMoonPath() {

        let moonPath: UIBezierPath = UIBezierPath()
        moonPath.move(to: CGPoint(x: -1.41, y: -4.99))
        moonPath.addCurve(to: CGPoint(x: -4.99, y: -0.12), controlPoint1: CGPoint(x: -3.48, y: -4.34), controlPoint2: CGPoint(x: -4.99, y: -2.4))
        moonPath.addCurve(to: CGPoint(x: 0.12, y: 4.99), controlPoint1: CGPoint(x: -4.99, y: 2.7), controlPoint2: CGPoint(x: -2.7, y: 4.99))
        moonPath.addCurve(to: CGPoint(x: 4.99, y: 1.41), controlPoint1: CGPoint(x: 2.4, y: 4.99), controlPoint2: CGPoint(x: 4.34, y: 3.48))
        moonPath.addCurve(to: CGPoint(x: 2.04, y: 2.49), controlPoint1: CGPoint(x: 4.2, y: 2.09), controlPoint2: CGPoint(x: 3.17, y: 2.49))
        moonPath.addCurve(to: CGPoint(x: -2.49, y: -2.04), controlPoint1: CGPoint(x: -0.46, y: 2.49), controlPoint2: CGPoint(x: -2.49, y: 0.46))
        moonPath.addCurve(to: CGPoint(x: -1.41, y: -4.99), controlPoint1: CGPoint(x: -2.49, y: -3.17), controlPoint2: CGPoint(x: -2.09, y: -4.2))
        moonPath.close()
        moonPath.usesEvenOddFillRule = true
        sleepColor.setFill()
        moonPath.fill()

    }

    private func drawBellPath() {

        context?.saveGState()
        context?.translateBy(x: -58, y: 29.5)
        context?.rotate(by: -dayIconAngle.radians)

        let bellPath: UIBezierPath = UIBezierPath()
        bellPath.move(to: CGPoint(x: 4.5, y: 3.07))
        bellPath.addCurve(to: CGPoint(x: 1.29, y: 3.9), controlPoint1: CGPoint(x: 4.5, y: 3.07), controlPoint2: CGPoint(x: 2.79, y: 3.64))
        bellPath.addCurve(to: CGPoint(x: 0, y: 5), controlPoint1: CGPoint(x: 1.19, y: 4.52), controlPoint2: CGPoint(x: 0.65, y: 5))
        bellPath.addCurve(to: CGPoint(x: -1.28, y: 3.89), controlPoint1: CGPoint(x: -0.65, y: 5), controlPoint2: CGPoint(x: -1.19, y: 4.52))
        bellPath.addCurve(to: CGPoint(x: -4.5, y: 3.08), controlPoint1: CGPoint(x: -2.79, y: 3.63), controlPoint2: CGPoint(x: -4.5, y: 3.08))
        bellPath.addCurve(to: CGPoint(x: -2.83, y: 0.56), controlPoint1: CGPoint(x: -3.9, y: 2.34), controlPoint2: CGPoint(x: -2.81, y: 1.35))
        bellPath.addLine(to: CGPoint(x: -2.88, y: -1.04))
        bellPath.addCurve(to: CGPoint(x: -0.89, y: -4.22), controlPoint1: CGPoint(x: -2.87, y: -2.58), controlPoint2: CGPoint(x: -2.34, y: -3.85))
        bellPath.addCurve(to: CGPoint(x: 0, y: -5), controlPoint1: CGPoint(x: -0.83, y: -4.66), controlPoint2: CGPoint(x: -0.45, y: -5))
        bellPath.addCurve(to: CGPoint(x: 0.89, y: -4.22), controlPoint1: CGPoint(x: 0.46, y: -5), controlPoint2: CGPoint(x: 0.84, y: -4.66))
        bellPath.addCurve(to: CGPoint(x: 2.93, y: -1.03), controlPoint1: CGPoint(x: 2.33, y: -3.86), controlPoint2: CGPoint(x: 2.91, y: -2.58))
        bellPath.addLine(to: CGPoint(x: 2.89, y: 0.56))
        bellPath.addCurve(to: CGPoint(x: 4.5, y: 3.07), controlPoint1: CGPoint(x: 2.87, y: 1.36), controlPoint2: CGPoint(x: 3.87, y: 2.39))
        bellPath.close()
        bellPath.usesEvenOddFillRule = true
        wakeColor.setFill()
        bellPath.fill()

    }

    private func drawWakePoint() {

        // TimeGroup
        context?.saveGState()
        context?.translateBy(x: 78, y: 97)
        context?.rotate(by: -90.0.radians)

        context?.saveGState()
        context?.rotate(by: -dayFrameAngle.radians)

        // WakePoint drawing
        context?.saveGState()
        context?.translateBy(x: -6.44, y: 3.28)
        context?.rotate(by: -27.0.radians)

        wakePointPath = UIBezierPath(ovalIn: CGRect(x: -66.78, y: -9, width: stateCircleDimension, height: stateCircleDimension))
        wakeBackgroundColor.setFill()
        wakePointPath?.fill()
        //        (equalPositionInCircle ? UIColor.clear : trackStartColor).setStroke()
        trackStartColor.setStroke()
        wakePointPath?.lineWidth = 0.5
        wakePointPath?.stroke()

    }

    private func drawSleepPoint() {

        context?.saveGState()
        context?.rotate(by: -(nightFrameAngle - minutesInTwoHours).radians)

        // SleepPoint drawing
        context?.saveGState()
        context?.translateBy(x: -6.25, y: -3.61)
        context?.rotate(by: -510.0.radians)

        sleepPointPath = UIBezierPath(ovalIn: CGRect(x: 48.78, y: -9, width: stateCircleDimension, height: stateCircleDimension))
        sleepBackgroundColor.setFill()
        sleepPointPath?.fill()
        //        (equalPositionInCircle ? UIColor.clear : trackEndColor).setStroke()
        trackEndColor.setStroke()
        sleepPointPath?.lineWidth = 0.5
        sleepPointPath?.stroke()

        restoreState()

        // MoonIcon
        context?.saveGState()
        context?.translateBy(x: -51.77, y: -37.47)
        context?.rotate(by: 90.0.radians)

        // Sleep
        context?.saveGState()
        context?.translateBy(x: 4.99, y: 4.99)
        context?.rotate(by: -nightIconAngle.radians)

    }

    private func drawMinutePointers() {

        // MinutePointers
        context?.saveGState()
        context?.translateBy(x: 78, y: 97)
        context?.rotate(by: -360.0.radians)

        drawMinuteGroup(group: (CGPoint(x: 0, y: 1), -7.5), pointer: (CGPoint(x: 0, y: pointers4Y), CGPoint(x: 0, y: 0)), opposite: (CGPoint(x: -0, y: pointersY), CGPoint(x: 0, y: 0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (CGPoint(x: 0, y: 1), -15), pointer: (CGPoint(x: -0, y: pointers4Y), CGPoint(x: 0, y: -0)), opposite: (CGPoint(x: -0, y: pointersY), CGPoint(x: 0, y: 0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (CGPoint(x: 0, y: 1), -22.5), pointer: (CGPoint(x: -0, y: pointers4Y), CGPoint(x: 0, y: 0)), opposite: (CGPoint(x: -0, y: pointersY), CGPoint(x: 0, y: 0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (nil, -37.5), pointer: (CGPoint(x: 0, y: pointers2Y), CGPoint(x: 0, y: 0)), opposite: (CGPoint(x: 0, y: pointers3Y), CGPoint(x: -0, y: 0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (nil, -45), pointer: (CGPoint(x: -0, y: pointers2Y), CGPoint(x: -0, y: 0)), opposite: (CGPoint(x: -0, y: pointers3Y), CGPoint(x: 0, y: 0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (nil, -52.5), pointer: (CGPoint(x: -0, y: pointers2Y), CGPoint(x: -0, y: 0)), opposite: (CGPoint(x: -0, y: pointers3Y), CGPoint(x: -0, y: 0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (nil, -97.5), pointer: (CGPoint(x: -0, y: pointers2Y), CGPoint(x: 0, y: -0)), opposite: (CGPoint(x: -0, y: pointers3Y), CGPoint(x: 0, y: -0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (nil, -105), pointer: (CGPoint(x: -0, y: pointers2Y), CGPoint(x: 0, y: -0)), opposite: (CGPoint(x: -0, y: pointers3Y), CGPoint(x: 0, y: 0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (nil, -112.5), pointer: (CGPoint(x: -0, y: pointers2Y), CGPoint(x: 0, y: 0)), opposite: (CGPoint(x: -0, y: pointers3Y), CGPoint(x: -0, y: 0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (nil, -127.5), pointer: (CGPoint(x: -0, y: pointers2Y), CGPoint(x: -0, y: -0)), opposite: (CGPoint(x: -0, y: pointers3Y), CGPoint(x: -0, y: -0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (nil, -135), pointer: (CGPoint(x: -0, y: pointers2Y), CGPoint(x: 0, y: -0)), opposite: (CGPoint(x: -0, y: pointers3Y), CGPoint(x: 0, y: -0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (nil, -142.5), pointer: (CGPoint(x: -0, y: pointers2Y), CGPoint(x: -0, y: -0)), opposite: (CGPoint(x: -0, y: pointers3Y), CGPoint(x: -0, y: -0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (CGPoint(x: 0.08, y: -0.05), -157.5), pointer: (CGPoint(x: -0, y: pointers2Y), CGPoint(x: -0, y: 0)), opposite: (CGPoint(x: -0, y: pointers3Y), CGPoint(x: -0, y: 0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (CGPoint(x: 0.08, y: -0.05), -165), pointer: (CGPoint(x: 0, y: pointers2Y), CGPoint(x: 0, y: 0)), opposite: (CGPoint(x: 0, y: pointers3Y), CGPoint(x: 0, y: -0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (CGPoint(x: 0.08, y: -0.05), -172.5), pointer: (CGPoint(x: 0, y: pointers2Y), CGPoint(x: -0, y: 0)), opposite: (CGPoint(x: 0, y: pointers3Y), CGPoint(x: -0, y: 0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (CGPoint(x: -1.05, y: -0.08), 112.5), pointer: (CGPoint(x: 0, y: pointers4Y), CGPoint(x: 0, y: 0)), opposite: (CGPoint(x: 0, y: pointersY), CGPoint(x: 0, y: 0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (CGPoint(x: -1.05, y: -0.08), 105), pointer: (CGPoint(x: 0, y: pointers4Y), CGPoint(x: 0, y: 0)), opposite: (CGPoint(x: 0, y: pointersY), CGPoint(x: 0, y: 0)))

        restoreState(times: 2)

        drawMinuteGroup(group: (CGPoint(x: -1.05, y: -0.08), 97.5), pointer: (CGPoint(x: -0, y: pointers4Y), CGPoint(x: 0, y: -0)), opposite: (CGPoint(x: 0, y: pointersY), CGPoint(x: 0, y: 0)))

    }

    private func drawMinuteGroup(group: (translate: CGPoint?, rotate: CGFloat), pointer: (translate: CGPoint, position: CGPoint), opposite: (translate: CGPoint, position: CGPoint)) {

        context?.saveGState()

        if let translate: CGPoint = group.translate { context?.translateBy(x: translate.x, y: translate.y) }
        context?.rotate(by: group.rotate.radians)

        drawMinuteWrap(translate: pointer.translate, point: pointer.position)

        restoreState()

        drawMinuteWrap(translate: opposite.translate, point: pointer.position)

    }

    private func drawMinuteWrap(translate: CGPoint, point: CGPoint) {

        context?.saveGState()
        context?.translateBy(x: translate.x, y: translate.y)

        drawMinutePointer(point)

    }

    private func drawMinutePointer(_ point: CGPoint) {

        let minutePath: UIBezierPath = UIBezierPath()
        minutePath.move(to: point)
        minutePath.addLine(to: CGPoint(x: 0, y: hourPointerHeight))
        minutePath.addLine(to: CGPoint(x: 0, y: hourPointerHeight))
        thinPointerColor.setFill()
        minutePath.fill()
        thinPointerColor.setStroke()
        minutePath.lineWidth = minutePointerWidth
        minutePath.stroke()

    }

    private func drawHourPointers() {

        context?.saveGState()
        context?.translateBy(x: 78, y: 97)
        context?.rotate(by: -360.0.radians)

        drawHourGroup(rotate: -90)

        restoreState()

        drawHourPointer(y: pointer12Y)
        drawHourPointer(y: pointer6Y)

        drawHourGroup(rotate: -degreesPerHour)
        drawHourGroup(rotate: -90)

        restoreState(times: 2)

        drawHourGroup(rotate: -60)
        drawHourGroup(rotate: -90)

    }

    private func drawHourGroup(rotate: CGFloat) {

        context?.saveGState()
        context?.rotate(by: rotate.radians)

        drawHourPointer(y: pointers2Y)
        drawHourPointer(y: pointers3Y)

    }

    private func drawHourPointer(y: CGFloat) {

        let hourPath: UIBezierPath = UIBezierPath(rect: CGRect(x: -0.5, y: y, width: hourPointerWidth, height: hourPointerHeight))
        thickPointerColor.setFill()
        hourPath.fill()
        
    }
    
    private func restoreState(times: Int = 1) { for _ in 0 ..< times { context?.restoreGState() } }
    
    public func changePalette(
        trackBackgroundColor: UIColor? = nil,
        centerBackgroundColor: UIColor? = nil,
        wakeBackgroundColor: UIColor? = nil,
        wakeColor: UIColor? = nil,
        sleepBackgroundColor: UIColor? = nil,
        sleepColor: UIColor? = nil,
        trackColor: UIColor? = nil,
        numberColor: UIColor? = nil,
        thickPointerColor: UIColor? = nil,
        thinPointerColor: UIColor? = nil,
        centerLabelColor: UIColor? = nil) {
        
        if let color = trackBackgroundColor { self.trackBackgroundColor = color }
        if let color = centerBackgroundColor { self.centerBackgroundColor = color }
        if let color = wakeBackgroundColor { self.wakeBackgroundColor = color }
        if let color = wakeColor { self.wakeColor = color }
        if let color = sleepBackgroundColor { self.sleepBackgroundColor = color }
        if let color = sleepColor { self.sleepColor = color }
        if let color = trackColor { self.trackStartColor = color }
        if let color = numberColor { self.numberColor = color }
        if let color = thickPointerColor { self.thickPointerColor = color }
        if let color = thinPointerColor { self.thinPointerColor = color }
        if let color = centerLabelColor { self.centerLabelColor = color }
        
        setNeedsDisplay()
        
    }
    
}

fileprivate extension Double { fileprivate var radians: CGFloat { return CGFloat(self) * CGFloat.pi / 180 } }
fileprivate extension CGFloat {
    
    fileprivate var degrees: CGFloat { return self * 180 / CGFloat.pi }
    fileprivate var radians: CGFloat { return self * CGFloat.pi / 180 }
    
}
