object FormMain: TFormMain
  Left = 127
  Top = 378
  Width = 873
  Height = 534
  Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1092#1072#1081#1083#1086#1074
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  DesignSize = (
    865
    505)
  PixelsPerInch = 96
  TextHeight = 13
  object LabelSource: TLabel
    Left = 16
    Top = 16
    Width = 36
    Height = 13
    Caption = #1054#1090#1082#1091#1076#1072
  end
  object LabelDestination: TLabel
    Left = 16
    Top = 80
    Width = 24
    Height = 13
    Caption = #1050#1091#1076#1072
  end
  object BitBtnStart: TBitBtn
    Left = 16
    Top = 120
    Width = 81
    Height = 25
    Caption = #1057#1090#1072#1088#1090
    TabOrder = 4
    OnClick = BitBtnStartClick
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
  end
  object BitBtnBrowseSource2: TBitBtn
    Left = 784
    Top = 40
    Width = 65
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1054#1073#1079#1086#1088
    TabOrder = 3
    OnClick = BitBtnBrowseSource2Click
  end
  object BitBtnBrowseSource1: TBitBtn
    Left = 784
    Top = 16
    Width = 65
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1054#1073#1079#1086#1088
    TabOrder = 2
    OnClick = BitBtnBrowseSource1Click
  end
  object EditDestination: TEdit
    Left = 64
    Top = 80
    Width = 713
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 0
    Text = 'C:\_Repository\FileRenamer\Dest\'
  end
  object BitBtnBrowseDest: TBitBtn
    Left = 784
    Top = 80
    Width = 65
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1054#1073#1079#1086#1088
    TabOrder = 1
    Visible = False
  end
  object NextGrid: TNextGrid
    Left = 16
    Top = 152
    Width = 833
    Height = 324
    Anchors = [akLeft, akTop, akRight, akBottom]
    AppearanceOptions = [aoHighlightSlideCells]
    Color = 16247513
    GridLinesColor = clSkyBlue
    Options = [goDisableColumnMoving, goGrid, goHeader, goIndicator, goRowResizing]
    TabOrder = 5
    TabStop = True
    object NxTextColumnSourceFile: TNxTextColumn
      Color = 16247513
      DefaultWidth = 334
      Header.Caption = #1048#1089#1093#1086#1076#1085#1099#1081' '#1092#1072#1081#1083
      Header.Alignment = taCenter
      Position = 0
      SortType = stAlphabetic
      Width = 334
      WrapKind = wkWordWrap
    end
    object NxDateColumnSourceDate: TNxDateColumn
      Color = 16247513
      DefaultValue = '03.12.2008'
      DefaultWidth = 123
      Header.Caption = #1044#1072#1090#1072
      Header.Alignment = taCenter
      Position = 1
      SortType = stDate
      Width = 123
      WrapKind = wkWordWrap
      NoneCaption = 'None'
      TodayCaption = 'Today'
    end
    object NxDateColumnDestDate: TNxDateColumn
      Color = 16247513
      DefaultValue = '03.12.2008'
      Header.Caption = #1044#1072#1090#1072
      Header.Alignment = taCenter
      Position = 2
      SortType = stDate
      Width = 123
      WrapKind = wkWordWrap
      NoneCaption = 'None'
      TodayCaption = 'Today'
    end
    object NxTextColumnDestFile: TNxTextColumn
      Color = 16247513
      DefaultWidth = 334
      Header.Caption = #1050#1086#1085#1077#1095#1085#1099#1081' '#1092#1072#1081#1083
      Header.Alignment = taCenter
      Position = 3
      SortType = stAlphabetic
      Width = 334
      WrapKind = wkWordWrap
    end
  end
  object EditSource1: TEdit
    Left = 64
    Top = 16
    Width = 353
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 6
    Text = 'C:\_Repository\FileRenamer\Source\1\'
  end
  object EditSource2: TEdit
    Left = 64
    Top = 40
    Width = 353
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 7
    Text = 'C:\_Repository\FileRenamer\Source\2\'
  end
  object SpinEditDigits: TSpinEdit
    Left = 120
    Top = 120
    Width = 41
    Height = 22
    EditorEnabled = False
    MaxValue = 5
    MinValue = 1
    TabOrder = 8
    Value = 3
  end
  object SpinEditDelta1Day: TSpinEdit
    Left = 424
    Top = 16
    Width = 41
    Height = 22
    EditorEnabled = False
    MaxValue = 31
    MinValue = -31
    TabOrder = 9
    Value = 0
  end
  object SpinEditDelta1Month: TSpinEdit
    Left = 472
    Top = 16
    Width = 41
    Height = 22
    EditorEnabled = False
    MaxValue = 12
    MinValue = -12
    TabOrder = 10
    Value = 0
  end
  object SpinEditDelta1Year: TSpinEdit
    Left = 520
    Top = 16
    Width = 41
    Height = 22
    EditorEnabled = False
    MaxValue = 5
    MinValue = -5
    TabOrder = 11
    Value = 0
  end
  object SpinEditDelta1Hour: TSpinEdit
    Left = 584
    Top = 16
    Width = 41
    Height = 22
    EditorEnabled = False
    MaxValue = 24
    MinValue = -24
    TabOrder = 12
    Value = -2
  end
  object SpinEditDelta1Minute: TSpinEdit
    Left = 632
    Top = 16
    Width = 41
    Height = 22
    EditorEnabled = False
    MaxValue = 60
    MinValue = -60
    TabOrder = 13
    Value = 1
  end
  object SpinEditDelta1Second: TSpinEdit
    Left = 680
    Top = 16
    Width = 41
    Height = 22
    EditorEnabled = False
    MaxValue = 60
    MinValue = -60
    TabOrder = 14
    Value = 0
  end
  object SpinEditDelta2Day: TSpinEdit
    Left = 424
    Top = 40
    Width = 41
    Height = 22
    EditorEnabled = False
    MaxValue = 31
    MinValue = -31
    TabOrder = 15
    Value = 0
  end
  object SpinEditDelta2Month: TSpinEdit
    Left = 472
    Top = 40
    Width = 41
    Height = 22
    EditorEnabled = False
    MaxValue = 12
    MinValue = -12
    TabOrder = 16
    Value = 0
  end
  object SpinEditDelta2Year: TSpinEdit
    Left = 520
    Top = 40
    Width = 41
    Height = 22
    EditorEnabled = False
    MaxValue = 5
    MinValue = -5
    TabOrder = 17
    Value = 0
  end
  object SpinEditDelta2Hour: TSpinEdit
    Left = 584
    Top = 40
    Width = 41
    Height = 22
    EditorEnabled = False
    MaxValue = 24
    MinValue = -24
    TabOrder = 18
    Value = 4
  end
  object SpinEditDelta2Minute: TSpinEdit
    Left = 632
    Top = 40
    Width = 41
    Height = 22
    EditorEnabled = False
    MaxValue = 60
    MinValue = -60
    TabOrder = 19
    Value = -8
  end
  object SpinEditDelta2Second: TSpinEdit
    Left = 680
    Top = 40
    Width = 41
    Height = 22
    EditorEnabled = False
    MaxValue = 60
    MinValue = -60
    TabOrder = 20
    Value = 5
  end
  object ProgressBar: TProgressBar
    Left = 168
    Top = 128
    Width = 681
    Height = 14
    Smooth = True
    TabOrder = 21
  end
end
