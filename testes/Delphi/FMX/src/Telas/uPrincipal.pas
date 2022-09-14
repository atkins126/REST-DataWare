unit uPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.DateUtils,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.Edit,
  FMX.Layouts, FMX.Objects, FMX.ListBox,
  REST.Types,

  uConsts,

  uRESTDWAbout, uRESTDWBasicClass, uRESTDWConsts,

  uRESTDAO, uRDWRESTDAO;

type
  TfPrincipal = class(TForm)
    FlowLayout1: TFlowLayout;
    eServidor: TEdit;
    Label1: TLabel;
    ePorta: TEdit;
    Label2: TLabel;
    eEndpoint: TEdit;
    Label3: TLabel;
    Memo1: TMemo;
    Layout1: TLayout;
    Image1: TImage;
    FlowLayout2: TFlowLayout;
    eUsuario: TEdit;
    Label4: TLabel;
    eSenha: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    ComboBox1: TComboBox;
    Layout2: TLayout;
    Button2: TButton;
    FlowLayout3: TFlowLayout;
    lVersao: TLabel;
    Button3: TButton;
    StyleBook1: TStyleBook;
    Button1: TButton;
    procedure IniciarClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Rectangle1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Rectangle2Click(Sender: TObject);
  private
    { Private declarations }
    REST: TRESTDAO;
    RDWREST, RDWBinary: TRDWRESTDAO;
    inicio, fim: Double;
    pass, fail: integer;
    procedure TesteRESTRequest(aMemo: TMemo);
    procedure TesteRDWRequest(aMemo: TMemo);
    procedure LogMessage(aMemo: TMemo; aMessage: string);
    procedure TesteEndpointREST(metodo: string; count: integer);
    procedure TesteEndpointRDW(metodo: TTestRequestMethod; count: integer);
    procedure TesteEndpointRDWBinary(metodo: TTestRequestMethod;
      count: integer);
  public
    { Public declarations }
  end;

var
  fPrincipal: TfPrincipal;

implementation

{$R *.fmx}

procedure TfPrincipal.Button2Click(Sender: TObject);
begin
  inicio := now;
  Memo1.Lines.Clear;
  LogMessage(Memo1, 'Teste de 1000 requests sequenciais iniciados �s ' +
    TimeToStr(inicio));
  REST := TRESTDAO.Create(eServidor.Text, ePorta.Text);
  RDWREST := TRDWRESTDAO.Create(eServidor.Text, ePorta.Text, false);
  RDWBinary := TRDWRESTDAO.Create(eServidor.Text, ePorta.Text, true);
  if (ComboBox1.ItemIndex = 1) and
    ((eUsuario.Text <> EmptyStr) and (eSenha.Text <> EmptyStr)) then
  begin
    REST.SetBasicAuth(eUsuario.Text, eSenha.Text);
    RDWREST.SetBasicAuth(eUsuario.Text, eSenha.Text);
    RDWBinary.SetBasicAuth(eUsuario.Text, eSenha.Text);
  end;

  TThread.CreateAnonymousThread(
    procedure
    begin
      pass := 0;
      fail := 0;
      LogMessage(Memo1, 'Iniciando testes com REST Nativos...');
      TesteEndpointREST('GET', 1000);
      LogMessage(Memo1, 'Iniciando testes com RDW ClientREST...');
      TesteEndpointRDW(rtmGET, 1000);
      LogMessage(Memo1, 'Iniciando testes bin�rios com RDW ClientREST...');
      TesteEndpointRDWBinary(rtmGET, 1000);

      fim := now;
      LogMessage(Memo1, '=======================================');
      LogMessage(Memo1, 'Testes finalizados ap�s ' +
        FormatDateTime('hh:nn:ss:zzz', (fim - inicio)) + ' (hor:min:seg:mil)');
      LogMessage(Memo1, Format(' - Total: %d, Sucesso: %d, Falha: %d',
        [pass + fail, pass, fail]));

      REST.Free;
      RDWREST.Free;
      RDWBinary.Free;
    end).Start;
end;

procedure TfPrincipal.Button3Click(Sender: TObject);
begin
  Memo1.Lines.SaveToFile(ExtractFileDir(ParamStr(0)) + '\logRDWTestTool.txt');
  LogMessage(Memo1, 'Log salvo no arquivo: ' + ExtractFileDir(ParamStr(0)) +
    '\logRDWTestTool.txt');
end;

procedure TfPrincipal.FormCreate(Sender: TObject);
var
  I: integer;
begin
  lVersao.Text := Format('Vers�o componentes: %s', [RESTDWVERSAO]);
end;

procedure TfPrincipal.IniciarClick(Sender: TObject);
begin
  inicio := now;
  Memo1.Lines.Clear;
  LogMessage(Memo1, 'Testes sequenciais iniciados �s ' + TimeToStr(inicio));
  REST := TRESTDAO.Create(eServidor.Text, ePorta.Text);
  RDWREST := TRDWRESTDAO.Create(eServidor.Text, ePorta.Text, false);
  if (ComboBox1.ItemIndex = 1) and
    ((eUsuario.Text <> EmptyStr) and (eSenha.Text <> EmptyStr)) then
  begin
    REST.SetBasicAuth(eUsuario.Text, eSenha.Text);
    RDWREST.SetBasicAuth(eUsuario.Text, eSenha.Text);
  end;
  TThread.CreateAnonymousThread(
    procedure
    begin
      TesteRESTRequest(Memo1);
      TesteRDWRequest(Memo1);

      fim := now;
      LogMessage(Memo1, '=======================================');
      LogMessage(Memo1, 'Testes finalizados ap�s ' +
        FormatDateTime('hh:nn:ss:zzz', (fim - inicio)) + ' (hor:min:seg:mil)');
    end).Start;
end;

procedure TfPrincipal.LogMessage(aMemo: TMemo; aMessage: string);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      aMemo.Lines.Add(aMessage);
      aMemo.GoToTextEnd;
    end);
end;

procedure TfPrincipal.Rectangle1MouseDown(Sender: TObject; Button: TMouseButton;
Shift: TShiftState; X, Y: Single);
begin
  StartWindowDrag;
end;

procedure TfPrincipal.Rectangle2Click(Sender: TObject);
begin
  Self.Close;
end;

procedure TfPrincipal.TesteEndpointREST(metodo: string; count: integer);
var
  I: integer;
  ini, fim: Double;
begin
  ini := now;
  if pos('GET', metodo) > 0 then
  begin
    LogMessage(Memo1, 'Testando ' + count.ToString + ' requisi��es...');
    for I := 0 to count do
      if not REST.TesteEndpointGET(eEndpoint.Text) then
      begin
        LogMessage(Memo1, 'M�todo GET falhou ap�s ' + I.ToString +
          ' requisi��es');
        inc(fail);
        break;
      end;
    fim := now;
    inc(pass);
    LogMessage(Memo1, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
      (fim - ini)) + ' (min:seg:mil)');
  end
  else if pos('POST', metodo) > 0 then
  begin
    LogMessage(Memo1, 'Testando ' + count.ToString + ' requisi��es...');
    for I := 0 to count do
      if not REST.TesteEndpointPOST(eEndpoint.Text) then
      begin
        LogMessage(Memo1, 'M�todo POST falhou ap�s ' + I.ToString +
          ' requisi��es');
        inc(fail);
        break;
      end;
    fim := now;
    inc(pass);
    LogMessage(Memo1, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
      (fim - ini)) + ' (min:seg:mil)');
  end
  else if pos('PUT', metodo) > 0 then
  begin
    LogMessage(Memo1, 'Testando ' + count.ToString + ' requisi��es...');
    for I := 0 to count do
      if not REST.TesteEndpointPUT(eEndpoint.Text) then
      begin
        LogMessage(Memo1, 'M�todo PUT falhou ap�s ' + I.ToString +
          ' requisi��es');
        inc(fail);
        break;
      end;
    fim := now;
    inc(pass);
    LogMessage(Memo1, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
      (fim - ini)) + ' (min:seg:mil)');
  end
  else if pos('PATCH', metodo) > 0 then
  begin
    LogMessage(Memo1, 'Testando ' + count.ToString + ' requisi��es...');
    for I := 0 to count do
      if not REST.TesteEndpointPATCH(eEndpoint.Text) then
      begin
        LogMessage(Memo1, 'M�todo PATCH falhou ap�s ' + I.ToString +
          ' requisi��es');
        inc(fail);
        break;
      end;
    fim := now;
    inc(pass);
    LogMessage(Memo1, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
      (fim - ini)) + ' (min:seg:mil)');
  end
  else if pos('DELETE', metodo) > 0 then
  begin
    LogMessage(Memo1, 'Testando ' + count.ToString + ' requisi��es...');
    for I := 0 to count do
      if not REST.TesteEndpointDELETE(eEndpoint.Text) then
      begin
        LogMessage(Memo1, 'M�todo DELETE falhou ap�s ' + I.ToString +
          ' requisi��es');
        inc(fail);
        break;
      end;
    fim := now;
    inc(pass);
    LogMessage(Memo1, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
      (fim - ini)) + ' (min:seg:mil)');
  end;
end;

procedure TfPrincipal.TesteEndpointRDW(metodo: TTestRequestMethod;
count: integer);
var
  I: integer;
  ini, fim: Double;
begin
  ini := now;
  LogMessage(Memo1, 'Testando ' + count.ToString + ' requisi��es...');
  case metodo of
    rtmGET:
      for I := 0 to pred(count) do
        if not RDWREST.TesteEndpoint(eEndpoint.Text, rtmGET) then
        begin
          LogMessage(Memo1, 'M�todo GET falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;

    rtmPOST:
      for I := 0 to count do
        if not RDWREST.TesteEndpoint(eEndpoint.Text, rtmPOST) then
        begin
          LogMessage(Memo1, 'M�todo POST falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;

    rtmPUT:
      for I := 0 to count do
        if not RDWREST.TesteEndpoint(eEndpoint.Text, rtmPUT) then
        begin
          LogMessage(Memo1, 'M�todo PUT falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;

    rtmPATCH:
      for I := 0 to count do
        if not RDWREST.TesteEndpoint(eEndpoint.Text, rtmPATCH) then
        begin
          LogMessage(Memo1, 'M�todo PATCH falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;

    rtmDELETE:
      for I := 0 to count do
        if not RDWREST.TesteEndpoint(eEndpoint.Text, rtmDELETE) then
        begin
          LogMessage(Memo1, 'M�todo DELETE falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;
  end;
  fim := now;
  inc(pass);
  LogMessage(Memo1, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
    (fim - ini)) + ' (min:seg:mil)');
end;

procedure TfPrincipal.TesteEndpointRDWBinary(metodo: TTestRequestMethod;
count: integer);
var
  I: integer;
  ini, fim: Double;
begin
  ini := now;
  LogMessage(Memo1, 'Testando ' + count.ToString + ' requisi��es...');
  case metodo of
    rtmGET:
      for I := 0 to pred(count) do
        if not RDWBinary.TesteEndpoint(eEndpoint.Text, rtmGET) then
        begin
          LogMessage(Memo1, 'M�todo GET falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;

    rtmPOST:
      for I := 0 to count do
        if not RDWBinary.TesteEndpoint(eEndpoint.Text, rtmPOST) then
        begin
          LogMessage(Memo1, 'M�todo POST falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;

    rtmPUT:
      for I := 0 to count do
        if not RDWBinary.TesteEndpoint(eEndpoint.Text, rtmPUT) then
        begin
          LogMessage(Memo1, 'M�todo PUT falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;

    rtmPATCH:
      for I := 0 to count do
        if not RDWBinary.TesteEndpoint(eEndpoint.Text, rtmPATCH) then
        begin
          LogMessage(Memo1, 'M�todo PATCH falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;

    rtmDELETE:
      for I := 0 to count do
        if not RDWBinary.TesteEndpoint(eEndpoint.Text, rtmDELETE) then
        begin
          LogMessage(Memo1, 'M�todo DELETE falhou ap�s ' + I.ToString +
            ' requisi��es');
          inc(fail);
          break;
        end;
  end;
  fim := now;
  inc(pass);
  LogMessage(Memo1, ' - finalizado ap�s ' + FormatDateTime('nn:ss:zzz',
    (fim - ini)) + ' (min:seg:mil)');
end;

procedure TfPrincipal.TesteRDWRequest(aMemo: TMemo);
begin
  pass := 0;
  fail := 0;
  LogMessage(aMemo, 'Realizando testes de Requisi��o com RDW RESTClient...');
  if (eServidor.Text = EmptyStr) or (ePorta.Text = EmptyStr) then
  begin
    LogMessage(aMemo, 'Erro: Configura��es de servidor ou porta inv�lidas');
    exit;
  end
  else
  begin
    if not RDWREST.TesteEndpoint(eEndpoint.Text, rtmGET) then
    begin
      LogMessage(aMemo, 'Teste m�todo GET falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo GET dispon�vel');
      TesteEndpointRDW(rtmGET, 100);
      TesteEndpointRDW(rtmGET, 1000);
      TesteEndpointRDW(rtmGET, 10000);

      // LogMessage(aMemo, 'Teste de requisi��es GET concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmGET, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo GET falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmGET, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo GET falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmGET, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo GET falhou!');

      LogMessage(aMemo, 'Teste GET conclu�do');
    end;

    if not RDWREST.TesteEndpoint(eEndpoint.Text, rtmPOST) then
    begin
      LogMessage(aMemo, 'Teste m�todo POST falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo POST dispon�vel');
      TesteEndpointRDW(rtmPOST, 100);
      TesteEndpointRDW(rtmPOST, 1000);
      TesteEndpointRDW(rtmPOST, 10000);

      // LogMessage(aMemo, 'Teste de requisi��es POST concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPOST, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo POST falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPOST, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo POST falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPOST, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo POST falhou!');

      LogMessage(aMemo, 'Teste POST conclu�do');
    end;

    if not RDWREST.TesteEndpoint(eEndpoint.Text, rtmPUT) then
    begin
      LogMessage(aMemo, 'Teste m�todo PUT falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo PUT dispon�vel');
      TesteEndpointRDW(rtmPUT, 100);
      TesteEndpointRDW(rtmPUT, 1000);
      TesteEndpointRDW(rtmPUT, 10000);

      // LogMessage(aMemo, 'Teste de requisi��es PUT concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPUT, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo PUT falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPUT, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo PUT falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPUT, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo PUT falhou!');

      LogMessage(aMemo, 'Teste PUT conclu�do');
    end;

    if not RDWREST.TesteEndpoint(eEndpoint.Text, rtmPATCH) then
    begin
      LogMessage(aMemo, 'Teste m�todo PATCH falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo PATCH dispon�vel');
      TesteEndpointRDW(rtmPATCH, 100);
      TesteEndpointRDW(rtmPATCH, 1000);
      TesteEndpointRDW(rtmPATCH, 10000);

      // LogMessage(aMemo, 'Teste de requisi��es PATCH concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPATCH, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo PATCH falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPATCH, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo PATCH falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPATCH, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo PATCH falhou!');

      LogMessage(aMemo, 'Teste PATCH conclu�do');
    end;

    if not RDWREST.TesteEndpoint(eEndpoint.Text, rtmDELETE) then
    begin
      aMemo.Lines.Add('Teste m�todo DELETE falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo DELETE dispon�vel');
      TesteEndpointRDW(rtmDELETE, 100);
      TesteEndpointRDW(rtmDELETE, 1000);
      TesteEndpointRDW(rtmDELETE, 10000);

      // LogMessage(aMemo, 'Teste de requisi��es DELETE concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmDELETE, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo DELETE falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmDELETE, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo DELETE falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmDELETE, 100000)
      // then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo DELETE falhou!');

      LogMessage(aMemo, 'Teste DELETE conclu�do');
    end;
  end;
  LogMessage(aMemo, 'Fim de testes de Requisi��o com RDW RESTClient...');
  LogMessage(aMemo, Format('Testes realizados: %d, Sucesso: %d, Falhas: %d',
    [pass + fail, pass, fail]));
end;

procedure TfPrincipal.TesteRESTRequest(aMemo: TMemo);
begin
  pass := 0;
  fail := 0;
  LogMessage(aMemo, 'Realizando testes de Requisi��o com REST nativos...');
  if (eServidor.Text = EmptyStr) or (ePorta.Text = EmptyStr) then
  begin
    LogMessage(aMemo, 'Erro: Configura��es de servidor ou porta inv�lidas');
    exit;
  end
  else
  begin
    if not REST.TesteEndpointGET(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste m�todo GET falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo GET dispon�vel');
      TesteEndpointREST('GET', 100);
      TesteEndpointREST('GET', 1000);
      TesteEndpointREST('GET', 10000);

      // LogMessage(aMemo, 'Teste de requisi��es GET concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmGET, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo GET falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmGET, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo GET falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmGET, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo GET falhou!');

      LogMessage(aMemo, 'Teste GET conclu�do');
    end;

    if not REST.TesteEndpointPOST(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste m�todo POST falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo POST dispon�vel');
      TesteEndpointREST('POST', 100);
      TesteEndpointREST('POST', 1000);
      TesteEndpointREST('POST', 10000);

      // LogMessage(aMemo, 'Teste de requisi��es POST concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPOST, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo POST falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPOST, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo POST falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPOST, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo POST falhou!');

      LogMessage(aMemo, 'Teste POST conclu�do');
    end;

    if not REST.TesteEndpointPUT(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste m�todo PUT falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo PUT dispon�vel');
      TesteEndpointREST('PUT', 100);
      TesteEndpointREST('PUT', 1000);
      TesteEndpointREST('PUT', 10000);

      // LogMessage(aMemo, 'Teste de requisi��es PUT concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPUT, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo PUT falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPUT, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo PUT falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPUT, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo PUT falhou!');

      LogMessage(aMemo, 'Teste PUT conclu�do');
    end;

    if not REST.TesteEndpointPATCH(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste m�todo PATCH falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo PATCH dispon�vel');
      TesteEndpointREST('PATCH', 100);
      TesteEndpointREST('PATCH', 1000);
      TesteEndpointREST('PATCH', 10000);

      // LogMessage(aMemo, 'Teste de requisi��es PATCH concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPATCH, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo PATCH falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPATCH, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo PATCH falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmPATCH, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo PATCH falhou!');

      LogMessage(aMemo, 'Teste PATCH conclu�do');
    end;

    if not REST.TesteEndpointDELETE(eEndpoint.Text) then
    begin
      aMemo.Lines.Add('Teste m�todo DELETE falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'M�todo DELETE dispon�vel');
      TesteEndpointREST('DELETE', 100);
      TesteEndpointREST('DELETE', 1000);
      TesteEndpointREST('DELETE', 10000);

      // LogMessage(aMemo, 'Teste de requisi��es DELETE concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmDELETE, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisi��es concorrentes em m�todo DELETE falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmDELETE, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisi��es concorrentes em m�todo DELETE falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rtmDELETE, 100000)
      // then
      // LogMessage(aMemo,
      // 'Teste 100000 requisi��es concorrentes em m�todo DELETE falhou!');

      LogMessage(aMemo, 'Teste DELETE conclu�do');
    end;
  end;
  LogMessage(aMemo, 'Fim de testes de Requisi��o com REST nativos...');
  LogMessage(aMemo, Format('Testes realizados: %d, Sucesso: %d, Falhas: %d',
    [pass + fail, pass, fail]));
end;

end.
