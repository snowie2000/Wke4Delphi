{ ******************************************************* }
{ }
{ WKE FOR DELPHI }
{ }
{ 版权所有 (C) 2018 Langji }
{ }
{ QQ:231850275 }
{ }
{ ******************************************************* }

unit Langji.Wke.Webbrowser;

// ==============================================================================
// WKE FOR DELPHI
// ==============================================================================

interface

{$I delphiver.inc}

uses
{$IFDEF DELPHI16_UP}
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.graphics, Vcl.Forms,
  System.Generics.Collections, WinAPI.Messages, Winapi.Windows,
{$ELSE}
  SysUtils, Classes, Controls, graphics, Forms, Messages, windows, Ole2,
{$ENDIF}
  Langji.Miniblink.libs, Langji.Miniblink.types, Langji.Wke.types,
  Langji.Wke.IWebBrowser, Langji.Wke.lib, Generics.Collections, superobject;

type
  TWkeWebBrowser = class;

  TOnNewWindowEvent = procedure(Sender: TObject; sUrl: string; navigationType: wkeNavigationType; windowFeatures: PwkeWindowFeatures; var openflg: TNewWindowFlag; var webbrow: TWkeWebBrowser) of object;

  TOnmbJsBindFunction = procedure(Sender: TObject; const msgid: Integer; const msgText: string) of object;

  TWkeApp = class(TComponent)
  private
    FCookieEnabled: boolean;
    FCookiePath: string;
    FUserAgent: string;
    FOnNewWindow: TOnNewWindowEvent;
    function GetWkeCookiePath: string;
    function GetWkeLibLocation: string;
    function GetWkeUserAgent: string;
    procedure SetCookieEnabled(const Value: boolean);
    procedure SetWkeCookiePath(const Value: string);
    procedure SetWkeLibLocation(const Value: string);
    procedure SetWkeUserAgent(const Value: string);
    procedure DoOnNewWindow(Sender: TObject; sUrl: string; navigationType: wkeNavigationType; windowFeatures: PwkeWindowFeatures; var wvw: wkeWebView);
  public
    FWkeWebPages: TList{$IFDEF DELPHI15_UP}<TWkeWebBrowser>{$ENDIF} ;
    constructor Create(Aowner: TComponent); override;
    destructor Destroy; override;
    procedure loaded; override;
    function CreateWebbrowser(Aparent: TWincontrol): TWkeWebBrowser; overload;
    function CreateWebbrowser(Aparent: TWincontrol; Ar: Trect): TWkeWebBrowser; overload;
    procedure CloseWebbrowser(Abrowser: TWkewebbrowser);
  published
    property WkelibLocation: string read GetWkeLibLocation write SetWkeLibLocation;
    property UserAgent: string read GetWkeUserAgent write SetWkeUserAgent;
    property CookieEnabled: boolean read FCookieEnabled write SetCookieEnabled;
    property CookiePath: string read GetWkeCookiePath write SetWkeCookiePath;
    property OnNewWindow: TOnNewWindowEvent read FOnNewWindow write FOnNewWindow;
  end;


  //浏览页面
  TWkeWebBrowser = class(TWinControl)
  private
    FwkeWndProc: TWindowProcPtr;
    FLastWebHandle: THandle;
    thewebview: TwkeWebView;
    FwkeApp: TWkeApp;
    FDragEnabled: Boolean;
    FLocalUrl, FLocalTitle: string; // 当前Url Title
    FpopupEnabled: boolean; // 允许弹窗
    FCookieEnabled: boolean;
    FZoomValue: Integer;
    FLoadFinished: boolean; // 加载完
    FIsmain: boolean;
    FPlatform: TwkePlatform;
    FDocumentIsReady: boolean; // 加载完
    FSizable: Boolean;
    FCookiePath: string;
    FLocalStorage: string;
    FUserAgent: string;
    // bCookiepathSet,bLocalStorageSet:boolean;
    FOnLoadEnd: TOnLoadEndEvent;
    FOnTitleChange: TOnTitleChangeEvent;
    FOnLoadStart: TOnBeforeLoadEvent;
    FOnUrlChange: TOnUrlChangeEvent;
    FOnCreateView: TOnCreateViewEvent;
    FOnDocumentReady: TNotifyEvent;
    FOnWindowClosing: TCloseQueryEvent;
    FOnWindowDestroy: TNotifyEvent;
    FOnAlertBox: TOnAlertBoxEvent;
    FOnConfirmBox: TOnConfirmBoxEvent;
    FOnPromptBox: TOnPromptBoxEvent;
    FOnDownload: TOnDownloadEvent;
    FOnDownload2: TOnDownload2Event;
    FOnMouseOverUrlChange: TOnUrlChangeEvent;
    FOnConsoleMessage: TOnConsoleMessgeEvent;
    FOnLoadUrlEnd: TOnLoadUrlEndEvent;
    FOnLoadUrlBegin: TOnLoadUrlBeginEvent;
    FOnLoadUrlFail: TOnLoadUrlFailEvent;
    FOnmbBindFunction: TOnmbJsBindFunction;
    class var
      FWebviewDict: TDictionary<THandle, TWkeWebBrowser>;
    class var
      FDefCookiePath, FDefLocalStoragePath: string;
    class var
      FDPIAware: boolean;
    function GetZoom: Integer;
    procedure SetZoom(const Value: Integer);

    // webview
    procedure DoWebViewTitleChange(Sender: TObject; const sTitle: string);
    procedure DoWebViewUrlChange(Sender: TObject; const sUrl: string);
    procedure DoWebViewMouseOverUrlChange(Sender: TObject; sUrl: string);
    procedure DoWebViewLoadStart(Sender: TObject; sUrl: string; navigationType: wkeNavigationType; var Cancel: boolean);
    procedure DoWebViewLoadEnd(Sender: TObject; sUrl: string; loadresult: wkeLoadingResult);
    procedure DoWebViewCreateView(Sender: TObject; sUrl: string; navigationType: wkeNavigationType; windowFeatures: PwkeWindowFeatures; var wvw: Pointer);
    procedure DoWebViewAlertBox(Sender: TObject; smsg: string);
    function DoWebViewConfirmBox(Sender: TObject; smsg: string): boolean;
    function DoWebViewPromptBox(Sender: TObject; smsg, defaultres, Strres: string): boolean;
    procedure DoWebViewConsoleMessage(Sender: TObject; const AMessage, sourceName: string; sourceLine: Cardinal; const stackTrack: string; const consoleLevel: Integer);
    procedure DoWebViewDocumentReady(Sender: TObject);
    function DoWebViewWindowClosing(Sender: TObject): Boolean;
    procedure DoWebViewWindowDestroy(Sender: TObject);
    function DoWebViewDownloadFile(Sender: TObject; sUrl: string): boolean;
    function DoWebViewDownloadFile2(Sender: TObject; sUrl, sFileName: string; var Handler: IFileDownloader): Boolean;
    procedure DoWebViewLoadUrlEnd(Sender: TObject; sUrl: string; job: Pointer; buf: Pointer; len: Integer);
    procedure DoWebViewLoadUrlFail(Sender: TObject; sUrl: string; job: Pointer);
    procedure DoWebViewLoadUrlStart(Sender: TObject; sUrl: string; job: Pointer; out bhook, bHandle: boolean);
    procedure DombJsBindFunction(Sender: TObject; const msgid: Integer; const response: string);
    procedure WM_SIZE(var msg: TMessage); message WM_SIZE;
    function GetCanBack: boolean;
    function GetCanForward: boolean;
    function GetCookieEnable: boolean;
    function GetLocationTitle: string;
    function GetLocationUrl: string;
    // function GetMediaVolume: Single;
    function GetLoadFinished: boolean;
    function GetWebHandle: Hwnd;
    /// <summary>
    ///   格式为：PRODUCTINFO=webxpress; domain=.fidelity.com; path=/; secure
    /// </summary>
    procedure SetCookie(const Value: string);
    function GetCookie: string;
    procedure SetLocaStoragePath(const Value: string);
    procedure SetHeadless(const Value: boolean);
    procedure SetTouchEnabled(const Value: boolean);
    procedure SetDragEnabled(const Value: boolean);
    procedure setOnAlertBox(const Value: TOnAlertBoxEvent);
    procedure setWkeCookiePath(const Value: string);
    procedure SetNewPopupEnabled(const Value: boolean);
    function getDocumentReady: boolean;
    function GetContentHeight: Integer;
    function GetContentWidth: Integer;
    procedure setUserAgent(const Value: string);
//    procedure webviewWndProc(hwnd: THandle; uMsg: Cardinal; wParam: WPARAM; lParam: LPARAM); stdcall;

    { Private declarations }
  protected
    { Protected declarations }
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    function WkeWndProc(hwnd: THandle; uMsg: Cardinal; wParam: wParam; lParam: lParam): LRESULT;
    procedure WndProc(var msg: TMessage); override;
    procedure setPlatform(const Value: TwkePlatform);
    property SimulatePlatform: TwkePlatform read FPlatform write setPlatform;
  public
    // 一些webview-dependent的方法，定义在这里的目的是为了方法mb和wke通用
    class procedure SetProxy(const Value: TwkeProxy; webview: TmbWebview = nil);
    class function NetHoldJobToAsynCommit(jobPtr: Pointer): BOOL;
    class procedure NetContinueJob(jobPtr: Pointer);
    class procedure NetCancelRequest(jobPtr: Pointer);
    class procedure NetSetHTTPHeaderField(jobPtr: Pointer; key, value: PWideChar; response: BOOL);
    class procedure NetSetMIMEType(jobPtr: TmbNetJob; const mtype: PAnsiChar);
    class procedure NetSetData(jobPtr: Pointer; buf: Pointer; len: Integer);
    // 一些默认值的设定
    class procedure SetDefaultCookiePath(const Value: string);
    class procedure SetDefaultLocalStoragePath(const Value: string);
    class procedure SetDPIAWare(const Value: boolean);
  public
    class function GetInstanceFromHandle(h: THandle): TWkeWebBrowser;
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CreateWebView;
    procedure GoBack;
    procedure GoForward;
    procedure Refresh;
    procedure Stop;
    procedure Wake;
    procedure FireJSEvent(eventName: string; options: ISuperObject = nil);
    procedure LoadUrl(const Aurl: string);
    /// <summary>
    ///   加载HTMLCODE
    /// </summary>
    procedure LoadHtml(const Astr: string);
    /// <summary>
    ///   加载文件
    /// </summary>
    procedure LoadFile(const AFile: string);
    /// <summary>
    ///   执行js 返回值 js执行结果
    /// </summary>
    function ExecuteJavascript(const js: string): Variant;
    /// <summary>
    /// 执行js，无视结果
    /// </summary>
    procedure RunJs(const js: string);

    /// <summary>
    ///   执行js并得到string返回值
    /// </summary>
    function GetJsTextResult(const js: string): string;
    /// <summary>
    ///   执行js并得到boolean返回值
    /// </summary>
    function GetJsBoolResult(const js: string): boolean;
    /// <summary>
    /// 是否显示指定的右键菜单
    /// </summary>
    procedure SetContextMenuItemShow(item: wkeMenuItemId; bIsShow: Boolean);

    /// <summary>
    /// 取webview 的DC
    /// </summary>
    function GetWebViewDC: HDC;
    procedure SetFocusToWebbrowser;
    procedure ShowDevTool; // 2018.3.14
    /// <summary>
    ///  取源码
    /// </summary>
    function GetSource: string;

    /// <summary>
    /// 模拟鼠标
    /// </summary>
    /// <param name=" msg">WM_MouseMove 等</param>
    /// <param name=" x,y">坐标</param>
    /// <param name=" flag">wke_lbutton 左键 、右键等 </param>
    procedure MouseEvent(const msg: Cardinal; const x, y: Integer; const flag: Integer = WKE_LBUTTON);
    /// <summary>
    /// 模拟键盘
    /// </summary>
    /// <param name=" flag">WKE_REPEAT等</param>
    procedure KeyEvent(const vkcode: Integer; const flag: Integer = 0);
    property CanBack: boolean read GetCanBack;
    property CanForward: boolean read GetCanForward;
    property LocationUrl: string read GetLocationUrl;
    property LocationTitle: string read GetLocationTitle;
    property LoadFinished: boolean read GetLoadFinished; // 加载完成
    property mainwkeview: TwkeWebView read thewebview;
    property WebViewHandle: Hwnd read GetWebHandle;
    property isMain: boolean read FIsmain;
    property IsDocumentReady: boolean read getDocumentReady;
    property ZoomPercent: Integer read GetZoom write SetZoom;
    property Headless: boolean write SetHeadless;
    property TouchEnabled: boolean write SetTouchEnabled;
    property DragEnabled: boolean write SetDragEnabled;
    property ContentWidth: Integer read GetContentWidth;
    property ContentHeight: Integer read GetContentHeight;
  published
    property Align;
    property Color;
    property Visible;
    property WkeApp: TWkeApp read FwkeApp write FwkeApp;
    property UserAgent: string read FUserAgent write setUserAgent;
    property CookieEnabled: boolean read FCookieEnabled write FCookieEnabled default true;
    property CookiePath: string read FCookiePath write setWkeCookiePath;
    /// <summary>
    ///   Cookie格式为：PRODUCTINFO=webxpress; domain=.fidelity.com; path=/; secure
    /// </summary>
    property Cookie: string read GetCookie write SetCookie;
    property LocalStoragePath: string write SetLocaStoragePath;
    property PopupEnabled: boolean read FpopupEnabled write SetNewPopupEnabled default true;
    property OnTitleChange: TOnTitleChangeEvent read FOnTitleChange write FOnTitleChange;
    property OnUrlChange: TOnUrlChangeEvent read FOnUrlChange write FOnUrlChange;
    property OnBeforeLoad: TOnBeforeLoadEvent read FOnLoadStart write FOnLoadStart;
    property OnLoadEnd: TOnLoadEndEvent read FOnLoadEnd write FOnLoadEnd;
    property OnCreateView: TOnCreateViewEvent read FOnCreateView write FOnCreateView;
    property OnWindowClosing: TCloseQueryEvent read FOnWindowClosing write FOnWindowClosing;
    property OnWindowDestroy: TNotifyEvent read FOnWindowDestroy write FOnWindowDestroy;
    property OnDocumentReady: TNotifyEvent read FOnDocumentReady write FOnDocumentReady;
    property OnAlertBox: TOnAlertBoxEvent read FOnAlertBox write setOnAlertBox;
    property OnConfirmBox: TOnConfirmBoxEvent read FOnConfirmBox write FOnConfirmBox;
    property OnPromptBox: TOnPromptBoxEvent read FOnPromptBox write FOnPromptBox;
    property OnDownloadFile: TOnDownloadEvent read FOnDownload write FOnDownload;
    property OnDownloadFile2: TOnDownload2Event read FOnDownload2 write FOnDownload2;
    property OnMouseOverUrlChanged: TOnUrlChangeEvent read FOnMouseOverUrlChange write FOnMouseOverUrlChange; // 2018.3.14
    property OnConsoleMessage: TOnConsoleMessgeEvent read FOnConsoleMessage write FOnConsoleMessage;
    property OnLoadUrlBegin: TOnLoadUrlBeginEvent read FOnLoadUrlBegin write FOnLoadUrlBegin;
    property OnLoadUrlEnd: TOnLoadUrlEndEvent read FOnLoadUrlEnd write FOnLoadUrlEnd;
    property OnLoadUrlFail: TOnLoadUrlFailEvent read FOnLoadUrlFail write FOnLoadUrlFail;
    property OnmbJsBindFunction: TOnmbJsBindFunction read FOnmbBindFunction write FOnmbBindFunction;
    property Sizable: Boolean read FSizable write FSizable default false;
  end;

implementation

uses
  dialogs, math, RegularExpressions, Variants;

type
  mbASyncJsCall = record
    evt: THandle;
    ret: Variant;
  end;

  pmbASyncJsCall = ^mbASyncJsCall;

function WkeWindowProc(hwnd: THandle; uMsg: Cardinal; wParam: wParam; lParam: lParam): LRESULT; stdcall;
var
  wke: TWkeWebBrowser;
begin
  wke := TWkeWebBrowser.GetInstanceFromHandle(hwnd);
  if wke <> nil then
    Result := wke.WkeWndProc(hwnd, uMsg, wParam, lParam)
  else
    Result := DefWindowProcW(hwnd, uMsg, wParam, lParam);
end;

// ==============================================================================
// 回调事件
// ==============================================================================

procedure doDucumentReadyCallback(webView: wkeWebView; param: Pointer; frameid: wkeFrameHwnd); cdecl;
begin
  if wkeIsMainFrame(webView, Cardinal(frameid)) then
    TWkeWebBrowser(param).DoWebViewDocumentReady(TWkeWebBrowser(param));
end;

procedure DoTitleChange(webView: wkeWebView; param: Pointer; title: wkeString); cdecl;
begin
  TWkeWebBrowser(param).DoWebViewTitleChange(TWkeWebBrowser(param), wkeWebView.GetString(title));
end;

procedure DoUrlChange(webView: wkeWebView; param: Pointer; url: wkeString); cdecl;
begin
  TWkeWebBrowser(param).DoWebViewUrlChange(TWkeWebBrowser(param), wkeWebView.GetString(url));
end;

procedure DoMouseOverUrlChange(webView: wkeWebView; param: Pointer; url: wkeString); cdecl;
begin
  TWkeWebBrowser(param).DoWebViewMouseOverUrlChange(TWkeWebBrowser(param), wkeWebView.GetString(url));
end;

procedure DoLoadEnd(webView: wkeWebView; param: Pointer; url: wkeString; result: wkeLoadingResult; failedReason: wkeString); cdecl;
begin
  TWkeWebBrowser(param).DoWebViewLoadEnd(TWkeWebBrowser(param), wkeWebView.GetString(url), result);
end;

var
  tmpSource: string = '';
  g_mbCallTimeout: boolean;

function DoGetSource(p1, p2, es: jsExecState): jsValue;
var
  s: string;
begin
  s := es.ToTempString(es.Arg(0));
  tmpSource := s;
  result := 0;
end;

function DoLoadStart(webView: wkeWebView; param: Pointer; navigationType: wkeNavigationType; url: wkeString): boolean; cdecl;
var
  Cancel: boolean;
begin
  Cancel := false;
  TWkeWebBrowser(param).DoWebViewLoadStart(TWkeWebBrowser(param), wkeWebView.GetString(url), navigationType, Cancel);
  result := not Cancel;
end;

function DoCreateView(webView: wkeWebView; param: Pointer; navigationType: wkeNavigationType; url: wkeString; windowFeatures: PwkeWindowFeatures): wkeWebView; cdecl;
var
  pt: Pointer;
begin
  TWkeWebBrowser(param).DoWebViewCreateView(TWkeWebBrowser(param), wkeWebView.GetString(url), navigationType, windowFeatures, pt);
  result := wkeWebView(pt);
end;

procedure DoPaintUpdated(webView: wkeWebView; param: Pointer; HDC: HDC; x: Integer; y: Integer; cx: Integer; cy: Integer); cdecl;
begin

end;

procedure DoAlertBox(webView: wkeWebView; param: Pointer; msg: wkeString); cdecl;
begin
  TWkeWebBrowser(param).DoWebViewAlertBox(TWkeWebBrowser(param), wkeWebView.GetString(msg));
end;

function DoConfirmBox(webView: wkeWebView; param: Pointer; msg: wkeString): boolean; cdecl;
begin
  result := TWkeWebBrowser(param).DoWebViewConfirmBox(TWkeWebBrowser(param), wkeWebView.GetString(msg));
end;

function DoPromptBox(webView: wkeWebView; param: Pointer; msg: wkeString; defaultResult: wkeString; sresult: wkeString): boolean; cdecl;
begin
  result := TWkeWebBrowser(param).DoWebViewPromptBox(TWkeWebBrowser(param), wkeWebView.GetString(msg), wkeWebView.GetString(defaultResult), wkeWebView.GetString(sresult));
end;

procedure DoConsoleMessage(webView: wkeWebView; param: Pointer; level: wkeMessageLevel; const AMessage, sourceName: wkeString; sourceLine: Cardinal; const stackTrack: wkeString); cdecl;
begin
  TWkeWebBrowser(param).DoWebViewConsoleMessage(TWkeWebBrowser(param), wkeWebView.GetString(AMessage), wkeWebView.GetString(sourceName), sourceLine, wkeWebView.GetString(stackTrack), Ord(level));
end;

procedure DocumentReady(webView: wkeWebView; param: Pointer); cdecl;
begin
  TWkeWebBrowser(param).DoWebViewDocumentReady(TWkeWebBrowser(param));
end;

function DoWindowClosing(webWindow: wkeWebView; param: Pointer): boolean; cdecl;
begin
  result := TWkeWebBrowser(param).DoWebViewWindowClosing(TWkeWebBrowser(param));
end;

procedure DoWindowDestroy(webWindow: wkeWebView; param: Pointer); cdecl;
begin
  TWkeWebBrowser(param).DoWebViewWindowDestroy(TWkeWebBrowser(param));
end;

function DodownloadFile(webView: wkeWebView; param: Pointer; url: PansiChar): boolean; cdecl; // url: wkeString): boolean; cdecl;
begin
  result := TWkeWebBrowser(param).DoWebViewDownloadFile(TWkeWebBrowser(param), StrPas(url)); // WkeStringtoString(url));
end;

function DodownloadFile2(webView: wkeWebView; param: Pointer; expectedContentLength: DWORD; const url, mime, disposition: PAnsiChar; job: wkeNetJob; dataBind: pwkeNetJobDataBind): wkeDownloadOpt; cdecl; // url: wkeString): boolean; cdecl;
var
  handler: IFileDownloader; // buggy, don't use for now.
  mh: TMatch;
  sfname: string;
  sdisposition: string;
begin
  sfname := '';
  if disposition <> nil then
  begin
    sdisposition := UTF8Decode(disposition);
    mh := TRegEx.Match(sdisposition, 'filename=(.+)');
    if mh.Success then
      sfname := mh.Groups.Item[1].Value;
  end;
  if TWkeWebBrowser(param).DoWebViewDownloadFile2(TWkeWebBrowser(param), StrPas(url), sfname, handler) then
    result := kWkeDownloadOptCacheData
  else
    result := kWkeDownloadOptCancel;
end;

procedure DoOnLoadUrlEnd(webView: wkeWebView; param: Pointer; const url: PansiChar; job: Pointer; buf: Pointer; len: Integer); cdecl;
begin
  TWkeWebBrowser(param).DoWebViewLoadUrlEnd(TWkeWebBrowser(param), StrPas(url), job, buf, len);
end;

procedure DoOnLoadUrlFail(webView: wkeWebView; param: Pointer; const url: PansiChar; job: Pointer); cdecl;
begin
  TWkeWebBrowser(param).DoWebViewLoadUrlFail(TWkeWebBrowser(param), StrPas(url), job);
end;

function DoOnLoadUrlBegin(webView: wkeWebView; param: Pointer; url: PansiChar; job: Pointer): boolean; cdecl;
var
  bhook, bHandled: boolean;
begin
  bhook := false;
  bHandled := false;
  TWkeWebBrowser(param).DoWebViewLoadUrlStart(TWkeWebBrowser(param), StrPas(url), job, bhook, bHandled);
  if bhook then
    if Assigned(wkeNetHookRequest) then
      wkeNetHookRequest(job);
  result := bHandled;
end;

function DombOnLoadUrlBegin(webView: TmbWebView; param: Pointer; const url: PAnsiChar; job: Pointer): boolean; stdcall;
var
  bhook, bHandled: boolean;
begin
  bhook := false;
  bHandled := false;
  TWkeWebBrowser(param).DoWebViewLoadUrlStart(TWkeWebBrowser(param), StrPas(url), job, bhook, bHandled);
  if bhook then
    if Assigned(wkeNetHookRequest) then
      wkeNetHookRequest(job);
  result := bHandled;
end;


//----------------------------mb回调------------------------------------//

procedure DombTitleChange(webView: TmbWebView; param: Pointer; const title: PAnsiChar); stdcall;
var
  s: string;
begin
  s := UTF8Decode(strpas(title));
  TWkeWebBrowser(param).DoWebViewTitleChange(TWkeWebBrowser(param), s);
end;

procedure DombUrlChange(webView: TmbWebView; param: Pointer; const url: PAnsiChar; bcanback, bcanforward: boolean); stdcall;
begin
  TWkeWebBrowser(param).DoWebViewUrlChange(TWkeWebBrowser(param), UTF8Decode(strpas(url)));
end;

function DombLoadStart(webView: TmbWebView; param: Pointer; navigationType: TmbNavigationType; const url: PAnsiChar): boolean; stdcall;
var
  cancel: boolean;
begin
  cancel := false;
  TWkeWebBrowser(param).DoWebViewLoadStart(TWkeWebBrowser(param), UTF8Decode(strpas(url)), wkeNavigationType(navigationType), cancel);
  result := not cancel;
end;

procedure DombLoadEnd(webView: TmbWebView; param: Pointer; frameId: TmbWebFrameHandle; const url: PAnsiChar; lresult: TmbLoadingResult; const failedReason: PAnsiChar); stdcall;
begin
  if frameId = mbWebFrameGetMainFrame(webView) then
    TWkeWebBrowser(param).DoWebViewLoadEnd(TWkeWebBrowser(param), UTF8Decode(strpas(url)), wkeLoadingResult(lresult));
end;

function DombCreateView(webView: TmbWebView; param: Pointer; navigationType: TmbNavigationType; const url: PAnsiChar; const windowFeatures: PmbWindowFeatures): TmbWebView; stdcall;
var
  xhandle: hwnd;
  wv: TmbWebview;
begin
  wv := nil;
  TWkeWebBrowser(param).DoWebViewCreateView(TWkeWebBrowser(param), UTF8Decode(strpas(url)), wkeNavigationType(navigationType), PwkeWindowFeatures(windowFeatures), wv);
  result := wv;
end;

procedure DombDocumentReady(webView: TmbWebView; param: Pointer; frameId: TmbWebFrameHandle); stdcall;
begin
  TWkeWebBrowser(param).DoWebViewDocumentReady(TWkeWebBrowser(param));
end;

procedure DoMbAlertBox(webView: TmbWebView; param: Pointer; const msg: PAnsiChar); stdcall;
begin
  TWkeWebBrowser(param).DoWebViewAlertBox(TWkeWebBrowser(param), UTF8Decode(strpas(msg)));
end;

function DombConfirmBox(webView: TmbWebView; param: Pointer; const msg: PAnsiChar): boolean; stdcall;
begin
  result := TWkeWebBrowser(param).DoWebViewConfirmBox(TWkeWebBrowser(param), UTF8Decode(strpas(msg)));
end;

function DombPromptBox(webView: TmbWebView; param: Pointer; const msg: PAnsiChar; const defaultResult: PAnsiChar; sresult: PAnsiChar): boolean; stdcall;
begin
  result := TWkeWebBrowser(param).DoWebViewPromptBox(TWkeWebBrowser(param), UTF8Decode(strpas(msg)), UTF8Decode(strpas(defaultResult)), UTF8Decode(strpas(sresult)));
end;

procedure DombConsole(webView: TmbWebView; param: Pointer; level: TmbConsoleLevel; const smessage: PAnsiChar; const sourceName: PAnsiChar; sourceLine: Cardinal; const stackTrace: PAnsiChar); stdcall;
begin
  TWkeWebBrowser(param).DoWebViewConsoleMessage(TWkeWebBrowser(param), UTF8Decode(strpas(smessage)), UTF8Decode(strpas(sourceName)), sourceLine, UTF8Decode(strpas(stackTrace)), level);
end;

function DombClose(webView: TmbWebView; param: Pointer; unuse: Pointer): boolean; stdcall;
begin
  result := TWkeWebBrowser(param).DoWebViewWindowClosing(TWkeWebBrowser(param));
end;

function DombDestory(webView: TmbWebView; param: Pointer; unuse: Pointer): boolean; stdcall;
begin
  result := false;
  TWkeWebBrowser(param).DoWebViewWindowDestroy(TWkeWebBrowser(param));
end;

function DombPrint(webView: TmbWebView; param: Pointer; step: TmbPrintintStep; hdc: hdc; const settings: TmbPrintintSettings; pagecount: Integer): Boolean; stdcall;
begin

end;

function DoMbThreadDownload(webView: TmbWebView; param: Pointer; expectedContentLength: DWORD; const url, mime, disposition: PAnsiChar; job: Tmbnetjob; databind: PmbNetJobDataBind): mbDownloadOpt; stdcall;
begin
  // 不使用databind, 自己解决下载流程
  result := mbDownloadOpt(DodownloadFile2(webView, param, expectedContentLength, url, mime, disposition, job, nil));
end;

type
  TGoBackForwardSyncEvent = record
    e: THandle;
    ret: Boolean;
  end;

  PGoBackForwardSyncEvent = ^TGoBackForwardSyncEvent;

procedure DombGetCanBackForward(webView: TmbWebView; param: Pointer; state: TMbAsynRequestState; b: Boolean); stdcall;
begin
  with PGoBackForwardSyncEvent(param)^ do
  begin
    ret := False;
    if state = kMbAsynRequestStateOk then
      ret := b;
    SetEvent(e);
  end;
end;

function mbCanGoBackSync(thewebview: TmbWebView): Boolean;
var
  syncevent: TGoBackForwardSyncEvent;
begin
  syncevent.e := CreateEvent(nil, True, False, nil);
  try
    mbCanGoBack(thewebview, DombGetCanBackForward, @syncevent);
    while not Application.Terminated do
    begin
      Application.ProcessMessages;
      if WaitForSingleObject(syncevent.e, 50) = WAIT_OBJECT_0 then
        Break;
    end;
    result := syncevent.ret;
  finally
    CloseHandle(syncevent.e);
  end;
end;

function mbCanGoForwardSync(thewebview: TmbWebView): Boolean;
var
  syncevent: TGoBackForwardSyncEvent;
begin
  syncevent.e := CreateEvent(nil, True, False, nil);
  try
    mbCanGoForward(thewebview, DombGetCanBackForward, @syncevent);
    while not Application.Terminated do
    begin
      Application.ProcessMessages;
      if WaitForSingleObject(syncevent.e, 50) = WAIT_OBJECT_0 then
        Break;
    end;
    result := syncevent.ret;
  finally
    CloseHandle(syncevent.e);
  end;
end;

procedure Dombjscallback(webView: TmbWebView; param: Pointer; es: TmbJsExecState; v: TmbJsValue); stdcall;
begin
  //TWkeWebBrowser(param).DoWebViewJsCallBack(TWkeWebBrowser(param), param, es, v);
  if (not g_mbCallTimeout) and (param <> nil) then
    with pmbASyncJsCall(param)^ do
    begin
      try
        case mbGetJsValueType(es, v) of
          kMbJsTypeNumber:
            ret := mbJsToDouble(es, v);
          kMbJsTypeString:
            ret := StrPas(mbJsToString(es, v));
          kMbJsTypeBool:
            ret := mbJsToBoolean(es, v);
          kMbJsTypeUndefined:
            ret := Unassigned;
        else
          ret := null;
        end;
      except
        ret := null;
      end;
      SetEvent(evt);
    end;
end;

procedure DombJsBindCallback(webView: TmbWebView; param: Pointer; es: TmbJsExecState; queryId: Int64; customMsg: Integer; const request: PAnsiChar); stdcall;
begin
  if customMsg = mbgetsourcemsg then
  begin
    tmpSource := UTF8Decode(StrPas(request));
//    FmbjsgetValue := true;
  end
  else
  begin
    TWkeWebBrowser(param).DombJsBindFunction(TWkeWebBrowser(param), customMsg, UTF8Decode(StrPas(request)));
    mbResponseQuery(webView, queryId, customMsg, PAnsiChar('DelphiCallback'));
  end;

end;



{ TWkeWebBrowser }

constructor TWkeWebBrowser.Create(AOwner: TComponent);
begin
  inherited;
  Color := clwhite;
  FZoomValue := 100;
  FDPIAware := False;
  FCookieEnabled := true;
  FpopupEnabled := true;
  FUserAgent := 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.1650.63 Safari/537.36';
  FPlatform := wp_Win32;
  FLocalUrl := '';
  FLocalTitle := '';
  FLocalStorage := FDefLocalStoragePath;
  FCookiePath := FDefCookiePath;
  thewebview := nil;
end;

destructor TWkeWebBrowser.Destroy;
begin
  inherited;
end;

procedure TWkeWebBrowser.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;
  if (csDesigning in ComponentState) then
    exit;
  if not Assigned(FwkeApp) then
    FIsmain := WkeLoadLibAndInit();
  CreateWebView;
end;

procedure TWkeWebBrowser.CreateWebView;
var
  wkeset: wkeSettings;
begin
  if UseFastMB then
  begin
    thewebview := mbCreateWebWindow(MB_WINDOW_TYPE_CONTROL, handle, 0, 0, Width, height);
    if Assigned(thewebview) then
    begin
      FLastWebHandle := mbGetHostHWND(thewebview);
      if FLastWebHandle <> 0 then
        FWebviewDict.Add(FLastWebHandle, Self);
      mbShowWindow(thewebview, true);
      mbSetDebugConfig(thewebview, 'wakeMinInterval', '1');
      mbSetDebugConfig(thewebview, 'drawMinInterval', '1');
      mbSetDebugConfig(thewebview, 'minimumLogicalFontSize', '1');
      mbSetDebugConfig(thewebview, 'minimumFontSize', '1');
      mbSetResourceGc(thewebview, 85);   // use Chrome's default GC interval
      SetWindowLong(FLastWebHandle, GWL_STYLE, GetWindowLong(mbGetHostHWND(thewebview), GWL_STYLE) or WS_CHILD or WS_TABSTOP or WS_CLIPCHILDREN or WS_CLIPSIBLINGS);
      if not (csDesigning in ComponentState) then
      begin
        FwkeWndProc := Pointer(GetWindowLong(FLastWebHandle, GWL_WNDPROC));
        SetWindowLong(FLastWebHandle, GWL_WNDPROC, Longint(@WkeWindowProc));
      end;
      mbResize(thewebview, Width, Height);

      mbOnTitleChanged(thewebview, DombTitleChange, Self);
      mbOnURLChanged(thewebview, DombUrlChange, Self);
      mbOnNavigation(thewebview, DombLoadStart, Self);
      mbOnLoadingFinish(thewebview, DombLoadEnd, Self);
     // if Assigned(FwkeApp) or Assigned(FOnCreateView) then
      mbOnCreateView(thewebview, DombCreateView, Self);
      mbOnDocumentReady(thewebview, DombDocumentReady, Self);
      if Assigned(FOnAlertBox) then
        mbOnAlertBox(thewebview, DoMbAlertBox, Self);
      if Assigned(FOnConfirmBox) then
        mbOnConfirmBox(thewebview, DombConfirmBox, Self);
      if Assigned(FOnPromptBox) then
        mbOnPromptBox(thewebview, DombPromptBox, Self);
      if Assigned(FOnConsoleMessage) then
        mbOnConsole(thewebview, DombCOnsole, Self);

      mbOnClose(thewebview, DombClose, Self);
      mbOnDestroy(thewebview, DombDestory, self);
      mbOnPrinting(thewebview, DombPrint, self);
      mbOnJsQuery(thewebview, DombJsBindCallback, self);
      mbOnDownloadInBlinkThread(thewebview, DoMbThreadDownload, Self);

      mbOnLoadUrlBegin(thewebview, DombOnLoadUrlBegin, Self);
      if FUserAgent <> '' then
        mbSetUserAgent(thewebview, PAnsiChar(AnsiString(FUserAgent)));
      if DirectoryExists(FCookiePath) then
        mbSetCookieJarPath(thewebview, PWideChar(FCookiePath));

      if DirectoryExists(FLocalStorage) then
        mbSetLocalStorageFullPath(thewebview, PWideChar(FLocalStorage));

      mbSetNavigationToNewWindowEnable(thewebview, FpopupEnabled);

      //wkeSetDebugConfig(thewebview, 'showDevTools', PAnsiChar(AnsiToUtf8(ExtractFilePath(ParamStr(0)) + '\front_end\inspector.html')));
//      mbSetDragDropEnable(thewebview, FDragEnabled);
      if not FDragEnabled then
        RevokeDragDrop(GetWebHandle);
      if FDPIAware then
        mbEnableHighDPISupport();
    end;
    exit;
  end;

  thewebview := wkeCreateWebWindow(WKE_WINDOW_TYPE_CONTROL, handle, 0, 0, Width, height);

  if Assigned(thewebview) then
  begin
    FLastWebHandle := wkeGetWindowHandle(thewebview);
    if FLastWebHandle <> 0 then
      FWebviewDict.Add(FLastWebHandle, Self);
    ShowWindow(thewebview.WindowHandle, SW_NORMAL);
    SetWindowLong(thewebview.WindowHandle, GWL_STYLE, GetWindowLong(thewebview.WindowHandle, GWL_STYLE) or WS_CHILD or WS_TABSTOP or WS_CLIPCHILDREN or WS_CLIPSIBLINGS);
    if not (csDesigning in ComponentState) then
    begin
      FwkeWndProc := Pointer(GetWindowLong(FLastWebHandle, GWL_WNDPROC));
      SetWindowLong(FLastWebHandle, GWL_WNDPROC, Longint(@WkeWindowProc));
    end;
    wkeSetDebugConfig(thewebview, 'wakeMinInterval', '0');
    wkeSetDebugConfig(thewebview, 'drawMinInterval', '0');
    wkeSetDebugConfig(thewebview, 'minimumLogicalFontSize', '1');
    //todo: set GC interval
    wkeSetDebugConfig(thewebview, 'minimumFontSize', '1');
    thewebview.SetOnTitleChanged(DoTitleChange, self);
    thewebview.SetOnURLChanged(DoUrlChange, self);
    thewebview.SetOnNavigation(DoLoadStart, self);
    thewebview.SetOnLoadingFinish(DoLoadEnd, self);
   // if Assigned(FwkeApp) or Assigned(FOnCreateView) then
    thewebview.SetOnCreateView(DoCreateView, self);
    thewebview.SetOnPaintUpdated(DoPaintUpdated, self);
    if Assigned(FOnAlertBox) then
      thewebview.SetOnAlertBox(DoAlertBox, self);
    if Assigned(FOnConfirmBox) then
      thewebview.SetOnConfirmBox(DoConfirmBox, self);
    if Assigned(FOnPromptBox) then
      thewebview.SetOnPromptBox(DoPromptBox, self);
    if Assigned(FOndownload) then
      thewebview.SetOnDownload(DoDownloadFile, Self);
    if Assigned(FOnDownload2) then
      thewebview.SetOnDownload2(DodownloadFile2, self);
    if Assigned(FOnMouseOverUrlChange) then
      wkeOnMouseOverUrlChanged(thewebview, DoMouseOverUrlChange, self);

    thewebview.SetOnConsoleMessage(DoConsoleMessage, self);
    wkeOnDocumentReady2(thewebview, doDucumentReadyCallback, Self);

    thewebview.SetOnWindowClosing(DoWindowClosing, self);
    thewebview.SetOnWindowDestroy(DoWindowDestroy, self);

    wkeOnLoadUrlBegin(thewebview, DoOnLoadUrlBegin, self);
    wkeOnLoadUrlEnd(thewebview, DoOnLoadUrlEnd, self);
    wkeOnLoadUrlFail(thewebview, DoOnLoadUrlFail, self);

    if FUserAgent <> '' then
     {$IFDEF UNICODE}
      wkeSetUserAgentw(thewebview, PChar(FUserAgent));
    {$ELSE}
    wkeSetUserAgent(thewebview, PansiChar(AnsiString(FUserAgent)));
    {$ENDIF}
    wkeSetCookieEnabled(thewebview, FCookieEnabled);

    if DirectoryExists(FCookiePath) and Assigned(wkeSetCookieJarPath) then
      wkeSetCookieJarPath(thewebview, PwideChar(FCookiePath));
    if DirectoryExists(FLocalStorage) and Assigned(wkeSetLocalStorageFullPath) then
      wkeSetLocalStorageFullPath(thewebview, PwideChar(FLocalStorage));

    wkeSetNavigationToNewWindowEnable(thewebview, FpopupEnabled);
//    wkeSetCspCheckEnable(thewebview, True); // 跨域检查
    jsBindFunction('GetSource', DoGetSource, 1);
//    wkeSetDragEnable(thewebview, True);
//    if not FDragEnabled then
//      RevokeDragDrop(FLastWebHandle);
    if FDPIAware then
      wkeEnableHighDPISupport();
  end;
end;

procedure TWkeWebBrowser.DombJsBindFunction(Sender: TObject; const msgid: Integer; const response: string);
begin
  if Assigned(FOnmbBindFunction) then
    FOnmbBindFunction(self, msgid, response);
end;

procedure TWkeWebBrowser.DoWebViewAlertBox(Sender: TObject; smsg: string);
begin
  if Assigned(FOnAlertBox) then
    FOnAlertBox(self, smsg);
end;

function TWkeWebBrowser.DoWebViewConfirmBox(Sender: TObject; smsg: string): boolean;
begin
  result := false;
  if Assigned(FOnConfirmBox) then
    FOnConfirmBox(self, smsg, result);
end;

procedure TWkeWebBrowser.DoWebViewConsoleMessage(Sender: TObject; const AMessage, sourceName: string; sourceLine: Cardinal; const stackTrack: string; const consoleLevel: Integer);
begin
  if Assigned(FOnConsoleMessage) then
    FOnConsoleMessage(self, AMessage, sourceName, sourceLine, stackTrack, consoleLevel);
end;

procedure TWkeWebBrowser.DoWebViewCreateView(Sender: TObject; sUrl: string; navigationType: wkeNavigationType; windowFeatures: PwkeWindowFeatures; var wvw: Pointer);
var
 // newFrm: TForm;
  view: wkeWebView;
begin
  wvw := nil;
  if Assigned(FOnCreateView) then
  begin
    FOnCreateView(self, sUrl, navigationType, windowFeatures, view);
    wvw := view;
  end;
  if not Assigned(wvw) then
  begin
    if UseFastMB then
    begin
      wvw := mbCreateWebWindow(MB_WINDOW_TYPE_POPUP, 0, windowFeatures.x, windowFeatures.y, 800, 600);
      mbShowWindow(wvw, True);
      mbMoveToCenter(wvw);
    end
    else
    begin
      wvw := wkeCreateWebWindow(WKE_WINDOW_TYPE_POPUP, 0, windowFeatures.x, windowFeatures.y, windowFeatures.Width, windowFeatures.height);
      wkeShowWindow(wvw, true);
      wkeSetWindowTitleW(wvw, PwideChar(sUrl));
    end;
  end
  else
  begin
    if UseFastMB then
    begin
      if (mbGetHostHWND(wvw) = 0) then
        wvw := thewebview;
    end
    else
    begin
      if wkeGetWindowHandle(wvw) = 0 then
        wvw := thewebview;
    end;
  end;
end;

procedure TWkeWebBrowser.DoWebViewDocumentReady(Sender: TObject);
begin
  FDocumentIsReady := true;
  if Assigned(FOnDocumentReady) then
    FOnDocumentReady(self);
end;

function TWkeWebBrowser.DoWebViewDownloadFile(Sender: TObject; sUrl: string): boolean;
begin
  if Assigned(FOnDownload) then
    FOnDownload(self, sUrl);
  result := True;
end;

function TWkeWebBrowser.DoWebViewDownloadFile2(Sender: TObject; sUrl, sFileName: string; var Handler: IFileDownloader): Boolean;
begin
  if Assigned(FOnDownload2) then
    FOnDownload2(Sender, sUrl, sFileName, Handler);
  result := Handler <> nil;
end;

procedure TWkeWebBrowser.DoWebViewLoadEnd(Sender: TObject; sUrl: string; loadresult: wkeLoadingResult);
begin
  FLoadFinished := true;
  FLocalUrl := sUrl;
  if Assigned(FOnLoadEnd) then
    FOnLoadEnd(self, sUrl, loadresult);
end;

procedure TWkeWebBrowser.DoWebViewLoadStart(Sender: TObject; sUrl: string; navigationType: wkeNavigationType; var Cancel: boolean);
begin
  FLoadFinished := false;
  FDocumentIsReady := false;
  FLocalUrl := sUrl;
  if Assigned(FOnLoadStart) then
    FOnLoadStart(self, sUrl, navigationType, Cancel);
end;

procedure TWkeWebBrowser.DoWebViewLoadUrlEnd(Sender: TObject; sUrl: string; job, buf: Pointer; len: Integer);
begin
  if Assigned(FOnLoadUrlEnd) then
    FOnLoadUrlEnd(self, sUrl, job, buf, len);
end;

procedure TWkeWebBrowser.DoWebViewLoadUrlFail(Sender: TObject; sUrl: string; job: Pointer);
begin
  if Assigned(FOnLoadUrlFail) then
    FOnLoadUrlFail(self, sUrl, job);
end;

procedure TWkeWebBrowser.DoWebViewLoadUrlStart(Sender: TObject; sUrl: string; job: Pointer; out bhook, bHandle: boolean);
begin
  // bhook:=true 表示hook会触发onloadurlend 如果只是设置 bhandle=true表示 ，只是拦截这个URL
  if Assigned(FOnLoadUrlBegin) then
    FOnLoadUrlBegin(self, sUrl, job, bhook, bHandle);
end;

procedure TWkeWebBrowser.DoWebViewMouseOverUrlChange(Sender: TObject; sUrl: string);
begin
  if Assigned(FOnMouseOverUrlChange) then
    FOnMouseOverUrlChange(self, sUrl);
end;

function TWkeWebBrowser.DoWebViewPromptBox(Sender: TObject; smsg, defaultres, Strres: string): boolean;
begin
  if Assigned(FOnPromptBox) then
    FOnPromptBox(self, smsg, defaultres, Strres, result);
end;

procedure TWkeWebBrowser.DoWebViewTitleChange(Sender: TObject; const sTitle: string);
begin
  FLocalTitle := sTitle;
  if Assigned(FOnTitleChange) then
    FOnTitleChange(self, sTitle);
end;

procedure TWkeWebBrowser.DoWebViewUrlChange(Sender: TObject; const sUrl: string);
begin
  if Assigned(FOnUrlChange) then
    FOnUrlChange(self, sUrl);
end;

function TWkeWebBrowser.DoWebViewWindowClosing(Sender: TObject): Boolean;
begin
  result := True;
  if Assigned(FOnWindowClosing) then
    FOnWindowClosing(self, result);
end;

procedure TWkeWebBrowser.DoWebViewWindowDestroy(Sender: TObject);
var
  h: THandle;
begin
  if Assigned(thewebview) then
  begin
    h := GetWebHandle();
    if h <> 0 then
      FWebviewDict.Remove(h)
    else
      FWebviewDict.Remove(FLastWebHandle);
    FLastWebHandle := 0;
  end;

  if Assigned(FOnWindowDestroy) then
    FOnWindowDestroy(self);
end;

function TWkeWebBrowser.ExecuteJavascript(const js: string): Variant; // 执行js
var
  newjs: AnsiString;
  r: jsValue;
  es: jsExecState;
  x: Integer;
  asynccall: mbASyncJsCall;
begin
  if UseFastMB then
  begin
    result := false;
    newjs := UTF8Encode('try { ' + js + '; return 1; } catch(err){ return 0;}');
    if Assigned(thewebview) then
    begin
      FillChar(asynccall, sizeof(asynccall), 0);
      with asynccall do
      begin
        evt := CreateEvent(nil, True, False, nil);
      end;
      g_mbCallTimeout := False;
      mbRunJs(thewebview, mbWebFrameGetMainFrame(thewebview), PAnsiChar(newjs), true, Dombjscallback, @asynccall, nil);
      for x := 1 to 20 do
      begin
        Application.ProcessMessages;
        if WaitForSingleObject(asynccall.evt, 100) = WAIT_OBJECT_0 then
          Break;
      end;
      g_mbCallTimeout := True;
      CloseHandle(asynccall.evt);

      result := asynccall.ret;
    end;
    exit;
  end;

  result := false;
  newjs := 'try { ' + js + '; return 1; } catch(err){ return 0;}';
  if Assigned(thewebview) then
  begin
    r := thewebview.RunJS(newjs);
    es := thewebview.GlobalExec;
    if es.IsNumber(r) then
    begin
      if es.Toint(r) = 1 then
        result := true;
    end;
  end;
end;

procedure TWkeWebBrowser.FireJSEvent(eventName: string; options: ISuperObject);
var
  json: ISuperObject;
begin
  if Assigned(thewebview) then
    if options = nil then
      RunJs(Format('window.dispatchEvent(new Event("%s"));', [eventName]))
    else
    begin
      json := SO();
      json.O['detail'] := options;
      RunJs(Format('window.dispatchEvent(new CustomEvent("%s", %s));', [eventName, json.AsJson()]));
    end;
end;

function TWkeWebBrowser.GetJsTextResult(const js: string): string;
var
  r: jsValue;
  es: jsExecState;
  x: Integer;
  ret: Variant;
begin
  result := '';

  if UseFastMB then
  begin
    if Assigned(thewebview) then
    begin
      ret := ExecuteJavascript(js);
      if VarIsStr(ret) then
        result := VarToStr(ret)
    end;
    exit;
  end;

  if Assigned(thewebview) then
  begin
    r := thewebview.RunJS(js);
    Sleep(100);
    es := thewebview.GlobalExec;
    if es.IsString(r) then
      result := es.ToTempString(r);
  end;
end;

class function TWkeWebBrowser.GetInstanceFromHandle(h: THandle): TWkeWebBrowser;
begin
  result := nil;
  if Assigned(FWebviewDict) and FWebviewDict.ContainsKey(h) then
    result := FWebviewDict[h];
end;

function TWkeWebBrowser.GetJsBoolResult(const js: string): boolean;
var
  r: jsValue;
  es: jsExecState;
  x: integer;
  ret: Variant;
begin
  result := false;
  if UseFastMB then
  begin
    if Assigned(thewebview) then
    begin
      ret := ExecuteJavascript(js);
      if VarType(ret) = varBoolean then
        result := Boolean(ret)
    end;
    exit;
  end;

  if Assigned(thewebview) then
  begin
    r := thewebview.RunJS(js);
    es := thewebview.GlobalExec;
    if es.IsBoolean(r) then
      result := es.ToBoolean(r);
  end;
end;

function TWkeWebBrowser.GetCanBack: boolean;
begin
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      result := mbCanGoBackSync(thewebview)
    else
      result := thewebview.CanGoBack;
  end;
end;

function TWkeWebBrowser.GetCanForward: boolean;
begin

  if Assigned(thewebview) then
  begin
    if UseFastMB then
      result := mbCanGoForwardSync(thewebview)
    else
      result := thewebview.CanGoForward;
  end;
end;

function TWkeWebBrowser.GetContentHeight: Integer;
begin
  result := 0;
  if UseFastMB then
    exit;
  if Assigned(thewebview) then
    result := wkeGetContentHeight(thewebview);
end;

function TWkeWebBrowser.GetContentWidth: Integer;
begin
  result := 0;
  if UseFastMB then
    exit;
  if Assigned(thewebview) then
    result := wkeGetContentWidth(thewebview);
end;

function TWkeWebBrowser.GetCookie: string;
begin
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      result := mbGetCookieOnBlinkThread(thewebview)
    else
      result := thewebview.Cookie;
  end;
end;

function TWkeWebBrowser.GetCookieEnable: boolean;
begin

  if Assigned(thewebview) then
  begin
    if UseFastMB then
      result := true
    else
      result := thewebview.CookieEnabled;
  end;

end;

function TWkeWebBrowser.getDocumentReady: boolean;
begin
  result := false;
  if Assigned(thewebview) then
  begin
    if not UseFastMB then
      FDocumentIsReady := wkeIsDocumentReady(thewebview);
    result := FDocumentIsReady;
  end;
end;

function TWkeWebBrowser.GetLoadFinished: Boolean;
begin
  result := FLoadFinished;
end;

function TWkeWebBrowser.GetLocationTitle: string;
begin

  if Assigned(thewebview) then
  begin
    if UseFastMB then
      result := FLocalTitle
    else
      result := wkeGetTitleW(thewebview);
  end;

end;

function TWkeWebBrowser.GetLocationUrl: string;
begin

  if Assigned(thewebview) then
  begin
    if UseFastMB then
      result := mbGetUrl(thewebview)
    else
      result := wkeGetUrl(thewebview);
  end;

end;

function TWkeWebBrowser.GetSource: string;        //取源码
begin
//  if Assigned(thewebview) then
//    result := wkeGetSource(thewebview);
  tmpSource := '';
  if Assigned(thewebview) then
  begin
    if UseFastMB then
    begin
      (*FmbjsgetValue := False;
      mbRunJs(thewebview, mbWebFrameGetMainFrame(thewebview), 'function onNative(customMsg, response) {console.log("on~~mbQuery:" + response);} ' + 'window.mbQuery(0x4001, document.getElementsByTagName("html")[0].outerHTML, onNative);', True, Dombjscallback, self, nil);
      repeat
        Sleep(200);
        Application.ProcessMessages;
      until FmbjsgetValue;  *)
    end
    else
    begin
      ExecuteJavascript('GetSource(document.getElementsByTagName("html")[0].outerHTML);');
    end;
    Sleep(100);
    result := tmpSource;
  end;
end;

function TWkeWebBrowser.GetWebHandle: hwnd;
begin
  result := 0;
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      result := FLastWebHandle//mbGetHostHWND(thewebview)
    else
      result := thewebview.WindowHandle;
  end;

end;

function TWkeWebBrowser.GetWebViewDC: HDC;
begin
  result := 0;
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      result := GetDC(FLastWebHandle)
    else
      result := wkeGetViewDC(thewebview);
  end;

end;

procedure TWkeWebBrowser.setUserAgent(const Value: string);
begin
  FUserAgent := Value;
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      mbSetUserAgent(thewebview, PAnsiChar(AnsiString(Value)))
    else
      wkeSetUserAgent(thewebview, PAnsiChar(AnsiString(Value)))
  end;
end;

procedure TWkeWebBrowser.setWkeCookiePath(const Value: string);
begin
  if DirectoryExists(Value) then
    FCookiePath := Value;

  if Assigned(thewebview) then
  begin
    if UseFastMB then
      mbSetCookieJarFullPath(thewebview, PwideChar(Value))
    else
      wkeSetCookieJarPath(thewebview, PwideChar(Value));
  end;
end;

function TWkeWebBrowser.getZoom: Integer;
begin

  if Assigned(thewebview) then
  begin
    if UseFastMB then
      result := Trunc(mbGetZoomFactor(thewebview) * 100)
    else
      result := Trunc(thewebview.ZoomFactor * 100)
  end
  else
    result := 100;
end;

procedure TWkeWebBrowser.GoBack;
var
  wv: TmbWebview;
begin
  if Assigned(thewebview) then
  begin
    if UseFastMB then
    begin
      mbGoBack(thewebview);
    end
    else
    begin
      if thewebview.CanGoBack then
        thewebview.GoBack;
    end;
  end;
end;

procedure TWkeWebBrowser.GoForward;
begin
  if Assigned(thewebview) then
  begin
    if UseFastMB then
    begin
      mbGoForward(thewebview);
    end
    else
    begin
      if thewebview.CanGoForward then
        thewebview.GoForward;
    end;
  end;
end;

procedure TWkeWebBrowser.KeyEvent(const vkcode, flag: integer);
begin
  if Assigned(thewebview) then
  begin
    if UseFastMB then
    begin
      mbFireKeyDownEvent(thewebview, vkcode, flag, False);
      Sleep(10);
      mbFireKeyUpEvent(thewebview, vkcode, flag, False);
    end
    else
    begin
      wkeFireKeyDownEvent(thewebview, vkcode, flag, False);
      Sleep(10);
      wkeFireKeyUpEvent(thewebview, vkcode, flag, False);
    end;
  end;
end;

procedure TWkeWebBrowser.LoadFile(const AFile: string);
begin
  if Assigned(thewebview) and FileExists(AFile) then
  begin
    FLoadFinished := false;
    if UseFastMB then
      mbLoadURL(thewebview, PAnsiChar(AnsiString(UTF8Encode('file:///' + AFile))))
    else
      thewebview.LoadFile(AFile);
  end;

end;

procedure TWkeWebBrowser.LoadHtml(const Astr: string);
begin
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      mbLoadHtmlWithBaseUrl(thewebview, PAnsiChar(UTF8String(Astr)), 'about:blank')
    else
      thewebview.LoadHTML(Astr);
  end;

end;

procedure TWkeWebBrowser.LoadUrl(const Aurl: string);
begin
  if Assigned(thewebview) then
  begin
    if UseFastMB then
    begin
      mbLoadURL(thewebview, PAnsiChar(AnsiString(UTF8Encode(Aurl))));
//      RunJs('window.location.href="' + Aurl + '";'); // mbLoadUrl存在不能加载的bug
      MoveWindow(GetWebHandle, 0, 0, Width, Height, False);
    end
    else
    begin
      thewebview.LoadURL(Aurl);
      thewebview.MoveWindow(0, 0, Width, Height);
    end;
  end;
end;

procedure TWkeWebBrowser.MouseEvent(const msg: Cardinal; const x, y, flag: Integer);
begin
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      mbFireMouseEvent(thewebview, msg, x, y, flag)
    else
      wkeFireMouseEvent(thewebview, msg, x, y, flag);
  end;
end;

class procedure TWkeWebBrowser.NetCancelRequest(jobPtr: Pointer);
begin
  if UseFastMB then
    mbNetCancelRequest(jobPtr)
  else
    wkeNetCancelRequest(jobPtr);
end;

class procedure TWkeWebBrowser.NetContinueJob(jobPtr: Pointer);
begin
  if UseFastMB then
    mbNetContinueJob(jobPtr)
  else
    wkeNetContinueJob(jobPtr);
end;

class function TWkeWebBrowser.NetHoldJobToAsynCommit(jobPtr: Pointer): BOOL;
begin
  if UseFastMB then
    result := mbNetHoldJobToAsynCommit(jobPtr)
  else
    result := wkeNetHoldJobToAsynCommit(jobPtr);
end;

class procedure TWkeWebBrowser.NetSetData(jobPtr, buf: Pointer; len: Integer);
begin
  if UseFastMB then
    mbNetSetData(jobPtr, buf, len)
  else
    wkeNetSetData(jobPtr, buf, len);
end;

class procedure TWkeWebBrowser.NetSetHTTPHeaderField(jobPtr: Pointer; key, value: PWideChar; response: BOOL);
begin
  if UseFastMB then
    mbNetSetHTTPHeaderField(jobPtr, key, value, response)
  else
    wkeNetSetHTTPHeaderField(jobPtr, key, value, response);
end;

class procedure TWkeWebBrowser.NetSetMIMEType(jobPtr: TmbNetJob; const mtype: PAnsiChar);
begin
  if UseFastMB then
    mbNetSetMIMEType(jobPtr, mtype)
  else
    wkeNetSetMIMEType(jobPtr, mtype);
end;

procedure TWkeWebBrowser.Refresh;
begin
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      mbReload(thewebview)
    else
      thewebview.Reload;
  end;
end;

procedure TWkeWebBrowser.RunJs(const js: string);
var
  newjs: AnsiString;
  r: jsValue;
  es: jsExecState;
  x: Integer;
begin
  if UseFastMB then
  begin
    newjs := UTF8Encode('try { ' + js + ';} catch(err){ }');
    if Assigned(thewebview) then
      mbRunJs(thewebview, mbWebFrameGetMainFrame(thewebview), PAnsiChar(newjs), False, Dombjscallback, nil, nil);
    exit;
  end;

  newjs := 'try { ' + js + '; return 1; } catch(err){ return 0;}';
  if Assigned(thewebview) then
  begin
    r := thewebview.RunJS(newjs);
  end;
end;

procedure TWkeWebBrowser.SetContextMenuItemShow(item: wkeMenuItemId; bIsShow: Boolean);
begin
  if Assigned(thewebview) then
    if UseFastMB then
      mbSetContextMenuItemShow(thewebview, mbMenuItemId(item), bIsShow)
    else
      wkeSetContextMenuItemShow(thewebview, item, bIsShow);
end;

procedure TWkeWebBrowser.SetCookie(const Value: string);          //设置cookie----------
begin
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      mbSetCookie(thewebview, PAnsiChar(FLocalUrl), PAnsiChar(Value))
    else
      thewebview.setcookie(Value);
  end;
end;

procedure TWkeWebBrowser.SetFocusToWebbrowser;
begin
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      SendMessage(FLastWebHandle, WM_ACTIVATE, 1, 0)
    else
    begin
      thewebview.SetFocus;
      SendMessage(thewebview.WindowHandle, WM_ACTIVATE, 1, 0);
    end;
  end;
end;

class procedure TWkeWebBrowser.SetDefaultCookiePath(const Value: string);
begin
  FDefCookiePath := Value;
end;

class procedure TWkeWebBrowser.SetDefaultLocalStoragePath(const Value: string);
begin
  FDefLocalStoragePath := Value;
end;

class procedure TWkeWebBrowser.SetDPIAware(const Value: boolean);
begin
  FDPIAware := Value;
  if Value and (Assigned(wkeEnableHighDPISupport)) then
  begin
    if UseFastMB then
      mbEnableHighDPISupport()
    else
      wkeEnableHighDPISupport();
  end
end;

procedure TWkeWebBrowser.SetDragEnabled(const Value: boolean);
begin
  // don't use! buggy!
  FDragEnabled := Value;
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      mbSetDragDropEnable(thewebview, Value)
    else
      wkeSetDragEnable(thewebview, Value);
    if not FDragEnabled then
      RevokeDragDrop(WebViewHandle);
  end;
end;

procedure TWkeWebBrowser.SetHeadless(const Value: Boolean);
begin
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      mbSetHeadlessEnabled(thewebview, Value)
    else
      wkeSetHeadlessEnabled(thewebview, Value);
  end;

end;

procedure TWkeWebBrowser.SetTouchEnabled(const Value: Boolean);
begin
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      Exit
    else
      wkeSetTouchEnabled(thewebview, Value);
  end;
end;

procedure TWkeWebBrowser.SetLocaStoragePath(const Value: string);
begin
  if Value <> FLocalStorage then
  begin
    FLocalStorage := Value;
    if Assigned(thewebview) then
    begin
      if UseFastMB then
        mbSetLocalStorageFullPath(thewebview, PWideChar(Value))
      else
        wkeSetLocalStorageFullPath(thewebview, PWideChar(Value));
      FLocalStorage := Value;
    end;
  end;

end;

procedure TWkeWebBrowser.SetNewPopupEnabled(const Value: Boolean);
begin
  FpopupEnabled := Value;
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      mbSetNavigationToNewWindowEnable(thewebview, Value)
    else
      wkeSetNavigationToNewWindowEnable(thewebview, Value);
  end;
end;

procedure TWkeWebBrowser.setOnAlertBox(const Value: TOnAlertBoxEvent);
begin
  FOnAlertBox := Value;
  if Assigned(thewebview) then
    thewebview.SetOnAlertBox(DoAlertBox, self);
end;

procedure TWkeWebBrowser.setPlatform(const Value: TwkePlatform);
begin
  if not Assigned(thewebview) then
    Exit;
  if UseFastMB then
    exit;
  if FPlatform <> Value then
  begin
    case Value of
      wp_Win32:
        wkeSetDeviceParameter(thewebview, PAnsiChar('navigator.platform'), PAnsiChar('Win32'), 0, 0);
      wp_Android:
        begin
          wkeSetDeviceParameter(thewebview, PAnsiChar('navigator.platform'), PAnsiChar('Android'), 0, 0);
          wkeSetDeviceParameter(thewebview, PAnsiChar('screen.width'), PAnsiChar('800'), 400, 0);
          wkeSetDeviceParameter(thewebview, PAnsiChar('screen.height'), PAnsiChar('1600'), 800, 0);
        end;
      wp_Ios:
        wkeSetDeviceParameter(thewebview, PAnsiChar('navigator.platform'), PAnsiChar('Android'), 0, 0);
    end;
    FPlatform := Value;
  end;
end;

class procedure TWkeWebBrowser.SetProxy(const Value: TwkeProxy; webview: TmbWebview = nil);
var
  xproxy: TmbProxy;
  shost: ansistring;
begin
// 目前不支持对单个webview设置代理，所以改为class方法
//  if Assigned(thewebview) then
  if UseFastMB then
  begin
    FillChar(xproxy, sizeof(xproxy), 0);
    with xproxy do
    begin
      mtype := TmbProxyType(Value.AType);
      shost := Value.hostname;
      StrPCopy(hostname, shost);
      port := Value.port;
      shost := Value.username;
      StrPCopy(username, shost);
      shost := Value.password;
      StrPCopy(password, shost);
    end;
    if webview <> nil then
      mbSetViewProxy(webview, @xproxy)
    else
      mbSetProxy(nil, @xproxy);
  end
  else
    wkeSetproxy(@Value);
end;

procedure TWkeWebBrowser.ShowDevTool;
begin
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      mbSetDebugConfig(thewebview, 'showDevTools', PAnsiChar(AnsiToUtf8(ExtractFilePath(ParamStr(0)) + '\front_end\inspector.html')))
    else
      wkeSetDebugConfig(thewebview, 'showDevTools', PAnsiChar(AnsiToUtf8(ExtractFilePath(ParamStr(0)) + '\front_end\inspector.html')));
  end;
end;

procedure TWkeWebBrowser.SetZoom(const Value: Integer);
begin
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      mbSetZoomFactor(thewebview, Value / 100)
    else
      thewebview.ZoomFactor := Value / 100;
  end;
end;

procedure TWkeWebBrowser.Stop;
begin
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      mbStopLoading(thewebview)
    else
      thewebview.StopLoading;
  end;

end;

procedure TWkeWebBrowser.Wake;
begin
  if Assigned(thewebview) and UseFastMB then
    mbWake(thewebview);
end;

function TWkeWebBrowser.WkeWndProc(hwnd: THandle; uMsg: Cardinal; wParam: wParam; lParam: lParam): lresult;
var
  x, y: Int16;
  p: TPoint;
const
  SIZEBOX_BORDER = 5;
begin
  result := 0;
  case uMsg of
    WM_NCHITTEST:
      if FSizable then
      begin
        x := lParam and $FFFF;
        y := lParam shr 16;
        p := ScreenToClient(Point(x, y));
        with BoundsRect do
        begin
          if (p.X - Left < SIZEBOX_BORDER) or (Right - p.X < SIZEBOX_BORDER) or (p.y < SIZEBOX_BORDER) or (bottom - p.Y < SIZEBOX_BORDER) then
            result := HTTRANSPARENT;
        end;
      end;
  end;
  if result = 0 then
    result := CallWindowProcW(FwkeWndProc, hwnd, uMsg, wParam, lParam)
end;

procedure TWkeWebBrowser.WM_SIZE(var msg: TMessage);
begin
  inherited;
  if Assigned(thewebview) then
  begin
    if UseFastMB then
      MoveWindow(FLastWebHandle, 0, 0, Width, Height, true)
    else
      thewebview.MoveWindow(0, 0, Width, Height);
  end;
end;

{procedure TWkeWebBrowser.webviewWndProc(hwnd: THandle; uMsg: Cardinal; wParam: WPARAM; lParam: LPARAM); stdcall;
begin
  case uMsg of
    Messages.WM_SIZE:
    begin
      lParam := MakeLParam(Width, Height);
    end;
  end;
  CallWindowProc(FwkeWndProc, hwnd, uMsg, wParam, lParam);
end;     }

procedure TWkeWebBrowser.WndProc(var msg: TMessage);
var
  hndl: hwnd;
begin
  case msg.msg of
    WM_SETFOCUS:
      begin
        hndl := GetWindow(handle, GW_CHILD);
        if (hndl <> 0) and (IsWindowVisible(handle)) then
          PostMessage(hndl, WM_SETFOCUS, msg.WParam, 0);
        inherited WndProc(msg);
      end;
    CM_WANTSPECIALKEY:                                  // VK_RETURN,
      if not (TWMKey(msg).CharCode in [VK_LEFT..VK_DOWN, VK_ESCAPE, VK_TAB]) then // 2018.07.26
        msg.result := 1
      else
        inherited WndProc(msg);
    WM_NCHITTEST:
      msg.Result := HTTRANSPARENT;
    WM_GETDLGCODE:
      msg.result := DLGC_WANTARROWS or DLGC_WANTCHARS or DLGC_WANTTAB;
  else
    inherited WndProc(msg);
  end;

end;









// procedure ShowLastError;
// var
// ErrorCode: DWORD;
// ErrorMessage: Pointer;
// begin
// ErrorCode := GetLastError;
// FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER or Format_MESSAGE_FROM_SYSTEM, nil, ErrorCode, 0, @ErrorMessage, 0, nil);
// showmessage('GetLastError Result: ' + IntToStr(ErrorCode) + #13 + 'Error Description: ' + string(Pchar(ErrorMessage)));
// end;

{ TWkeApp }

constructor TWkeApp.Create(AOwner: TComponent);
begin
  inherited;
  FWkeWebPages := TList{$IFDEF DELPHI15_UP}<TWkeWebBrowser>{$ENDIF}.create;
end;

destructor TWkeApp.Destroy;
begin
  FWkeWebPages.Clear;
  FWkeWebPages.Free;
  WkeFinalizeAndUnloadLib;
  inherited;
end;

procedure TWkeApp.loaded;
begin
  inherited;
  if csDesigning in ComponentState then
    exit;
  WkeLoadLibAndInit();

end;

procedure TWkeApp.CloseWebbrowser(Abrowser: TWkeWebBrowser);
begin
  FWkeWebPages.Remove(Abrowser);
end;

function TWkeApp.CreateWebbrowser(Aparent: TWinControl; Ar: Trect): TWkeWebBrowser;
var
  newBrowser: TWkeWebBrowser;
begin
  if wkeLibHandle = 0 then
    RaiseLastOSError;
  newBrowser := TWkeWebBrowser.Create(Aparent);
  newBrowser.WkeApp := self;
  newBrowser.Parent := Aparent;
  newBrowser.BoundsRect := Ar;
  newBrowser.OnCreateView := DoOnNewWindow;
  // 设置初始值
  if FUserAgent <> '' then
    newBrowser.UserAgent := FUserAgent;
  newBrowser.CookieEnabled := FCookieEnabled;
  if DirectoryExists(FCookiePath) then
    newBrowser.CookiePath := FCookiePath;
  FWkeWebPages.Add(newBrowser);
  result := newBrowser;
  wkeSetNavigationToNewWindowEnable(newBrowser.thewebview, true);

  wkeSetCspCheckEnable(newBrowser.thewebview, True);
end;

function TWkeApp.CreateWebbrowser(Aparent: TWinControl): TWkeWebBrowser;
var
  newBrowser: TWkeWebBrowser;
begin
  newBrowser := CreateWebbrowser(Aparent, Rect(0, 0, 100, 100));
  newBrowser.Align := alClient;
  result := newBrowser;
end;

procedure TWkeApp.DoOnNewWindow(Sender: TObject; sUrl: string; navigationType: wkeNavigationType; windowFeatures: PwkeWindowFeatures; var wvw: wkeWebView);
var
  Openflag: TNewWindowFlag;
  NewwebPage: TWkeWebBrowser;
begin
  Openflag := nwf_NewPage;
  NewwebPage := nil;
  if Assigned(FOnNewWindow) then
    FOnNewWindow(self, sUrl, navigationType, windowFeatures, Openflag, NewwebPage);
  case Openflag of
    nwf_Cancel:
      wvw := nil;
    nwf_NewPage:
      begin
        if NewwebPage <> nil then
          wvw := NewwebPage.thewebview;
      end;
    nwf_OpenInCurrent:
      wvw := TWkeWebBrowser(Sender).thewebview;
  end;
end;

function TWkeApp.GetWkeCookiePath: string;
begin
  result := FCookiePath;
end;

function TWkeApp.GetWkeLibLocation: string;
begin
  result := wkeLibFileName;
end;

function TWkeApp.GetWkeUserAgent: string;
begin
  result := FUserAgent;
end;

procedure TWkeApp.SetCookieEnabled(const Value: boolean);
begin
  FCookieEnabled := Value;
end;

procedure TWkeApp.setWkeCookiePath(const Value: string);
begin
  FCookiePath := Value;
end;

procedure TWkeApp.SetWkeLibLocation(const Value: string);
begin
  if FileExists(Value) then
    wkeLibFileName := Value;
end;

procedure TWkeApp.SetWkeUserAgent(const Value: string);
begin
  FUserAgent := Value;
end;

initialization
  TWkeWebBrowser.FWebviewDict := TDictionary<THandle, TWkeWebBrowser>.Create;


finalization
  FreeAndNil(TWkeWebBrowser.FWebviewDict);

end.

