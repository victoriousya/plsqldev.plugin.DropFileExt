library DropFileExt;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Classes,
  uPlugin in 'uPlugin.pas',
  RegExpr in 'regexpr.pas',
  uDropFileExConfig in 'uDropFileExConfig.pas' {fDropFileExConfig},
  PlugInIntf in '..\Common\PlugInIntf.pas' {$IFDEF DEBUG},
  DbugIntf in 'C:\Delphi7\Experts\GExperts\DbugIntf.pas' {$ENDIF};

{$R *.res}

begin
end.
