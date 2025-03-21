import UIKit
import SpriteKit

// Instead of a class, define GameView as a protocol
// This allows GameViewController to conform to it
protocol GameView: AnyObject {
    func presentMainMenu()
    func presentGameScene(countryId: String?, landmarkId: String?)
    func presentLandmarkTransition(landmark: Landmark, onComplete: @escaping () -> Void)
    func presentProgressDashboard()
    func presentSettings()
}

// Provide default argument values
extension GameView {
    func presentGameScene(countryId: String? = nil, landmarkId: String? = nil) {
        presentGameScene(countryId: countryId, landmarkId: landmarkId)
    }
}
