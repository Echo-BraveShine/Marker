files = [defines['app']]
symlinks = {'Applications': '/Applications'}
background = defines['background']
format = 'UDZO'
window_rect = ((160, 160), (660, 452))
icon_size = 96
text_size = 14
# Off-window icon positions expand Finder's scrollable content bounds.
icon_locations = {'Marker.app': (180, 228), 'Applications': (480, 228)}
hide = ['.background.png']
scroll_position = (0, 0)
default_view = 'icon-view'
show_status_bar = False
show_tab_view = False
show_toolbar = False
show_pathbar = False
show_sidebar = False
