import UIKit

final class OrientationManager {
    static let shared = OrientationManager()
    private init() {}

    var currentMask: UIInterfaceOrientationMask = .all
}
