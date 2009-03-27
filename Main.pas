unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, NxColumns, NxColumnClasses, NxScrollControl,
  NxCustomGridControl, NxCustomGrid, NxGrid;

type
  TFormMain = class(TForm)
    EditDestination: TEdit;
    LabelDestination: TLabel;
    BitBtnBrowse: TBitBtn;
    LabelSource: TLabel;
    ListBoxSource: TListBox;
    BitBtnAdd: TBitBtn;
    BitBtnRemove: TBitBtn;
    BitBtnStart: TBitBtn;
    NextGrid: TNextGrid;
    NxTextColumnSourceFile: TNxTextColumn;
    NxDateColumnDate: TNxDateColumn;
    NxTextColumnDestFile: TNxTextColumn;
    procedure BitBtnAddClick(Sender: TObject);
    procedure BitBtnRemoveClick(Sender: TObject);
    procedure BitBtnStartClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.BitBtnAddClick(Sender: TObject);
var s : string;
begin
  s := InputBox('¬ведите путь', '¬ведите путь', '');
  if s = '' then Exit;

  if s[Length(s)] <> '\' then s := s + '\';
  if not DirectoryExists(s) then
  begin
    Application.MessageBox(PChar('ѕуть ' + s + ' не существует'), 'ќшибка', MB_ICONERROR);
    Exit;
  end;

  ListBoxSource.Items.Add(s);
  ListBoxSource.ItemIndex := ListBoxSource.Items.Count - 1;
end;

procedure TFormMain.BitBtnRemoveClick(Sender: TObject);
begin
  if ListBoxSource.ItemIndex < 0 then Exit;

  ListBoxSource.Items.Delete(ListBoxSource.ItemIndex);

  if ListBoxSource.Items.Count > 0 then ListBoxSource.ItemIndex := 0;
end;

procedure TFormMain.BitBtnStartClick(Sender: TObject);
var sr: TSearchRec;
    FileAttrs: integer;
    i : longint;
begin
  if EditDestination.Text[Length(EditDestination.Text)] <> '\' then EditDestination.Text := EditDestination.Text + '\';

  if not DirectoryExists(EditDestination.Text) then
  begin
    Application.MessageBox(PChar('ѕуть ' + EditDestination.Text + ' не существует'), 'ќшибка', MB_ICONERROR);
    Exit;
  end;

  FileAttrs := faArchive + faReadOnly + faHidden + faSysFile;

  NextGrid.BeginUpdate;

  NextGrid.ClearRows;
  for i := 0 to ListBoxSource.Items.Count - 1 do
  begin
    if FindFirst(ListBoxSource.Items.Strings[i] + '*.*', FileAttrs, sr) = 0 then
    begin
      repeat
        if (sr.Attr and FileAttrs) = sr.Attr then
        begin
          NextGrid.AddRow;
          NextGrid.CellByName['NxTextColumnSourceFile', NextGrid.RowCount - 1].AsString   := ListBoxSource.Items.Strings[i] + sr.Name;
          NextGrid.CellByName['NxDateColumnDate',       NextGrid.RowCount - 1].AsDateTime := FileDateToDateTime(sr.Time);
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
  end;

  NextGrid.EndUpdate;

  NextGrid.ColumnByName['NxDateColumnDate'].SortKind := skAscending;
  NextGrid.ColumnByName['NxDateColumnDate'].SortType := stDate;
  NextGrid.ColumnByName['NxDateColumnDate'].Sorted   := True;

  for i := 1 to NextGrid.RowCount do
  begin
    NextGrid.CellByName['NxTextColumnDestFile'].AsString :=
  end;
  

end;

end.
