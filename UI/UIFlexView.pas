unit UIFlexView;

interface

uses
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FMX.Controls,
  FMX.Dialogs,
  FMX.Graphics,
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Types,
  FMX.Objects,
  FMX.UIFlexBuilder,
  System.Classes,
  System.DateUtils,
  System.JSON,
  System.StrUtils,
  System.SysUtils,
  System.UITypes,
  UIFlexTypes;

const
  LANCAR_CONTA = 1;
  LANCAR_SUBCATEGORIA = 2;

  WIDTH_DESCRICAO = 200;
  WIDTH_STATUS = 70;
  WIDTH_VENCIMENTO = 80;
  WIDTH_VALOR = 80;
  WIDTH_DATA_PAGAMENTO = 80;
  WIDTH_VALOR_PAGO = 80;

type
  TFlexView = class
  public
     class function CreateLayout(AControl: TControl; AHeight: Single;APaddingLeft: Single = 0): TFlowLayout;
     class function FindBitmapByName(const AName: string): TBitmap;
     class function ValidateFlexFormReturn(const AInput: String; out AID, AValue: String): Boolean;
     class procedure BuildList(AOwner: TComponent; AVertTarget: TVertScrollBox; AFDQuery: TFDQuery);
     class procedure BuildHeader(AFlexBuilder: TUIFlexBuilder);
     class procedure BuildMenu(AOwner : TComponent; ATarget : TVertScrollBox);
     class procedure RegisterItem(const AID, AValue: String; AFDQuery: TFDQuery; ATipo :TTipoCadastro = tcCategoria);
     class procedure RegisterContas(const AID, ACategoria: String; const ATabContas, ATabSubcategorias: TFDQuery);
     class procedure LoadContas(AFlexBuilder: TUIFlexBuilder);
     class procedure UpdateItemInList(const AID: String);
     class procedure DeleteItemFromList(const AID: String);
     class procedure OnClickUpdateItem(Sender: TObject);
     class procedure OnClickDeleteItem(Sender: TObject);
     class procedure OnClickRegisterCategoria(Sender: TObject);
     class procedure OnClickRegisterConta(Sender: TObject);
     class procedure OnClickConsultContas(Sender: TObject);
 end;

implementation

{ TFlexView }

uses  FMX.UIFlexBuilder.Types, Frm.Main,
  FMX.UIFlexBuilder.Forms, DM.Main, FMX.UIFlexBuilder.Dialogs,
  DC.DatabaseScripts, FMX.UIFlexBuilder.Utils, DC.Firedac.VersionControl,
  UIFlexTheme, FMX.UIFlexBuilder.Classes;

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
     .SetButtonColor(TAlphaColors.Darkcyan, TAlphaColors.Cadetblue)
     .SetButtonTextColor(TAlphaColors.Ghostwhite, TAlphaColors.Ghostwhite)
    // Botão para consultar registros
    .AddButton('Consultar', OnClickConsultContas)
    .SetMargins(10, 27, 0, 0)
    .SetWidth(100)
    .AddIcon(FindBitmapByName('pesquisar'));

  LoadContas(AFlexBuilder);

end;

class procedure TFlexView.BuildList(AOwner: TComponent;
  AVertTarget: TVertScrollBox; AFDQuery: TFDQuery);
var
  fxBuilder: TUIFlexBuilder;
  Layout : TFlowLayout;
  sGroupBy : String;
  Totais : TTotais;
  txt : TFlexText;
begin

  TFlexUtils.ClearComponents(AVertTarget);

  AVertTarget.BeginUpdate;

  fxBuilder := TUIFlexBuilder.Create(AOwner, AVertTarget);
  fxBuilder.AddTitle('Lista de movimentos');

  AFDQuery.First;
  while not AFDQuery.Eof do begin

    if sGroupBy <> AFDQuery.Fields[IDX_TIPO_MOVIMENTO].AsString  then begin
       sGroupBy := AFDQuery.Fields[IDX_TIPO_MOVIMENTO].AsString;

       Layout := CreateLayout(AVertTarget, 40);
       fxBuilder.InParent(Layout);
       fxBuilder.AddTitle('Lista de movimentos: '+ sGroupBy, 12);

       Layout := CreateLayout(AVertTarget, 40);
       fxBuilder.InParent(Layout);
       fxBuilder.SetButtonColor(TAlphaColors.White).SetButtonTextColor(TAlphaColors.Darkgray);

       fxBuilder.AddTextBox('Descrição',0,WIDTH_DESCRICAO);
       fxBuilder.AddTextBox('Status',0, WIDTH_STATUS );
       fxBuilder.AddTextBox('Vencimento',0, WIDTH_VENCIMENTO);
       fxBuilder.AddTextBox('Valor',0, WIDTH_VALOR);
       fxBuilder.AddTextBox('Data de Pagamento',0,WIDTH_DATA_PAGAMENTO);
       fxBuilder.AddTextBox('Valor Pago',0,WIDTH_VALOR_PAGO);
    end;

    fxBuilder.SetButtonColor(TAlphaColors.Ghostwhite);
    fxBuilder.SetButtonTextColor(TAlphaColors.Darkslategray);

    Layout := CreateLayout(AVertTarget, 40);
    fxBuilder.InParent(Layout);

    fxBuilder.AddTextBox(AFDQuery.Fields[IDX_DESCRICAO].AsString,0,WIDTH_DESCRICAO);
    fxBuilder.AddTextBox(AFDQuery.Fields[IDX_STATUS].AsString,0, WIDTH_STATUS );
    fxBuilder.AddTextBox(AFDQuery.Fields[IDX_VENCIMENTO].AsString,0, WIDTH_VENCIMENTO);
    fxBuilder.AddTextBox(AFDQuery.Fields[IDX_VALOR_FORMATADO].AsString,0, WIDTH_VALOR);
    fxBuilder.AddTextBox(AFDQuery.Fields[IDX_PAGAMENTO].AsString,0,WIDTH_DATA_PAGAMENTO,0);

    if AFDQuery.Fields[IDX_PAGAMENTO].AsString <> '' then
       fxBuilder.AddTextBox(AFDQuery.Fields[IDX_VALOR_PAGO_FORMATADO].AsString,0,WIDTH_VALOR_PAGO)
    else
       fxBuilder.AddTextBox('',0,WIDTH_VALOR_PAGO);

    fxBuilder.SetFieldSize(fsSmall);

    fxBuilder
     .SetButtonColor(TAlphaColors.Darkcyan, TAlphaColors.Cadetblue)
     .SetButtonTextColor(TAlphaColors.Ghostwhite, TAlphaColors.Ghostwhite);

    fxBuilder.AddButton('', OnClickUpdateItem)
      .SetTag(AFDQuery.Fields[IDX_ID].AsInteger)
      .SetWidth(40)
      .AddIcon(FindBitmapByName('save'));

    fxBuilder
     .SetButtonColor(TAlphaColors.Darkred, TAlphaColors.Firebrick)
     .SetButtonTextColor(TAlphaColors.Ghostwhite, TAlphaColors.Ghostwhite);

    TFlexTheme.ApplyButtonDanger(fxBuilder);

    fxBuilder.AddButton('', OnClickDeleteItem)
      .SetTag(AFDQuery.Fields[IDX_ID].AsInteger)
      .SetWidth(40)
      .AddIcon(FindBitmapByName('delete'));

    AFDQuery.Next;
  end;

  AVertTarget.EndUpdate;
  fxBuilder.free;
end;

class procedure TFlexView.BuildMenu(AOwner: TComponent;
  ATarget: TVertScrollBox);
var
  fxMenu: TUIFlexBuilder;
begin
  fxMenu := TUIFlexBuilder.Create(AOwner, ATarget);

  fxMenu.SetButtonColor(TAlphaColors.Ghostwhite, TAlphaColors.Darkgrey)
    .SetButtonTextColor(TAlphaColors.Darkgrey, TAlphaColors.Ghostwhite);

  fxMenu
    .AddTitle('Demo UIFlexBuilder')
    .SetFieldSize(fsSmall)

    .AddTitle('Lançar')
      .AddButton('Despesa', OnClickRegisterConta)
        .SetTag(LANCAR_CONTA)
        .AddIcon(FindBitmapByName('Item 0'))
      .AddButton('Receita', OnClickRegisterConta)
        .SetTag(LANCAR_CONTA)
        .AddIcon(FindBitmapByName('Item 1'))

    .AddTitle('Categorias')
       .AddButton('Despesa',OnClickRegisterCategoria)
          .AddIcon(FindBitmapByName('Item 3'))
       .AddButton('Receita',OnClickRegisterCategoria)
          .AddIcon(FindBitmapByName('Item 6'))

    .AddTitle('Subcategorias')
      .AddButton('Despesa', OnClickRegisterConta)
          .SetTag(LANCAR_SUBCATEGORIA)
          .AddIcon(FindBitmapByName('Item 7'))
      .AddButton('Receita',OnClickRegisterConta)
          .SetTag(LANCAR_SUBCATEGORIA)
          .AddIcon(FindBitmapByName('Item 8'));

  fxMenu.free;
end;

class procedure TFlexView.RegisterContas(const AID, ACategoria: String; const ATabContas, ATabSubcategorias: TFDQuery);
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

class procedure TFlexView.RegisterItem(const AID, AValue: String; AFDQuery: TFDQuery; ATipo :TTipoCadastro = tcCategoria);
var
  FlexForm: TUIFlexForm;
  FormularioConfig: TFormularioConfig;
begin

  case ATipo of
     tcCategoria: FormularioConfig := TFormularioConfig.Create('Cadastro de categorias', 315);
     tcSubCategoria:  FormularioConfig := TFormularioConfig.Create('Cadastrar subcategoria',400);
  end;

  FlexForm := TUIFlexForm.Create(FormularioConfig.Titulo);

  try
    FlexForm.FlexBuilder.AddNewLine(5)
      .AddEditField('id', 'Código', 50)
      .AddEditField('descricao', 'Descrição', FormularioConfig.Largura);

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

class procedure TFlexView.LoadContas(AFlexBuilder: TUIFlexBuilder);
var
  Result : TValidationResult;
  sSQL: TStringBuilder;
begin
  Result := AFlexBuilder
               .SetErrorColor(TAlphaColors.Lightblue)
               //.NotEmpty('VencimentoInicial')
               .IsDate('VencimentoInicial')
               //.NotEmpty('VencimentoFinal')
               .IsDate('VencimentoFinal')
               .Validate;

  if not Result.IsValid then begin
     TUIFlexMessageBox.ShowMessage('Aviso', String.Join(sLineBreak, Result.Errors), ['OK']);
     abort;
  end;

  sSQL := TStringBuilder.Create;

  if AFlexBuilder.Edit('VencimentoInicial').AsDateText <> '' then
     sSQL.Append(' AND DataVencimento >= ' + QuotedStr(AFlexBuilder.Edit('VencimentoInicial').AsDateText));

  if AFlexBuilder.Edit('VencimentoFinal').AsDateText <> '' then
     sSQL.Append(' AND DataVencimento <= ' + QuotedStr(AFlexBuilder.Edit('VencimentoFinal').AsDateText));

  sSQL.Append(' GROUP BY P.ID ORDER BY TipoMovimento');

  tabParcelas.Open(TDatabaseScripts.GetParcelas(sSQL.ToString));

  sSQL.Free;

  BuildList(frmMain, frmMain.vsbUIList, tabParcelas);

end;

class function TFlexView.CreateLayout(AControl: TControl;
  AHeight: Single; APaddingLeft: Single = 0): TFlowLayout;
begin
  Result := TFlowLayout.Create(AControl);
  AControl.AddObject(Result);
  Result.Height := AHeight;
  Result.Width := AControl.Width;
  Result.Padding.Left := APaddingLeft;
  Result.Align := TAlignLayout.Top;
  Result.Position.Y := 10000;
end;

class function TFlexView.FindBitmapByName(const AName: string): TBitmap;
begin
   Result := frmMain.FindBitmapByName(AName)
end;

class procedure TFlexView.DeleteItemFromList(const AID: string);
begin
  if TUIFlexMessageBox.ShowMessage('Confirmar', 'Deseja excluir o item selecionado?', ['Sim', 'Não']) = mrYes then begin
    try
      SQLiteConnection.ExecSQL(TDatabaseScripts.DeleteParcelas(AID));

      TFlexView.LoadContas(frmMain.FlexHeader);
    except
      on E: Exception do
        TUIFlexMessageBox.ShowMessage('Erro', 'Ocorreu um erro ao excluir o item: ' + E.Message, ['OK']);
    end;
  end;
end;

class procedure TFlexView.UpdateItemInList(const AID: string);
begin
   if TUIFlexMessageBox.ShowMessage('Confirmar', 'Alterar o item selecionado?', ['Sim', 'Não']) = mrYes then begin
    try
      SQLiteConnection.ExecSQL(TDatabaseScripts.UpdateParcelas(AID));

      TFlexView.LoadContas(frmMain.FlexHeader);
    except
      on E: Exception do
        TUIFlexMessageBox.ShowMessage('Erro', 'Ocorreu um erro ao alterar o item: ' + E.Message, ['OK']);
    end;
  end;
end;

class procedure TFlexView.OnClickRegisterCategoria(Sender: TObject);
begin
   RegisterItem(TButton(Sender).TagString.Chars[0],TButton(Sender).TagString, tabCategorias);
end;

class procedure TFlexView.OnClickRegisterConta(Sender: TObject);
var ID, Descricao, Retorno : String;
begin
   tabCategorias.Filtered := False;
   tabCategorias.Filter := 'TipoMovimento = ' +  QuotedStr(TButton(Sender).TagString.Chars[0]);
   tabCategorias.Filtered := True;

   Retorno := TUIFlexForm.ShowForm('Lista de categorias', tabCategorias);
   if ValidateFlexFormReturn(Retorno, ID, Descricao) then
   begin
      case TButton(Sender).Tag of
         LANCAR_CONTA : RegisterContas(ID, Descricao, tabContas, tabSubCategorias);
         LANCAR_SUBCATEGORIA: RegisterItem(ID, Descricao, tabSubCategorias, tcSubCategoria);
      end;
   end;
end;

class procedure TFlexView.OnClickConsultContas(Sender: TObject);
begin
   LoadContas(frmMain.FlexHeader);
end;

class procedure TFlexView.OnClickDeleteItem(Sender: TObject);
begin
   DeleteItemFromList(TButton(Sender).Tag.ToString )
end;

class procedure TFlexView.OnClickUpdateItem(Sender: TObject);
begin
   UpdateItemInList(TButton(Sender).Tag.ToString)
end;

class function TFlexView.ValidateFlexFormReturn(const AInput: String; out AID, AValue: String): Boolean;
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
