unit fMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects;

type
  TForm2 = class(TForm)
    DrawTimer: TTimer;
    procedure DrawTimerTimer(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

uses uScreenMonitoring;

procedure TForm2.DrawTimerTimer(Sender: TObject);
var
  FormeCree: TShape;
begin
  ScreenMonitoringLib.AffichageEcranModifie := true;
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

initialization

randomize;
{$IFDEF DEBUG}
ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
