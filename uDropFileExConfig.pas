unit uDropFileExConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TfDropFileExConfig = class(TForm)
    pgc1: TPageControl;
    ts1: TTabSheet;
    ts2: TTabSheet;
    ts3: TTabSheet;
    ts4: TTabSheet;
    pnl1: TPanel;
    pnl2: TPanel;
    btn1: TButton;
    mmoProgram: TMemo;
    mmoCommand: TMemo;
    mmoTest: TMemo;
    mmoSQL: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure DoConfig(OwnerHandle: THandle; var rx_program, rx_command, rx_test, rx_sql : string);

//var
//  fDropFileExConfig: TfDropFileExConfig;

implementation

{$R *.dfm}

procedure DoConfig(OwnerHandle: THandle; var rx_program, rx_command, rx_test,
  rx_sql: string);
var
  f: TfDropFileExConfig;
begin
  Application.Handle:= OwnerHandle;
  f:= TfDropFileExConfig.Create(Application);
  f.mmoProgram.Lines.Text:= rx_program;
  f.mmoCommand.Lines.Text:= rx_command;
  f.mmoTest.Lines.Text:= rx_test;
  f.mmoSQL.Lines.Text:= rx_sql;
  if f.ShowModal = mrOk then begin
      rx_program:= f.mmoProgram.Lines.Text;
      rx_command:= f.mmoCommand.Lines.Text;
      rx_test:= f.mmoTest.Lines.Text;
      rx_sql:= f.mmoSQL.Lines.Text;
  end;
  FreeAndNil(f);
end;

end.
