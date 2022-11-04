Unit uRESTDWPhysicBase;

{$I ..\Includes\uRESTDWPlataform.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tamb�m tem por objetivo levar componentes compat�veis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc� usu�rio que precisa
 de produtividade e flexibilidade para produ��o de Servi�os REST/JSON, simplificando o processo para voc� programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organiza��o dos Projetos
 Fl�vio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
 Fernando Banhos            - Drivers e Datasets.
}

Interface

Uses
 Classes,  SysUtils, uRESTDWConsts, uRESTDWComponentBase, Db;

 Type
  TRESTDWPhysicBase = Class(TRESTDWComponent)
 Private
  vBinaryCompatibleMode : Boolean;
  aBaseComponentClass   : TComponentClass;
 Protected
  Procedure SetBaseComponentClass(aClass : TComponentClass);
  Function  CreateComponent              : TComponent;       Virtual;
  Procedure Notification     (AComponent : TComponent;
                              Operation  : TOperation);      Override;
 Public
  Constructor Create          (AOwner    : TComponent);      Override;
  Destructor  Destroy; Override;
  Property    BaseComponentClass         : TComponentClass   Read aBaseComponentClass;
 Published
  Property    BinaryCompatibleMode       : Boolean           Read vBinaryCompatibleMode Write vBinaryCompatibleMode;
 End;

Implementation

{ TRESTDWPhysicBase }

Procedure TRESTDWPhysicBase.SetBaseComponentClass(aClass : TComponentClass);
Begin
 aBaseComponentClass := aClass;
End;

Constructor TRESTDWPhysicBase.Create(AOwner: TComponent);
Begin
 Inherited;
 vBinaryCompatibleMode := False;
End;

Function TRESTDWPhysicBase.CreateComponent : TComponent;
Begin
 Result := Nil;
 If Not Assigned(aBaseComponentClass) Then
  Raise Exception.Create('BaseComponentClass not assigned...')
 Else
  Result := aBaseComponentClass.Create(Nil);
End;

Destructor TRESTDWPhysicBase.Destroy;
Begin
 Inherited;
End;

Procedure TRESTDWPhysicBase.Notification(AComponent : TComponent;
                                         Operation  : TOperation);
Begin
 Inherited Notification(AComponent, Operation);
End;

End.
