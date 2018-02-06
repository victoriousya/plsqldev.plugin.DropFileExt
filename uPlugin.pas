unit uPlugin;

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ShellAPI, PlugInIntf;

const // Description of this Plug-In (as displayed in Plug-In configuration dialog)
  Plugin_Desc = 'File Drag&Drop master';
  C_RX_PROGRAM = '.+\.spec\.sql|.+\.body\.sql|.+\.pks|.+\.pkb';
  C_RX_COMMAND = '.+\.view\.sql|.+\.type\.sql|.+\.data\.sql';
  C_RX_TEST = '.+\.tst';
  C_RX_SQL = '.+\.sql';

procedure SetRoamingFolderPath;

var
  gRoamingFolderPath: string;

implementation

uses
  ExtCtrls, StrUtils, RegExpr, uDropFileExConfig, IniFiles {$IFDEF DEBUG}, DbugIntf{$ENDIF};

var
  HookHandle: hHook;
  TheHandle: HWND;
  rx_program : string;
  rx_command : string;
  rx_test : string;
  rx_sql : string;
  ini_file_name: string;

procedure OutDebug(Str: string);
begin
{$IFDEF DEBUG}
  SendDebug(Str);
//  OutputDebugString(Str);
{$ENDIF}
end;

procedure OutDebugFmt(const Msg: string; const Args: array of const);
begin
{$IFDEF DEBUG}
  SendDebugFmt(Msg, Args);
//  OutputDebugString(Str);
{$ENDIF}
end;

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

procedure write_ini_settings;
var
    ini          : TIniFile;
    RoamingFolder: string;
begin
    RoamingFolder:= uPlugin.gRoamingFolderPath;
    ini_file_name:= RoamingFolder+'DropFileEx.ini';
    ini:= TIniFile.Create(ini_file_name);
//    ini.WriteInteger('position', 'left', Self.Left);
//    ini.WriteInteger('position', 'top', Self.Top);

    ini.WriteString('regexp', 'program', rx_program);
    ini.WriteString('regexp', 'command', rx_command);
    ini.WriteString('regexp', 'test', rx_test);
    ini.WriteString('regexp', 'sql', rx_sql);

    ini.UpdateFile;
    ini.Free;
end;

procedure read_ini_settings;
var
    ini          : TIniFile;
    RoamingFolder: string;
begin
    RoamingFolder:= gRoamingFolderPath;
    ini_file_name:= RoamingFolder+'DropFileEx.ini';
    ini:= TIniFile.Create(ini_file_name);
//    Self.Left:= ini.ReadInteger('position', 'left', Self.Left);
//    Self.Top:= ini.ReadInteger('position', 'top', Self.Top);

    rx_program:= ini.ReadString('regexp', 'program', C_RX_PROGRAM);
    rx_command:= ini.ReadString('regexp', 'command', C_RX_COMMAND);
    rx_test:= ini.ReadString('regexp', 'test', C_RX_TEST);
    rx_sql:= ini.ReadString('regexp', 'sql', C_RX_SQL);

    ini.UpdateFile;
    ini.Free;
    write_ini_settings;
end;


function getWindowType(i_file_name: string): integer;
var
  rx: TRegExpr;
  function test_for(i_expression: string): Boolean;
  begin
    rx.Expression:= i_expression;
    Result:= rx.Exec;
  end;
begin
  try
  try
    rx:= TRegExpr.Create;
    rx.ModifierI:= True;
    rx.ModifierS:= True;
    rx.InputString:= i_file_name;
    if test_for(rx_program) then
        result:= wtProcEdit
    else if test_for(rx_command) then
        result:= wtCommand
    else if test_for(rx_test) then
        result:= wtTest
    else if test_for(rx_sql) then
        result:= wtSQL
    else
        result:= wtNone;
except
  on E: Exception do
     result:= wtNone;
end;
finally
  rx.Free;
end;
end;


function ProcessFilesDrop(code: Integer; wparam: WPARAM; lparam: LPARAM): LRESULT; stdcall;
var
  msg: PMsg;
  procedure process(DropH: HDROP);
  var
    DroppedFileCount: Integer;  // количество переданных файлов
    FileNameLength: Integer;    // длина имени файла
    FileName: string;           // буфер, принимающий имя файла
    I: Integer;                 // итератор для прохода по списку
    DropPoint: TPoint;          // структура с координатами операции Dropbegin
 begin
    try
      // Получаем количество переданных файлов
      DroppedFileCount := DragQueryFile(DropH, $FFFFFFFF, nil, 0);
      OutDebugFmt('Files drop count %d', [DroppedFileCount]);
      // Получаем имя каждого файла и обрабатываем его
      for I := 0 to Pred(DroppedFileCount) do
      begin
        // получаем размер буфера
        FileNameLength := DragQueryFile(DropH, I, nil, 0);
        // создаем буфер, который может принять в себя строку с именем файла
        // (Delphi добавляет терминирующий ноль автоматически в конец строки)
        SetLength(FileName, FileNameLength);
        // получаем имя файла
        DragQueryFile(DropH, I, PChar(FileName), FileNameLength + 1);
        // что-то делаем с данным именем (все зависит от вашей фантазии)
        // ... код обработки пишем здесь
        IDE_OpenFile(getWindowType(FileName), PChar(FileName));
      end;
      // Опционально: получаем координаты, по которым произошла операция Drop
      // DragQueryPoint(DropH, DropPoint);
      // ... что-то делаем с данными координатами здесь
    finally
      // Финализация - разрушаем дескриптор
      // не используйте DropH после выполнения данного кода...
      DragFinish(DropH);
    end;
 end;
begin
  if Code < 0 then begin
    OutDebug('Drop files message '+ IntToStr(wparam)+ ' ' + IntToStr(code));
    Result:= CallNextHookEx(HookHandle, Code, wParam, lParam)
  end else begin
    msg:= Pointer(lparam);
    if (msg^.message = WM_DROPFILES) and ( wparam = PM_REMOVE) then begin
        process(msg^.wParam);
        msg^.message:= WM_NULL;
    end;
    Result:= CallNextHookEx(HookHandle, Code, wParam, lParam);
  end;
end;

procedure Start_Monitoring;
var
  TheThread: DWORD;
begin
  HookHandle:= 0;
  TheHandle:= IDE_GetWindowHandle;
  if TheHandle <> 0 then begin
    TheThread:= GetWindowThreadProcessId(TheHandle, nil);
    OutDebugFmt('The handle %x The thread %x', [TheHandle, TheThread]);
    HookHandle:= SetWindowsHookEx(WH_GETMESSAGE, ProcessFilesDrop, HInstance, TheThread);
    if HookHandle = 0 then OutDebug( 'Setting Hook Failed.') else OutDebug( 'Setting Hook Success.')
  end;
end;

procedure Stop_Monitoring;
begin
  if HookHandle > 0 then UnhookWindowsHookEx(HookHandle);
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
    OutDebug('Activated');
    read_ini_settings;
    Start_Monitoring;
end;

procedure OnDeactivate; cdecl;
begin
    Stop_Monitoring;
    write_ini_settings;
end;

// Called when the Plug-In is destroyed
procedure OnDestroy; cdecl;
begin
end;

procedure Configure; cdecl;
begin
  uDropFileExConfig.DoConfig(IDE_GetAppHandle, rx_program, rx_command, rx_test, rx_SQL);
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
