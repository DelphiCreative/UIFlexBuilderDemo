unit UIFlexView;

interface

uses
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FMX.Dialogs, FMX.StdCtrls, System.StrUtils, System.SysUtils,
  System.Classes, FMX.Layouts,FMX.Graphics,  System.UITypes;

type
  TFlexView = class
  public
     class function FindBitmapByName(const AName: string): TBitmap;
     class function ValidarRetornoFlexForm(const AInput: String; out AID, AValue: String): Boolean;
     class procedure BuildMenu(AOwner : TComponent; ATarget : TVertScrollBox);
     class procedure CadastrarCategoria(TipoMovimento: String);
     class procedure CadastrarSubCategoria(ID, Categoria: String);
     class procedure OnClickCadastrarCategoria(Sender: TObject);
     class procedure OnClickCadastrarSubcategoria(Sender: TObject);
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
      .AddButton('Despesa').AddIcon(FindBitmapByName('Item 0'))
      .AddButton('Receita').AddIcon(FindBitmapByName('Item 1'))

    .AddTitle('Categorias')
       .AddButton('Despesa',OnClickCadastrarCategoria).AddIcon(FindBitmapByName('Item 3'))
       .AddButton('Receita',OnClickCadastrarCategoria).AddIcon(FindBitmapByName('Item 6'))

    .AddTitle('Subcategorias')
      .AddButton('Despesa', OnClickCadastrarSubcategoria).AddIcon(FindBitmapByName('Item 7'))
      .AddButton('Receita',OnClickCadastrarSubcategoria).AddIcon(FindBitmapByName('Item 8'));

  fxMenu.free;
end;

class procedure TFlexView.CadastrarCategoria(TipoMovimento: String);
var
   FlexForm : TUIFlexForm;
begin

   FlexForm := TUIFlexForm.Create('Cadastro de categorias');

   try
      FlexForm.FlexBuilder
       .AddNewLine(5)
       .AddEditField('id', 'Código', 50)
       .AddEditField('descricao', 'Descrição', 315)
       .AddEditField('TipoMovimento', 'Tipo', 80)
          .SetText(TipoMovimento.ToUpper)
          .SetDefaultKeyValue(TipoMovimento.Chars[0]);

      FlexForm.AddButtonSaveAndCancel;

      FlexForm.AddValidationRule('descricao','"NotEmpty" : true');

      FlexForm.FlexBuilder.DataSet := tabCategorias;
      FlexForm.FlexBuilder.KeyField := 'id';

      FlexForm.Show;
   finally
     FlexForm.Free;
   end;

end;

class procedure TFlexView.CadastrarSubCategoria(ID, Categoria: String);
var
  FlexForm: TUIFlexForm;
begin

  FlexForm := TUIFlexForm.Create('Cadastrar subcategoria');
  try
    FlexForm.FlexBuilder.AddNewLine(5)
      .AddEditField('id', 'Código', 50)
      .AddEditField('descricao', 'Descrição', 400)
      .AddEditField('ID_Categoria', 'Tipo', 450)
        .SetText(Categoria)
        .SetDefaultKeyValue(ID);

    FlexForm.AddButtonSaveAndCancel;

    FlexForm.AddValidationRule('descricao','"NotEmpty": true');

    FlexForm.FlexBuilder.DataSet := tabSubCategorias;
    FlexForm.FlexBuilder.KeyField := 'id';

    FlexForm.Show;
  finally
    FlexForm.Free;
  end;

end;

class function TFlexView.FindBitmapByName(const AName: string): TBitmap;
begin
   Result := frmMain.FindBitmapByName(AName)
end;

class procedure TFlexView.OnClickCadastrarCategoria(Sender: TObject);
begin
   CadastrarCategoria(TButton(Sender).TagString);
end;

class procedure TFlexView.OnClickCadastrarSubcategoria(Sender: TObject);
var ID, Descricao, Retorno : String;
begin
   tabCategorias.Filtered := False;
   tabCategorias.Filter := 'TipoMovimento = ' +  QuotedStr(TButton(Sender).TagString.Chars[0]);
   tabCategorias.Filtered := True;

   Retorno := TUIFlexForm.ShowForm('Lista de categorias', tabCategorias);
   if ValidarRetornoFlexForm(Retorno, ID, Descricao) then
       CadastrarSubCategoria(ID,Descricao);

end;

class function TFlexView.ValidarRetornoFlexForm(const AInput: String; out AID, AValue: String): Boolean;
var
  Parts: TArray<String>;
begin
  Result := False;
  AValue := '';
  AID := '';

  if not AInput.IsEmpty then
  begin
    Parts := AInput.Split(['|']);
    if Length(Parts) = 2 then
    begin
      AID := Parts[0];
      AValue := Parts[1];
      Result := True;
    end;
  end;
end;

end.
