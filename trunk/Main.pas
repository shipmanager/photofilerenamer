unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, NxColumns, NxColumnClasses, NxScrollControl,
  NxCustomGridControl, NxCustomGrid, NxGrid, Spin, StrUtils, DateUtils;

type
  TFormMain = class(TForm)
    EditDestination: TEdit;
    LabelDestination: TLabel;
    BitBtnBrowseDest: TBitBtn;
    LabelSource: TLabel;
    BitBtnBrowseSource1: TBitBtn;
    BitBtnBrowseSource2: TBitBtn;
    BitBtnStart: TBitBtn;
    NextGrid: TNextGrid;
    NxTextColumnSourceFile: TNxTextColumn;
    NxDateColumnSourceDate: TNxDateColumn;
    NxTextColumnDestFile: TNxTextColumn;
    EditSource1: TEdit;
    EditSource2: TEdit;
    SpinEditDigits: TSpinEdit;
    SpinEditDelta1Day: TSpinEdit;
    SpinEditDelta1Month: TSpinEdit;
    SpinEditDelta1Year: TSpinEdit;
    SpinEditDelta1Hour: TSpinEdit;
    SpinEditDelta1Minute: TSpinEdit;
    SpinEditDelta1Second: TSpinEdit;
    SpinEditDelta2Day: TSpinEdit;
    SpinEditDelta2Month: TSpinEdit;
    SpinEditDelta2Year: TSpinEdit;
    SpinEditDelta2Hour: TSpinEdit;
    SpinEditDelta2Minute: TSpinEdit;
    SpinEditDelta2Second: TSpinEdit;
    NxDateColumnDestDate: TNxDateColumn;
    procedure BitBtnBrowseSource1Click(Sender: TObject);
    procedure BitBtnBrowseSource2Click(Sender: TObject);
    procedure BitBtnStartClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  FormMain: TFormMain;

implementation

uses Exif;

{$R *.dfm}

procedure TFormMain.BitBtnBrowseSource1Click(Sender: TObject);
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

  EditSource1.Text := s;
end;

procedure TFormMain.BitBtnBrowseSource2Click(Sender: TObject);
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

  EditSource2.Text := s;
end;

function ExifToDateTime(s : string) : TDateTime;
var d : TDateTime;
begin
  ExifToDateTime := StrToDateTime(Copy(s, 9, 2) + '.' + Copy(s, 6, 2) + '.' + Copy(s, 1, 4) + ' ' + Copy(s, 12, 2) + ':' + Copy(s, 15, 2) + ':' + Copy(s, 18, 2));
end;

procedure TFormMain.BitBtnStartClick(Sender: TObject);
var sr: TSearchRec;
    FileAttrs: integer;
    i : longint;
    ex : TExif;
begin
  if EditDestination.Text[Length(EditDestination.Text)] <> '\' then EditDestination.Text := EditDestination.Text + '\';

  if not DirectoryExists(EditDestination.Text) then
  begin
    Application.MessageBox(PChar('ѕуть ' + EditDestination.Text + ' не существует'), 'ќшибка', MB_ICONERROR);
    Exit;
  end;

  ex := TExif.Create;

  FileAttrs := faArchive + faReadOnly + faHidden + faSysFile;

  NextGrid.BeginUpdate;
  NextGrid.ClearRows;

  if FindFirst(EditSource1.Text + '*.jpg', FileAttrs, sr) = 0 then
  begin
    repeat
      NextGrid.AddRow;
      NextGrid.CellByName['NxTextColumnSourceFile', NextGrid.RowCount - 1].AsString   := EditSource1.Text + sr.Name;
      ex.ReadFromFile(NextGrid.CellByName['NxTextColumnSourceFile', NextGrid.RowCount - 1].AsString);
      if ex.Valid then
      begin
        NextGrid.CellByName['NxDateColumnSourceDate', NextGrid.RowCount - 1].AsDateTime := ExifToDateTime(ex.DateTime);
        NextGrid.CellByName['NxDateColumnDestDate',   NextGrid.RowCount - 1].AsDateTime := IncSecond(IncMinute(IncHour(IncYear(IncMonth(IncDay(NextGrid.CellByName['NxDateColumnSourceDate', NextGrid.RowCount - 1].AsDateTime, SpinEditDelta1Day.Value), SpinEditDelta1Month.Value), SpinEditDelta1Year.Value), SpinEditDelta1Hour.Value), SpinEditDelta1Minute.Value), SpinEditDelta1Second.Value);
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;

  if FindFirst(EditSource2.Text + '*.jpg', FileAttrs, sr) = 0 then
  begin
    repeat
      NextGrid.AddRow;
      NextGrid.CellByName['NxTextColumnSourceFile', NextGrid.RowCount - 1].AsString   := EditSource2.Text + sr.Name;
      ex.ReadFromFile(NextGrid.CellByName['NxTextColumnSourceFile', NextGrid.RowCount - 1].AsString);
      if ex.Valid then
      begin
        NextGrid.CellByName['NxDateColumnSourceDate', NextGrid.RowCount - 1].AsDateTime := ExifToDateTime(ex.DateTime);
        NextGrid.CellByName['NxDateColumnDestDate',   NextGrid.RowCount - 1].AsDateTime := IncSecond(IncMinute(IncHour(IncYear(IncMonth(IncDay(NextGrid.CellByName['NxDateColumnSourceDate', NextGrid.RowCount - 1].AsDateTime, SpinEditDelta2Day.Value), SpinEditDelta2Month.Value), SpinEditDelta2Year.Value), SpinEditDelta2Hour.Value), SpinEditDelta2Minute.Value), SpinEditDelta2Second.Value);
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;

  NextGrid.EndUpdate;

  NextGrid.ColumnByName['NxDateColumnDestDate'].SortKind := skAscending;
  NextGrid.ColumnByName['NxDateColumnDestDate'].SortType := stDate;
  NextGrid.ColumnByName['NxDateColumnDestDate'].Sorted   := True;

  for i := 0 to NextGrid.RowCount - 1 do
  begin
    NextGrid.CellByName['NxTextColumnDestFile', i].AsString := EditDestination.Text + RightStr('00000' + IntToStr(i+1), SpinEditDigits.Value) + '.jpg';
  end;

  ex.Free;
end;

end.
