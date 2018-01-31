program DropFileExt_test;

uses
  Forms,
  uDropWindow in '..\uDropWindow.pas' {fDropWindow};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfDropWindow, fDropWindow);
  Application.Run;
end.
