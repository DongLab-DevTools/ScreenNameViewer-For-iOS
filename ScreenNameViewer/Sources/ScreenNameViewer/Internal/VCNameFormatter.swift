#if DEBUG
import UIKit

/// Turns a `UIViewController` instance into a name suitable for display in
/// the overlay. The contract is: every name shown must be a symbol the
/// developer can grep for in their own codebase. If the controller's class is
/// a framework base class whose name would not lead anywhere useful (e.g.
/// `UIHostingController<...>`), this returns `nil` and the vc label is
/// hidden — at which point the SwiftUI `.trackScreenName(...)` modifier is
/// expected to provide a meaningful route name instead.
enum VCNameFormatter {

    private static let frameworkBaseClasses: Set<String> = [
        "UIViewController",
        "UINavigationController",
        "UITabBarController",
        "UISplitViewController",
        "UIPageViewController",
        "UIHostingController",
        "UIAlertController",
        "UIActivityViewController",
        "UIDocumentPickerViewController",
        "UIImagePickerController",
        "UISearchController",
    ]

    static func displayName(for vc: UIViewController) -> String? {
        var name = String(describing: type(of: vc))

        // `UIHostingController<NavigationStack<…>>` → `UIHostingController`
        if let lt = name.firstIndex(of: "<") {
            name = String(name[..<lt])
        }

        // `MyApp.HomeViewController` → `HomeViewController`
        if let dot = name.lastIndex(of: ".") {
            name = String(name[name.index(after: dot)...])
        }

        if name.isEmpty || frameworkBaseClasses.contains(name) {
            return nil
        }
        return name
    }
}
#endif
