unit Frm.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.ImageList, FMX.ImgList, FMX.Layouts, FMX.Effects, FMX.Objects;

type
  TfrmMain = class(TForm)
    StyleBook1: TStyleBook;
    Rectangle2: TRectangle;
    ShadowEffect2: TShadowEffect;
    vsbUIMenu: TVertScrollBox;
    Rectangle1: TRectangle;
    ShadowEffect3: TShadowEffect;
    vsbUIList: TVertScrollBox;
    flwHeader: TFlowLayout;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function FindBitmapByName(const AName: string): TBitmap;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses FMX.UIFlexBuilder, FMX.UIFlexBuilder.Types, DC.Helper.Utils, UIFlexView,
  DM.Main;

function TfrmMain.FindBitmapByName(const AName: string): TBitmap;
begin
  Result := ImageList1.BitmapByName(AName);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
   TFlexView.BuildMenu(Self, vsbUIMenu);
   tabCategorias.Open('SELECT * FROM categorias ORDER BY descricao');
   tabSubCategorias.Open('SELECT * FROM subcategorias ORDER BY descricao');
end;

initialization
  ReportMemoryLeaksOnShutdown := True;
end.
