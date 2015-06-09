program NetTraf;

uses
  Forms,
  NTMain in 'NTMain.pas' {NetTrafForm},
  NFConfig in 'NFConfig.pas' {NetTrafConfigForm},
  About in 'About.pas' {AboutForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'NetTraf';
  Application.ShowMainForm := False;
  Application.CreateForm(TNetTrafForm, NetTrafForm);
  Application.Run;
end.
