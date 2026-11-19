// Compile on Linux with pkg-config --cflags --libs glib-2.0.
#define APPLICATION_ID "dev.ekko.marker"
#include "../linux/runner/appearance_launcher.h"
#include <string>
#include <glib/gstdio.h>

int main() {
  g_autofree gchar* root = g_dir_make_tmp("marker-icon-test-XXXXXX", nullptr);
  g_assert_nonnull(root);
  const std::string data = std::string(root) + "/user";
  const std::string system = std::string(root) + "/system";
  const std::string bundle = std::string(root) + "/bundle";
  g_setenv("XDG_DATA_HOME", data.c_str(), TRUE);
  g_setenv("XDG_DATA_DIRS", system.c_str(), TRUE);
  const std::string source = bundle + "/share/icons/hicolor/256x256/apps";
  g_assert_cmpint(g_mkdir_with_parents(source.c_str(), 0755), ==, 0);
  for (const auto name : {"marker.png", "marker-dark.png"}) {
    g_assert_true(g_file_set_contents((source + "/" + name).c_str(), name, -1, nullptr));
  }
  g_mkdir_with_parents((system + "/applications").c_str(), 0755);
  const std::string desktop = system + "/applications/" APPLICATION_ID ".desktop";
  const char* original = "[Desktop Entry]\nName=Marker\nName[zh_CN]=编辑器\nExec=/opt/marker/marker %F\nIcon=marker\nMimeType=text/markdown;\n";
  g_assert_true(g_file_set_contents(desktop.c_str(), original, -1, nullptr));
  g_autoptr(GKeyFile) entry = g_key_file_new();
  const std::string user_launcher = data + "/applications/" APPLICATION_ID ".desktop";
  for (const bool dark : {false, true, false}) {
    g_assert_true(update_launcher_icon(bundle.c_str(), "/temporary/mount/marker", dark));
    g_assert_true(g_key_file_load_from_file(entry, user_launcher.c_str(), G_KEY_FILE_KEEP_TRANSLATIONS, nullptr));
    g_autofree gchar* icon = g_key_file_get_string(entry, "Desktop Entry", "Icon", nullptr);
    const std::string expected = data + "/" APPLICATION_ID "/icons/" + (dark ? "marker-dark.png" : "marker.png");
    g_assert_cmpstr(icon, ==, expected.c_str());
    g_assert_true(g_file_test(icon, G_FILE_TEST_IS_REGULAR));
    g_autofree gchar* exec = g_key_file_get_string(entry, "Desktop Entry", "Exec", nullptr);
    g_assert_cmpstr(exec, ==, "/opt/marker/marker %F");
    g_autofree gchar* name = g_key_file_get_string(entry, "Desktop Entry", "Name[zh_CN]", nullptr);
    g_assert_cmpstr(name, ==, "编辑器");
  }
  g_autofree gchar* unchanged = nullptr;
  g_file_get_contents(desktop.c_str(), &unchanged, nullptr, nullptr);
  g_assert_cmpstr(unchanged, ==, original);
  // A first AppImage launch must point to the persistent AppImage, not its mount.
  g_remove(user_launcher.c_str());
  g_remove(desktop.c_str());
  g_mkdir_with_parents((bundle + "/share/applications").c_str(), 0755);
  g_file_set_contents((bundle + "/share/applications/" APPLICATION_ID ".desktop").c_str(), original, -1, nullptr);
  g_setenv("APPIMAGE", "/home/test/Marker 中文.AppImage", TRUE);
  g_assert_true(update_launcher_icon(bundle.c_str(), "/temporary/mount/marker", TRUE));
  g_key_file_load_from_file(entry, user_launcher.c_str(), G_KEY_FILE_KEEP_TRANSLATIONS, nullptr);
  g_autofree gchar* exec = g_key_file_get_string(entry, "Desktop Entry", "Exec", nullptr);
  g_assert_cmpstr(exec, ==, "\"/home/test/Marker 中文.AppImage\" %F");
  g_print("Linux launcher light/dark, persistent AppImage, metadata preservation: passed\n");
  return 0;
}
