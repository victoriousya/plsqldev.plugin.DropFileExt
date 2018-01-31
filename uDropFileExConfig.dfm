object fDropFileExConfig: TfDropFileExConfig
  Left = 591
  Top = 258
  Width = 489
  Height = 194
  HorzScrollBar.Visible = False
  Caption = 'DropFileEx config'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    481
    167)
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 0
    Top = 0
    Width = 251
    Height = 13
    Caption = 'Provide PRCE Regular expressions for window types'
  end
  object lbl2: TLabel
    Left = 0
    Top = 24
    Width = 40
    Height = 13
    Caption = 'Program'
  end
  object lbl3: TLabel
    Left = 0
    Top = 48
    Width = 47
    Height = 13
    Caption = 'Command'
  end
  object lbl4: TLabel
    Left = 0
    Top = 72
    Width = 21
    Height = 13
    Caption = 'Test'
  end
  object lbl5: TLabel
    Left = 0
    Top = 96
    Width = 19
    Height = 13
    Caption = 'SQL'
  end
  object edtProgram: TEdit
    Left = 64
    Top = 24
    Width = 401
    Height = 21
    TabOrder = 0
    Text = 'edtProgram'
  end
  object edtCommand: TEdit
    Left = 64
    Top = 48
    Width = 401
    Height = 21
    TabOrder = 1
    Text = 'edtCommand'
  end
  object edtTest: TEdit
    Left = 64
    Top = 72
    Width = 401
    Height = 21
    TabOrder = 2
    Text = 'edtTest'
  end
  object edtSQL: TEdit
    Left = 64
    Top = 96
    Width = 401
    Height = 21
    TabOrder = 3
    Text = 'edtSQL'
  end
  object btn1: TButton
    Left = 203
    Top = 136
    Width = 75
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Apply'
    ModalResult = 1
    TabOrder = 4
  end
end
