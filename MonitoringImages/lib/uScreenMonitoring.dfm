object ScreenMonitoringLib: TScreenMonitoringLib
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 472
  Width = 684
  object ScreenCaptureTimer: TTimer
    Interval = 33
    OnTimer = ScreenCaptureTimerTimer
    Left = 264
    Top = 72
  end
  object MonitoringConnexionClient: TTetheringManager
    OnEndManagersDiscovery = MonitoringConnexionClientEndManagersDiscovery
    OnEndProfilesDiscovery = MonitoringConnexionClientEndProfilesDiscovery
    OnPairedFromLocal = MonitoringConnexionClientPairedFromLocal
    OnPairedToRemote = MonitoringConnexionClientPairedToRemote
    OnRequestManagerPassword = MonitoringConnexionClientRequestManagerPassword
    OnNewManager = MonitoringConnexionClientNewManager
    Text = 'MonitoringConnexionClient'
    AllowedAdapters = 'Network'
    Left = 560
    Top = 72
  end
  object MonitoringProfileClient: TTetheringAppProfile
    Manager = MonitoringConnexionClient
    Text = 'MonitoringProfileClient'
    Actions = <>
    Resources = <
      item
        Name = 'NumeroImage'
        IsPublic = True
      end>
    Left = 560
    Top = 176
  end
end
