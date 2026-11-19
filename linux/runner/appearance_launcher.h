#ifndef MARKER_APPEARANCE_LAUNCHER_H_
#define MARKER_APPEARANCE_LAUNCHER_H_

#include <glib.h>

// Preserve the stable desktop ID and user launcher settings. Desktop shells that
// ignore window icons can observe this user-local launcher metadata change.
inline gboolean update_launcher_icon(const gchar* directory, const gchar* executable,
                                     gboolean dark) {
  g_autofree gchar* applications = g_build_filename(g_get_user_data_dir(), "applications", nullptr);
  g_autofree gchar* launcher = g_build_filename(applications, APPLICATION_ID ".desktop", nullptr);
  g_autofree gchar* bundled = g_build_filename(directory, "share", "applications", APPLICATION_ID ".desktop", nullptr);
  g_autoptr(GKeyFile) entry = g_key_file_new();
  const auto flags = static_cast<GKeyFileFlags>(G_KEY_FILE_KEEP_COMMENTS | G_KEY_FILE_KEEP_TRANSLATIONS);
  gboolean existing = g_key_file_load_from_file(entry, launcher, flags, nullptr);
  if (!existing) {
    for (const gchar* const* data = g_get_system_data_dirs(); *data != nullptr; ++data) {
      g_autofree gchar* system_launcher = g_build_filename(*data, "applications", APPLICATION_ID ".desktop", nullptr);
      if (g_key_file_load_from_file(entry, system_launcher, flags, nullptr)) {
        existing = TRUE;
        break;
      }
    }
  }
  if (!existing && !g_key_file_load_from_file(entry, bundled, flags, nullptr)) return FALSE;

  // AppImage mounts are temporary. Keep launcher artwork in persistent user data.
  g_autofree gchar* icon_directory = g_build_filename(g_get_user_data_dir(), APPLICATION_ID, "icons", nullptr);
  g_autofree gchar* icon = g_build_filename(icon_directory, dark ? "marker-dark.png" : "marker.png", nullptr);
  g_autofree gchar* source = g_build_filename(directory, "share", "icons", "hicolor",
      "256x256", "apps", dark ? "marker-dark.png" : "marker.png", nullptr);
  g_autofree gchar* pixels = nullptr;
  gsize pixel_length = 0;
  if (g_mkdir_with_parents(icon_directory, 0755) != 0 ||
      !g_file_get_contents(source, &pixels, &pixel_length, nullptr) ||
      !g_file_set_contents(icon, pixels, pixel_length, nullptr)) return FALSE;
  g_autofree gchar* previous = g_key_file_get_string(entry, "Desktop Entry", "Icon", nullptr);
  if (g_strcmp0(previous, icon) == 0) return TRUE;
  if (!existing) {
    const gchar* appimage = g_getenv("APPIMAGE");
    const gchar* launch_executable = appimage != nullptr && g_path_is_absolute(appimage)
        ? appimage : executable;
    GString* command = g_string_new("\"");
    for (const gchar* c = launch_executable; *c != '\0'; ++c) {
      if (*c == '\\' || *c == '"' || *c == '$' || *c == '`') g_string_append_c(command, '\\');
      if (*c == '%') g_string_append_c(command, '%');
      g_string_append_c(command, *c);
    }
    g_string_append(command, "\" %F");
    g_key_file_set_string(entry, "Desktop Entry", "Exec", command->str);
    g_string_free(command, TRUE);
  }
  g_key_file_set_string(entry, "Desktop Entry", "Icon", icon);
  gsize length = 0;
  g_autofree gchar* contents = g_key_file_to_data(entry, &length, nullptr);
  // Only this app's current-user launcher; never rewrite a system desktop file.
  return g_mkdir_with_parents(applications, 0755) == 0 &&
      g_file_set_contents(launcher, contents, length, nullptr);
}

#endif  // MARKER_APPEARANCE_LAUNCHER_H_
