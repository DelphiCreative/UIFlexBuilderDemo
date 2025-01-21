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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

end.
