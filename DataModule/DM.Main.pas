unit DM.Main;

interface

uses
  System.IOUtils,
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.VCLUI.Wait;

type
  PTFDQuery = ^TFDQuery;

type
  TdmMain = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Connected;
    procedure UpdateDatabase;
    procedure InitializeQueries(const AQueries: array of PTFDQuery; AConnection: TFDConnection);
  end;

var
  dmMain: TdmMain;
  SQLiteConnection: TFDConnection;
  tabCategorias: TFDQuery;
  tabSubCategorias: TFDQuery;
  tabContas: TFDQuery;
  tabParcelas: TFDQuery;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses DC.Firedac.VersionControl, DC.DatabaseScripts;

{$R *.dfm}

procedure TdmMain.InitializeQueries(const AQueries: array of PTFDQuery; AConnection: TFDConnection);
var
  i: Integer;
begin
  for i := Low(AQueries) to High(AQueries) do
  begin
    AQueries[i]^ := TFDQuery.Create(Self);
    AQueries[i]^.Connection := AConnection;
  end;
end;

procedure TdmMain.Connected;
var
   DatabaseFilePath: string;
begin
   SQLiteConnection := TFDConnection.Create(Self);
   DatabaseFilePath := TPath.Combine( DatabaseFilePath, 'DB');
   ForceDirectories(DatabaseFilePath);
   SQLiteConnection.DriverName := 'SQLite';
   SQLiteConnection.Params.Database := TPath.Combine(DatabaseFilePath, 'fxDemo.db');
   SQLiteConnection.Connected := True;
   UpdateDatabase;

   InitializeQueries([@tabCategorias, @tabSubCategorias, @tabContas, @tabParcelas], SQLiteConnection);

end;

procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
   Connected;
end;

procedure TdmMain.UpdateDatabase;
var
   VersionControl: TDCFiredacVersionControl;
begin
   VersionControl := TDCFiredacVersionControl.Create(SQLiteConnection);
   try
     VersionControl.AddScript(1, 'Criação da tabela categorias', TDatabaseScripts.GetCreateTableCategoriasScript);
     VersionControl.AddScript(2, 'Criação da trigger ValidarCategorias', TDatabaseScripts.GetCreateTriggerValidarCategoriasScript);
     VersionControl.AddScript(3, 'Inclusão de registros na tabela categorias',TDatabaseScripts.GetInsertIntoCategoriasScript);
     VersionControl.AddScript(4, 'Criação da tabela SubCategorias', TDatabaseScripts.GetCreateTableSubCategoriasScript);
     VersionControl.AddScript(5, 'Criação da trigger ValidarSubCategorias', TDatabaseScripts.GetCreateTriggerValidarSubCategoriasScript);
     VersionControl.AddScript(6, 'Criação da tabela Contas', TDatabaseScripts.GetCreateTableContasScript);
     VersionControl.AddScript(7, 'Criação da trigger ValidarContas', TDatabaseScripts.GetCreateTriggerValidarContasScript);
     VersionControl.AddScript(8, 'Criação da tabela Parcelas', TDatabaseScripts.GetCreateTableParcelasScript);
     VersionControl.AddScript(9, 'Criação da trigger GerarPrimeiraParcela', TDatabaseScripts.GetCreateTriggerGerarPrimeiraParcelaScript);
     VersionControl.AddScript(10, 'Criação da trigger GerarParcelas', TDatabaseScripts.GetCreateTriggerGerarParcelasScript);

      VersionControl.ExecuteVersionedScripts;
   finally
      VersionControl.Free;
   end;

end;

end.
