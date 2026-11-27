# Native launch appearance

`LaunchScreen.storyboard` uses `LaunchImage` and `LaunchBackground`. Both asset catalogs supply Any and Dark appearances, selected by the device system setting. Keep all three image scales for both appearances. The scene background uses the same dynamic color during the handoff to Flutter.

The native launch screen follows the system. After the first Flutter frame, the saved app theme applies; selecting System in Marker keeps both appearances aligned.
