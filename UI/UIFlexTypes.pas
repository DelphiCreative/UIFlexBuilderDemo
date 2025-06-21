unit UIFlexTypes;

interface

const
  WIDTH_DESCRICAO = 200;
  WIDTH_STATUS = 70;
  WIDTH_VENCIMENTO = 80;
  WIDTH_VALOR = 80;
  WIDTH_DATA_PAGAMENTO = 80;
  WIDTH_VALOR_PAGO = 80;


type
  TTipoCadastro = (tcCategoria, tcSubCategoria);

type
  TFormularioConfig = record
    Titulo: String;
    Largura: Single;
    class function Create(const ATitulo: String; ALargura: Single): TFormularioConfig; static;
  end;

  TTotais = record
    ValorTotal: Double;
    ValorPago: Double;
    Quantidade: Double;
    procedure Clear;
    procedure Add(AValor, APago: Double);
  end;

implementation

{ TFormularioConfig }

class function TFormularioConfig.Create(const ATitulo: String; ALargura: Single): TFormularioConfig;
begin
  Result.Titulo := ATitulo;
  Result.Largura := ALargura;
end;

{ TTotais }

procedure TTotais.Clear;
begin
  ValorTotal := 0;
  ValorPago := 0;
  Quantidade:= 0;
end;

procedure TTotais.Add(AValor, APago: Double);
begin
  ValorTotal := ValorTotal + AValor;
  ValorPago := ValorPago + APago;
  Quantidade  := Quantidade + 1;
end;

end.
