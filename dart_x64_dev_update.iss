; !!!!!!!!! EXECUTABLE TO BE BUNDLED WITH MAIN INSTALLER !!!!!!!!!

#define MyAppName "Dart"
#define MyAppVersion "dev 64-bit"
#define MyAppPublisher "Gekorm"
#define MyAppURL "https://www.dartlang.org/"
#define MyAppExeName "dart.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{E30EFA88-E6EE-4149-860C-049E4F1A1CFC}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
ArchitecturesInstallIn64BitMode=x64
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableDirPage=yes 
DisableFinishedPage=yes  
DisableProgramGroupPage=yes
DisableReadyMemo=yes
DisableReadyPage=no
DisableStartupPrompt=yes
DisableWelcomePage=yes
AllowNoIcons=yes
InfoBeforeFile=assets\updater\INFO.txt
InfoAfterFile=assets\updater\AFTER.txt
OutputDir=bin\updater-dev
OutputBaseFilename=Dart Update
SetupIconFile=assets\dart-icon.ico
Compression=lzma
SolidCompression=yes
; Tell Windows Explorer to reload the environment
ChangesEnvironment=yes
; Size of files to download:
ExtraDiskSpaceRequired=1
UninstallDisplayIcon={app}\dart-icon.ico
WizardImageFile=assets\dart-logo-wordmark.bmp
WizardSmallImageFile=assets\dart-bird.bmp
WizardImageStretch=no
WizardImageBackColor=$fafafa

#include <idp.iss>

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "assets\7za.exe"; DestDir: {tmp}; Flags: dontcopy
Source: "assets\dart-icon.ico"; DestDir: "{app}\"; Flags: ignoreversion overwritereadonly
Source: "{tmp}\dart-sdk\*"; DestDir: "{app}\dart-sdk"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly external
Source: "{tmp}\temp-dartium\chromium\*"; DestDir: "{app}\chromium"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly external
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[Registry]
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}\dart-sdk\bin"; Check: NeedsAddPath('{app}\dart-sdk\bin')
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "DART_SDK"; ValueData: "{app}\dart-sdk";

[Messages]
SetupAppTitle = Update {#MyAppName}
SetupWindowTitle = Update {#MyAppName}
ExitSetupTitle = Exit Update
ExitSetupMessage = Update is not complete. If you exit now, Dart will not be updated.%n%nYou may run Dart Update again at another time to complete the installation.%n%nExit Update?

[CustomMessages]
DartInstalledVersion=Installed version: %1
DartLatestVersion=Latest (dev) version: %1

[Code]
// SO: http://stackoverflow.com/questions/3304463/
function NeedsAddPath(Param: string): Boolean;
var
  OrigPath: string;
  ParamExpanded: string;
begin
  // Expand the setup constants like {app} from Param
  ParamExpanded := ExpandConstant(Param);
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', OrigPath) then 
  begin
    Result := TRUE;
    Exit;
  end;
  // Look for the path with leading and trailing semicolon and with or without \ ending
  // Pos() returns 0 if not found
  Result := Pos(';' + UpperCase(ParamExpanded) + ';', ';' + UpperCase(OrigPath) + ';') = 0;  
  if Result = TRUE then
    Result := Pos(';' + UpperCase(ParamExpanded) + '\;', ';' + UpperCase(OrigPath) + ';') = 0; 
end;

// Internet latest revision
function GetCurRevision(Param: string): string;
var
  FormattedRevision: string;
  Index: Integer;
begin
  FormattedRevision := Param;
  Index := Pos('revision', Param);
  Index := Index +11;
  Delete(FormattedRevision, 1, Index);
  Index := Pos('"', FormattedRevision);
  Delete(FormattedRevision, Index, 4); 
  Result := FormattedRevision;
  Exit;
end;

// Installed revision
function GetInsRevision(PathToApp: string): string;
var
  FormattedRevision: string;
  Index: Integer;
  RevisionFile: string;
begin
  LoadStringFromFile(PathToApp + 'dart-sdk\revision', FormattedRevision);
  FormattedRevision := Trim(FormattedRevision);
  Log('The final Ins Rev is: ' + FormattedRevision);  
  Result := FormattedRevision;
end;

// Internet latest version
function GetCurVersion(Param: string): string;
var
  FormattedRevision: string;
  Index: Integer;
begin
  FormattedRevision := Param;
  Index := Pos('version', Param);
  Index := Index +11;
  Delete(FormattedRevision, 1, Index - 1);
  Index := Pos('"', FormattedRevision);
  Delete(FormattedRevision, Index, 4);
  Index := Pos('"', FormattedRevision);
  Delete(FormattedRevision, Index, 400); 
  Result := FormattedRevision;
  Exit;
end;

// Installed version
function GetInsVersion(PathToApp: string): string;
var
  FormattedRevision: string;
  Index: Integer;
  RevisionFile: string;
begin
  LoadStringFromFile(PathToApp + 'dart-sdk\version', FormattedRevision);
  FormattedRevision := Trim(FormattedRevision);
  Log('The final Ins Ver is: ' + FormattedRevision);  
  Result := FormattedRevision;
end;

procedure InitializeWizard;
begin
  // Only tell the plugin when we want to start downloading
  // Add the files to the list; at this time, the {app} directory is known
  idpSetOption('ConnectTimeout', '90000');
  idpSetOption('SendTimeout', '90000');
  idpSetOption('ReceiveTimeout', '90000');
  idpAddFile('https://storage.googleapis.com/dart-archive/channels/dev/release/latest/dartium/dartium-windows-ia32-release.zip', ExpandConstant('{tmp}\dartium.zip'));
  idpAddFile('https://storage.googleapis.com/dart-archive/channels/dev/release/latest/sdk/dartsdk-windows-x64-release.zip', ExpandConstant('{tmp}\dart-sdk.zip'));
  idpDownloadAfter(wpReady);
end;

procedure DoUnzip(Source: string; targetdir: string);
var 
  unzipTool: string;
  ReturnCode: Integer;
begin
  // Source contains tmp constant, so resolve it to path name
  Source := ExpandConstant(Source);

  unzipTool := ExpandConstant('{tmp}\7za.exe');

  if not FileExists(unzipTool) then 
    MsgBox('UnzipTool not found: ' + unzipTool, mbError, MB_OK)
  else if not FileExists(Source) then 
    MsgBox('File was not found while trying to unzip: ' + Source, mbError, MB_OK)
  else 
  begin
    if Exec(unzipTool, ' x "' + Source + '" -o"' + targetdir + '" -y', '', SW_HIDE, ewWaitUntilTerminated, ReturnCode) = FALSE then 
    begin
      MsgBox('Unzip failed:' + Source, mbError, MB_OK);
    end;
  end;
end;

function TryGetFirstSubfolder(const Path: string; out Folder: string): Boolean;
var
  S: string;
  FindRec: TFindRec;
begin
  Result := FALSE;
  if FindFirst(ExpandConstant(AddBackslash(Path) + '*'), FindRec) then
    try
      repeat
        if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY <> 0) and (FindRec.Name <> '.') and (FindRec.Name <> '..') then
        begin
          Result := TRUE;
          Folder := AddBackslash(Path) + FindRec.Name;
          Exit;
        end;
      until not FindNext(FindRec);
    finally
      FindClose(FindRec);
    end;
end;

function GetDartiumName(Param: string): string;
var
  B: string;
begin
  B := '';
  if (TryGetFirstSubfolder(ExpandConstant('{tmp}\temp-dartium'), B)) then
    Result := B;
  Exit;
end;

procedure CopyDartium();
var
  Y: string;
  ResultCode: Integer;
begin
  Exec(ExpandConstant('{win}\cmd.exe'), 'ROBOCOPY ' + GetDartiumName(Y) + ' ' + ExpandConstant('{tmp}\chromium') + ' /E', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure CurPageChanged(CurPageID: Integer); 
var
  SilUpdate: string;
  Current: string;
  Installed: string;
  CurrentVersion: string;
  InstalledVersion: string;
  S: string;
  Page: TWizardPage;
  InstalledLabel: TNewStaticText;
  LatestLabel: TNewStaticText;
begin
  // If the user just reached the Ready page, then...
  if CurPageID = wpReady then
  begin
    // Download VERSION text file
    if idpDownloadFile('https://storage.googleapis.com/dart-archive/channels/dev/release/latest/VERSION', ExpandConstant('{tmp}\VERSION.txt')) then
    begin
      // Version fetched
      // Read the file and transform the String to: int.int.int. ... .int
      LoadStringFromFile(ExpandConstant('{tmp}\VERSION.txt'), SilUpdate);
      Current := GetCurRevision(SilUpdate);
      Installed := GetInsRevision(ExpandConstant('{app}\'));
      CurrentVersion := GetCurVersion(SilUpdate);
      InstalledVersion := GetInsVersion(ExpandConstant('{app}\'));
      if (Installed = Current) then 
      begin
        // Dart is up to date
        MsgBox('Dart is up to date!', mbInformation, MB_OK);
        WizardForm.Close;
      end
      else
      begin
        Page := PageFromID(wpReady);
        InstalledLabel := TNewStaticText.Create(WizardForm);
        InstalledLabel.Parent := Page.Surface;
        InstalledLabel.Caption := FmtMessage(CustomMessage('DartInstalledVersion'), [InstalledVersion]);
        LatestLabel := TNewStaticText.Create(WizardForm);
        LatestLabel.Parent := Page.Surface;
        LatestLabel.Caption := FmtMessage(CustomMessage('DartLatestVersion'), [CurrentVersion]);
        LatestLabel.Top := InstalledLabel.Top + LatestLabel.Height + 4;
        WizardForm.ReadyLabel.Top := LatestLabel.Top + WizardForm.ReadyLabel.Height + 16;
      end
    end
    else 
      // Failed to fetch resource
      MsgBox(SilUpdate, mbError, MB_OK);
  end;
  // If the user just reached the Installing page, then...
  if CurPageID = wpInstalling then
  begin
    // Extract 7za to temp folder
    ExtractTemporaryFile('7za.exe');
    // Extract the zip to the temp folder (when included in the installer)
    // Skip this, when the file is downloaded with IDP to the temp folder
    // ExtractTemporaryFile('app.zip);

    // Unzip the Dart SDK zip in the tempfolder to your temp target path
    DoUnzip(ExpandConstant('{tmp}\') + 'dart-sdk.zip', ExpandConstant('{tmp}'));

    // Unzip the Dartium zip in the tempfolder to your temp target path
    DoUnzip(ExpandConstant('{tmp}\') + 'dartium.zip', ExpandConstant('{tmp}\temp-dartium'));
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  S: string;
begin
  if (CurStep = ssInstall) then
  begin
    RenameFile(GetDartiumName(S), ExpandConstant('{tmp}\temp-dartium\chromium'));
  end;
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  if CurPageID = wpReady then
    Confirm := FALSE;
end;