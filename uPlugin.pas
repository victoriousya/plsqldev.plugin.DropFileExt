unit uPlugin;

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ShellAPI, PlugInIntf;

const // Description of this Plug-In (as displayed in Plug-In configuration dialog)
  Plugin_Desc = 'File Drag&Drop master';

procedure SetRoamingFolderPath;

var
  gRoamingFolderPath: string;

implementation

uses
  uDropWindow, ExtCtrls, StrUtils;

var
  dw: TfDropWindow;

// Plug-In identification, a unique identifier is received and
// the description is returned
function IdentifyPlugIn(ID: Integer): PChar;  cdecl;
begin
  PlugInID := ID;
  Result := Plugin_Desc;
end;

function add_trailing_slash( i_dir  : string): string;
begin
    if copy(i_dir, Length(i_dir), 1) = PathDelim then begin
      result:= i_dir;
    end else begin
      result:= i_dir + PathDelim;
    end;
end;

procedure SetRoamingFolderPath;
var
  buf  : PAnsiChar;
begin
  GetMem(buf,MAX_PATH);
  ZeroMemory(buf,MAX_PATH);
  Windows.GetEnvironmentVariable('APPDATA', buf,MAX_PATH);
  gRoamingFolderPath:= buf;
  FreeMem(Buf);

  gRoamingFolderPath:= add_trailing_slash(gRoamingFolderPath)+'PLSQL Developer'+ PathDelim;
  if not DirectoryExists(gRoamingFolderPath) then
      CreateDir(gRoamingFolderPath);
  gRoamingFolderPath:= gRoamingFolderPath + 'Plugins'+ PathDelim;
  if not DirectoryExists(gRoamingFolderPath) then
      CreateDir(gRoamingFolderPath);
  gRoamingFolderPath:= gRoamingFolderPath + 'DropFileExt'+ PathDelim;
  if not DirectoryExists(gRoamingFolderPath) then
      CreateDir(gRoamingFolderPath);
  gRoamingFolderPath:= gRoamingFolderPath;
end;

// Called when the Plug-In is created
procedure OnCreate; cdecl;
begin
  SetRoamingFolderPath;
end;

procedure trace(i_msg: string);
var
    l_file_name: string;
    f: TextFile;
begin
    l_file_name:= gRoamingFolderPath+'DropFileExt.log';
    AssignFile( f, l_file_name);
    Append(f);
    Writeln(f, DateTimeToStr(Now()) + ' | ' + i_msg);
    Flush(f);
    CloseFile(f);
end;

procedure OnActivate; cdecl;
begin
    Application.Handle := IDE_GetAppHandle;
    dw:= TfDropWindow.Create(Application);
    @dw.open_file_proc:= @IDE_OpenFile;
    dw.ParentWindow:= IDE_GetWindowHandle;
    dw.Init;
    dw.Show;
end;

procedure OnDeactivate; cdecl;
begin
    dw.Close;
    FreeAndNil(dw);
end;

// Called when the Plug-In is destroyed
procedure OnDestroy; cdecl;
begin
end;

procedure Configure; cdecl;
begin
  dw.DoConfig;
end;

function About: PChar;
begin
  Result:= Plugin_Desc+
           #13'©2018 VictoriousSoft Team'
         + #13#13'Solves Drag&Drop weakness functionality'
         + #13'eMail to author: victorious.soft@gmail.ru'
         + #13'or visit my GitHub page: github.com/victoriousya'
           ;
end;

exports
  IdentifyPlugIn,
  RegisterCallback,
  OnCreate,
  OnActivate,
  OnDeactivate,
  OnDestroy,
  Configure,
  About;

end.
