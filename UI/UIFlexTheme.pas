unit UIFlexTheme;

interface

uses FMX.UIFlexBuilder, FMX.UIFlexBuilder.Types, System.UITypes;

type
  TFlexTheme = class
  public
    class procedure ApplyHeaderStyle(ABuilder: TUIFlexBuilder); static;
    class procedure ApplyButtonPrimary(ABuilder: TUIFlexBuilder); static;
    class procedure ApplyButtonDanger(ABuilder: TUIFlexBuilder); static;
    class procedure ApplyListRowStyle(ABuilder: TUIFlexBuilder); static;
    class procedure ApplyListTitleStyle(ABuilder: TUIFlexBuilder); static;
    class procedure ApplyMenuStyle(ABuilder: TUIFlexBuilder); static;
  end;

implementation

{ TFlexTheme }

class procedure TFlexTheme.ApplyHeaderStyle(ABuilder: TUIFlexBuilder);
begin
  ABuilder
    .SetFieldSize(fsSmall)
    .SetButtonColor(TAlphaColors.Darkcyan, TAlphaColors.Cadetblue)
    .SetButtonTextColor(TAlphaColors.Ghostwhite, TAlphaColors.Ghostwhite);
end;

class procedure TFlexTheme.ApplyButtonPrimary(ABuilder: TUIFlexBuilder);
begin
  ABuilder
    .SetButtonColor(TAlphaColors.Darkcyan, TAlphaColors.Cadetblue)
    .SetButtonTextColor(TAlphaColors.White, TAlphaColors.White);
end;

class procedure TFlexTheme.ApplyButtonDanger(ABuilder: TUIFlexBuilder);
begin
  ABuilder
    .SetButtonColor(TAlphaColors.Darkred, TAlphaColors.Firebrick)
    .SetButtonTextColor(TAlphaColors.White, TAlphaColors.White);
end;

class procedure TFlexTheme.ApplyListRowStyle(ABuilder: TUIFlexBuilder);
begin
  ABuilder
    .SetButtonColor(TAlphaColors.Ghostwhite)
    .SetButtonTextColor(TAlphaColors.Darkslategray);
end;

class procedure TFlexTheme.ApplyListTitleStyle(ABuilder: TUIFlexBuilder);
begin
  ABuilder
    .SetButtonColor(TAlphaColors.White)
    .SetButtonTextColor(TAlphaColors.Darkgray);
end;

class procedure TFlexTheme.ApplyMenuStyle(ABuilder: TUIFlexBuilder);
begin
  ABuilder
    .SetFieldSize(fsSmall)
    .SetButtonColor(TAlphaColors.Ghostwhite, TAlphaColors.Darkgrey)
    .SetButtonTextColor(TAlphaColors.Darkgrey, TAlphaColors.Ghostwhite);
end;

end.
