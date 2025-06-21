unit DC.GridLoader;

interface

uses
  Data.DB, System.SysUtils, System.Classes, System.Math, FireDAC.Comp.Client, FMX.Grid, FMX.Types;

type
  TCellStyleCallback = reference to procedure(AStringGrid: TStringGrid; ACol, ARow: Integer; var AValue: string);

  TGridLoader = class
  private
    FStringGrid: TStringGrid;
    FQuery: TFDQuery;
    FLimit: Integer;
    FPage: Integer;
    FOnCellStyle: TCellStyleCallback;
    procedure AdjustColumnWidths;
  public
    constructor Create(AStringGrid: TStringGrid; AQuery: TFDQuery);
    procedure LoadData(FormatData: Boolean = True);
    procedure SetPagination(Limit, Page: Integer);
    procedure ExportToCSV(const FilePath: string);
    procedure SetCellStyleCallback(Callback: TCellStyleCallback);
  end;

implementation

{ TGridLoader }

constructor TGridLoader.Create(AStringGrid: TStringGrid; AQuery: TFDQuery);
begin
  if not Assigned(AStringGrid) then
    raise Exception.Create('StringGrid não atribuído.');

  if not Assigned(AQuery) then
    raise Exception.Create('TFDQuery não atribuído.');

  FStringGrid := AStringGrid;
  FQuery := AQuery;
  FLimit := 100;
  FPage := 1;
end;

procedure TGridLoader.SetPagination(Limit, Page: Integer);
begin
  if Limit <= 0 then
    raise Exception.Create('O limite deve ser maior que zero.');

  if Page <= 0 then
    raise Exception.Create('A página deve ser maior que zero.');

  FLimit := Limit;
  FPage := Page;
end;

procedure TGridLoader.SetCellStyleCallback(Callback: TCellStyleCallback);
begin
  FOnCellStyle := Callback;
end;

procedure TGridLoader.AdjustColumnWidths;
var
  I: Integer;
  DefaultWidth: Single;
begin
  if FStringGrid.ColumnCount = 0 then
    Exit;

  DefaultWidth := FStringGrid.Width / FStringGrid.ColumnCount;

  for I := 0 to FStringGrid.ColumnCount - 1 do
    FStringGrid.Columns[I].Width := DefaultWidth;end;

procedure TGridLoader.LoadData(FormatData: Boolean);
var
  I, J, StartRow: Integer;
  Col: TColumn;
  Value: string;
  TotalRecords: Integer;
begin
  if not FQuery.Active then
    raise Exception.Create('A consulta não está ativa.');

  FStringGrid.ClearColumns;
  FStringGrid.RowCount := 0;

  for I := 0 to FQuery.FieldCount - 1 do
  begin
    Col := TColumn.Create(FStringGrid);
    Col.Header := FQuery.Fields[I].FieldName;
    FStringGrid.AddObject(Col);
  end;

  TotalRecords := FQuery.RecordCount;
  StartRow := (FPage - 1) * FLimit;

  FQuery.First;
  for I := 0 to StartRow - 1 do
    if not FQuery.Eof then
      FQuery.Next;

  for I := 0 to FLimit - 1 do
  begin
    if FQuery.Eof then Break;

    FStringGrid.RowCount := FStringGrid.RowCount + 1;
    for J := 0 to FQuery.FieldCount - 1 do
    begin
      if FormatData then
      begin
        case FQuery.Fields[J].DataType of
          ftFloat, ftCurrency:
            Value := FormatFloat('#,##0.00', FQuery.Fields[J].AsFloat);
          ftDate, ftDateTime:
            Value := FormatDateTime('dd/mm/yyyy', FQuery.Fields[J].AsDateTime);
          else
            Value := FQuery.Fields[J].AsString;
        end;
      end
      else
        Value := FQuery.Fields[J].AsString;

      if Assigned(FOnCellStyle) then
        FOnCellStyle(FStringGrid, J, FStringGrid.RowCount - 1, Value);

      FStringGrid.Cells[J, FStringGrid.RowCount - 1] := Value;
    end;
    FQuery.Next;
  end;

  AdjustColumnWidths;
end;

procedure TGridLoader.ExportToCSV(const FilePath: string);
var
  SL: TStringList;
  Lin, Col: Integer;
  Line: string;
begin
  SL := TStringList.Create;
  try
    for Lin := 0 to FStringGrid.RowCount - 1 do
    begin
      Line := '';
      for Col := 0 to FStringGrid.ColumnCount - 1 do
      begin
        Line := Line + FStringGrid.Cells[Col, Lin];
        if Col < FStringGrid.ColumnCount - 1 then
          Line := Line + ',';
      end;
      SL.Add(Line);
    end;
    SL.SaveToFile(FilePath);
  finally
    SL.Free;
  end;
end;

end.

