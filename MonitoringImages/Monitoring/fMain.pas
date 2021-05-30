unit fMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, IPPeerClient,
  IPPeerServer, System.Tether.Manager, System.Tether.AppProfile, FMX.Memo.Types,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.Layouts;

const
  CImgWidth = 200;
  CImgHeight = 200;

type
  TfrmMain = class(TForm)
    MonitoringConnexion: TTetheringManager;
    MonitoringProfile: TTetheringAppProfile;
    EcranMosaique: TVertScrollBox;
    Mosaique: TFlowLayout;
    Memo1: TMemo;
    EcranZoomSurImageBackground: TRectangle;
    EcranZoomSurImage: TLayout;
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
    procedure EcranMosaiqueResized(Sender: TObject);
  private
    { Déclarations privées }
    procedure CalculeHauteurMosaique;
    procedure AddLog(Txt: string);
    procedure ClickSurImage(Sender: TObject);
    procedure RetireImage(ManagerIdentifier: string);
  public
    { Déclarations publiques }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses uScreenMonitoring;

procedure TfrmMain.AddLog(Txt: string);
begin
{$IFDEF DEBUG}
  Memo1.lines.insert(0, Txt);
  Memo1.GoToTextBegin;
{$ENDIF}
end;

procedure TfrmMain.CalculeHauteurMosaique;
var
  i: integer;
  c: tcontrol;
  NewHeight: single;
  CHeight: single;
begin
  NewHeight := 0;
  for i := 0 to Mosaique.ChildrenCount - 1 do
    if (Mosaique.Children[i] is tcontrol) then
    begin
      c := (Mosaique.Children[i] as tcontrol);
      ///
      CHeight := c.Margins.Top + c.Height + c.Margins.Bottom;
      if (NewHeight < c.Position.y + CHeight) then
        NewHeight := c.Position.y + CHeight;
      /// ==
      // NewHeight := max(NewHeight, c.Position.y + c.Margins.Top + c.Height +
      // c.Margins.Bottom);
      ///
    end;
  Mosaique.Height := Mosaique.Padding.Top + NewHeight + Mosaique.Padding.Bottom;
end;

procedure TfrmMain.ClickSurImage(Sender: TObject);
var
  img: timage;
begin
  if (Sender is timage) then
  begin
    img := Sender as timage;
    if (img.parent = Mosaique) then
    begin
      EcranZoomSurImage.Visible := true;
      EcranZoomSurImage.BringToFront;
      img.parent := EcranZoomSurImage;
      img.align := TAlignLayout.Contents;
      img.BringToFront;
    end
    else
    begin
      img.align := TAlignLayout.none;
      img.width := CImgWidth;
      img.Height := CImgHeight;
      img.parent := Mosaique;
      EcranZoomSurImage.Visible := false;
    end;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  MonitoringConnexion.Password := CMonitoringManagerPassword;
  MonitoringProfile.Group := CMonitoringGroupProfile;
  EcranZoomSurImage.Visible := false;
{$IFDEF DEBUG}
{$ELSE}
  Memo1.Visible := false;
{$ENDIF}
end;

procedure TfrmMain.MonitoringConnexionEndAutoConnect(Sender: TObject);
begin
  AddLog('endautoconnect');
end;

procedure TfrmMain.MonitoringConnexionEndManagersDiscovery
  (const Sender: TObject; const ARemoteManagers: TTetheringManagerInfoList);
begin
  AddLog('endmanagerdiscovery');
end;

procedure TfrmMain.MonitoringConnexionEndProfilesDiscovery
  (const Sender: TObject; const ARemoteProfiles: TTetheringProfileInfoList);
begin
  AddLog('endprofilesdiscovery');
end;

procedure TfrmMain.MonitoringConnexionError(const Sender, Data: TObject;
  AError: TTetheringError);
begin
  AddLog('error');
end;

procedure TfrmMain.MonitoringConnexionNewManager(const Sender: TObject;
  const AManagerInfo: TTetheringManagerInfo);
begin
  AddLog(AManagerInfo.ManagerIdentifier + '-' + AManagerInfo.ManagerName);
end;

procedure TfrmMain.MonitoringConnexionPairedFromLocal(const Sender: TObject;
  const AManagerInfo: TTetheringManagerInfo);
begin
  AddLog('pairedfromlocal');
end;

procedure TfrmMain.MonitoringConnexionPairedToRemote(const Sender: TObject;
  const AManagerInfo: TTetheringManagerInfo);
begin
  AddLog('pairedtoremote');
end;

procedure TfrmMain.MonitoringConnexionRemoteManagerShutdown
  (const Sender: TObject; const AManagerIdentifier: string);
begin
  AddLog('remotemanagershutdown');
  RetireImage(AManagerIdentifier);
end;

procedure TfrmMain.MonitoringConnexionRequestManagerPassword
  (const Sender: TObject; const ARemoteIdentifier: string;
  var Password: string);
begin
  AddLog('requestmanagerpassword');
end;

procedure TfrmMain.MonitoringConnexionRequestStorage(const Sender: TObject;
  var AStorage: TTetheringCustomStorage);
begin
  AddLog('requeststorage');
end;

procedure TfrmMain.MonitoringConnexionUnPairManager(const Sender: TObject;
  const AManagerInfo: TTetheringManagerInfo);
begin
  AddLog('unpairmanager');
  RetireImage(AManagerInfo.ManagerIdentifier);
end;

procedure TfrmMain.MonitoringProfileAcceptResource(const Sender: TObject;
  const AProfileId: string; const AResource: TCustomRemoteItem;
  var AcceptResource: Boolean);
begin
  AcceptResource := (AResource.Hint.StartsWith('ImageCapture-'));
end;

procedure TfrmMain.MonitoringProfileResourceReceived(const Sender: TObject;
  const AResource: TRemoteResource);
var
  i: integer;
  img: timage;
  ImgExists: Boolean;
begin
  if (AResource.Hint.StartsWith('ImageCapture-')) then
  begin
    ImgExists := false;
    // Recherche image dans la mosaïque
    for i := 0 to Mosaique.ChildrenCount - 1 do
      if (Mosaique.Children[i] is timage) then
      begin
        img := (Mosaique.Children[i] as timage);
        if (img.TagString = AResource.Hint) then
        begin
          ImgExists := true;
          break;
        end;
      end;
    // Recherche image en plein écran si elle n'est plus en mosaïque
    if not ImgExists then
      for i := 0 to EcranZoomSurImage.ChildrenCount - 1 do
        if (EcranZoomSurImage.Children[i] is timage) then
        begin
          img := (EcranZoomSurImage.Children[i] as timage);
          if (img.TagString = AResource.Hint) then
          begin
            ImgExists := true;
            break;
          end;
        end;
    // Image non trouvée, donc on la crée
    if not ImgExists then
    begin
      img := timage.Create(self);
      img.parent := Mosaique;
      img.Margins.Rect := rectf(5, 5, 5, 5);
      img.TagString := AResource.Hint;
      img.OnClick := ClickSurImage;
      img.width := CImgWidth;
      img.Height := CImgHeight;
      CalculeHauteurMosaique;
    end;
    img.Bitmap.LoadFromStream(AResource.Value.AsStream);
  end;
end;

procedure TfrmMain.RetireImage(ManagerIdentifier: string);
var
  i: integer;
  img: timage;
begin
  if ManagerIdentifier.IsEmpty then
    exit;
  for i := Mosaique.ChildrenCount - 1 downto 0 do
    if (Mosaique.Children[i] is timage) then
    begin
      img := (Mosaique.Children[i] as timage);
      if (img.TagString.EndsWith('-' + ManagerIdentifier)) then
      begin
        if (img.parent = EcranZoomSurImage) then
          EcranZoomSurImage.Visible := false;
        img.free;
      end;
    end;
end;

procedure TfrmMain.TetheringAppProfile1Resources0ResourceReceived
  (const Sender: TObject; const AResource: TRemoteResource);
begin
  // if AResource.Value.DataType = TResourceType.Integer then
  // AddLog(AResource.Value.AsInteger.ToString);
end;

procedure TfrmMain.EcranMosaiqueResized(Sender: TObject);
begin
  CalculeHauteurMosaique;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
