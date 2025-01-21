unit DC.Firedac.VersionControl;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Variants,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, System.IOUtils,
  DC.Logger;

type
  TDCFiredacVersionControl = class
  private
    FDBConnection: TFDConnection;
    FMemTable: TFDMemTable;
    FActiveLog: Boolean;
    procedure WriteLog(const Msg: string);
    function GetVersion: Integer;
    procedure CreateVersionTableIfNotExists;
  public
    constructor Create(DBConnection: TFDConnection);
    destructor Destroy; override;
    procedure AddScript(Version: Integer; Description: string; SQLScript: string);
    procedure ExecuteVersionedScripts;
    property ActiveLog: Boolean read FActiveLog write FActiveLog;
  end;

implementation

{ TDatabaseVersionControl }

constructor TDCFiredacVersionControl.Create(DBConnection: TFDConnection);
begin
  FDBConnection := DBConnection;
  FMemTable := TFDMemTable.Create(nil);
  FMemTable.FieldDefs.Add('versao', ftInteger);
  FMemTable.FieldDefs.Add('descricao', ftString, 255);
  FMemTable.FieldDefs.Add('script', ftMemo);
  FMemTable.CreateDataSet;
  FActiveLog := True;
end;

destructor TDCFiredacVersionControl.Destroy;
begin
  FMemTable.Free;
  inherited;
end;

procedure TDCFiredacVersionControl.CreateVersionTableIfNotExists;
begin
  FDBConnection.ExecSQL('CREATE TABLE IF NOT EXISTS sistema (versao INTEGER DEFAULT 0, descricao VARCHAR(255));');
end;

function TDCFiredacVersionControl.GetVersion: Integer;
var
  v: Variant;
begin
  try
    FDBConnection.Open;
    CreateVersionTableIfNotExists;
    v := FDBConnection.ExecSQLScalar('SELECT versao FROM sistema');
    if not VarIsNull(v) then
    begin
      if v = 0 then
      begin
        FDBConnection.ExecSQL('INSERT INTO sistema (versao, descricao) VALUES (0, "Versão inicial")');
        Result := 0;
      end
      else
        Result := v;
    end
    else
      Result := -1;
  except
    on E: Exception do
    begin
      WriteLog('Erro ao obter versão: ' + E.Message);
      raise;
    end;
  end;
end;

procedure TDCFiredacVersionControl.AddScript(Version: Integer; Description: string; SQLScript: string);
begin
  FMemTable.Append;
  FMemTable.FieldByName('versao').AsInteger := Version;
  FMemTable.FieldByName('descricao').AsString := Description;
  FMemTable.FieldByName('script').AsString := SQLScript;
  FMemTable.Post;
end;

procedure TDCFiredacVersionControl.WriteLog(const Msg: string);
begin
  if FActiveLog then
    TLogger.Info(Msg);
end;

procedure TDCFiredacVersionControl.ExecuteVersionedScripts;
var
  CurrentVersion, ScriptVersion: Integer;
  ScriptDesc: string;
begin
  CurrentVersion := GetVersion;

  FMemTable.First;
  while not FMemTable.Eof do
  begin
    ScriptVersion := FMemTable.FieldByName('versao').AsInteger;
    ScriptDesc := FMemTable.FieldByName('descricao').AsString;

    if ScriptVersion > CurrentVersion then
    begin
      try
        FDBConnection.ExecSQL(FMemTable.FieldByName('script').AsString);

        FDBConnection.ExecSQL('UPDATE sistema SET versao = ?, descricao = ?;', [ScriptVersion, ScriptDesc]);

        TLogger.Info(Format('Script versão %d (%s) executado com sucesso.', [ScriptVersion, ScriptDesc]));
      except
        on E: Exception do
        begin
          TLogger.Error(Format('Erro ao executar o script da versão %d (%s): %s', [ScriptVersion, ScriptDesc, E.Message]));
          raise Exception.CreateFmt('Erro ao executar o script da versão %d: %s', [ScriptVersion, E.Message]);
        end;
      end;
    end;

    FMemTable.Next;
  end;
end;

end.

