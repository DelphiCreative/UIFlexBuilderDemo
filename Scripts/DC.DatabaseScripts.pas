unit DC.DatabaseScripts;

interface

uses
  System.SysUtils;

const
  IDX_ID = 0;
  IDX_ID_CONTA = 1;
  IDX_VALOR_PARCELA = 2;
  IDX_PAGAMENTO = 3;
  IDX_VALOR_PAGO = 4;
  IDX_NPARCELA = 5;
  IDX_NPARCELAS = 6;
  IDX_DESCRICAO_PARCELA = 7;
  IDX_CATEGORIA = 8;
  IDX_SUBCATEGORIA = 9;
  IDX_DESCRICAO = 10;
  IDX_VENCIMENTO = 11;
  IDX_VALOR_FORMATADO = 12;
  IDX_TIPO_MOVIMENTO = 13;
  IDX_STATUS = 14;
  IDX_PORCENTAGEM_PAGA = 15;

type
  TDatabaseScripts = class
  public
    // Método para retornar o script de criação da tabela Categorias
    class function GetCreateTableCategoriasScript: string;

    // Método para retornar o script de criação da trigger ValidarCategorias
    class function GetCreateTriggerValidarCategoriasScript: string;

    // Método para retornar o script de inserção de registros na tabela Categorias
    class function GetInsertIntoCategoriasScript: string;

    // Método para retornar o script de criação da tabela SubCategorias
    class function GetCreateTableSubCategoriasScript: string;

    // Método para retornar o script de criação da trigger ValidarSubCategorias
    class function GetCreateTriggerValidarSubCategoriasScript: string;

    // Método para retornar o script de criação da tabela Contas
    class function GetCreateTableContasScript: string;

    // Método para retornar o script de criação da trigger ValidarContas
    class function GetCreateTriggerValidarContasScript: string;

    // Método para retornar o script de criação da tabela Parcelas
    class function GetCreateTableParcelasScript: string;

    // Método para retornar o script de criação da trigger GerarPrimeiraParcela
    class function GetCreateTriggerGerarPrimeiraParcelaScript: string;

    // Método para retornar o script de criação da trigger GerarParcelas
    class function GetCreateTriggerGerarParcelasScript: string;

    // Método para retornar o script de consulta de parcelas com filtro genérico
    class function GetParcelas(ASQL: string): string;

    class function GetCategorias(ASQL: string = ''): string;

    class function GetSubcategorias(ASQL: string = ''): string;

    class function DeleteParcelas(AID: string): string;

  end;

implementation

class function TDatabaseScripts.DeleteParcelas(AID: string): string;
begin
   Result := 'DELETE FROM Parcelas WHERE ID = ' + QuotedStr(AID);
end;

class function TDatabaseScripts.GetCategorias(ASQL: string = ''): string;
begin
  Result := 'SELECT * FROM categorias ' + ASQL + ' ORDER BY descricao';
end;

class function TDatabaseScripts.GetCreateTableCategoriasScript: string;
begin
  Result := '''
    CREATE TABLE IF NOT EXISTS Categorias(
      ID INTEGER PRIMARY KEY AUTOINCREMENT,
      Descricao VARCHAR(100) NOT NULL,
      TipoMovimento CHAR(1) );
  ''';
end;

class function TDatabaseScripts.GetCreateTriggerValidarCategoriasScript: string;
begin
  Result := '''
    DROP TRIGGER IF EXISTS ValidarCategorias;

    CREATE TRIGGER IF NOT EXISTS ValidarCategorias
    BEFORE INSERT ON Categorias
    BEGIN
      SELECT
        CASE
          WHEN (NEW.Descricao IS NULL) OR (NEW.Descricao = '') THEN RAISE (ABORT,"Informe uma descrição! ")
          WHEN 0 < (SELECT COUNT(*) FROM Categorias WHERE LOWER(Descricao) = LOWER(NEW.Descricao)) THEN RAISE (ABORT, "Categoria já cadastrada! ")
        END;
    END;
  ''';
end;

class function TDatabaseScripts.GetInsertIntoCategoriasScript: string;
begin
  Result := '''
    INSERT INTO Categorias
     (Descricao, TipoMovimento)
    VALUES
     ("SALÁRIO","R"),
     ("PRESTAÇÃO DE SERVIÇO","R"),
     ("SUPERMERCADO","D"),
     ("FAST FOOD","D"),
     ("ASSINATURA","D"),
     ("COMBUSTÍVEL","D"),
     ("EDUCAÇÃO","D"),
     ("LAZER","D"),
     ("MORADIA","D"),
     ("SAÚDE","D"),
     ("TRANSPORTE","D"),
     ("VIAGEM","D"),
     ("VESTUÁRIO","D");
  ''';
end;

class function TDatabaseScripts.GetCreateTableSubCategoriasScript: string;
begin
  Result := '''
    CREATE TABLE IF NOT EXISTS SubCategorias(
      ID INTEGER PRIMARY KEY AUTOINCREMENT,
      Descricao VARCHAR(100) NOT NULL,
      ID_Categoria INTEGER,
      TipoMovimento CHAR(1));
  ''';
end;

class function TDatabaseScripts.GetCreateTriggerValidarSubCategoriasScript: string;
begin
  Result := '''
    DROP TRIGGER IF EXISTS ValidarSubCategorias;

    CREATE TRIGGER IF NOT EXISTS ValidarSubCategorias
    BEFORE INSERT ON SubCategorias
    BEGIN
      SELECT
        CASE
          WHEN (NEW.Descricao IS NULL) OR (NEW.Descricao = '') THEN RAISE (ABORT,"Informe uma descrição! ")
          WHEN 0 < (SELECT COUNT(*) FROM SubCategorias WHERE LOWER(Descricao) = LOWER(NEW.Descricao) AND ID_Categoria = NEW.ID_Categoria) THEN RAISE (ABORT, "Subcategoria já cadastrada! ")
        END;
    END;
  ''';
end;

class function TDatabaseScripts.GetCreateTableContasScript: string;
begin
  Result := '''
    CREATE TABLE IF NOT EXISTS Contas(
      ID INTEGER PRIMARY KEY AUTOINCREMENT,
      Descricao VARCHAR(500),
      ID_Subcategoria INTEGER,
      NParcela INT,
      Valor FLOAT(15,2),
      TipoMovimento CHAR(1),
      DataVencimento DATETIME,
      ID_Categoria INTEGER,
      ValorPago FLOAT(15,2),
      DataPagamento DATETIME,
      Observacoes TEXT);
  ''';
end;

class function TDatabaseScripts.GetCreateTriggerValidarContasScript: string;
begin
  Result := '''
    CREATE TRIGGER IF NOT EXISTS ValidarContas
    BEFORE INSERT ON Contas
    BEGIN
      SELECT
        CASE
          WHEN NEW.NParcela IS NULL OR NEW.NParcela = 0 THEN RAISE (ABORT,"Informe o número de parcelas")
          WHEN NEW.Valor IS NULL OR NEW.Valor = 0 THEN RAISE (ABORT,"Informe o valor da parcela")
          WHEN NEW.DataVencimento IS NULL THEN RAISE (ABORT,"Informe o 1º vencimento")
          WHEN NEW.ID_Categoria IS NULL THEN RAISE (ABORT,"Informe uma categoria ! ")
          WHEN (SELECT TipoMovimento FROM Categorias WHERE ID = NEW.ID_Categoria) IS NULL THEN RAISE (ABORT, "Tipo de movimento inválido para a categoria selecionada")
        END;
    END;
  ''';
end;

class function TDatabaseScripts.GetParcelas(ASQL: string): string;
begin

   if ASQL.IsEmpty then
      ASQL := ' GROUP BY P.ID';

   Result := 'SELECT ' +
            '  P.ID,' +
            '  P.ID_Conta,' +
            '  SUM(Valor) ValorParcela,' +
            '  DataPagamento Pagamento,' +
            '  SUM(ValorPago) ValorPago,' +
            '  NParcela,' +
            '  (NParcela ||''/''|| (SELECT Count(*) FROM Parcelas P1 WHERE P1.ID_Conta = P.ID_Conta)) NParcelas,' +
            '  P.Descricao Descricao_Parcela,' +
            '  C.Descricao Categoria,' +
            '  S.Descricao Subcategoria ,' +
            '  IIF(COALESCE(P.Descricao,"")="", IIF(COALESCE(S.Descricao,"") = "", C.Descricao, S.Descricao), P.Descricao) Descricao,' +
            '  strftime("%d/%m/%Y", DataVencimento) Vencimento,' +
            '  Replace(printf("R$ %.2f",SUM(Valor)),".",",") AS Valor,' +
            '  C.TipoMovimento,' +
            '  IIF(DataPagamento IS NOT NULL, "LIQUIDADA", ' +
            '      IIF(strftime("%Y/%m/%d", DataVencimento) < strftime("%Y/%m/%d", Datetime()), "ATRASADA", "ABERTA")) Status,' +
            '  ROUND(((SELECT SUM(ValorPago) FROM Parcelas P2 WHERE P2.ID_Conta = P.ID_Conta) * 100 / ' +
            '         (SELECT SUM(Valor) FROM Parcelas P2 WHERE P2.ID_Conta = P.ID_Conta)), 2) PorcentagemPaga ' +
            'FROM ' +
            '  Parcelas P ' +
            '  INNER JOIN Categorias C ON C.ID = P.ID_Categoria ' +
            '  LEFT JOIN SubCategorias S ON S.ID = P.ID_Subcategoria ' +
            'WHERE 1 = 1 ' +
            ASQL;
end;

class function TDatabaseScripts.GetSubcategorias(ASQL: string): string;
begin
  Result := 'SELECT * FROM subcategorias ' + ASQL + ' ORDER BY descricao';
end;

class function TDatabaseScripts.GetCreateTableParcelasScript: string;
begin
  Result := '''
    CREATE TABLE IF NOT EXISTS Parcelas(
      ID INTEGER PRIMARY KEY AUTOINCREMENT,
      ID_Subcategoria INTEGER,
      ID_Conta INTEGER,
      ID_Categoria INTEGER,
      TipoMovimento CHAR(1),
      NParcela INT,
      Descricao VARCHAR(500),
      Valor FLOAT(15,2),
      ValorPago FLOAT(15,2),
      DataVencimento DATETIME,
      DataPagamento DATETIME,
      Observacoes TEXT);
  ''';
end;


class function TDatabaseScripts.GetCreateTriggerGerarPrimeiraParcelaScript: string;
begin
  Result := '''
    DROP TRIGGER IF EXISTS GerarPrimeiraParcela;

    CREATE TRIGGER GerarPrimeiraParcela
       AFTER INSERT ON Contas
       BEGIN
       INSERT INTO Parcelas(Descricao, ID_Subcategoria, NParcela, Valor, DataPagamento, DataVencimento, ID_Categoria, Observacoes, ID_Conta, TipoMovimento, ValorPago)
       VALUES (NEW.Descricao, NEW.ID_Subcategoria, 1, NEW.Valor, Date(NEW.DataPagamento), Date(NEW.DataVencimento), NEW.ID_Categoria, NEW.Observacoes, NEW.ID, NEW.TipoMovimento, NEW.ValorPago);
    END;
  ''';
end;

class function TDatabaseScripts.GetCreateTriggerGerarParcelasScript: string;
begin
  Result := '''
    DROP TRIGGER IF EXISTS GerarParcelas;

    CREATE TRIGGER IF NOT EXISTS GerarParcelas
       BEFORE INSERT ON Parcelas
       WHEN NEW.NParcela <> (SELECT NParcela FROM Contas ORDER BY ID DESC LIMIT 1) BEGIN
       INSERT INTO Parcelas(TipoMovimento, Descricao, ID_Subcategoria, ID_Conta, NParcela, Valor, ValorPago, DataVencimento, DataPagamento, ID_Categoria, Observacoes)
       VALUES (NEW.TipoMovimento, NEW.Descricao, NEW.ID_Subcategoria, NEW.ID_Conta, NEW.NParcela + 1, NEW.Valor, NEW.ValorPago, Date(NEW.DataVencimento, "+1 month"), NEW.DataPagamento, NEW.ID_Categoria, NEW.Observacoes);
    END;
  ''';
end;

end.

