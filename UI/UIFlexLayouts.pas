unit UIFlexLayouts;

interface

uses FMX.Controls, FMX.Objects, FMX.Types, FMX.UIFlexBuilder, FMX.Layouts, System.UITypes, FireDAC.Comp.Client;

type
  TFlexLayouts = class
  public
    class function CreateLayout(AParent: TControl; AHeight: Single; APaddingLeft: Single = 0): TFlowLayout; static;
    class procedure AddMovementTitle(ABuilder: TUIFlexBuilder; AParent: TControl; const ATitle: String); static;
    class procedure AddMovementColumns(ABuilder: TUIFlexBuilder; AParent: TControl); static;
    class procedure AddMovementData(ABuilder: TUIFlexBuilder; AParent: TControl; AFDQuery: TFDQuery); static;
  end;

implementation

{ TFlexLayouts }

uses UIFlexTypes, DC.DatabaseScripts, UIFlexTheme, FMX.UIFlexBuilder.Types;

class function TFlexLayouts.CreateLayout(AParent: TControl; AHeight,
  APaddingLeft: Single): TFlowLayout;
begin
  Result := TFlowLayout.Create(AParent);
  AParent.AddObject(Result);
  Result.Height := AHeight;
  Result.Width := AParent.Width;
  Result.Padding.Left := APaddingLeft;
  Result.Align := TAlignLayout.Top;
  Result.Position.Y := 10000;
end;

class procedure TFlexLayouts.AddMovementTitle(ABuilder: TUIFlexBuilder; AParent: TControl; const ATitle: String);
begin
  var Layout := CreateLayout(AParent, 40);
  ABuilder.InParent(Layout);
  ABuilder.AddTitle(ATitle, 12);
end;

class procedure TFlexLayouts.AddMovementColumns(ABuilder: TUIFlexBuilder; AParent: TControl);
begin

  ABuilder.SetFieldSize(fsSmall);
  var Layout := CreateLayout(AParent, 40);
  ABuilder.InParent(Layout);

  TFlexTheme.ApplyListTitleStyle(ABuilder);

  ABuilder.AddTextBox('Descrição', 0, WIDTH_DESCRICAO);
  ABuilder.AddTextBox('Status', 0, WIDTH_STATUS);
  ABuilder.AddTextBox('Vencimento', 0, WIDTH_VENCIMENTO);
  ABuilder.AddTextBox('Valor', 0, WIDTH_VALOR);
  ABuilder.AddTextBox('Data de Pagamento', 0, WIDTH_DATA_PAGAMENTO);
  ABuilder.AddTextBox('Valor Pago', 0, WIDTH_VALOR_PAGO);
end;

class procedure TFlexLayouts.AddMovementData(ABuilder: TUIFlexBuilder; AParent: TControl; AFDQuery: TFDQuery);
begin
  var Layout := CreateLayout(AParent, 40);

  ABuilder.InParent(Layout);

  TFlexTheme.ApplyListRowStyle(ABuilder);

  ABuilder.AddTextBox(AFDQuery.Fields[IDX_DESCRICAO].AsString, 0, WIDTH_DESCRICAO);
  ABuilder.AddTextBox(AFDQuery.Fields[IDX_STATUS].AsString, 0, WIDTH_STATUS);
  ABuilder.AddTextBox(AFDQuery.Fields[IDX_VENCIMENTO].AsString, 0, WIDTH_VENCIMENTO);
  ABuilder.AddTextBox(AFDQuery.Fields[IDX_VALOR_FORMATADO].AsString, 0, WIDTH_VALOR);
  ABuilder.AddTextBox(AFDQuery.Fields[IDX_PAGAMENTO].AsString, 0, WIDTH_DATA_PAGAMENTO, 0);

  if AFDQuery.Fields[IDX_PAGAMENTO].AsString <> '' then
    ABuilder.AddTextBox(AFDQuery.Fields[IDX_VALOR_PAGO_FORMATADO].AsString, 0, WIDTH_VALOR_PAGO)
  else
    ABuilder.AddTextBox('', 0, WIDTH_VALOR_PAGO);
end;

end.
