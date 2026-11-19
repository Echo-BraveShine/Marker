Name: marker
Version: %{marker_version}
Release: %{marker_build}
Summary: Markdown editor
Summary(zh_CN): Markdown 编辑与实时预览
License: LicenseRef-Marker
URL: https://github.com/Echo-BraveShine/Marker
Source0: marker.tar.gz
# The packaging script checks for patchelf on PATH. Ubuntu CI installs it via
# APT, so rpmbuild cannot resolve it through the RPM database.

# The archive contains Flutter's existing release binaries.
%global debug_package %{nil}
%global __brp_strip %{nil}
%global __brp_strip_comment_note %{nil}
%global __brp_strip_static_archive %{nil}

Requires: libgtk-3.so.0()(64bit)
Requires: libGL.so.1()(64bit)
Requires: libsecret-1.so.0()(64bit)
Requires: shared-mime-info
Requires: desktop-file-utils

%description
Write Markdown with live preview, math and Mermaid support.

%description -l zh_CN
在本地编辑和预览 Markdown、数学公式与 Mermaid 图表。

%install
mkdir -p %{buildroot}/opt/marker %{buildroot}/usr/bin
tar -xzf %{SOURCE0} -C %{buildroot}/opt/marker
# Plugins are installed beside the Flutter engine. Replace the build path with
# a path relative to each plugin so the same package works after relocation.
for plugin in %{buildroot}/opt/marker/lib/*_plugin.so; do
  [ -f "$plugin" ] || continue
  patchelf --set-rpath '$ORIGIN' "$plugin"
done
mv %{buildroot}/opt/marker/share %{buildroot}/usr/share
ln -s ../../opt/marker/marker %{buildroot}/usr/bin/marker

%post
if command -v update-mime-database >/dev/null 2>&1; then
  update-mime-database /usr/share/mime || :
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database /usr/share/applications || :
fi

%postun
if command -v update-mime-database >/dev/null 2>&1; then
  update-mime-database /usr/share/mime || :
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database /usr/share/applications || :
fi

%files
/opt/marker
/usr/bin/marker
/usr/share/applications/dev.ekko.marker.desktop
/usr/share/icons/hicolor
/usr/share/metainfo/dev.ekko.marker.metainfo.xml
/usr/share/mime/packages/dev.ekko.marker.xml
