unit uScreenMonitoring;

interface

uses
  System.SysUtils, System.Classes, IPPeerClient, IPPeerServer,
  System.Tether.Manager, System.Tether.AppProfile, FMX.Types, FMX.Forms;

const
  CMonitoringGroupProfile = '{B876EAF0-EBD6-4AED-BDA5-3B2B4BEBA723}';
  CMonitoringManagerPassword = '{34D7A2DC-0576-4E7A-9586-731A819E1A69}';

type
  TScreenMonitoringLib = class(TDataModule)
    ScreenCaptureTimer: TTimer;
    MonitoringConnexionClient: TTetheringManager;
    MonitoringProfileClient: TTetheringAppProfile;
    procedure ScreenCaptureTimerTimer(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure MonitoringConnexionClientRequestManagerPassword
      (const Sender: TObject; const ARemoteIdentifier: string;
      var Password: string);
    procedure MonitoringConnexionClientEndManagersDiscovery
      (const Sender: TObject; const ARemoteManagers: TTetheringManagerInfoList);
    procedure MonitoringConnexionClientEndProfilesDiscovery
      (const Sender: TObject; const ARemoteProfiles: TTetheringProfileInfoList);
    procedure MonitoringConnexionClientNewManager(const Sender: TObject;
      const AManagerInfo: TTetheringManagerInfo);
    procedure MonitoringConnexionClientPairedToRemote(const Sender: TObject;
      const AManagerInfo: TTetheringManagerInfo);
    procedure MonitoringConnexionClientPairedFromLocal(const Sender: TObject;
      const AManagerInfo: TTetheringManagerInfo);
  private
    { Déclarations privées }
    nb: integer;
    DecouverteEnCours: boolean;
    TransfertEnCours: boolean;
    FAffichageEcranModifie: boolean;
    procedure SetAffichageEcranModifie(const Value: boolean);
    function getActiveForm: TForm;
  public
    { Déclarations publiques }
    property AffichageEcranModifie: boolean read FAffichageEcranModifie
      write SetAffichageEcranModifie;
  end;

function ScreenMonitoringLib: TScreenMonitoringLib;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}

uses
  System.Threading, System.IOUtils, FMX.graphics;

procedure TScreenMonitoringLib.DataModuleCreate(Sender: TObject);
begin
  nb := 0;
  DecouverteEnCours := false;
  AffichageEcranModifie := false;
  TransfertEnCours := false;
  MonitoringProfileClient.Group := CMonitoringGroupProfile;
end;

function TScreenMonitoringLib.getActiveForm: TForm;
var
  i: integer;
  frm: TForm;
begin
  if (application.MainForm is TForm) then
    result := (application.MainForm as TForm)
  else
    result := nil;
  for i := 0 to application.ComponentCount - 1 do
    if (application.Components[i] is TForm) then
    begin
      frm := (application.Components[i] as TForm);
      if frm.Active then
      begin
        result := frm;
        break;
      end;
    end;
end;

procedure TScreenMonitoringLib.MonitoringConnexionClientEndManagersDiscovery
  (const Sender: TObject; const ARemoteManagers: TTetheringManagerInfoList);
var
  i: integer;
begin
  for i := 0 to ARemoteManagers.Count - 1 do
    if (1 > MonitoringConnexionClient.PairedManagers.IndexOf(ARemoteManagers[i]))
    then
      MonitoringConnexionClient.PairManager(ARemoteManagers[i]);
  DecouverteEnCours := false;
end;

procedure TScreenMonitoringLib.MonitoringConnexionClientEndProfilesDiscovery
  (const Sender: TObject; const ARemoteProfiles: TTetheringProfileInfoList);
var
  i: integer;
begin
  for i := 0 to ARemoteProfiles.Count - 1 do
    if ARemoteProfiles[i].ProfileGroup = MonitoringProfileClient.Group then
      MonitoringProfileClient.Connect(ARemoteProfiles[i]);
end;

procedure TScreenMonitoringLib.MonitoringConnexionClientNewManager
  (const Sender: TObject; const AManagerInfo: TTetheringManagerInfo);
begin
  if (1 > MonitoringConnexionClient.PairedManagers.IndexOf(AManagerInfo)) then
    MonitoringConnexionClient.PairManager(AManagerInfo);
end;

procedure TScreenMonitoringLib.MonitoringConnexionClientPairedFromLocal
  (const Sender: TObject; const AManagerInfo: TTetheringManagerInfo);
begin
  MonitoringConnexionClient.DiscoverProfiles(AManagerInfo);
end;

procedure TScreenMonitoringLib.MonitoringConnexionClientPairedToRemote
  (const Sender: TObject; const AManagerInfo: TTetheringManagerInfo);
begin
  MonitoringConnexionClient.DiscoverProfiles(AManagerInfo);
end;

procedure TScreenMonitoringLib.MonitoringConnexionClientRequestManagerPassword
  (const Sender: TObject; const ARemoteIdentifier: string;
  var Password: string);
begin
  Password := CMonitoringManagerPassword;
end;

procedure TScreenMonitoringLib.ScreenCaptureTimerTimer(Sender: TObject);
var
  bmp: tbitmap;
  mem: TMemoryStream;
  frm: TForm;
begin
  if (not AffichageEcranModifie) or TransfertEnCours then
    exit;
  if (MonitoringConnexionClient.PairedManagers.Count > 0) and
    (MonitoringProfileClient.ConnectedProfiles.Count > 0) then
  begin
    TransfertEnCours := true;
    inc(nb);
    MonitoringProfileClient.Resources.FindByName('NumeroImage').Value := nb;
    frm := getActiveForm;
    bmp := tbitmap.Create(frm.clientwidth, frm.clientheight);
    try
      frm.paintto(bmp.Canvas);
      // bmp.SaveToFile(tpath.combine(tpath.GetDocumentsPath, 'CopieEcran.jpg'));
      mem := TMemoryStream.Create;
      try
        bmp.SaveToStream(mem);
        ttask.run(
          procedure
          var
            i: integer;
          begin
            try
              for i := 0 to MonitoringProfileClient.ConnectedProfiles.
                Count - 1 do
              begin
                mem.Position := 0;
                MonitoringProfileClient.SendStream
                  (MonitoringProfileClient.ConnectedProfiles[i],
                  'ImageCapture-' + MonitoringConnexionClient.Identifier, mem);
                // TODO : retirer ManagerIdentifier de la description lorsque le AResource côté réception aura son RemoteProfile renseigné (cf QP)
              end;
            finally
              mem.free;
              TransfertEnCours := false;
            end;
          end);
      except
        mem.free;
        TransfertEnCours := false;
      end;
    finally
      bmp.free;
    end;
  end
  else if not DecouverteEnCours then
  begin
    DecouverteEnCours := true;
    MonitoringConnexionClient.DiscoverManagers;
  end;
end;

procedure TScreenMonitoringLib.SetAffichageEcranModifie(const Value: boolean);
begin
  FAffichageEcranModifie := Value;
end;

var
  LocalScreenMonitoringLib: TScreenMonitoringLib;

function ScreenMonitoringLib: TScreenMonitoringLib;
begin
  if not assigned(LocalScreenMonitoringLib) then
    LocalScreenMonitoringLib := TScreenMonitoringLib.Create(application);
  result := LocalScreenMonitoringLib;
end;

initialization

LocalScreenMonitoringLib := nil;

finalization

// if assigned(LocalScreenMonitoringLib) then
// LocalScreenMonitoringLib.free;

end.
