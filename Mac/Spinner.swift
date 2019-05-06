import AppKit

class Spinner: NSView {
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer = {
            $0.path = {
                $0.addEllipse(in: CGRect(x: 1, y: 1, width: 50, height: 50))
                return $0
            } (CGMutablePath())
            $0.fillColor = NSColor.black.cgColor
            $0.mask = {
                $0.path = {
                    $0.addEllipse(in: CGRect(x: 1, y: 1, width: 50, height: 50))
                    return $0
                } (CGMutablePath())
                return $0
            } (CAShapeLayer())
            return $0
        } (CAShapeLayer())
        wantsLayer = true
        
        layer?.addSublayer({
            $0.path = {
                $1.addArc(center: CGPoint(x: 26, y: 26), radius: 26, startAngle: 0, endAngle: 2.35619, clockwise: true)
                $0.move(to: $1.currentPoint)
                $1.addArc(center: CGPoint(x: 26, y: 26), radius: 25, startAngle: 0, endAngle: 2.35619, clockwise: true)
                $0.addLine(to: $1.currentPoint)
                return $0
            } (CGMutablePath(), CGMutablePath())
            $0.lineCap = .round
            $0.add({
                $0.duration = 0.3
                $0.repeatCount = .infinity
                $0.autoreverses = true
                $0.toValue = {
                    $1.addArc(center: CGPoint(x: 26, y: 26), radius: 26, startAngle: 0, endAngle: 2.35619, clockwise: true)
                    $0.move(to: $1.currentPoint)
                    $1.addArc(center: CGPoint(x: 26, y: 26), radius: 10, startAngle: 0, endAngle: 2.35619, clockwise: true)
                    $0.addLine(to: $1.currentPoint)
                    return $0
                } (CGMutablePath(), CGMutablePath())
                return $0
            } (CABasicAnimation(keyPath: "path")), forKey: nil)
            $0.lineWidth = 3
            $0.strokeColor = NSColor.halo.cgColor
            return $0
        } (CAShapeLayer()))
        
        layer?.addSublayer({
            $0.path = {
                $1.addArc(center: CGPoint(x: 26, y: 19), radius: 35, startAngle: 0, endAngle: 2.35619, clockwise: true)
                $0.move(to: $1.currentPoint)
                $1.addArc(center: CGPoint(x: 26, y: 19), radius: 30, startAngle: 0, endAngle: 2.35619, clockwise: true)
                $0.addLine(to: $1.currentPoint)
                return $0
            } (CGMutablePath(), CGMutablePath())
            $0.lineCap = .round
            $0.add({
                $0.duration = 0.4
                $0.repeatCount = .infinity
                $0.autoreverses = true
                $0.toValue = {
                    $1.addArc(center: CGPoint(x: 26, y: 19), radius: 35, startAngle: 0, endAngle: 2.35619, clockwise: true)
                    $0.move(to: $1.currentPoint)
                    $1.addArc(center: CGPoint(x: 26, y: 19), radius: 5, startAngle: 0, endAngle: 2.35619, clockwise: true)
                    $0.addLine(to: $1.currentPoint)
                    return $0
                } (CGMutablePath(), CGMutablePath())
                return $0
            } (CABasicAnimation(keyPath: "path")), forKey: nil)
            $0.lineWidth = 3
            $0.strokeColor = NSColor.halo.cgColor
            return $0
        } (CAShapeLayer()))
        
        layer?.addSublayer({
            $0.path = {
                $1.addArc(center: CGPoint(x: 26, y: 33), radius: 26, startAngle: 0, endAngle: 2.35619, clockwise: true)
                $0.move(to: $1.currentPoint)
                $1.addArc(center: CGPoint(x: 26, y: 33), radius: 21, startAngle: 0, endAngle: 2.35619, clockwise: true)
                $0.addLine(to: $1.currentPoint)
                return $0
            } (CGMutablePath(), CGMutablePath())
            $0.lineCap = .round
            $0.add({
                $0.duration = 0.5
                $0.repeatCount = .infinity
                $0.autoreverses = true
                $0.toValue = {
                    $1.addArc(center: CGPoint(x: 26, y: 33), radius: 26, startAngle: 0, endAngle: 2.35619, clockwise: true)
                    $0.move(to: $1.currentPoint)
                    $1.addArc(center: CGPoint(x: 26, y: 33), radius: 0, startAngle: 0, endAngle: 2.35619, clockwise: true)
                    $0.addLine(to: $1.currentPoint)
                    return $0
                } (CGMutablePath(), CGMutablePath())
                return $0
            } (CABasicAnimation(keyPath: "path")), forKey: nil)
            $0.lineWidth = 3
            $0.strokeColor = NSColor.halo.cgColor
            return $0
        } (CAShapeLayer()))
        
        widthAnchor.constraint(equalToConstant: 52).isActive = true
        heightAnchor.constraint(equalToConstant: 52).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
}
