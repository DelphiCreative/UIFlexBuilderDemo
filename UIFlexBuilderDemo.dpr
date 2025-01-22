program UIFlexBuilderDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  Frm.Main in 'Forms\Frm.Main.pas' {frmMain},
  DM.Main in 'DataModule\DM.Main.pas' {dmMain: TDataModule},
  DC.Firedac.VersionControl in 'DC.Units\DC.Firedac.VersionControl.pas',
  DC.Logger in 'DC.Units\DC.Logger.pas',
  DC.DatabaseScripts in 'Scripts\DC.DatabaseScripts.pas',
  DC.Helper.Utils in 'DC.Units\DC.Helper.Utils.pas',
  FMX.UIFlexBuilder.Classes in 'UIFlex.Units\FMX.UIFlexBuilder.Classes.pas',
  FMX.UIFlexBuilder.Dialogs in 'UIFlex.Units\FMX.UIFlexBuilder.Dialogs.pas',
  FMX.UIFlexBuilder.Forms in 'UIFlex.Units\FMX.UIFlexBuilder.Forms.pas',
  FMX.UIFlexBuilder.MaskEvents in 'UIFlex.Units\FMX.UIFlexBuilder.MaskEvents.pas',
  FMX.UIFlexBuilder in 'UIFlex.Units\FMX.UIFlexBuilder.pas',
  FMX.UIFlexBuilder.Types in 'UIFlex.Units\FMX.UIFlexBuilder.Types.pas',
  FMX.UIFlexBuilder.Utils in 'UIFlex.Units\FMX.UIFlexBuilder.Utils.pas',
  DC.Utils in 'DC.Units\DC.Utils.pas',
  UIFlexView in 'UIFlexView.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
