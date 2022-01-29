import UIKit

class ViewController: UIViewController {

    let shapeLayer = CAShapeLayer()
    let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    var timer = Timer()
    var isWorkTime = true
    var isStarted = false
    let workTimeDuration = 1500
    let restTimeDuration = 300
    var timerDuration = 10

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

        let viewCenter = view.center
        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: viewCenter, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)

        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 5

        view.layer.addSublayer(trackLayer)

        shapeLayer.path = circularPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 0
        shapeLayer.lineWidth = 8
        shapeLayer.lineCap = CAShapeLayerLineCap.round

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
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            isStarted = true
        } else {
            if shapeLayer.speed > 0 {
                pauseAnimation()
            } else {
                resumeAnimation()
            }
        }
    }

    private func secondsToMinutesAndSeconds(_ seconds: Int) -> String {
        let minutesInt = (seconds / 60) % 60
        let secondsInt = seconds % 60
        var result = ""

        if secondsInt == 0 {
            result = String(minutesInt) + ":" + String(secondsInt) + "0"
        } else {
            result = String(minutesInt) + ":" + String(secondsInt)
        }

        return result
    }

    private func chooseAnimation() {
        basicAnimation.toValue = 1
        basicAnimation.speed = 0.8
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
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }

    @objc private func timerAction() {

        timerDuration -= 1

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

