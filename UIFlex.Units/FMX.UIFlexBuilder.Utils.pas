unit FMX.UIFlexBuilder.Utils;

interface

uses
  System.JSON, System.RegularExpressions, System.SysUtils, System.Types,
  FireDAC.Comp.Client,  System.Variants,Data.DB,  System.TypInfo,
  FMX.ListBox, FMX.ComboEdit, FMX.TextLayout,  FMX.Controls, FMX.Layouts;

type
  TFlexUtils = class

  public
    class procedure ClearComponents(AComponent: TControl);
    class procedure FindAndSelectItemInComboBox(ComboBox: TComboBox; const ItemText: string);
    class procedure FindAndSelectItemInComboBoxByID(ComboBox: TComboBox; const ItemID: Integer);
    class procedure FindAndSelectItemInComboEdit(ComboEdit: TComboEdit; const ItemText: string);
    class function JSONToInsertStatement(const TableName: string; const JSONStr: string): string;
    class function RemoveTextInBrackets(const AText: string): string;
    class function CreateMemTableFromJSONArray(const AJSONArray: TJSONArray): TFDMemTable;
    class function CreateMemTableFromJSONString(const AJSONString: string): TFDMemTable;
    class function JSONValueToVariant(AValue: TJSONValue): Variant; static;
    class function CreateMemTablePopulated(const AData: TArray<TArray<Variant>>): TFDMemTable;

    class function CalculateTextSize(const AText: string; AFontSize: Single): TSizeF;
    class function GetFieldMaskTypeNames: TArray<string>;
    class function GetEnumNameAsString(EnumValue: Integer; EnumType: PTypeInfo): string;
    class function GetJSONValueOrDefault(AObject: TJSONObject; const AKey: string; const ADefault: string): string; overload;
    class function GetJSONValueOrDefault(AObject: TJSONObject; const AKey: string; const ADefault: Single): Single; overload;

  end;

implementation

{ TFlexUtils }

uses FMX.UIFlexBuilder.Types;

class function TFlexUtils.CalculateTextSize(const AText: string;
  AFontSize: Single): TSizeF;
var
  TextLayout: TTextLayout;
begin
  TextLayout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    TextLayout.BeginUpdate;
    TextLayout.Text := AText;
    TextLayout.Font.Size := AFontSize;
    TextLayout.MaxSize := TPointF.Create(1000, 10000);
    TextLayout.WordWrap := True;
    TextLayout.EndUpdate;

    Result := TSizeF.Create(TextLayout.TextWidth, TextLayout.TextHeight);
  finally
    TextLayout.Free;
  end;

end;

class procedure TFlexUtils.ClearComponents(AComponent: TControl);
var
  I: Integer;
begin
  AComponent.BeginUpdate;
  try
    for I := AComponent.ComponentCount - 1 downto 0 do
    begin
      if not (AComponent.Components[I] is TScrollContent) then
        AComponent.Components[I].Free;
    end;
  finally
    AComponent.EndUpdate;
  end;
end;

class function TFlexUtils.CreateMemTableFromJSONArray(
  const AJSONArray: TJSONArray): TFDMemTable;
var
  I, J: Integer;
  Obj: TJSONObject;
  FieldName: string;
  FieldValue: TJSONValue;
begin
  Result := TFDMemTable.Create(nil);

  // Definir campos baseado no primeiro objeto
  if AJSONArray.Count > 0 then
  begin
    Obj := AJSONArray.Items[0] as TJSONObject;
    for J := 0 to Obj.Count - 1 do
    begin
      FieldName := Obj.Pairs[J].JsonString.Value;
      FieldValue := Obj.Pairs[J].JsonValue;

      // Criar campo com base no tipo do valor
      if FieldValue is TJSONString then
        Result.FieldDefs.Add(FieldName, ftString, 255)
      else if FieldValue is TJSONNumber then
        Result.FieldDefs.Add(FieldName, ftFloat)
      else if (FieldValue.ToString = 'true') or (FieldValue.ToString = 'false') then
        Result.FieldDefs.Add(FieldName, ftBoolean)
      else
        Result.FieldDefs.Add(FieldName, ftString, 255); // Default
    end;
  end;

  Result.CreateDataSet;
  Result.Open;

  // Preencher dados
  for I := 0 to AJSONArray.Count - 1 do
  begin
    Obj := AJSONArray.Items[I] as TJSONObject;
    Result.Append;
    for J := 0 to Obj.Count - 1 do
    begin
      FieldName := Obj.Pairs[J].JsonString.Value;
      FieldValue := Obj.Pairs[J].JsonValue;
      if Result.FindField(FieldName) <> nil then
        Result.FieldByName(FieldName).AsVariant := JSONValueToVariant(FieldValue);
    end;
    Result.Post;
    Obj.Free;  // Libera o objeto após o uso
  end;

  // Libera a memória do JSONArray
  //AJSONArray.Free;
end;

class function TFlexUtils.CreateMemTableFromJSONString(
  const AJSONString: string): TFDMemTable;
var
  JSONArr: TJSONArray;
  I, J: Integer;
  Obj: TJSONObject;
  FieldName: string;
  FieldValue: TJSONValue;
begin
  Result := TFDMemTable.Create(nil);

  // Tentar fazer o parsing da string JSON para TJSONArray
  JSONArr := TJSONObject.ParseJSONValue(AJSONString) as TJSONArray;
  try
    if (JSONArr = nil) or (JSONArr.Count = 0) then
      raise Exception.Create('O JSON fornecido não é válido ou está vazio.');

    // Definir os campos do MemTable com base no primeiro item do JSONArray
    if JSONArr.Count > 0 then
    begin
      Obj := JSONArr.Items[0] as TJSONObject;
      for J := 0 to Obj.Count - 1 do
      begin
        FieldName := Obj.Pairs[J].JsonString.Value;
        FieldValue := Obj.Pairs[J].JsonValue;

        // Adiciona os campos ao memtable conforme tipo do valor
        if FieldValue is TJSONString then
          Result.FieldDefs.Add(FieldName, ftString, 255)
        else if FieldValue is TJSONNumber then
          Result.FieldDefs.Add(FieldName, ftFloat)
        else if (FieldValue.ToString = 'true') or (FieldValue.ToString = 'false') then
          Result.FieldDefs.Add(FieldName, ftBoolean)
        else
          Result.FieldDefs.Add(FieldName, ftString, 255); // Default
      end;
    end;

    Result.CreateDataSet;
    Result.Open;

    // Preencher os dados no MemTable
    for I := 0 to JSONArr.Count - 1 do
    begin
      Obj := JSONArr.Items[I] as TJSONObject;
      Result.Append;
      for J := 0 to Obj.Count - 1 do
      begin
        FieldName := Obj.Pairs[J].JsonString.Value;
        FieldValue := Obj.Pairs[J].JsonValue;

        if Result.FindField(FieldName) <> nil then
          Result.FieldByName(FieldName).AsVariant := JSONValueToVariant(FieldValue);
      end;
      Result.Post;
    end;
  finally
    // Liberar o JSONArr
    JSONArr.Free;
  end;
end;



class function TFlexUtils.CreateMemTablePopulated(
  const AData: TArray<TArray<Variant>>): TFDMemTable;
var
  I: Integer;
begin
  Result := TFDMemTable.Create(nil);

  // Definir campos
  Result.FieldDefs.Clear;
  Result.FieldDefs.Add('key', ftString, 255);
  Result.FieldDefs.Add('value', ftString, 255);

  Result.CreateDataSet;
  Result.Open;

  // Popular com os dados passados
  for I := 0 to High(AData) do
    Result.AppendRecord([AData[I][0], AData[I][1] ]);

end;

class procedure TFlexUtils.FindAndSelectItemInComboBox(ComboBox: TComboBox;
  const ItemText: string);
var
  Index: Integer;
begin
  Index := ComboBox.Items.IndexOf(ItemText);
  if Index <> -1 then
    ComboBox.ItemIndex := Index;
end;

class procedure TFlexUtils.FindAndSelectItemInComboBoxByID(ComboBox: TComboBox;
  const ItemID: Integer);
var
  Index: Integer;
begin
  for Index := 0 to ComboBox.Items.Count - 1 do
  begin
    if Integer(ComboBox.Items.Objects[Index]) = ItemID then
    begin
      ComboBox.ItemIndex := Index;
      Exit;
    end;
  end;
  ComboBox.ItemIndex := -1;
end;

class procedure TFlexUtils.FindAndSelectItemInComboEdit(ComboEdit: TComboEdit;
  const ItemText: string);
var
  Index: Integer;
begin
  Index := ComboEdit.Items.IndexOf(ItemText);
  if Index <> -1 then
  begin
    ComboEdit.Text := ItemText;
    ComboEdit.ItemIndex := Index;
  end;
end;

class function TFlexUtils.GetEnumNameAsString(EnumValue: Integer;
  EnumType: PTypeInfo): string;
begin

end;

class function TFlexUtils.GetFieldMaskTypeNames: TArray<string>;
var
  I: Integer;
  EnumType: PTypeInfo;
begin
  EnumType := TypeInfo(TFieldMaskType);
  SetLength(Result, GetTypeData(EnumType)^.MaxValue + 1);

  for I := 0 to High(Result) do
    Result[I] := GetEnumName(EnumType, I);

end;

class function TFlexUtils.GetJSONValueOrDefault(AObject: TJSONObject;
  const AKey, ADefault: string): string;
begin
//  if EnumType = nil then
//    raise Exception.Create('Tipo de enumeração inválido.');
//
//  Result := GetEnumName(EnumType, EnumValue);
end;

class function TFlexUtils.GetJSONValueOrDefault(AObject: TJSONObject;
  const AKey: string; const ADefault: Single): Single;
begin
  if not AObject.TryGetValue(AKey, Result) then
    Result := ADefault;
end;

class function TFlexUtils.JSONToInsertStatement(const TableName: string; const JSONStr: string): string;
var
  JSONObject: TJSONObject;
  Pair: TJSONPair;
  Columns, Values: string;
begin
  JSONObject := TJSONObject.ParseJSONValue(JSONStr) as TJSONObject;
  try
    if JSONObject = nil then
      raise Exception.Create('Erro ao converter JSON para SQL: JSON inválido.');

    for Pair in JSONObject do
    begin
      if Columns <> '' then
      begin
        Columns := Columns + ', ';
        Values := Values + ', ';
      end;

      Columns := Columns + Pair.JsonString.Value;
      Values := Values + QuotedStr(Pair.JsonValue.Value);
    end;

    Result := Format('INSERT INTO %s (%s) VALUES (%s);', [TableName, Columns, Values]);
  finally
    JSONObject.Free;
  end;
end;

class function TFlexUtils.JSONValueToVariant(AValue: TJSONValue): Variant;
begin
  if AValue = nil then
    Exit(Null);

  if AValue is TJSONString then
    Result := TJSONString(AValue).Value
  else if AValue is TJSONNumber then
    Result := TJSONNumber(AValue).AsDouble
  else if (AValue.ToString = 'true') then
    Result := True
  else if (AValue.ToString = 'false') then
    Result := False
  else
    Result := AValue.ToString;
end;

class function TFlexUtils.RemoveTextInBrackets(const AText: string): string;
var
  Regex: TRegEx;
begin
  Regex := TRegEx.Create('\[.*?\]', [roIgnoreCase]);
  Result := Trim(Regex.Replace(AText.Replace('ERROR:','') , ''));
end;

end.
