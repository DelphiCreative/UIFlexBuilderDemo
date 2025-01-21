program UIFlexBuilderDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  Frm.Main in 'Forms\Frm.Main.pas' {frmMain},
  DM.Main in 'DataModule\DM.Main.pas' {dmMain: TDataModule},
  DC.Firedac.VersionControl in 'DC.Units\DC.Firedac.VersionControl.pas',
  DC.Logger in 'DC.Units\DC.Logger.pas',
  DC.DatabaseScripts in 'Scripts\DC.DatabaseScripts.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TdmMain, dmMain);
  Application.Run;
end.
