unit dmdwcgiserver;

// Cria��o de Exemplo usando CGI para Apache Server feito por "Gilberto Rocha da Silva",
//para uso do Componente TRESTServiceCGI

interface

uses
  SysUtils, Classes, HTTPApp, WSDLPub, SOAPPasInv, SOAPHTTPPasInv,
  SOAPHTTPDisp, WebBrokerSOAP, Soap.InvokeRegistry, Soap.WSDLIntf,
  System.TypInfo, Soap.WebServExp, Soap.WSDLBind, Xml.XMLSchema,
  uRESTDWBase, uDmService, uConsts, uDWAbout;

type
  TdwCGIService = class(TWebModule)
    RESTServiceCGI1: TRESTServiceCGI;
    procedure dwCGIServiceDefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dwCGIService: TdwCGIService;

implementation

uses WebReq;

{$R *.dfm}


procedure TdwCGIService.dwCGIServiceDefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
 If RESTServiceCGI1 <> Nil Then
  RESTServiceCGI1.Command(Request, Response, Handled);
end;

procedure TdwCGIService.WebModuleCreate(Sender: TObject);
begin
 RESTServiceCGI1.RootPath          := apacheWWW;
 RESTServiceCGI1.ServerMethodClass := TServerMethodDM;
end;

initialization
  WebRequestHandler.WebModuleClass := TdwCGIService;

end.
