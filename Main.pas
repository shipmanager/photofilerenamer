unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, NxColumns, NxColumnClasses, NxScrollControl,
  NxCustomGridControl, NxCustomGrid, NxGrid, Spin, StrUtils, DateUtils,
  ComCtrls;

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
    ProgressBar: TProgressBar;
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
  s := InputBox('Введите путь', 'Введите путь', '');
  if s = '' then Exit;

  if s[Length(s)] <> '\' then s := s + '\';
  if not DirectoryExists(s) then
  begin
    Application.MessageBox(PChar('Путь ' + s + ' не существует'), 'Ошибка', MB_ICONERROR);
    Exit;
  end;

  EditSource1.Text := s;
end;

procedure TFormMain.BitBtnBrowseSource2Click(Sender: TObject);
var s : string;
begin
  s := InputBox('Введите путь', 'Введите путь', '');
  if s = '' then Exit;

  if s[Length(s)] <> '\' then s := s + '\';
  if not DirectoryExists(s) then
  begin
    Application.MessageBox(PChar('Путь ' + s + ' не существует'), 'Ошибка', MB_ICONERROR);
    Exit;
  end;

  EditSource2.Text := s;
end;

function ExifToDateTime(s : string) : TDateTime;
begin
  ExifToDateTime := StrToDateTime(Copy(s, 9, 2) + '.' + Copy(s, 6, 2) + '.' + Copy(s, 1, 4) + ' ' + Copy(s, 12, 2) + ':' + Copy(s, 15, 2) + ':' + Copy(s, 18, 2));
end;

function DateTimeToExif(d : TDateTime) : string;
begin
  DateTimeToExif := AnsiReplaceText(DateTimeToStr(d), '.', ':');
end;

procedure TFormMain.BitBtnStartClick(Sender: TObject);
var sr: TSearchRec;
    FileAttrs: integer;
    i : longint;
    ex : TExif;
    FromF, ToF: file;
    NumRead, NumWritten: Integer;
    Buf: array[1..2048] of Char;
    DateTime, DateTimeOriginal, DateTimeDigitized : string;
begin
  if EditDestination.Text[Length(EditDestination.Text)] <> '\' then EditDestination.Text := EditDestination.Text + '\';

  if not DirectoryExists(EditDestination.Text) then
  begin
    Application.MessageBox(PChar('Путь ' + EditDestination.Text + ' не существует'), 'Ошибка', MB_ICONERROR);
    Exit;
  end;

  ProgressBar.Position := 0;
  
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
        if (ExifToDateTime(ex.DateTime) <> ExifToDateTime(ex.DateTimeOriginal)) or
           (ExifToDateTime(ex.DateTime) <> ExifToDateTime(ex.DateTimeDigitized)) then
        begin
          Application.MessageBox(PChar('В файле ' + NextGrid.CellByName['NxTextColumnSourceFile', NextGrid.RowCount - 1].AsString + ' отсутствуют или не равны записи DateTime, DateTimeOriginal, DateTimeDigitized'), 'Ошибка', MB_OK + MB_ICONERROR + MB_TOPMOST);
          Exit;
        end;
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
        if (ExifToDateTime(ex.DateTime) <> ExifToDateTime(ex.DateTimeOriginal)) or
           (ExifToDateTime(ex.DateTime) <> ExifToDateTime(ex.DateTimeDigitized)) then
        begin
          Application.MessageBox(PChar('В файле ' + NextGrid.CellByName['NxTextColumnSourceFile', NextGrid.RowCount - 1].AsString + ' отсутствуют или не равны записи DateTime, DateTimeOriginal, DateTimeDigitized'), 'Ошибка', MB_OK + MB_ICONERROR + MB_TOPMOST);
          Exit;
        end;
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

  if FindFirst(EditDestination.Text + '*.*', FileAttrs, sr) = 0 then
  begin
    Application.MessageBox(PChar('Папка ' + EditDestination.Text + ' должна быть пустая'), 'Ошибка', MB_ICONERROR);
    Exit;
  end;

  ProgressBar.Max := NextGrid.RowCount;

  for i := 0 to NextGrid.RowCount - 1 do
  begin
    NextGrid.CellByName['NxTextColumnDestFile', i].AsString := EditDestination.Text + RightStr('00000' + IntToStr(i+1), SpinEditDigits.Value) + '.jpg';

    try
      AssignFile(FromF, NextGrid.CellByName['NxTextColumnSourceFile', i].AsString);
      Reset(FromF, 1);
    except
      Application.MessageBox(PChar('Ошибка открытия файла ' + NextGrid.CellByName['NxTextColumnSourceFile', i].AsString), 'Ошибка', MB_OK + MB_ICONERROR + MB_TOPMOST);
      Exit;
    end;

    try
      AssignFile(ToF, NextGrid.CellByName['NxTextColumnDestFile', i].AsString);
      Rewrite(ToF, 1);
    except
      CloseFile(FromF);
      Application.MessageBox(PChar('Ошибка создания файла ' + NextGrid.CellByName['NxTextColumnDestFile', i].AsString), 'Ошибка', MB_OK + MB_ICONERROR + MB_TOPMOST);
      Exit;
    end;

    try
      repeat
        BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
        BlockWrite(ToF, Buf, NumRead, NumWritten);
      until (NumRead = 0) or (NumWritten <> NumRead);
    except
      CloseFile(FromF);
      CloseFile(ToF);
      Application.MessageBox('Ошибка копирования файла', 'Ошибка', MB_OK + MB_ICONERROR + MB_TOPMOST);
      Exit;
    end;

    CloseFile(FromF);
    CloseFile(ToF);

    //ex.ReadFromFile(NextGrid.CellByName['NxTextColumnDestFile', NextGrid.RowCount - 1].AsString);
    DateTime          := DateTimeToExif(NextGrid.CellByName['NxDateColumnDestDate', i].AsDateTime);
    DateTimeOriginal  := DateTimeToExif(NextGrid.CellByName['NxDateColumnDestDate', i].AsDateTime);
    DateTimeDigitized := DateTimeToExif(NextGrid.CellByName['NxDateColumnDestDate', i].AsDateTime);

    ProgressBar.Position := i + 1;
    Application.ProcessMessages;
  end;

  ProgressBar.Position := 0;

  ex.Free;
end;

end.
