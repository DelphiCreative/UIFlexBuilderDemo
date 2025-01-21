unit DC.Helper.Utils;

interface

uses
   FMX.Forms, FMX.StdCtrls, FMX.Menus, FMX.Dialogs, FMX.Objects,
   System.Generics.Collections, System.SysUtils, System.JSON,
   FMX.TabControl,
   FMX.Ani,
   FMX.Graphics,
   FMX.ImgList,
   FMX.Types,
   FMX.Edit,
   FMX.MultiResBitmap,
   System.UITypes,
   FMX.Gestures,

   System.StrUtils,
   System.Types
   ;


//type
//  TObjectListFrameHelper = class helper for TObjectList<TFrame>
//    function Filter(const AFilterText: string): Boolean;
//  end;

//function TfrmMain.FindBitmapByName(const AName: string): TBitmap;
//var
//  Item: TCustomBitmapItem;
//  Size: TSize;
//begin
//  if ImageList1.BitmapItemByName(AName, Item, Size) then
//     Result := Item.MultiResBitmap.Bitmaps[1.0]
//  else
//     Result := nil;
//end;


type
  TImageListHelper = class helper for TImageList
     function BitmapByName(const AName: string): TBitmap;
  end;


type
  TImageHelper = class helper for TImage
  private
    procedure LoadImageFromFileDialog(AEdit: TEdit = nil);
    procedure RemoveImage(AEdit: TEdit = nil);
    procedure PopupMenuClick(Sender: TObject);
  public
    procedure EnableImagePopup(AEdit: TEdit = nil);
  end;

type
  TJSONHelper = class helper for TJSONObject
  public
    function GetValueOrDefault(const Key: string; const Default: string = ''): string;
  end;


implementation

uses DC.Utils;

//function TObjectListFrameHelper.Filter(const AFilterText: String): Boolean;
//var I :Integer;
//begin
//   Result := False;
//
//   for I := 0 to Self.Count - 1 do begin
//      if Trim(AFilterText) <> '' then begin
//         TFrame(Self[I]).Visible := ContainsStr(AnsiLowerCase(TFrame(Self[I]).TagString),AnsiLowerCase(AFilterText));
//         if TFrame(Self[I]).Visible then
//            Result := True;
//      end
//      else begin
//         TFrame(Self[I]).Visible := True;
//         Result := True;
//      end;
//   end;
//end;

procedure TImageHelper.EnableImagePopup(AEdit: TEdit = nil);
var
  PopupMenu: TPopupMenu;
  MenuItemLoadImage, MenuItemRemoveImage: TMenuItem;
begin
  PopupMenu := TPopupMenu.Create(Self);

  MenuItemLoadImage := TMenuItem.Create(PopupMenu);
  MenuItemLoadImage.Text := 'Carregar Imagem';
  MenuItemLoadImage.OnClick := PopupMenuClick;
  MenuItemLoadImage.Tag := 0;
  PopupMenu.AddObject(MenuItemLoadImage);

  MenuItemRemoveImage := TMenuItem.Create(PopupMenu);
  MenuItemRemoveImage.Text := 'Remover Imagem';
  MenuItemRemoveImage.OnClick := PopupMenuClick;
  MenuItemRemoveImage.Tag := 1;
  PopupMenu.AddObject(MenuItemRemoveImage);

  Self.AddObject(PopupMenu);
  Self.PopupMenu := PopupMenu;

  // Armazena o Edit no TagObject do PopupMenu (Opcional)
  Self.tagObject := AEdit;
end;

procedure TImageHelper.LoadImageFromFileDialog(AEdit: TEdit = nil);
var
  OpenFileDialog: TOpenDialog;
begin
  OpenFileDialog := TOpenDialog.Create(nil);
  try
    OpenFileDialog.Filter := 'Imagens|*.jpg;*.jpeg;*.png;*.bmp';
    if OpenFileDialog.Execute then
    begin
      try
        var sImagePath := ResizeImage(OpenFileDialog.FileName, 150, 150, '');
        Self.Bitmap.LoadFromFile(sImagePath);
        Self.TagString := sImagePath;
        Self.Tag := 1;

        // Atualiza o TEdit com o caminho da imagem
        if Assigned(AEdit) then
          AEdit.Text := sImagePath;
      except
        on E: Exception do
          ShowMessage('Erro ao carregar a imagem: ' + E.Message);
      end;
    end;
  finally
    OpenFileDialog.Free;
  end;
end;

procedure TImageHelper.RemoveImage(AEdit: TEdit = nil);
begin
  Self.TagString := '';
  Self.Bitmap := nil;
  Self.Tag := 1;

  // Limpa o TEdit quando a imagem é removida
  if Assigned(AEdit) then
    AEdit.Text := '';
end;

procedure TImageHelper.PopupMenuClick(Sender: TObject);
var
  AEdit: TEdit;
begin
  // Obtém o TEdit armazenado no PopupMenu (se existir)
  AEdit := TEdit(Self.TagObject);

  case (Sender as TMenuItem).Tag of
    0: LoadImageFromFileDialog(AEdit);
    1: RemoveImage(AEdit);
  end;
end;


{ TJSONHelper }

function TJSONHelper.GetValueOrDefault(const Key, Default: string): string;
begin
   if not Self.TryGetValue<string>(Key, Result) then
     Result := Default;
end;

{ TImageListHelper }

function TImageListHelper.BitmapByName(const AName: string): TBitmap;
var
  Item: TCustomBitmapItem;
  Size: TSize;
begin
  if Self.BitmapItemByName(AName, Item, Size) then
     Result := Item.MultiResBitmap.Bitmaps[1.0]
  else
     Result := nil;

end;

end.
