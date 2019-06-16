object AlgoForm: TAlgoForm
  Left = 132
  Top = 198
  Width = 838
  Height = 862
  Caption = 'Something in ALGO like graphics window'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object MyImage: TImage
    Left = 6
    Top = 21
    Width = 800
    Height = 800
    Visible = False
  end
  object MyArea: TPaintBox
    Left = 6
    Top = 21
    Width = 800
    Height = 800
    Color = clWhite
    ParentColor = False
  end
  object StartStopButton: TButton
    Left = 1
    Top = 1
    Width = 100
    Height = 20
    Caption = 'Start'
    TabOrder = 0
  end
  object ImagePaintBoxButton: TButton
    Left = 101
    Top = 1
    Width = 100
    Height = 20
    Caption = 'Paint image'
    TabOrder = 1
  end
  object SavePictButton: TButton
    Left = 202
    Top = 1
    Width = 100
    Height = 20
    Caption = 'Save image'
    Enabled = False
    TabOrder = 2
  end
  object Grabber: TEdit
    Left = 303
    Top = 1
    Width = 509
    Height = 21
    Color = clSilver
    TabOrder = 3
  end
end
