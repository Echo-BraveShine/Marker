import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    // Preserve the system-adaptive launch surface until Flutter paints its theme.
    let launchBackground = UIColor(named: "LaunchBackground") ?? .systemBackground
    window?.backgroundColor = launchBackground
    window?.rootViewController?.view.backgroundColor = launchBackground
    for context in connectionOptions.urlContexts {
      MarkerIncomingFiles.shared.receive(context.url)
    }
  }
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    let remaining = Set(URLContexts.filter { !MarkerIncomingFiles.shared.receive($0.url) })
    if !remaining.isEmpty { super.scene(scene, openURLContexts: remaining) }
  }
}
