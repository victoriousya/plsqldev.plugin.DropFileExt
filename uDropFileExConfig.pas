unit uDropFileExConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfDropFileExConfig = class(TForm)
    edtProgram: TEdit;
    edtCommand: TEdit;
    edtTest: TEdit;
    edtSQL: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    btn1: TButton;
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
  f.edtProgram.Text:= rx_program;
  f.edtCommand.Text:= rx_command;
  f.edtTest.Text:= rx_test;
  f.edtSQL.Text:= rx_sql;
  if f.ShowModal = mrOk then begin
      rx_program:= f.edtProgram.Text;
      rx_command:= f.edtCommand.Text;
      rx_test:= f.edtTest.Text;
      rx_sql:= f.edtSQL.Text;
  end;
  FreeAndNil(f);
end;

end.
