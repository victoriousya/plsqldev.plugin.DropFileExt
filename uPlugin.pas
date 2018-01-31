unit uPlugin;

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ShellAPI;

const // Description of this Plug-In (as displayed in Plug-In configuration dialog)
  Plugin_Desc = 'File Drag&Drop master';

procedure SetRoamingFolderPath;

var
  PlugInID: Integer;
  gRoamingFolderPath: string;

var // Declaration of PL/SQL Developer callback functions
//  SYS_Version: function: Integer; cdecl;
//  SYS_Registry: function: PChar; cdecl;
//  SYS_RootDir: function: PChar; cdecl;
//  SYS_OracleHome: function: PChar; cdecl;
//
//  IDE_MenuState: procedure(ID, Index: Integer; Enabled: Bool); cdecl;
//  IDE_Connected: function: Bool; cdecl;
//  IDE_GetConnectionInfo: procedure(var Username, Password, Database: PChar); cdecl;
//  IDE_GetBrowserInfo: procedure(var ObjectType, ObjectOwner, ObjectName: PChar); cdecl;
//  IDE_GetWindowType: function: Integer; cdecl;
  IDE_GetAppHandle: function: Integer; cdecl;
  IDE_GetWindowHandle: function: Integer; cdecl;
  IDE_GetClientHandle: function: Integer; cdecl;
//  IDE_GetChildHandle: function: Integer; cdecl;
//
//  IDE_CreateWindow: procedure(WindowType: Integer; Text: PChar; Execute: Bool); cdecl;
  IDE_OpenFile: function(WindowType: Integer; Filename: PChar): Bool; cdecl;
//  IDE_SaveFile: function: Bool; cdecl;
//  IDE_CloseFile: procedure; cdecl;
//  IDE_SetReadOnly: procedure(ReadOnly: Bool); cdecl;
//
//  IDE_GetText: function: PChar; cdecl;
//  IDE_GetSelectedText: function: PChar; cdecl;
//  IDE_GetCursorWord: function: PChar; cdecl;
//  IDE_GetEditorHandle: function: Integer; cdecl;
//
//  SQL_Execute: function(SQL: PChar): Integer; cdecl;
//  SQL_FieldCount: function: Integer; cdecl;
//  SQL_Eof: function: Bool; cdecl;
//  SQL_Next: function: Integer; cdecl;
//  SQL_Field: function(Field: Integer): PChar; cdecl;
//  SQL_FieldName: function(Field: Integer): PChar; cdecl;
//  SQL_FieldIndex: function(Name: PChar): Integer; cdecl;
//  SQL_FieldType: function(Field: Integer): Integer; cdecl;

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

// Registration of PL/SQL Developer callback functions
procedure RegisterCallback(Index: Integer; Addr: Pointer); cdecl;
begin
  case Index of
//     1 : @SYS_Version := Addr;
//     2 : @SYS_Registry := Addr;
//     3 : @SYS_RootDir := Addr;
//     4 : @SYS_OracleHome := Addr;
//    10 : @IDE_MenuState := Addr;
//    11 : @IDE_Connected := Addr;
//    12 : @IDE_GetConnectionInfo := Addr;
//    13 : @IDE_GetBrowserInfo := Addr;
//    14 : @IDE_GetWindowType := Addr;
    15 : @IDE_GetAppHandle := Addr;
    16 : @IDE_GetWindowHandle := Addr;
    17 : @IDE_GetClientHandle := Addr;
//    18 : @IDE_GetChildHandle := Addr;
    19 : begin
//              @IDE_Refresh := Addr;
         end;
//    20 : @IDE_CreateWindow := Addr;
    21 : @IDE_OpenFile := Addr;
//    22 : @IDE_SaveFile := Addr;
//    23 : @IDE_Filename := Addr;
//    24 : @IDE_CloseFile := Addr;
//    25 : @IDE_SetReadOnly := Addr;
//    30 : @IDE_GetText := Addr;
//    31 : @IDE_GetSelectedText := Addr;
//    32 : @IDE_GetCursorWord := Addr;
//    33 : @IDE_GetEditorHandle := Addr;
//    40 : @SQL_Execute := Addr;
//    41 : @SQL_FieldCount := Addr;
//    42 : @SQL_Eof := Addr;
//    43 : @SQL_Next := Addr;
//    44 : @SQL_Field := Addr;
//    45 : @SQL_FieldName := Addr;
//    46 : @SQL_FieldIndex := Addr;
//    47 : @SQL_FieldType := Addr;
    64: begin
//           @IDE_RefreshMenus := Addr;
        end;
    65: begin
//           @IDE_SetMenuName :=Addr;
        end;
    67: begin
//           @IDE_SetMenuVisible :=Addr;
        end;
    68: begin
//           @IDE_GetMenulayout:= Addr;
        end;
  end;
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

exports
  IdentifyPlugIn,
  RegisterCallback,
  OnCreate,
  OnActivate,
  OnDeactivate,
  OnDestroy,
  Configure;

end.
