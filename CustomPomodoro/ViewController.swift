import UIKit

class ViewController: UIViewController {

    let shapeLayer = CAShapeLayer()
    let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    var timer = Timer()
    var isWorkTime = true
    var isStarted = false
    let workTimeDuration: Double = 10
    let restTimeDuration: Double = 5
    var timerDuration: Double = 10

    private lazy var button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "playIcon"), for: .normal)
        return button
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = secondsToMinutesAndSeconds(workTimeDuration)
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = .red
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)

        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 5
        trackLayer.position = view.center

        view.layer.addSublayer(trackLayer)

        shapeLayer.path = circularPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 0
        shapeLayer.lineWidth = 8
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.position = view.center
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)

        view.layer.addSublayer(shapeLayer)

        view.addSubview(label)
        view.addSubview(button)

        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 150).isActive = true
        button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -18).isActive = true
    }

    @objc private func buttonTapped() {

        timer.invalidate()

        if !isStarted {
            chooseAnimation()
            timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            isStarted = true
        } else {
            if shapeLayer.speed > 0 {
                pauseAnimation()
            } else {
                resumeAnimation()
            }
        }
    }

    private func secondsToMinutesAndSeconds(_ seconds: Double) -> String {

        let minutesInt = Int((seconds / 60).truncatingRemainder(dividingBy: 60))
        let secondsInt = Int(seconds.truncatingRemainder(dividingBy: 60))
        var result = String(minutesInt) + ":"

        if minutesInt < 10 {
            result = "0" + String(minutesInt) + ":"
        }

        if secondsInt == 0 || secondsInt < 10 {
            result += "0" + String(secondsInt)
        } else {
            result += String(secondsInt)
        }

        return result
    }

    private func chooseAnimation() {
        basicAnimation.toValue = 1
        basicAnimation.speed = 1.0
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        button.setImage(UIImage(named: "pauseIcon"), for: .normal)

        if isWorkTime {
            basicAnimation.duration = CFTimeInterval(workTimeDuration)
            timerDuration = workTimeDuration
            shapeLayer.strokeColor = UIColor.red.cgColor
            shapeLayer.add(basicAnimation, forKey: "someStroke")
            isWorkTime = false
        } else {
            basicAnimation.duration = CFTimeInterval(restTimeDuration)
            timerDuration = restTimeDuration
            shapeLayer.strokeColor = UIColor.green.cgColor
            shapeLayer.add(basicAnimation, forKey: "someStroke")
            isWorkTime = true
        }
    }

    private func pauseAnimation() {
        let pausedTime: CFTimeInterval = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)

        shapeLayer.speed = 0.0
        timer.invalidate()
        shapeLayer.timeOffset = pausedTime
        button.setImage(UIImage(named: "playIcon"), for: .normal)

    }

    private func resumeAnimation() {
        let pausedTime: CFTimeInterval = shapeLayer.timeOffset

        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0

        let timeSincePause: CFTimeInterval = shapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime

        shapeLayer.beginTime = timeSincePause
        button.setImage(UIImage(named: "pauseIcon"), for: .normal)
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        print(timer.timeInterval)
    }

    var counter = 0

    @objc private func timerAction() {
        counter += 1

        if counter == 1000 {
                timerDuration -= 1
                counter = 0
        }

        if timerDuration >= 0 {
            label.text = secondsToMinutesAndSeconds(timerDuration)
        } else {
            timer.invalidate()
            isStarted = false
            shapeLayer.removeAnimation(forKey: "someStroke")
            if isWorkTime {
                label.text = secondsToMinutesAndSeconds(workTimeDuration)
                label.textColor = .red
            } else {
                label.text = secondsToMinutesAndSeconds(restTimeDuration)
                label.textColor = .green
            }
            button.setImage(UIImage(named: "playIcon"), for: .normal)
        }
    }
}

