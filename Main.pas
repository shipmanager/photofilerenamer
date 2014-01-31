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
  f : file;
  FSwap : boolean;

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

procedure WriteDatesToExif(const FileName, DateTime, DateTimeOriginal, DateTimeDigitized: string);
type
  TMarker = packed record
    Marker  : Word;      //Section marker
    Len     : Word;      //Length Section
    Indefin : Array [0..4] of Char; //Indefiner - "Exif" 00, "JFIF" 00 and ets
    Pad     : Char;      //0x00
  end;

  TIFDHeader = packed record
    pad       : Byte; //00h
    ByteOrder : Word; //II (4D4D) or MM
    i42       : Word; //2A00 (magic number from the 'Hitchhikers Guide'
    Offset    : Cardinal; //0th offset IFD
    Count     : Word;     // number of IFD entries
  end;

function SwapLong(Value: Cardinal): Cardinal;
asm bswap eax end;

procedure ReadTag(var tag: TIfdTag);
begin
  BlockRead(f, tag, 12);
  if FSwap then with tag do
  begin // motorola or intel byte order ?
    ID  := Swap(ID);
    Typ := Swap(Typ);
    Count := SwapLong(Count);
    if (Typ=1) or (Typ=3) then
      Offset := (Offset shr 8) and $FF
    else
      Offset  := SwapLong(Offset);
    end
  else with tag do begin
    if ID<>$8827 then  //ISO Metering Mode not need conversion
      if (Typ=1) or (Typ=3) then
        Offset := Offset and $FF; // other bytes are undefined but maybe not zero
  end;
end;

procedure WriteAsci(const Offset, Count : Cardinal; Value : string);
var
  fp : LongInt;
  i  : Word;
begin
  showmessage(Value);
  fp := FilePos(f); //Save file offset
  Seek(f, Offset);
  try
    i := 1;
    repeat
      BlockWrite(f, Value[i], 1);
      inc(i);
    until (i >= Count);// or (Result[i-1] = #0);
    //if i <= Count then Result := Copy(Result, 1, i-1);
  except

  end;
  Seek(f, fp);     //Restore file offset
end;

var SOI : Word; //2 bytes SOI marker. FF D8 (Start Of Image)
    j : TMarker;
    i : integer;
    off0 : Cardinal; //Null Exif Offset
    ifd  : TIFDHeader;
    tag  : TIfdTag;
    ifdp : Cardinal;
    IfdCnt : Word;
begin
  System.FileMode := 2;

  AssignFile(f,FileName);
  Reset(f,1);

  BlockRead(f, SOI, 2);
  if SOI = $D8FF then //Is this Jpeg
  begin
    BlockRead(f,j,9);

    if j.Marker = $E0FF then //JFIF Marker Found
    begin
      Seek(f, 20); //Skip JFIF Header
      BlockRead(f, j, 9);
    end;

    //Search Exif start marker;
    if j.Marker <> $E1FF then
    begin
      i := 0;
      repeat
        BlockRead(f, SOI, 2); //Read bytes.
        inc(i);
      until (EOF(f) or (i>1000) or (SOI=$E1FF));
      //If we find maker
      if SOI = $E1FF then
      begin
        Seek(f, FilePos(f)-2); //return Back on 2 bytes
        BlockRead(f, j, 9);    //read Exif header
      end;
    end;

    if j.Marker = $E1FF then
    begin //If we found Exif Section. j.Indefin='Exif'.
      off0 := FilePos(f) + 1;   //0'th offset Exif header
      BlockRead(f, ifd, 11);  //Read IDF Header
      FSwap := ifd.ByteOrder=$4D4D; // II or MM  - if MM we have to swap
      if FSwap then begin
        ifd.Offset := SwapLong(ifd.Offset);
        ifd.Count  := Swap(ifd.Count);
      end;
      if ifd.Offset <> 8 then begin
        Seek(f, FilePos(f)+abs(ifd.Offset)-8);
      end;

      if (ifd.Count=0) then ifd.Count:=100;

      for i := 1 to ifd.Count do begin
        ReadTag(tag);
        case tag.ID of
              0: break;
              $0132: WriteAsci(tag.Offset+off0, tag.Count, DateTime);
        end;
      end;

      if ifdp > 0 then
      begin
        Seek(f, ifdp + off0);
        BlockRead(f, IfdCnt, 2);
        if FSwap then IfdCnt := swap(IfdCnt);
        for i := 1 to IfdCnt do
        begin
          ReadTag(tag);

          case tag.ID of
                0: break;
            $9003: WriteAsci(tag.OffSet+off0,tag.Count, DateTimeOriginal);
            $9004: WriteAsci(tag.OffSet+off0,tag.Count, DateTimeDigitized);
          end;
        end;
      end;
    end;
  end;
  CloseFile(f);
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

    if NextGrid.CellByName['NxDateColumnSourceDate', i].AsDateTime <> NextGrid.CellByName['NxDateColumnDestDate', i].AsDateTime then
    begin
      //ex.ReadFromFile(NextGrid.CellByName['NxTextColumnDestFile', NextGrid.RowCount - 1].AsString);
      //DateTime          := DateTimeToExif(NextGrid.CellByName['NxDateColumnDestDate', i].AsDateTime);
      WriteDatesToExif(NextGrid.CellByName['NxTextColumnDestFile', i].AsString, DateTimeToExif(NextGrid.CellByName['NxDateColumnDestDate', i].AsDateTime), DateTimeToExif(NextGrid.CellByName['NxDateColumnDestDate', i].AsDateTime), DateTimeToExif(NextGrid.CellByName['NxDateColumnDestDate', i].AsDateTime));
      //DateTimeOriginal  := DateTimeToExif(NextGrid.CellByName['NxDateColumnDestDate', i].AsDateTime);
      //DateTimeDigitized := DateTimeToExif(NextGrid.CellByName['NxDateColumnDestDate', i].AsDateTime);
    end;

    ProgressBar.Position := i + 1;
    Application.ProcessMessages;
  end;

  ProgressBar.Position := 0;

  ex.Free;
end;

end.
