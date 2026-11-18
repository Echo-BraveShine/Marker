#include "my_application.h"
#include <initializer_list>

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Preserve the stable desktop ID and user launcher settings. Desktop shells that
// ignore window icons can observe this user-local launcher metadata change.
static void update_launcher_icon(const gchar* directory, const gchar* executable,
                                 gboolean dark) {
  g_autofree gchar* applications = g_build_filename(g_get_user_data_dir(), "applications", nullptr);
  g_autofree gchar* launcher = g_build_filename(applications, APPLICATION_ID ".desktop", nullptr);
  g_autofree gchar* bundled = g_build_filename(directory, "share", "applications", APPLICATION_ID ".desktop", nullptr);
  const gboolean existing = g_file_test(launcher, G_FILE_TEST_IS_REGULAR);
  g_autoptr(GKeyFile) entry = g_key_file_new();
  if (!g_key_file_load_from_file(entry, existing ? launcher : bundled,
      static_cast<GKeyFileFlags>(G_KEY_FILE_KEEP_COMMENTS | G_KEY_FILE_KEEP_TRANSLATIONS), nullptr)) return;
  g_autofree gchar* icon = g_build_filename(directory, "share", "icons", "hicolor",
      "256x256", "apps", dark ? "marker-dark.png" : "marker.png", nullptr);
  g_autofree gchar* previous = g_key_file_get_string(entry, "Desktop Entry", "Icon", nullptr);
  if (g_strcmp0(previous, icon) == 0) return;
  if (!existing) {
    GString* command = g_string_new("\"");
    for (const gchar* c = executable; *c != '\0'; ++c) {
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
  if (g_mkdir_with_parents(applications, 0755) == 0) {
    // Only this app's current-user launcher; never rewrite a system desktop file.
    g_file_set_contents(launcher, contents, length, nullptr);
  }
}

// GTK/X11 forwards this icon list to the window manager. Wayland docks may
// instead use the stable desktop-file icon and ignore per-window artwork.
static gboolean apply_appearance_icon(GtkWindow* window, gboolean dark) {
  g_autofree gchar* executable = g_file_read_link("/proc/self/exe", nullptr);
  if (executable == nullptr) return FALSE;
  g_autofree gchar* directory = g_path_get_dirname(executable);
  GList* icons = nullptr;
  for (const int size : {16, 24, 32, 48, 64, 128, 256, 512}) {
    g_autofree gchar* dimensions = g_strdup_printf("%dx%d", size, size);
    g_autofree gchar* path = g_build_filename(directory, "share", "icons", "hicolor",
        dimensions, "apps", dark ? "marker-dark.png" : "marker.png", nullptr);
    GdkPixbuf* image = gdk_pixbuf_new_from_file(path, nullptr);
    if (image != nullptr) icons = g_list_append(icons, image);
  }
  if (icons == nullptr) return FALSE;
  update_launcher_icon(directory, executable, dark);
  gtk_window_set_default_icon_list(icons);
  gtk_window_set_icon_list(window, icons);
  g_list_free_full(icons, g_object_unref);
  return TRUE;
}

static void appearance_method_call(FlMethodChannel* channel, FlMethodCall* call,
                                   gpointer user_data) {
  g_autoptr(FlMethodResponse) response = nullptr;
  if (g_strcmp0(fl_method_call_get_name(call), "setDark") != 0) {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  } else {
    FlValue* arguments = fl_method_call_get_args(call);
    if (arguments == nullptr || fl_value_get_type(arguments) != FL_VALUE_TYPE_BOOL) {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("invalid-arguments",
          "Expected dark appearance boolean", nullptr));
    } else if (!apply_appearance_icon(GTK_WINDOW(user_data), fl_value_get_bool(arguments))) {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("missing-icon",
          "Appearance icon files not found", nullptr));
    } else {
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
    }
  }
  fl_method_call_respond(call, response, nullptr);
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "Marker");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "Marker");
  }

  gtk_window_set_default_size(window, 1200, 800);
  gtk_window_set_icon_name(window, "marker");
  // Resolve the bundled icon as well as installed desktop theme icons.
  g_autofree gchar* executable = g_file_read_link("/proc/self/exe", nullptr);
  if (executable != nullptr) {
    g_autofree gchar* directory = g_path_get_dirname(executable);
    g_autofree gchar* icon = g_build_filename(directory, "share", "icons", "hicolor",
                                             "256x256", "apps", "marker.png", nullptr);
    if (g_file_test(icon, G_FILE_TEST_IS_REGULAR)) {
      gtk_window_set_icon_from_file(window, icon, nullptr);
    }
  }

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  // Background defaults to black, override it here if necessary, e.g. #00000000
  // for transparent.
  gdk_rgba_parse(&background_color, "#F5F5F7");
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  // Realize the hidden surface; Dart shows it after configuration and first raster.
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      fl_engine_get_binary_messenger(fl_view_get_engine(view)), "marker/appearance", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, appearance_method_call, window, nullptr);
  g_object_set_data_full(G_OBJECT(window), "marker-appearance-channel", g_object_ref(channel), g_object_unref);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_NON_UNIQUE, nullptr));
}
