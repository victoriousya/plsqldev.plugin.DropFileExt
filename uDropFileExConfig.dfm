object fDropFileExConfig: TfDropFileExConfig
  Left = 591
  Top = 251
  Width = 589
  Height = 234
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
  PixelsPerInch = 96
  TextHeight = 13
  object pgc1: TPageControl
    Left = 0
    Top = 25
    Width = 581
    Height = 141
    ActivePage = ts1
    Align = alClient
    TabOrder = 0
    object ts1: TTabSheet
      Caption = 'Program'
      object mmoProgram: TMemo
        Left = 0
        Top = 0
        Width = 573
        Height = 113
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Pitch = fpFixed
        Font.Style = []
        Lines.Strings = (
          'mmoProgram')
        ParentFont = False
        TabOrder = 0
      end
    end
    object ts2: TTabSheet
      Caption = 'Command'
      ImageIndex = 1
      object mmoCommand: TMemo
        Left = 0
        Top = 0
        Width = 573
        Height = 113
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Pitch = fpFixed
        Font.Style = []
        Lines.Strings = (
          
            '.+\.view\.sql|.+\.type\.sql|.+\.data\.sql|.+\.tabl\.sql|.+\.cstr' +
            '\.sql|\d{2}_\d{3}'
          
            '_\d{2}_(depot|gbl_tech|lcl_tech|tpii_arch|fraud|svlb|sw_common|s' +
            'vista(_pos|_atm|_'
          'gfd|_ecom|_switch|))(_before|)(_rollback|)\.sql')
        ParentFont = False
        TabOrder = 0
      end
    end
    object ts3: TTabSheet
      Caption = 'Test'
      ImageIndex = 2
      object mmoTest: TMemo
        Left = 0
        Top = 0
        Width = 573
        Height = 113
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Pitch = fpFixed
        Font.Style = []
        Lines.Strings = (
          'mmoTest')
        ParentFont = False
        TabOrder = 0
      end
    end
    object ts4: TTabSheet
      Caption = 'SQL'
      ImageIndex = 3
      object mmoSQL: TMemo
        Left = 0
        Top = 0
        Width = 573
        Height = 113
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Pitch = fpFixed
        Font.Style = []
        Lines.Strings = (
          'mmoSQL')
        ParentFont = False
        TabOrder = 0
      end
    end
  end
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 581
    Height = 25
    Align = alTop
    BevelOuter = bvSpace
    Caption = 'Provide PRCE Regular expressions for window types'
    TabOrder = 1
  end
  object pnl2: TPanel
    Left = 0
    Top = 166
    Width = 581
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 2
    DesignSize = (
      581
      41)
    object btn1: TButton
      Left = 203
      Top = 8
      Width = 175
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Apply'
      ModalResult = 1
      TabOrder = 0
    end
  end
end
