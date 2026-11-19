"""Installer translations; no GTK dependency so locale selection is testable."""
import os

TEXT = {
    'en': {
        'title': 'Install Marker',
        'welcome': 'Install Marker for your user account.\nYour documents stay where they are.',
        'close': 'Close', 'install': 'Install Marker', 'working': 'Installing Marker…',
        'failed': 'Installation could not finish. You can try again.',
        'error': 'Could not install Marker',
        'ready': 'Marker is ready.\nFind it in your applications or use Open With on a Markdown file.',
        'open': 'Open Marker', 'language': 'Language',
    },
    'zh': {
        'title': '安装 Marker',
        'welcome': '为当前用户安装 Marker。\n你的文档将保留在原来的位置。',
        'close': '关闭', 'install': '安装 Marker', 'working': '正在安装 Marker…',
        'failed': '安装未能完成，你可以重试。', 'error': '无法安装 Marker',
        'ready': 'Marker 已准备就绪。\n可在应用列表中打开，或在 Markdown 文档上选择「打开方式」。',
        'open': '打开 Marker', 'language': '语言',
    },
}


def language_for_environment(environment=None):
    env = os.environ if environment is None else environment
    explicit = env.get('MARKER_INSTALLER_LANGUAGE', '')
    if explicit in TEXT:
        return explicit
    value = next((env.get(key) for key in ('LC_ALL', 'LANGUAGE', 'LC_MESSAGES', 'LANG') if env.get(key)), 'en')
    return 'zh' if value.lower().startswith('zh') else 'en'
