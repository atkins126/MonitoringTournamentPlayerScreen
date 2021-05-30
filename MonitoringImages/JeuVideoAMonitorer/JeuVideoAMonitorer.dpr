program JeuVideoAMonitorer;

uses
  System.StartUpCopy,
  FMX.Forms,
  fMain in 'fMain.pas' {Form2},
  uScreenMonitoring in '..\lib\uScreenMonitoring.pas' {ScreenMonitoringLib: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
