#include "my_application.h"
#include <fontconfig/fontconfig.h>

int main(int argc, char** argv) {
  // Make the bundled CJK font visible to native GTK dialogs and WebKit too.
  g_autofree gchar* executable = g_file_read_link("/proc/self/exe", nullptr);
  g_autofree gchar* directory = executable ? g_path_get_dirname(executable) : nullptr;
  g_autofree gchar* font = directory ? g_build_filename(directory, "data", "flutter_assets",
      "assets", "fonts", "NotoSansSC.ttf", nullptr) : nullptr;
  if (font && g_file_test(font, G_FILE_TEST_IS_REGULAR)) {
    FcConfigAppFontAddFile(FcConfigGetCurrent(), reinterpret_cast<const FcChar8*>(font));
  }
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
