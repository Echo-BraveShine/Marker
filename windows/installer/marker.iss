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
WizardStyle=modern
DisableWelcomePage=no
WizardImageFile=wizard-sidebar.bmp
WizardSmallImageFile=wizard-small.bmp
WizardImageStretch=yes
AppPublisher=Marker
AppId=dev.ekko.marker
AppName={#AppName}
AppVersion={#AppVersion}
VersionInfoVersion={#AppVersion}.{#BuildNumber}
VersionInfoProductVersion={#AppVersion}.{#BuildNumber}
VersionInfoProductTextVersion={#AppVersion}+{#BuildNumber}
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
[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "zh"; MessagesFile: "ChineseSimplified.isl"

[CustomMessages]
en.LaunchMarker=Open Marker
zh.LaunchMarker=打开 Marker
en.WelcomeLabel1=Welcome to Marker
zh.WelcomeLabel1=欢迎安装 Marker
en.WelcomeLabel2=A little space for your next idea.%n%nThis will install Marker on your computer.
zh.WelcomeLabel2=让灵感，自在落笔。%n%n即将在你的电脑上安装 Marker。

[Messages]
en.WelcomeLabel1=Welcome to Marker
zh.WelcomeLabel1=欢迎安装 Marker
en.WelcomeLabel2=A little space for your next idea.%n%nThis will install Marker on your computer.
zh.WelcomeLabel2=让灵感，自在落笔。%n%n即将在你的电脑上安装 Marker。

[Files]
Source: "{#BuildOutput}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
[Icons]
Name: "{group}\Marker"; Filename: "{app}\marker.exe"; AppUserModelID: "dev.ekko.marker"
[Run]
Filename: "{app}\marker.exe"; Description: "{cm:LaunchMarker}"; WorkingDir: "{app}"; Flags: nowait postinstall skipifsilent

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
