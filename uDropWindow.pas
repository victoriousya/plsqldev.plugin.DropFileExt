unit uDropWindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, Forms,
  ShellAPI, IniFiles, PlugInIntf;

const
  C_RX_PROGRAM = '.+\.spec\.sql|.+\.body\.sql|.+\.pks|.+\.pkb';
  C_RX_COMMAND = '.+\.view\.sql|.+\.type\.sql|.+\.data\.sql';
  C_RX_TEST = '.+\.tst';
  C_RX_SQL = '.+\.sql';

type
  TIDE_OpenFile = function(WindowType: Integer; Filename: PChar): Bool; cdecl;

  TfDropWindow = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DoConfig;
  private
    { Private declarations }
    rx_program : string;
    rx_command : string;
    rx_test : string;
    rx_sql : string;
    ini_file_name: string;
    function getWindowType(i_file_name: string): integer;
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure DoInvisible;
    function InitialPos: TPoint;
    procedure read_ini_settings;
    procedure write_ini_settings;
  public
    { Public declarations }
    open_file_proc: TIDE_OpenFile;
    procedure Init;
  end;

var
  fDropWindow: TfDropWindow;
  FullRgn, ClientRgn, CtlRgn: THandle;

implementation

uses
  RegExpr, Types, uPlugin, uDropFileExConfig;

{$R *.dfm}

procedure TfDropWindow.DoInvisible;
var
    AControl: TControl;
    A, Margin, X, Y, CtlX, CtlY: Integer;
begin
    Margin := (Width - ClientWidth) div 2;
    {First, get form region}
    FullRgn := CreateRectRgn(0, 0, Width, Height);
    {Find client area region}
    X := Margin;
    Y := Height - ClientHeight - Margin;
    ClientRgn := CreateRectRgn(X, Y, X + ClientWidth, Y + ClientHeight);
    {'Mask' out all but non-client areas}
    CombineRgn(FullRgn, FullRgn, ClientRgn, RGN_DIFF);
      {Now, walk through all the controls on the form and 'OR' them into the existing
    Full region}
    for A := 0 to ControlCount - 1 do
    begin
      AControl := Controls[A];
      if (AControl is TWinControl) or (AControl is TGraphicControl) then
        with AControl do
        begin
          if Visible then
          begin
            CtlX := X + Left;
            CtlY := Y + Top;
            CtlRgn := CreateRectRgn(CtlX, CtlY, CtlX + Width, CtlY + Height);
            CombineRgn(FullRgn, FullRgn, CtlRgn, RGN_OR);
          end;
        end;
    end;
    {When the region is all ready, put it into effect:}
    SetWindowRgn(Handle, FullRgn, TRUE);
end;

procedure TfDropWindow.write_ini_settings;
var
    ini          : TIniFile;
    RoamingFolder: string;
begin
    RoamingFolder:= uPlugin.gRoamingFolderPath;
    Self.ini_file_name:= RoamingFolder+'DropFileEx.ini';
    ini:= TIniFile.Create(Self.ini_file_name);
    ini.WriteInteger('position', 'left', Self.Left);
    ini.WriteInteger('position', 'top', Self.Top);

    ini.WriteString('regexp', 'program', rx_program);
    ini.WriteString('regexp', 'command', rx_command);
    ini.WriteString('regexp', 'test', rx_test);
    ini.WriteString('regexp', 'sql', rx_sql);

    ini.UpdateFile;
    ini.Free;
end;

procedure TfDropWindow.read_ini_settings;
var
    ini          : TIniFile;
    RoamingFolder: string;
begin
    RoamingFolder:= uPlugin.gRoamingFolderPath;
    Self.ini_file_name:= RoamingFolder+'DropFileEx.ini';
    ini:= TIniFile.Create(Self.ini_file_name);
    Self.Left:= ini.ReadInteger('position', 'left', Self.Left);
    Self.Top:= ini.ReadInteger('position', 'top', Self.Top);

    rx_program:= ini.ReadString('regexp', 'program', C_RX_PROGRAM);
    rx_command:= ini.ReadString('regexp', 'command', C_RX_COMMAND);
    rx_test:= ini.ReadString('regexp', 'test', C_RX_TEST);
    rx_sql:= ini.ReadString('regexp', 'sql', C_RX_SQL);

    ini.UpdateFile;
    ini.Free;
    Self.write_ini_settings;
end;


function TfDropWindow.InitialPos: TPoint;
var
  h: THandle;
  r: TRect;
begin
  h:= Self.GetTopParentHandle;
  GetWindowRect(h, r);
  Result.X:= r.Right - Self.Width - r.Left - 30;
  Result.Y:= r.Bottom - Self.Height - r.Top - 30;
end;

procedure TfDropWindow.Init;
var
  p: TPoint;
begin
  p:= InitialPos;
  Self.Left:= p.X;
  Self.Top:= p.Y;
  read_ini_settings;
  DragAcceptFiles(Self.Handle, True);
end;

procedure TfDropWindow.FormCreate(Sender: TObject);
begin
//  DoInvisible;
end;

procedure TfDropWindow.WMDropFiles(var Msg: TWMDropFiles);
var
  DropH: HDROP;               // дескриптор операции перетаскивания
  DroppedFileCount: Integer;  // количество переданных файлов
  FileNameLength: Integer;    // длина имени файла
  FileName: string;           // буфер, принимающий имя файла
  I: Integer;                 // итератор для прохода по списку
  DropPoint: TPoint;          // структура с координатами операции Dropbegin
begin
  inherited;
  // Сохраняем дескриптор
  DropH := Msg.Drop;
  try
    // Получаем количество переданных файлов
    DroppedFileCount := DragQueryFile(DropH, $FFFFFFFF, nil, 0);
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
      if Assigned(@open_file_proc) then
          open_file_proc(getWindowType(FileName), PChar(FileName));
    end;
    // Опционально: получаем координаты, по которым произошла операция Drop
    // DragQueryPoint(DropH, DropPoint);
    // ... что-то делаем с данными координатами здесь
  finally
    // Финализация - разрушаем дескриптор
    // не используйте DropH после выполнения данного кода...
    DragFinish(DropH);
  end;
  // Говорим о том, что сообщение обработано
  Msg.Result := 0;
end;

procedure TfDropWindow.FormDestroy(Sender: TObject);
begin
  Self.write_ini_settings;
  DragAcceptFiles(Self.Handle, False);
end;

function TfDropWindow.getWindowType(i_file_name: string): integer;
var
  rx: TRegExpr;
  function test_for(i_expression: string): Boolean;
  begin
    rx.Expression:= i_expression;
    Result:= rx.Exec;
  end;
begin
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
  rx.Free;

end;

procedure TfDropWindow.DoConfig;
begin
  uDropFileExConfig.DoConfig(TApplication(Self.Owner).Handle, rx_program, rx_command, rx_test, rx_SQL);
  Self.write_ini_settings;
  if not Self.Visible then Self.Show;
end;

end.
