unit fMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  IPPeerClient, IPPeerServer, System.Tether.Manager, System.Tether.AppProfile;

type
  TForm2 = class(TForm)
    DrawTimer: TTimer;
    ScreenCaptureTimer: TTimer;
    MonitoringConnexionClient: TTetheringManager;
    MonitoringProfileClient: TTetheringAppProfile;
    procedure DrawTimerTimer(Sender: TObject);
    procedure ScreenCaptureTimerTimer(Sender: TObject);
    procedure MonitoringConnexionClientRequestManagerPassword
      (const Sender: TObject; const ARemoteIdentifier: string;
      var Password: string);
    procedure MonitoringConnexionClientNewManager(const Sender: TObject;
      const AManagerInfo: TTetheringManagerInfo);
    procedure MonitoringConnexionClientPairedToRemote(const Sender: TObject;
      const AManagerInfo: TTetheringManagerInfo);
    procedure MonitoringConnexionClientEndManagersDiscovery
      (const Sender: TObject; const ARemoteManagers: TTetheringManagerInfoList);
    procedure FormCreate(Sender: TObject);
    procedure MonitoringConnexionClientPairedFromLocal(const Sender: TObject;
      const AManagerInfo: TTetheringManagerInfo);
    procedure MonitoringConnexionClientEndProfilesDiscovery
      (const Sender: TObject; const ARemoteProfiles: TTetheringProfileInfoList);
  private
    { Déclarations privées }
    nb: integer;
    DecouverteEnCours: boolean;
    AffichageEcranModifie: boolean;
    TransfertEnCours: boolean;
  public
    { Déclarations publiques }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

uses
  System.Threading, System.IOUtils, uTetheringSetup;

procedure TForm2.DrawTimerTimer(Sender: TObject);
var
  FormeCree: TShape;
begin
  AffichageEcranModifie := true;
  case random(2) of
    0: // création rectangle
      FormeCree := TRectangle.Create(self);
  else // création cercle
    FormeCree := tcircle.Create(self);
  end;
  FormeCree.parent := self;
  FormeCree.Position.point := pointf(random(clientwidth), random(clientheight));
  FormeCree.size.size := pointf(random(clientwidth), random(clientheight));
  case random(2) of
    0:
      FormeCree.Stroke.Kind := TBrushKind.None;
  else
    FormeCree.Stroke.Kind := TBrushKind.solid;
  end;
  if (FormeCree.Stroke.Kind = TBrushKind.solid) then
  begin
    FormeCree.Stroke.Thickness := random(10);
    case random(5) of
      0:
        FormeCree.Stroke.Dash := TStrokeDash.solid;
      1:
        FormeCree.Stroke.Dash := TStrokeDash.Dash;
      3:
        FormeCree.Stroke.Dash := TStrokeDash.Dot;
      4:
        FormeCree.Stroke.Dash := TStrokeDash.DashDot;
    else
      FormeCree.Stroke.Dash := TStrokeDash.DashDotDot;
    end;
    FormeCree.Stroke.Color := $FF000000 + (random(256) * 256 * 256) +
      (random(256) * 256) + random(256);
  end;
  case random(2) of
    0:
      FormeCree.Fill.Kind := TBrushKind.None;
  else
    FormeCree.Fill.Kind := TBrushKind.solid;
  end;
  if (FormeCree.Fill.Kind = TBrushKind.solid) then
    FormeCree.Fill.Color := $FF000000 + (random(256) * 256 * 256) +
      (random(256) * 256) + random(256);
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  nb := 0;
  DecouverteEnCours := false;
  AffichageEcranModifie := false;
  TransfertEnCours := false;
  MonitoringProfileClient.Group := CMonitoringGroupProfile;
end;

procedure TForm2.MonitoringConnexionClientEndManagersDiscovery
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

procedure TForm2.MonitoringConnexionClientEndProfilesDiscovery
  (const Sender: TObject; const ARemoteProfiles: TTetheringProfileInfoList);
var
  i: integer;
begin
  for i := 0 to ARemoteProfiles.Count - 1 do
    if ARemoteProfiles[i].ProfileGroup = MonitoringProfileClient.Group then
      MonitoringProfileClient.Connect(ARemoteProfiles[i]);
end;

procedure TForm2.MonitoringConnexionClientNewManager(const Sender: TObject;
  const AManagerInfo: TTetheringManagerInfo);
begin
  if (1 > MonitoringConnexionClient.PairedManagers.IndexOf(AManagerInfo)) then
    MonitoringConnexionClient.PairManager(AManagerInfo);
end;

procedure TForm2.MonitoringConnexionClientPairedFromLocal(const Sender: TObject;
  const AManagerInfo: TTetheringManagerInfo);
begin
  MonitoringConnexionClient.DiscoverProfiles(AManagerInfo);
end;

procedure TForm2.MonitoringConnexionClientPairedToRemote(const Sender: TObject;
  const AManagerInfo: TTetheringManagerInfo);
begin
  MonitoringConnexionClient.DiscoverProfiles(AManagerInfo);
end;

procedure TForm2.MonitoringConnexionClientRequestManagerPassword
  (const Sender: TObject; const ARemoteIdentifier: string;
  var Password: string);
begin
  Password := CMonitoringManagerPassword;
end;

procedure TForm2.ScreenCaptureTimerTimer(Sender: TObject);
var
  bmp: tbitmap;
  mem: TMemoryStream;
begin
  if (not AffichageEcranModifie) or TransfertEnCours then
    exit;
  if (MonitoringConnexionClient.PairedManagers.Count > 0) and
    (MonitoringProfileClient.ConnectedProfiles.Count > 0) then
  begin
    TransfertEnCours := true;
    inc(nb);
    MonitoringProfileClient.Resources.FindByName('NumeroImage').value := nb;
    bmp := tbitmap.Create(clientwidth, clientheight);
    try
      paintto(bmp.Canvas);
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
                  'ImageCapture', mem);
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

initialization

randomize;
{$IFDEF DEBUG}
ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
