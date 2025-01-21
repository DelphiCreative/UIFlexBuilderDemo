unit UIFlexView;

interface

uses
  System.Classes, FMX.Layouts,FMX.Graphics,  System.UITypes;

type
  TFlexView = class

  public
     class function FindBitmapByName(const AName: string): TBitmap;
     class procedure BuildMenu(AOwner : TComponent; ATarget : TVertScrollBox);
  end;

implementation


{ TFlexView }

uses FMX.UIFlexBuilder, FMX.UIFlexBuilder.Types, Frm.Main;

class procedure TFlexView.BuildMenu(AOwner: TComponent;
  ATarget: TVertScrollBox);
var
  fxMenu: TUIFlexBuilder;
begin
  fxMenu := TUIFlexBuilder.Create(AOwner, ATarget);

  fxMenu
    .SetButtonColor(TAlphaColors.Ghostwhite, TAlphaColors.Darkgrey)
    .SetButtonTextColor(TAlphaColors.Darkgrey, TAlphaColors.Ghostwhite)

    .AddTitle('Demo UIFlexBuilder')
    .SetFieldSize(fsSmall)

    .AddTitle('Lançar')
      .AddButton('Despesa')
        .AddIcon(FindBitmapByName('Item 0'))
      .AddButton('Receita')
        .AddIcon(FindBitmapByName('Item 1'))

    .AddTitle('Categorias')
      .AddButton('Despesa')
         .AddIcon(FindBitmapByName('Item 3'))
      .AddButton('Receita')
         .AddIcon(FindBitmapByName('Item 6'))

    .AddTitle('Subcategorias')
      .AddButton('Despesa')
         .AddIcon(FindBitmapByName('Item 7'))
      .AddButton('Receita')
         .AddIcon(FindBitmapByName('Item 8'))
  ;

  fxMenu.free;
end;

class function TFlexView.FindBitmapByName(const AName: string): TBitmap;
begin
   Result := frmMain.FindBitmapByName(AName)
end;

end.
