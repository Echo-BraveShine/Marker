#ifndef MARKER_MERMAID_RENDERER_H_
#define MARKER_MERMAID_RENDERER_H_
#include <glib.h>
#include <functional>
// The callback borrows the PNG bytes/error for its duration. Renders offline.
void render_mermaid(const gchar* html, int width,
                    std::function<void(GBytes*, const gchar*)> callback);
void render_document_export(const gchar* html, int width, bool pdf,
    std::function<void(GBytes*, const gchar*)> callback);
#endif
