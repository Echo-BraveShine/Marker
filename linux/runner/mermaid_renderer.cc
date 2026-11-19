#include "mermaid_renderer.h"
#include <webkit2/webkit2.h>
#include <algorithm>
#include <memory>
#include <utility>
#include <glib/gstdio.h>
#include <unistd.h>
#include <string>

namespace {
struct Render {
  GtkWidget* window = nullptr;
  WebKitWebView* view = nullptr;
  WebKitUserContentManager* manager = nullptr;
  guint timeout = 0;
  gulong message_handler = 0;
  bool finished = false;
  bool ready = false;
  bool pdf = false;
  bool document = false;
  int width = 0;
  std::string output;
  WebKitPrintOperation* print = nullptr;
  gulong print_failed = 0, print_finished = 0;
  ~Render() { if (!output.empty()) g_unlink(output.c_str()); }
  std::function<void(GBytes*, const gchar*)> callback;
  void Complete(GBytes* bytes, const gchar* error) {
    if (finished) return;
    finished = true;
    if (timeout != 0) { g_source_remove(timeout); timeout = 0; }
    callback(bytes, error);
    if (print) {
      g_signal_handler_disconnect(print, print_failed);
      g_signal_handler_disconnect(print, print_finished);
      g_clear_object(&print);
    }
    g_signal_handler_disconnect(manager, message_handler);
    gtk_widget_destroy(window);
  }
};
using Task = std::shared_ptr<Render>;
void DeleteTask(gpointer data) { delete static_cast<Task*>(data); }
cairo_status_t AppendPng(void* closure, const unsigned char* bytes, unsigned int length) {
  g_byte_array_append(static_cast<GByteArray*>(closure), bytes, length);
  return CAIRO_STATUS_SUCCESS;
}
void SnapshotFinished(GObject* source, GAsyncResult* result, gpointer data) {
  std::unique_ptr<Task> owned(static_cast<Task*>(data));
  Task task = *owned;
  g_autoptr(GError) error = nullptr;
  cairo_surface_t* surface = webkit_web_view_get_snapshot_finish(WEBKIT_WEB_VIEW(source), result, &error);
  if (surface == nullptr) {
    task->Complete(nullptr, error ? error->message : "Snapshot failed");
    return;
  }
  if (task->document && cairo_image_surface_get_width(surface) != task->width) {
    const double scale = static_cast<double>(task->width) / cairo_image_surface_get_width(surface);
    auto* scaled = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, task->width,
        static_cast<int>(cairo_image_surface_get_height(surface) * scale));
    auto* context = cairo_create(scaled);
    cairo_scale(context, scale, scale);
    cairo_set_source_surface(context, surface, 0, 0);
    cairo_pattern_set_filter(cairo_get_source(context), CAIRO_FILTER_BEST);
    cairo_paint(context);
    cairo_destroy(context);
    cairo_surface_destroy(surface);
    surface = scaled;
  }
  g_autoptr(GByteArray) png = g_byte_array_new();
  const auto status = cairo_surface_write_to_png_stream(surface, AppendPng, png);
  cairo_surface_destroy(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    task->Complete(nullptr, "PNG encoding failed");
    return;
  }
  g_autoptr(GBytes) bytes = g_byte_array_free_to_bytes(g_steal_pointer(&png));
  task->Complete(bytes, nullptr);
}
gboolean TakeSnapshot(gpointer data) {
  Task task = *static_cast<Task*>(data);
  if (!task->finished) {
    webkit_web_view_get_snapshot(task->view, WEBKIT_SNAPSHOT_REGION_VISIBLE,
        WEBKIT_SNAPSHOT_OPTIONS_TRANSPARENT_BACKGROUND, nullptr, SnapshotFinished, new Task(task));
  }
  return G_SOURCE_REMOVE;
}
void PrintDocument(Task task) {
  g_autofree gchar* output = nullptr;
  const int file = g_file_open_tmp("marker-export-XXXXXX", &output, nullptr);
  if (file < 0) { task->Complete(nullptr, "Cannot create temporary PDF"); return; }
  close(file);
  task->output = output;
  g_autofree gchar* uri = g_filename_to_uri(output, nullptr, nullptr);
  g_autoptr(GtkPrintSettings) settings = gtk_print_settings_new();
  gtk_print_settings_set_printer(settings, "Print to File");
  gtk_print_settings_set(settings, GTK_PRINT_SETTINGS_OUTPUT_URI, uri);
  gtk_print_settings_set(settings, GTK_PRINT_SETTINGS_OUTPUT_FILE_FORMAT, "pdf");
  gtk_print_settings_set_print_pages(settings, GTK_PRINT_PAGES_ALL);
  g_autoptr(GtkPageSetup) setup = gtk_page_setup_new();
  auto* paper = gtk_paper_size_new(GTK_PAPER_NAME_A4);
  gtk_page_setup_set_paper_size(setup, paper);
  gtk_paper_size_free(paper);
  gtk_page_setup_set_top_margin(setup, 18, GTK_UNIT_MM);
  gtk_page_setup_set_bottom_margin(setup, 18, GTK_UNIT_MM);
  gtk_page_setup_set_left_margin(setup, 18, GTK_UNIT_MM);
  gtk_page_setup_set_right_margin(setup, 18, GTK_UNIT_MM);
  task->print = webkit_print_operation_new(task->view);
  webkit_print_operation_set_print_settings(task->print, settings);
  webkit_print_operation_set_page_setup(task->print, setup);
  task->print_failed = g_signal_connect_data(task->print, "failed", G_CALLBACK(+[](WebKitPrintOperation*, GError* error, gpointer data) {
    Task pending = *static_cast<Task*>(data);
    pending->Complete(nullptr, error->message);
  }), new Task(task), [](gpointer data, GClosure*) { DeleteTask(data); }, G_CONNECT_DEFAULT);
  task->print_finished = g_signal_connect_data(task->print, "finished", G_CALLBACK(+[](WebKitPrintOperation*, gpointer data) {
    Task pending = *static_cast<Task*>(data);
    if (pending->finished) return;
    g_autofree gchar* contents = nullptr;
    gsize length = 0;
    if (!g_file_get_contents(pending->output.c_str(), &contents, &length, nullptr) || length < 5 ||
        !g_str_has_prefix(contents, "%PDF-")) {
      pending->Complete(nullptr, "Unable to create PDF"); return;
    }
    g_autoptr(GBytes) bytes = g_bytes_new(contents, length);
    pending->Complete(bytes, nullptr);
  }), new Task(task), [](gpointer data, GClosure*) { DeleteTask(data); }, G_CONNECT_DEFAULT);
  webkit_print_operation_print(task->print);
}
void Message(WebKitUserContentManager*, WebKitJavascriptResult* result, gpointer data) {
  Task task = *static_cast<Task*>(data);
  if (task->finished || task->ready) return;
  JSCValue* value = webkit_javascript_result_get_js_value(result);
  if (!jsc_value_is_object(value)) return;
  g_autoptr(JSCValue) error = jsc_value_object_get_property(value, "error");
  if (jsc_value_is_string(error)) {
    g_autofree gchar* message = jsc_value_to_string(error);
    task->Complete(nullptr, message);
    return;
  }
  g_autoptr(JSCValue) height = jsc_value_object_get_property(value, "height");
  if (!jsc_value_is_number(height)) return;
  task->ready = true;
  const int content_height = jsc_value_to_int32(height);
  if (task->pdf) { PrintDocument(task); return; }
  if (content_height < 1 || content_height > (task->document ? 32768 : 8192)) {
    task->Complete(nullptr, "Document is too tall for PNG; choose PDF");
    return;
  }
  gtk_widget_set_size_request(GTK_WIDGET(task->view), -1, content_height);
  gtk_window_resize(GTK_WINDOW(task->window), gtk_widget_get_allocated_width(GTK_WIDGET(task->view)), content_height);
  // Allow the GTK allocation and WebKit paint to reflect the completed diagram.
  g_timeout_add_full(G_PRIORITY_DEFAULT, 150, TakeSnapshot, new Task(task), DeleteTask);
}
}  // namespace

static void StartRender(const gchar* html, int width, bool document, bool pdf,
                    std::function<void(GBytes*, const gchar*)> callback) {
  Task task = std::make_shared<Render>();
  task->callback = std::move(callback);
  task->document = document; task->pdf = pdf; task->width = width;
  task->window = gtk_offscreen_window_new();
  // Ephemeral context: no cookie/profile files, external resources blocked by CSP.
  auto* context = webkit_web_context_new_ephemeral();
  task->view = WEBKIT_WEB_VIEW(webkit_web_view_new_with_context(context));
  g_object_unref(context);
  auto* settings = webkit_web_view_get_settings(task->view);
  webkit_settings_set_allow_file_access_from_file_urls(settings, TRUE);
  webkit_settings_set_hardware_acceleration_policy(settings, WEBKIT_HARDWARE_ACCELERATION_POLICY_NEVER);
  task->manager = webkit_web_view_get_user_content_manager(task->view);
  task->message_handler = g_signal_connect_data(task->manager, "script-message-received::marker", G_CALLBACK(Message),
      new Task(task), [](gpointer data, GClosure*) { DeleteTask(data); }, G_CONNECT_DEFAULT);
  webkit_user_content_manager_register_script_message_handler(task->manager, "marker");
  gtk_window_set_default_size(GTK_WINDOW(task->window), std::min(std::max(width, 240), 2048), 100);
  gtk_container_add(GTK_CONTAINER(task->window), GTK_WIDGET(task->view));
  gtk_widget_show_all(task->window);
  task->timeout = g_timeout_add_full(G_PRIORITY_DEFAULT, document ? 75000 : 20000, [](gpointer data) -> gboolean {
    Task pending = *static_cast<Task*>(data);
    pending->timeout = 0;
    pending->Complete(nullptr, "Mermaid rendering timed out");
    return G_SOURCE_REMOVE;
  }, new Task(task), DeleteTask);
  // A local origin lets the page use the bundled CJK font. CSP restricts other resources.
  g_autofree gchar* executable = g_file_read_link("/proc/self/exe", nullptr);
  g_autofree gchar* base_uri = executable ? g_filename_to_uri(executable, nullptr, nullptr) : nullptr;
  webkit_web_view_load_html(task->view, html, base_uri ? base_uri : "about:blank");
}

void render_mermaid(const gchar* html, int width, std::function<void(GBytes*, const gchar*)> callback) {
  StartRender(html, width, false, false, std::move(callback));
}
void render_document_export(const gchar* html, int width, bool pdf, std::function<void(GBytes*, const gchar*)> callback) {
  StartRender(html, width, true, pdf, std::move(callback));
}
