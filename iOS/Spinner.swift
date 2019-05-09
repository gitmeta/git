import UIKit

class Spinner: UIView {
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .halo
        layer.mask = {
            $0.path = {
                $0.addEllipse(in: CGRect(x: 1, y: 1, width: 68, height: 68))
                return $0
            } (CGMutablePath())
            return $0
        } (CAShapeLayer())
        
        layer.addSublayer({
            $0.path = {
                $1.addArc(center: CGPoint(x: 35, y: 35), radius: 40, startAngle: 0, endAngle: -2.35619, clockwise: true)
                $0.move(to: $1.currentPoint)
                $1.addArc(center: CGPoint(x: 35, y: 35), radius: 30, startAngle: 0, endAngle: -2.35619, clockwise: true)
                $0.addLine(to: $1.currentPoint)
                return $0
            } (CGMutablePath(), CGMutablePath())
            $0.lineCap = .butt
            $0.add({
                $0.duration = 0.5
                $0.repeatCount = .infinity
                $0.autoreverses = true
                $0.toValue = {
                    $1.addArc(center: CGPoint(x: 35, y: 35), radius: 40, startAngle: 0, endAngle: -2.35619, clockwise: true)
                    $0.move(to: $1.currentPoint)
                    $1.addArc(center: CGPoint(x: 35, y: 35), radius: 18, startAngle: 0, endAngle: -2.35619, clockwise: true)
                    $0.addLine(to: $1.currentPoint)
                    return $0
                } (CGMutablePath(), CGMutablePath())
                return $0
            } (CABasicAnimation(keyPath: "path")), forKey: nil)
            $0.lineWidth = 4
            $0.strokeColor = UIColor.black.cgColor
            return $0
        } (CAShapeLayer()))
        
        layer.addSublayer({
            $0.path = {
                $1.addArc(center: CGPoint(x: 35, y: 47), radius: 50, startAngle: 0, endAngle: -2.35619, clockwise: true)
                $0.move(to: $1.currentPoint)
                $1.addArc(center: CGPoint(x: 35, y: 47), radius: 30, startAngle: 0, endAngle: -2.35619, clockwise: true)
                $0.addLine(to: $1.currentPoint)
                return $0
            } (CGMutablePath(), CGMutablePath())
            $0.lineCap = .butt
            $0.add({
                $0.duration = 0.6
                $0.repeatCount = .infinity
                $0.autoreverses = true
                $0.toValue = {
                    $1.addArc(center: CGPoint(x: 35, y: 47), radius: 50, startAngle: 0, endAngle: -2.35619, clockwise: true)
                    $0.move(to: $1.currentPoint)
                    $1.addArc(center: CGPoint(x: 35, y: 47), radius: 15, startAngle: 0, endAngle: -2.35619, clockwise: true)
                    $0.addLine(to: $1.currentPoint)
                    return $0
                } (CGMutablePath(), CGMutablePath())
                return $0
            } (CABasicAnimation(keyPath: "path")), forKey: nil)
            $0.lineWidth = 4
            $0.strokeColor = UIColor.black.cgColor
            return $0
        } (CAShapeLayer()))
        
        layer.addSublayer({
            $0.path = {
                $1.addArc(center: CGPoint(x: 35, y: 23), radius: 35, startAngle: 0, endAngle: -2.35619, clockwise: true)
                $0.move(to: $1.currentPoint)
                $1.addArc(center: CGPoint(x: 35, y: 23), radius: 21, startAngle: 0, endAngle: -2.35619, clockwise: true)
                $0.addLine(to: $1.currentPoint)
                return $0
            } (CGMutablePath(), CGMutablePath())
            $0.lineCap = .butt
            $0.add({
                $0.duration = 0.7
                $0.repeatCount = .infinity
                $0.autoreverses = true
                $0.toValue = {
                    $1.addArc(center: CGPoint(x: 35, y: 23), radius: 35, startAngle: 0, endAngle: -2.35619, clockwise: true)
                    $0.move(to: $1.currentPoint)
                    $1.addArc(center: CGPoint(x: 35, y: 23), radius: 0, startAngle: 0, endAngle: -2.35619, clockwise: true)
                    $0.addLine(to: $1.currentPoint)
                    return $0
                } (CGMutablePath(), CGMutablePath())
                return $0
            } (CABasicAnimation(keyPath: "path")), forKey: nil)
            $0.lineWidth = 4
            $0.strokeColor = UIColor.black.cgColor
            return $0
        } (CAShapeLayer()))
        
        widthAnchor.constraint(equalToConstant: 70).isActive = true
        heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
}
