unit fMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, IPPeerClient,
  IPPeerServer, System.Tether.Manager, System.Tether.AppProfile, FMX.Memo.Types,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Objects;

type
  TfrmMain = class(TForm)
    MonitoringConnexion: TTetheringManager;
    MonitoringProfile: TTetheringAppProfile;
    Memo1: TMemo;
    Image1: TImage;
    procedure MonitoringConnexionNewManager(const Sender: TObject;
      const AManagerInfo: TTetheringManagerInfo);
    procedure TetheringAppProfile1Resources0ResourceReceived
      (const Sender: TObject; const AResource: TRemoteResource);
    procedure MonitoringConnexionEndAutoConnect(Sender: TObject);
    procedure MonitoringConnexionEndManagersDiscovery(const Sender: TObject;
      const ARemoteManagers: TTetheringManagerInfoList);
    procedure MonitoringConnexionEndProfilesDiscovery(const Sender: TObject;
      const ARemoteProfiles: TTetheringProfileInfoList);
    procedure MonitoringConnexionError(const Sender, Data: TObject;
      AError: TTetheringError);
    procedure MonitoringConnexionPairedFromLocal(const Sender: TObject;
      const AManagerInfo: TTetheringManagerInfo);
    procedure MonitoringConnexionPairedToRemote(const Sender: TObject;
      const AManagerInfo: TTetheringManagerInfo);
    procedure MonitoringConnexionRemoteManagerShutdown(const Sender: TObject;
      const AManagerIdentifier: string);
    procedure MonitoringConnexionRequestManagerPassword(const Sender: TObject;
      const ARemoteIdentifier: string; var Password: string);
    procedure MonitoringConnexionRequestStorage(const Sender: TObject;
      var AStorage: TTetheringCustomStorage);
    procedure MonitoringConnexionUnPairManager(const Sender: TObject;
      const AManagerInfo: TTetheringManagerInfo);
    procedure FormCreate(Sender: TObject);
    procedure MonitoringProfileAcceptResource(const Sender: TObject;
      const AProfileId: string; const AResource: TCustomRemoteItem;
      var AcceptResource: Boolean);
    procedure MonitoringProfileResourceReceived(const Sender: TObject;
      const AResource: TRemoteResource);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses uTetheringSetup;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  MonitoringConnexion.Password := CMonitoringManagerPassword;
  MonitoringProfile.Group := CMonitoringGroupProfile;
end;

procedure TfrmMain.MonitoringConnexionEndAutoConnect(Sender: TObject);
begin
  Memo1.Lines.Insert(0, 'endautoconnect');
end;

procedure TfrmMain.MonitoringConnexionEndManagersDiscovery
  (const Sender: TObject; const ARemoteManagers: TTetheringManagerInfoList);
begin
  Memo1.Lines.Insert(0, 'endmanagerdiscovery');
end;

procedure TfrmMain.MonitoringConnexionEndProfilesDiscovery
  (const Sender: TObject; const ARemoteProfiles: TTetheringProfileInfoList);
begin
  Memo1.Lines.Insert(0, 'endprofilesdiscovery');
end;

procedure TfrmMain.MonitoringConnexionError(const Sender, Data: TObject;
  AError: TTetheringError);
begin
  Memo1.Lines.Insert(0, 'error');
end;

procedure TfrmMain.MonitoringConnexionNewManager(const Sender: TObject;
  const AManagerInfo: TTetheringManagerInfo);
begin
  Memo1.Lines.Insert(0, AManagerInfo.ManagerIdentifier + '-' +
    AManagerInfo.ManagerName);
end;

procedure TfrmMain.MonitoringConnexionPairedFromLocal(const Sender: TObject;
  const AManagerInfo: TTetheringManagerInfo);
begin
  Memo1.Lines.Insert(0, 'pairedfromlocal');
end;

procedure TfrmMain.MonitoringConnexionPairedToRemote(const Sender: TObject;
  const AManagerInfo: TTetheringManagerInfo);
begin
  Memo1.Lines.Insert(0, 'pairedtoremote');
end;

procedure TfrmMain.MonitoringConnexionRemoteManagerShutdown
  (const Sender: TObject; const AManagerIdentifier: string);
begin
  Memo1.Lines.Insert(0, 'remotemanagershutdown');
end;

procedure TfrmMain.MonitoringConnexionRequestManagerPassword
  (const Sender: TObject; const ARemoteIdentifier: string;
  var Password: string);
begin
  Memo1.Lines.Insert(0, 'requestmanagerpassword');
end;

procedure TfrmMain.MonitoringConnexionRequestStorage(const Sender: TObject;
  var AStorage: TTetheringCustomStorage);
begin
  Memo1.Lines.Insert(0, 'requeststorage');
end;

procedure TfrmMain.MonitoringConnexionUnPairManager(const Sender: TObject;
  const AManagerInfo: TTetheringManagerInfo);
begin
  Memo1.Lines.Insert(0, 'unpairmanager');
end;

procedure TfrmMain.MonitoringProfileAcceptResource(const Sender: TObject;
  const AProfileId: string; const AResource: TCustomRemoteItem;
  var AcceptResource: Boolean);
begin
  AcceptResource := (AResource.Hint = 'ImageCapture');
end;

procedure TfrmMain.MonitoringProfileResourceReceived(const Sender: TObject;
  const AResource: TRemoteResource);
begin
  if (AResource.Hint = 'ImageCapture') then
    Image1.Bitmap.LoadFromStream(AResource.Value.AsStream);
end;

procedure TfrmMain.TetheringAppProfile1Resources0ResourceReceived
  (const Sender: TObject; const AResource: TRemoteResource);
begin
  if AResource.Value.DataType = TResourceType.Integer then
    Memo1.Lines.Insert(0, AResource.Value.AsInteger.ToString);
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
