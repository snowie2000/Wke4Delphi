unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Langji.Wke.Webbrowser,
  Langji.Wke.types,
  Vcl.ExtCtrls, Vcl.Buttons, Vcl.ComCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Edit1: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    WkeApp1: TWkeApp;
    Button2: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure WkeWebBrowser1TitleChange(Sender: TObject; sTitle: string);
    procedure WkeWebBrowser1LoadEnd (Sender: TObject; sUrl: string; loadresult: wkeLoadingResult);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure WkeApp1NewWindow(Sender: TObject; sUrl: string;
      navigationType: wkeNavigationType; windowFeatures: PwkeWindowFeatures;
      var openflg: TNewWindowFlag; var webbrow: TWkeWebBrowser);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    WkeWebBrowser1: TWkeWebBrowser;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  WkeWebBrowser1.GoBack;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
  WkeWebBrowser1.GoForward;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  WkeWebBrowser1.loadurl(Edit1.Text);
  WkeWebBrowser1.DragEnabled :=False;
 // WkeWebBrowser1.Headless :=true;
end;



procedure TForm1.Button2Click(Sender: TObject);
var newtab:TTabSheet;
begin
 // WkeWebBrowser1.ShowDevTool;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  WkeWebBrowser1 := WkeApp1.CreateWebbrowser(TabSheet1 );
  WkeWebBrowser1.OnTitleChange := WkeWebBrowser1TitleChange;
  WkeWebBrowser1.OnLoadEnd  :=    WkeWebBrowser1LoadEnd;
end;

procedure TForm1.WkeApp1NewWindow(Sender: TObject; sUrl: string;
  navigationType: wkeNavigationType; windowFeatures: PwkeWindowFeatures;
  var openflg: TNewWindowFlag; var webbrow: TWkeWebBrowser);
  var newtab:TTabSheet;
    newwke:TWkeWebBrowser;
begin
  openflg :=TNewWindowFlag.nwf_NewPage;

  //??????tabsheet
 // ShowMessage('new');
  newtab :=TTabSheet.Create(PageControl1 );
  newtab.Caption :=sUrl;
  newtab.PageControl :=PageControl1;
  PageControl1.ActivePage :=newtab;
  newwke:= WkeApp1.CreateWebbrowser(newtab );
  newwke.OnTitleChange := WkeWebBrowser1TitleChange;
  newwke.OnLoadEnd  :=    WkeWebBrowser1LoadEnd;


  newwke.Visible :=true;
  newwke.Align :=alClient;
  webbrow :=newwke;
end;

procedure TForm1.WkeWebBrowser1LoadEnd(Sender: TObject; sUrl: string;
  loadresult: wkeLoadingResult);
begin
  Edit1.Text :=WkeWebBrowser1.LocationUrl;
end;

procedure TForm1.WkeWebBrowser1TitleChange(Sender: TObject; sTitle: string);
begin
  Caption := sTitle;
end;

end.

