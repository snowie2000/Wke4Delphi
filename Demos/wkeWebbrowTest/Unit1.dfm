object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 482
  ClientWidth = 846
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object WkeWebBrowser1: TWkeWebBrowser
    Left = 0
    Top = 75
    Width = 846
    Height = 407
    Align = alClient
    Color = clWhite
    UserAgent = 
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, l' +
      'ike Gecko) Chrome/31.0.1650.63 Safari/537.36 Langji.Wke 1.0'
    ZoomPercent = 100
    OnTitleChange = WkeWebBrowser1TitleChange
    OnLoadEnd = WkeWebBrowser1LoadEnd
    OnCreateView = WkeWebBrowser1CreateView
    ExplicitTop = 0
    ExplicitWidth = 636
    ExplicitHeight = 421
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 846
    Height = 75
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 0
    ExplicitLeft = -215
    ExplicitWidth = 851
    object Button2: TButton
      Left = 703
      Top = 24
      Width = 55
      Height = 25
      Caption = 'Go'
      TabOrder = 2
      OnClick = Button2Click
    end
    object Edit1: TEdit
      Left = 92
      Top = 27
      Width = 606
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 4
      Text = 'https://www.baidu.com/'
    end
    object btn_back: TBitBtn
      Left = 18
      Top = 23
      Width = 29
      Height = 27
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #8592
      TabOrder = 0
      OnClick = btn_backClick
    end
    object btn_forward: TBitBtn
      Left = 52
      Top = 23
      Width = 29
      Height = 27
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #8594
      TabOrder = 1
      OnClick = btn_forwardClick
    end
    object Button1: TButton
      Left = 764
      Top = 24
      Width = 75
      Height = 25
      Caption = #21462#28304#30721
      TabOrder = 3
      OnClick = Button1Click
    end
  end
end
