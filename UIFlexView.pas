unit UIFlexView;

interface

uses
  System.DateUtils,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.UIFlexBuilder,
  FMX.Dialogs, FMX.StdCtrls, System.StrUtils, System.SysUtils,
  System.Classes, FMX.Layouts,FMX.Graphics,  System.UITypes;

const
  LANCAR_CONTA = 1;
  LANCAR_SUBCATEGORIA = 2;

type
  TTipoCadastro = (tcCategoria, tcSubCategoria);

type
  TFlexView = class
  public
     class function FindBitmapByName(const AName: string): TBitmap;
     class function ValidarRetornoFlexForm(const AInput: String; out AID, AValue: String): Boolean;
     class procedure BuildMenu(AOwner : TComponent; ATarget : TVertScrollBox);
     class procedure BuildHeader(AFlexBuilder: TUIFlexBuilder);
     class procedure CadastrarItem(const AID, AValue: String; AFDQuery: TFDQuery; ATipo :TTipoCadastro = tcCategoria);
     class procedure CadastrarContas(const AID, ACategoria: String; const ATabContas, ATabSubcategorias: TFDQuery);
     class procedure OnClickCadastrarCategoria(Sender: TObject);
     class procedure OnClickCadastrarConta(Sender: TObject);
  end;

implementation

{ TFlexView }

uses  FMX.UIFlexBuilder.Types, Frm.Main,
  FMX.UIFlexBuilder.Forms, DM.Main;


class procedure TFlexView.BuildHeader(AFlexBuilder: TUIFlexBuilder);
begin
  AFlexBuilder.AddTitle('Lista de contas no período')

    // Campo para data de vencimento inicial
    .AddEditField('VencimentoInicial', 'Vencimento Inicial', 'dd/mm/aaaa', 160, fmtDate)
      .SetText(FormatDateTime('dd/mm/yyyy', StartOfTheMonth(Date)))

    // Campo para data de vencimento final
    .AddEditField('VencimentoFinal', 'Vencimento Final', 'dd/mm/aaaa', 160, fmtDate)
      .SetText(FormatDateTime('dd/mm/yyyy', EndOfTheMonth(Date)));

  AFlexBuilder.SetFieldSize(fsSmall)

    // Botão para consultar registros
    .AddButton('Consultar')
    .SetMargins(10, 27, 0, 0)
    .SetWidth(100)
    .AddIcon(FindBitmapByName('pesquisar'));

end;

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
      .AddButton('Despesa', OnClickCadastrarConta)
        .SetTag(LANCAR_CONTA)
        .AddIcon(FindBitmapByName('Item 0'))
      .AddButton('Receita', OnClickCadastrarConta)
        .SetTag(LANCAR_CONTA)
        .AddIcon(FindBitmapByName('Item 1'))

    .AddTitle('Categorias')
       .AddButton('Despesa',OnClickCadastrarCategoria)
          .AddIcon(FindBitmapByName('Item 3'))
       .AddButton('Receita',OnClickCadastrarCategoria)
          .AddIcon(FindBitmapByName('Item 6'))

    .AddTitle('Subcategorias')
      .AddButton('Despesa', OnClickCadastrarConta)
          .SetTag(LANCAR_SUBCATEGORIA)
          .AddIcon(FindBitmapByName('Item 7'))
      .AddButton('Receita',OnClickCadastrarConta)
          .SetTag(LANCAR_SUBCATEGORIA)
          .AddIcon(FindBitmapByName('Item 8'));

  fxMenu.free;
end;


class procedure TFlexView.CadastrarContas(const AID, ACategoria: String;const ATabContas, ATabSubcategorias: TFDQuery);
var
  FlexForm: TUIFlexForm;
begin

  ATabContas.Open('SELECT * FROM contas ORDER BY id DESC LIMIT 1');

  ATabSubcategorias.Filtered := False;
  ATabSubcategorias.Filter := 'ID_Categoria =' + QuotedStr(AID);
  ATabSubcategorias.Filtered := True;


  FlexForm := TUIFlexForm.Create('Lançar novo conta',700 );
  try

    FlexForm.FlexBuilder
      .AddNewLine(10)
      .AddEditField('id', 'Código', 50)
      .AddEditField('ID_Categoria', 'Categoria', 300)
          .SetText(ACategoria)
          .SetDefaultKeyValue(AID)

      .AddEditSearch('ID_Subcategoria', 'SubCategoria','', 'Selecione uma subcategoria', ATabSubcategorias, 300)

      .AddEditField('descricao', 'Descrição', 600)
      .AddEditField('NParcela', 'Parcelas', 50)
         .SetText('1')
      .AddEditField('DataVencimento', 'Data de vencimento','dd/mm/aaaa', 160, fmtDate)
         .SetText(FormatDateTime('dd/mm/yyyy', Date))
      .AddEditField('DataPagamento', 'Data de pagamento','dd/mm/aaaa', 160, fmtDate)
      .AddEditField('Valor', 'Valor', '0,00', 160, fmtDecimal )
      .AddEditField('ValorPago', 'Valor Pago', '0,00', 160, fmtDecimal);


    FlexForm.AddButtonSaveAndCancel;

    FlexForm.FlexBuilder.DataSet := ATabContas;
    FlexForm.FlexBuilder.KeyField := 'id';

    FlexForm.Show;
  finally
    FlexForm.Free;
  end;

end;

class procedure TFlexView.CadastrarItem(const AID, AValue: String; AFDQuery: TFDQuery; ATipo :TTipoCadastro = tcCategoria);
var
  FlexForm: TUIFlexForm;
  Titulo: String;
  Largura: Single;
begin

  case ATipo of

    tcCategoria:
    begin
       Titulo := 'Cadastro de categorias' ;
       Largura := 315;
    end;

    tcSubCategoria:
    begin
       Titulo := 'Cadastrar subcategoria' ;
       Largura := 400;
    end;
  end;

  FlexForm := TUIFlexForm.Create(Titulo);

  try
    FlexForm.FlexBuilder.AddNewLine(5)
      .AddEditField('id', 'Código', 50)
      .AddEditField('descricao', 'Descrição', Largura);

    if ATipo = tcCategoria then
       FlexForm.FlexBuilder.AddEditField('TipoMovimento', 'Tipo', 80)
    else
       FlexForm.FlexBuilder.AddEditField('ID_Categoria', 'Tipo', 450);

    FlexForm.FlexBuilder
        .SetText(AValue)
        .SetDefaultKeyValue(AID);

    FlexForm.AddButtonSaveAndCancel;

    FlexForm.AddValidationRule('descricao','"NotEmpty": true');

    FlexForm.FlexBuilder.DataSet := AFDQuery;
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
   CadastrarItem(TButton(Sender).TagString.Chars[0],TButton(Sender).TagString, tabCategorias);
end;

class procedure TFlexView.OnClickCadastrarConta(Sender: TObject);
var ID, Descricao, Retorno : String;
begin
   tabCategorias.Filtered := False;
   tabCategorias.Filter := 'TipoMovimento = ' +  QuotedStr(TButton(Sender).TagString.Chars[0]);
   tabCategorias.Filtered := True;

   Retorno := TUIFlexForm.ShowForm('Lista de categorias', tabCategorias);
   if ValidarRetornoFlexForm(Retorno, ID, Descricao) then begin

       case TButton(Sender).Tag of
          LANCAR_CONTA : CadastrarContas(ID, Descricao, tabContas, tabSubCategorias);
          LANCAR_SUBCATEGORIA: CadastrarItem(ID, Descricao, tabSubCategorias, tcSubCategoria);
       end;
   end;
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
