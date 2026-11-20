#include "my_application.h"
#include "appearance_launcher.h"
#include "mermaid_renderer.h"
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
  const gboolean launcher_updated = update_launcher_icon(directory, executable, dark);
  gtk_window_set_default_icon_list(icons);
  gtk_window_set_icon_list(window, icons);
  g_list_free_full(icons, g_object_unref);
  return launcher_updated;
}

static void appearance_method_call(FlMethodChannel*, FlMethodCall* call,
                                   gpointer user_data) {
  g_autoptr(FlMethodResponse) response = nullptr;
  if (g_strcmp0(fl_method_call_get_name(call), "setDark") != 0) {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  } else {
    FlValue* arguments = fl_method_call_get_args(call);
    if (arguments == nullptr || fl_value_get_type(arguments) != FL_VALUE_TYPE_BOOL) {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("invalid-arguments",
          "Expected dark appearance boolean", nullptr));
    } else {
      const gboolean dark = fl_value_get_bool(arguments);
      // Apply native chrome even when launcher artwork cannot be updated.
      GtkSettings* settings = gtk_settings_get_default();
      g_object_set(settings, "gtk-application-prefer-dark-theme", dark, nullptr);
      GtkWidget* titlebar = gtk_window_get_titlebar(GTK_WINDOW(user_data));
      if (titlebar) {
        auto* style = gtk_widget_get_style_context(titlebar);
        auto* provider = GTK_CSS_PROVIDER(g_object_get_data(G_OBJECT(titlebar), "marker-titlebar-css"));
        if (!provider) {
          provider = gtk_css_provider_new();
          gtk_style_context_add_provider(style, GTK_STYLE_PROVIDER(provider), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
          g_object_set_data_full(G_OBJECT(titlebar), "marker-titlebar-css", provider, g_object_unref);
        }
        gtk_css_provider_load_from_data(provider, dark
            ? "headerbar { background-image:none; background-color:#262628; color:#f5f5f7; } headerbar button { color:#f5f5f7; }"
            : "headerbar { background-image:none; background-color:#f6f6f7; color:#252527; } headerbar button { color:#252527; }", -1, nullptr);
      }
      if (!apply_appearance_icon(GTK_WINDOW(user_data), dark)) {
        response = FL_METHOD_RESPONSE(fl_method_error_response_new("missing-icon",
            "Appearance icon files not found", nullptr));
      } else {
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
      }
    }
  }
  fl_method_call_respond(call, response, nullptr);
}

static void resource_method_call(FlMethodChannel*, FlMethodCall* call, gpointer user_data) {
  const gchar* method = fl_method_call_get_name(call);
  if (g_strcmp0(method, "trash") != 0 && g_strcmp0(method, "reveal") != 0) {
    fl_method_call_respond_not_implemented(call, nullptr); return;
  }
  FlValue* arg = fl_method_call_get_args(call);
  if (!arg || fl_value_get_type(arg) != FL_VALUE_TYPE_STRING) {
    fl_method_call_respond_error(call, "invalid-path", "Expected a file path", nullptr, nullptr); return;
  }
  g_autoptr(GFile) file = g_file_new_for_path(fl_value_get_string(arg));
  if (g_strcmp0(method, "trash") == 0) {
    g_object_ref(call);
    g_file_trash_async(file, G_PRIORITY_DEFAULT, nullptr, [](GObject* source, GAsyncResult* result, gpointer data) {
      auto* pending = FL_METHOD_CALL(data);
      g_autoptr(GError) error = nullptr;
      if (g_file_trash_finish(G_FILE(source), result, &error)) fl_method_call_respond_success(pending, nullptr, nullptr);
      else fl_method_call_respond_error(pending, "trash-unavailable", error ? error->message : "Trash is unavailable; file kept", nullptr, nullptr);
      g_object_unref(pending);
    }, call);
  } else {
    g_autoptr(GFile) parent = g_file_get_parent(file);
    g_autofree gchar* uri = parent ? g_file_get_uri(parent) : nullptr;
    g_autoptr(GError) error = nullptr;
    if (uri && gtk_show_uri_on_window(GTK_WINDOW(user_data), uri, GDK_CURRENT_TIME, &error)) {
      fl_method_call_respond_success(call, nullptr, nullptr);
    } else { fl_method_call_respond_error(call, "reveal-failed", error ? error->message : "Cannot show folder", nullptr, nullptr); }
  }
}

static void mermaid_method_call(FlMethodChannel*, FlMethodCall* call, gpointer) {
  if (g_strcmp0(fl_method_call_get_name(call), "render") != 0) {
    fl_method_call_respond_not_implemented(call, nullptr);
    return;
  }
  FlValue* args = fl_method_call_get_args(call);
  FlValue* html = args && fl_value_get_type(args) == FL_VALUE_TYPE_MAP
      ? fl_value_lookup_string(args, "html") : nullptr;
  FlValue* width = args && fl_value_get_type(args) == FL_VALUE_TYPE_MAP
      ? fl_value_lookup_string(args, "width") : nullptr;
  if (!html || fl_value_get_type(html) != FL_VALUE_TYPE_STRING ||
      !width || fl_value_get_type(width) != FL_VALUE_TYPE_INT) {
    fl_method_call_respond_error(call, "invalid-arguments", "Expected HTML and width", nullptr, nullptr);
    return;
  }
  g_object_ref(call);
  render_mermaid(fl_value_get_string(html), static_cast<int>(fl_value_get_int(width)),
      [call](GBytes* bytes, const gchar* error) {
    if (error) {
      fl_method_call_respond_error(call, "mermaid-render", error, nullptr, nullptr);
    } else {
      gsize size = 0;
      const auto* data = static_cast<const uint8_t*>(g_bytes_get_data(bytes, &size));
      g_autoptr(FlValue) value = fl_value_new_uint8_list(data, size);
      fl_method_call_respond_success(call, value, nullptr);
    }
    g_object_unref(call);
  });
}

static void export_method_call(FlMethodChannel*, FlMethodCall* call, gpointer) {
  if (g_strcmp0(fl_method_call_get_name(call), "render") != 0) {
    fl_method_call_respond_not_implemented(call, nullptr); return;
  }
  FlValue* args = fl_method_call_get_args(call);
  if (!args || fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    fl_method_call_respond_error(call, "invalid-export", "Expected export arguments", nullptr, nullptr); return;
  }
  FlValue* path = fl_value_lookup_string(args, "path");
  FlValue* format = fl_value_lookup_string(args, "format");
  FlValue* width = fl_value_lookup_string(args, "width");
  if (!path || fl_value_get_type(path) != FL_VALUE_TYPE_STRING ||
      !format || fl_value_get_type(format) != FL_VALUE_TYPE_STRING ||
      !width || fl_value_get_type(width) != FL_VALUE_TYPE_INT) {
    fl_method_call_respond_error(call, "invalid-export", "Expected document path, format and width", nullptr, nullptr); return;
  }
  g_autofree gchar* html = nullptr;
  if (!g_file_get_contents(fl_value_get_string(path), &html, nullptr, nullptr)) {
    fl_method_call_respond_error(call, "missing-document", "Export document not found", nullptr, nullptr); return;
  }
  g_object_ref(call);
  render_document_export(html, static_cast<int>(fl_value_get_int(width)),
      g_strcmp0(fl_value_get_string(format), "pdf") == 0, [call](GBytes* bytes, const gchar* error) {
    if (error) fl_method_call_respond_error(call, "export-failed", error, nullptr, nullptr);
    else {
      gsize length = 0;
      auto* data = static_cast<const uint8_t*>(g_bytes_get_data(bytes, &length));
      g_autoptr(FlValue) value = fl_value_new_uint8_list(data, length);
      fl_method_call_respond_success(call, value, nullptr);
    }
    g_object_unref(call);
  });
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Own the header on all desktops so app theme is independent of WM chrome.
  const gboolean use_header_bar = TRUE;

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

  g_autoptr(FlMethodChannel) resources = fl_method_channel_new(
      fl_engine_get_binary_messenger(fl_view_get_engine(view)), "marker/resources", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(resources, resource_method_call, window, nullptr);
  g_object_set_data_full(G_OBJECT(window), "marker-resource-channel", g_object_ref(resources), g_object_unref);

  g_autoptr(FlMethodChannel) mermaid = fl_method_channel_new(
      fl_engine_get_binary_messenger(fl_view_get_engine(view)), "marker/mermaid", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(mermaid, mermaid_method_call, nullptr, nullptr);
  g_object_set_data_full(G_OBJECT(window), "marker-mermaid-channel", g_object_ref(mermaid), g_object_unref);

  g_autoptr(FlMethodChannel) exporter = fl_method_channel_new(
      fl_engine_get_binary_messenger(fl_view_get_engine(view)), "marker/export", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(exporter, export_method_call, nullptr, nullptr);
  g_object_set_data_full(G_OBJECT(window), "marker-export-channel", g_object_ref(exporter), g_object_unref);

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
