#define AppName "Marker"
#ifndef AppVersion
  #define AppVersion "0.0.1"
#endif
#ifndef BuildNumber
  #define BuildNumber "1"
#endif
#ifndef BuildOutput
  #define BuildOutput "..\..\build\windows\x64\runner\Release"
#endif
[Setup]
AppId=dev.ekko.marker
AppName={#AppName}
AppVersion={#AppVersion}
VersionInfoVersion={#AppVersion}.{#BuildNumber}
VersionInfoProductVersion={#AppVersion}+{#BuildNumber}
DefaultDirName={localappdata}\Programs\Marker
DefaultGroupName=Marker
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
ChangesAssociations=yes
OutputBaseFilename=Marker-Setup
Compression=lzma2
SolidCompression=yes
UninstallDisplayIcon={app}\marker.exe
SetupIconFile=..\runner\resources\app_icon.ico
[Files]
Source: "{#BuildOutput}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
[Icons]
Name: "{group}\Marker"; Filename: "{app}\marker.exe"; AppUserModelID: "dev.ekko.marker"
[Registry]
Root: HKCU; Subkey: "Software\Classes\.md\OpenWithProgids"; ValueType: string; ValueName: "dev.ekko.marker.Markdown"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\.markdown\OpenWithProgids"; ValueType: string; ValueName: "dev.ekko.marker.Markdown"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\dev.ekko.marker.Markdown"; ValueType: string; ValueData: "Markdown document"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\dev.ekko.marker.Markdown\DefaultIcon"; ValueType: string; ValueData: "{app}\marker.exe,0"
Root: HKCU; Subkey: "Software\Classes\dev.ekko.marker.Markdown\shell\open\command"; ValueType: string; ValueData: """{app}\marker.exe"" ""%1"""
Root: HKCU; Subkey: "Software\Classes\Applications\marker.exe"; ValueType: string; ValueName: "FriendlyAppName"; ValueData: "Marker"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\Applications\marker.exe\shell\open\command"; ValueType: string; ValueData: """{app}\marker.exe"" ""%1"""
Root: HKCU; Subkey: "Software\Classes\Applications\marker.exe\SupportedTypes"; ValueType: string; ValueName: ".md"; ValueData: ""
Root: HKCU; Subkey: "Software\Classes\Applications\marker.exe\SupportedTypes"; ValueType: string; ValueName: ".markdown"; ValueData: ""
