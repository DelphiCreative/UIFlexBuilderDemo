unit UIFlexView;

interface

uses
  FMX.Dialogs, FMX.StdCtrls, System.StrUtils, System.SysUtils,
  System.Classes, FMX.Layouts,FMX.Graphics,  System.UITypes;

type
  TFlexView = class
  public
     class procedure OnClickCadastrarCategoria(Sender: TObject);
     class function FindBitmapByName(const AName: string): TBitmap;
     class procedure BuildMenu(AOwner : TComponent; ATarget : TVertScrollBox);
  end;

implementation


{ TFlexView }

uses FMX.UIFlexBuilder, FMX.UIFlexBuilder.Types, Frm.Main,
  FMX.UIFlexBuilder.Forms, DM.Main;

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
        .OnClick(OnClickCadastrarCategoria)
        .AddIcon(FindBitmapByName('Item 3'))
      .AddButton('Receita')
        .OnClick(OnClickCadastrarCategoria)
        .AddIcon(FindBitmapByName('Item 6'))

    .AddTitle('Subcategorias')
      .AddButton('Despesa')
        .AddIcon(FindBitmapByName('Item 7'))
      .AddButton('Receita')
        .AddIcon(FindBitmapByName('Item 8'));

  fxMenu.free;
end;

class function TFlexView.FindBitmapByName(const AName: string): TBitmap;
begin
   Result := frmMain.FindBitmapByName(AName)
end;

class procedure TFlexView.OnClickCadastrarCategoria(Sender: TObject);
var FlexForm : TUIFlexForm;
begin

   FlexForm := TUIFlexForm.Create('Cadastro de categorias');

   try
      FlexForm.FlexBuilder
       .AddNewLine(5)
       .AddEditField('id', 'Código', 50)
       .AddEditField('descricao', 'Descrição', 315)
       .AddEditField('TipoMovimento', 'Tipo', 80)
          .SetText(TButton(Sender).TagString.ToUpper)
          .SetDefaultKeyValue( TButton(Sender).TagString.ToUpper.Chars[0])
          ;

      FlexForm.AddButtonSaveAndCancel;

      FlexForm.AddValidationRule('descricao','"NotEmpty" : true');

      FlexForm.FlexBuilder.DataSet := tabCategorias;
      FlexForm.FlexBuilder.KeyField := 'id';

      FlexForm.Show;
   finally
     FlexForm.Free;
   end;

end;

end.
