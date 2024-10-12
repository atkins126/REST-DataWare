unit uRESTDWMemBase;
{$I ..\..\Includes\uRESTDW.inc}

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
}

interface
uses
  uRESTDWMemConsts,
  {$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF MSWINDOWS}
  System.SysUtils
  {$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  SysUtils
  {$ENDIF ~HAS_UNITSCOPE},
  uRESTDWProtoTypes;
// Version
const
  {$IFDEF UNIX}
  // renamed to DirDelimiter
  // PathSeparator    = '/';
  DirDelimiter = '/';
  DirSeparator = ':';
  {$ENDIF UNIX}
  {$IFDEF MSWINDOWS}
  PathDevicePrefix = '\\.\';
  // renamed to DirDelimiter
  // PathSeparator    = '\';
  DirDelimiter = '\';
  DirSeparator = ';';
  PathUncPrefix    = '\\';
  {$ENDIF MSWINDOWS}
  JclVersionMajor   = 2;    // 0=pre-release|beta/1, 2, ...=final
  JclVersionMinor   = 8;    // Fifth minor release since JCL 1.90
  JclVersionRelease = 0;    // 0: pre-release|beta/ 1: release
  JclVersionBuild   = 5677; // build number, days since march 1, 2000
  JclVersion = (JclVersionMajor shl 24) or (JclVersionMinor shl 16) or
    (JclVersionRelease shl 15) or (JclVersionBuild shl 0);
// EJclError
type
  EJclError = class(Exception);
// EJclInternalError
type
  EJclInternalError = class(EJclError);
// Types
Type
 {$IFDEF FPC}
  Float  = Single;
 {$ELSE}
  Float = Single;
 {$ENDIF}
 PFloat = ^Float;
type
  {$IFDEF FPC}
   Largeint = Int64;
   SizeInt  = Integer;
  {$ELSE}
   SizeInt = Integer;
   PSizeInt = ^SizeInt;
   PPointer = ^Pointer;
   PByte = System.PByte;
   Int8 = ShortInt;
   Int16 = Smallint;
   Int32 = Integer;
   UInt8 = Byte;
   UInt16 = Word;
   UInt32 = LongWord;
   PCardinal = ^Cardinal;
   {$IFNDEF COMPILER7_UP}
    UInt64 = Int64;
   {$ENDIF ~COMPILER7_UP}
    PAnsiChar = ^DWString;
    PWideChar = System.PWideChar;
    PPWideChar = ^PWideChar;
    PPAnsiChar = ^PAnsiChar;
    PInt64 = type System.PInt64;
   {$ENDIF}
  PPInt64 = ^PInt64;
  PPPAnsiChar = ^PPAnsiChar;
{$IFNDEF FPC}
type
  PLargeInteger = ^TLargeInteger;
  TLargeInteger = Int64;
{$ENDIF ~FPC}
{$IFNDEF COMPILER11_UP}
type
  TBytes = array of Byte;
{$ENDIF ~COMPILER11_UP}
// Redefinition of PByteArray to avoid range check exceptions.
type
  TJclByteArray = array [0..MaxInt div SizeOf(Byte) - 1] of Byte;
  PJclByteArray = ^TJclByteArray;
  TJclBytes = Pointer; // under .NET System.pas: TBytes = array of Byte;
// Redefinition of ULARGE_INTEGER to relieve dependency on Windows.pas
type
  {$IFNDEF FPC}
  PULARGE_INTEGER = ^ULARGE_INTEGER;
  {$EXTERNALSYM PULARGE_INTEGER}
  ULARGE_INTEGER = record
    case Integer of
    0:
     (LowPart: LongWord;
      HighPart: LongWord);
    1:
     (QuadPart: Int64);
  end;
  {$EXTERNALSYM ULARGE_INTEGER}
  {$ENDIF ~FPC}
  TJclULargeInteger = ULARGE_INTEGER;
  PJclULargeInteger = PULARGE_INTEGER;
  {$IFNDEF COMPILER16_UP}
  LONG = Longint;
  {$EXTERNALSYM LONG}
  {$ENDIF ~COMPILER16_UP}
// Dynamic Array support
type
  TDynByteArray          = array of Byte;
  TDynShortIntArray      = array of Shortint;
  TDynWordArray          = array of Word;
  TDynSmallIntArray      = array of Smallint;
  TDynLongIntArray       = array of Longint;
  TDynInt64Array         = array of Int64;
  TDynCardinalArray      = array of Cardinal;
  TDynIntegerArray       = array of Integer;
  TDynSizeIntArray       = array of SizeInt;
  TDynExtendedArray      = array of Extended;
  TDynDoubleArray        = array of Double;
  TDynSingleArray        = array of Single;
  TDynFloatArray         = array of Float;
  TDynPointerArray       = array of Pointer;
  TDynStringArray        = array of string;
  TDynAnsiStringArray    = array of DwString;
  TDynWideStringArray    = array of DwWideString;
  {$IFDEF SUPPORTS_UNICODE_STRING}
  TDynUnicodeStringArray = array of UnicodeString;
  {$ENDIF SUPPORTS_UNICODE_STRING}
  TDynIInterfaceArray    = array of IInterface;
  TDynObjectArray        = array of TObject;
  TDynCharArray       = array of Char;
  TDynAnsiCharArray   = array of DwChar;
  TDynWideCharArray   = array of WideChar;
// Cross-Platform Compatibility
const
  // line delimiters for a version of Delphi/C++Builder
  NativeLineFeed       = Char(#10);
  NativeCarriageReturn = Char(#13);
  NativeCrLf           = string(#13#10);
  // default line break for a version of Delphi on a platform
  {$IFDEF MSWINDOWS}
  NativeLineBreak      = NativeCrLf;
  {$ENDIF MSWINDOWS}
  {$IFDEF UNIX}
  NativeLineBreak      = NativeLineFeed;
  {$ENDIF UNIX}
  HexPrefixPascal = string('$');
  HexPrefixC      = string('0x');
  HexDigitFmt32   = string('%.8x');
  HexDigitFmt64   = string('%.16x');
  HexPrefix       = HexPrefixPascal;
  {$IFDEF FPC}
   {$IFDEF CPU32}
   HexDigitFmt     = HexDigitFmt32;
   {$ENDIF CPU32}
   {$IFDEF CPU64}
   HexDigitFmt     = HexDigitFmt64;
   {$ENDIF CPU64}
  {$ELSE}
   {$IF Defined(CPUX32)}
   HexDigitFmt     = HexDigitFmt32;
   {$ELSEIF CPUX64}
   HexDigitFmt     = HexDigitFmt64;
   {$ELSE}
    HexDigitFmt     = HexDigitFmt32;
   {$IFEND}
  {$ENDIF}
  HexFmt = HexPrefix + HexDigitFmt;
const
  BOM_UTF16_LSB: array [0..1] of Byte = ($FF,$FE);
  BOM_UTF16_MSB: array [0..1] of Byte = ($FE,$FF);
  BOM_UTF8: array [0..2] of Byte = ($EF,$BB,$BF);
  BOM_UTF32_LSB: array [0..3] of Byte = ($FF,$FE,$00,$00);
  BOM_UTF32_MSB: array [0..3] of Byte = ($00,$00,$FE,$FF);
//  BOM_UTF7_1: array [0..3] of Byte = ($2B,$2F,$76,$38);
//  BOM_UTF7_2: array [0..3] of Byte = ($2B,$2F,$76,$39);
//  BOM_UTF7_3: array [0..3] of Byte = ($2B,$2F,$76,$2B);
//  BOM_UTF7_4: array [0..3] of Byte = ($2B,$2F,$76,$2F);
//  BOM_UTF7_5: array [0..3] of Byte = ($2B,$2F,$76,$38,$2D);
type
  // Unicode transformation formats (UTF) data types
  PUTF7 = ^UTF7;
  UTF7 = DwChar;
  PUTF8 = ^UTF8;
  UTF8 = DwChar;
  PUTF16 = ^UTF16;
  UTF16 = WideChar;
  PUTF32 = ^UTF32;
  UTF32 = Cardinal;
  // UTF conversion schemes (UCS) data types
  PUCS4 = ^UCS4;
  UCS4 = Cardinal;
  PUCS2 = PDWChar;
  UCS2 = WideChar;
  TUCS2Array = array of UCS2;
  TUCS4Array = array of UCS4;
  // string types
  TUTF8String = DwString;
  {$IFDEF SUPPORTS_UNICODE_STRING}
  TUTF16String = UnicodeString;
  TUCS2String = UnicodeString;
  {$ELSE}
  TUTF16String = DWWideString;
  TUCS2String = DWWideString;
  {$ENDIF SUPPORTS_UNICODE_STRING}
var
  AnsiReplacementCharacter: DwChar;
const
  UCS4ReplacementCharacter: UCS4 = $0000FFFD;
  MaximumUCS2: UCS4 = $0000FFFF;
  MaximumUTF16: UCS4 = $0010FFFF;
  MaximumUCS4: UCS4 = $7FFFFFFF;
  SurrogateHighStart = UCS4($D800);
  SurrogateHighEnd = UCS4($DBFF);
  SurrogateLowStart = UCS4($DC00);
  SurrogateLowEnd = UCS4($DFFF);
// basic set types
type
  TSetOfAnsiChar = set of DwChar;
{$IFNDEF HAS_FMX}
procedure RaiseLastOSError;
{$ENDIF ~HAS_FMX}
{$IFNDEF RTL230_UP}
procedure CheckOSError(ErrorCode: Cardinal);
{$ENDIF RTL230_UP}
procedure MoveChar(const Source: string; FromIndex: SizeInt;
  var Dest: string; ToIndex, Count: SizeInt); overload; // Index: 0..n-1
function AnsiByteArrayStringLen(Data: TBytes): SizeInt;
function StringToAnsiByteArray(const S: string): TBytes;
function AnsiByteArrayToString(const Data: TBytes; Count: SizeInt): string;
function BytesOf(const Value: DWString): TBytes; overload;
{$IFNDEF FPC}
{$IFNDEF COMPILER11_UP}
type // Definitions for 32 Bit Compilers
  // From BaseTsd.h
  INT_PTR = Integer;
  {$EXTERNALSYM INT_PTR}
  LONG_PTR = Longint;
  {$EXTERNALSYM LONG_PTR}
  UINT_PTR = Cardinal;
  {$EXTERNALSYM UINT_PTR}
  ULONG_PTR = LongWord;
  {$EXTERNALSYM DWORD_PTR}
{$ENDIF ~COMPILER11_UP}
type
  DWORD_PTR  = LongWord;
  PDWORD_PTR = ^DWORD_PTR;
  {$EXTERNALSYM PDWORD_PTR}
{$ENDIF ~FPC}
type
  TJclAddr32 = Cardinal;
  {$IFDEF FPC}
   TJclAddr64 = QWord;
   {$IFDEF CPU32}
   TJclAddr = Cardinal;
   {$ENDIF CPU32}
   {$IFDEF CPU64}
   TJclAddr = QWord;
   {$ENDIF CPU64}
  {$ELSE}
   TJclAddr64 = Int64;
   {$IF Defined(CPUX32)}
    TJclAddr = TJclAddr32;
   {$ELSEIF CPUX64}
    TJclAddr = TJclAddr64;
   {$ELSE}
    TJclAddr = TJclAddr32;
   {$IFEND}
  {$ENDIF}
  PJclAddr = ^TJclAddr;
  EJclAddr64Exception = class(EJclError);
function Addr64ToAddr32(const Value: TJclAddr64): TJclAddr32;
function Addr32ToAddr64(const Value: TJclAddr32): TJclAddr64;
{$IFDEF FPC}
type
  HWND = type Windows.HWND;
{$ENDIF FPC}
 {$IFDEF SUPPORTS_GENERICS}
//DOM-IGNORE-BEGIN
type
  TCompare<T> = function(const Obj1, Obj2: T): Integer;
  TEqualityCompare<T> = function(const Obj1, Obj2: T): Boolean;
  THashConvert<T> = function(const AItem: T): Integer;
  IEqualityComparer<T> = interface
    function Equals(A, B: T): Boolean;
    function GetHashCode(Obj: T): Integer;
  end;
  TEquatable<T: class> = class(TInterfacedObject, IEquatable<T>, IEqualityComparer<T>)
  public
    { IEquatable<T> }
    function TestEquals(Other: T): Boolean; overload;
    function IEquatable<T>.Equals = TestEquals;
    { IEqualityComparer<T> }
    function TestEquals(A, B: T): Boolean; overload;
    function IEqualityComparer<T>.Equals = TestEquals;
    function GetHashCode2(Obj: T): Integer;
    function IEqualityComparer<T>.GetHashCode = GetHashCode2;
  end;
//DOM-IGNORE-END
{$ENDIF SUPPORTS_GENERICS}
const
  {$IFDEF SUPPORTS_UNICODE}
  AWSuffix = 'W';
  {$ELSE ~SUPPORTS_UNICODE}
  AWSuffix = 'A';
  {$ENDIF ~SUPPORTS_UNICODE}
{$IFDEF FPC}
// FPC emits a lot of warning because the first parameter of its internal
// GetMem is a var parameter, which is not initialized before the call to GetMem
procedure GetMem(out P; Size: Longint);
{$ENDIF FPC}

implementation

uses
  uRESTDWMemResources;

{$IFDEF MSWINDOWS}
function IsDirectory(const FileName: string): Boolean;
var
  R: DWORD;
begin
  R := GetFileAttributes(PChar(FileName));
  Result := (R <> DWORD(-1)) and ((R and FILE_ATTRIBUTE_DIRECTORY) <> 0);
end;
{$ENDIF MSWINDOWS}
{$IFDEF UNIX}
function IsDirectory(const FileName: string; ResolveSymLinks: Boolean): Boolean;
var
  Buf: TStatBuf64;
begin
  Result := False;
  if GetFileStatus(FileName, Buf, ResolveSymLinks) = 0 then
    Result := S_ISDIR(Buf.st_mode);
end;
{$ENDIF UNIX}

procedure MoveChar(const Source: string; FromIndex: SizeInt;
  var Dest: string; ToIndex, Count: SizeInt);
begin
  Move(Source[FromIndex + 1], Dest[ToIndex + 1], Count * SizeOf(Char));
end;
function AnsiByteArrayStringLen(Data: TBytes): SizeInt;
var
  I: SizeInt;
begin
  Result := Length(Data);
  for I := 0 to Result - 1 do
    if Data[I] = 0 then
    begin
      Result := I + 1;
      Break;
    end;
end;
function StringToAnsiByteArray(const S: string): TBytes;
var
  I: SizeInt;
  AnsiS: DWString;
begin
  AnsiS := DWString(S); // convert to DWString
  SetLength(Result, Length(AnsiS));
  for I := 0 to High(Result) do
    Result[I] := Byte(AnsiS[I + 1]);
end;
function AnsiByteArrayToString(const Data: TBytes; Count: SizeInt): string;
var
  I: SizeInt;
  AnsiS: DWString;
begin
  if Length(Data) < Count then
    Count := Length(Data);
  SetLength(AnsiS, Count);
  for I := 0 to Length(AnsiS) - 1 do
    PDWChar(@AnsiS[I + 1])^ := DWChar(Data[I]);
  Result := string(AnsiS); // convert to System.String
end;
function BytesOf(const Value: DWString): TBytes;
begin
  SetLength(Result, Length(Value));
  if Value <> '' then
    Move(Pointer(Value)^, Result[0], Length(Value));
end;
function StringOf(const Bytes: array of Byte): DWString;
begin
  if Length(Bytes) > 0 then
  begin
    SetLength(Result, Length(Bytes));
    Move(Bytes[0], Pointer(Result)^, Length(Bytes));
  end
  else
    Result := '';
end;
// Cross Platform Compatibility
{$IFNDEF HAS_FMX}
procedure RaiseLastOSError;
begin
{$IFDEF MSWINDOWS}
  RaiseLastWin32Error;
{$ENDIF}
end;
{$ENDIF ~HAS_FMX}
{$IFNDEF RTL230_UP}
procedure CheckOSError(ErrorCode: Cardinal);
begin
  if ErrorCode <> ERROR_SUCCESS then
    {$IFDEF RTL170_UP}
    RaiseLastOSError(ErrorCode);
    {$ELSE ~RTL170_UP}
    RaiseLastOSError;
    {$ENDIF ~RTL170_UP}
end;
{$ENDIF RTL230_UP}
{$OVERFLOWCHECKS OFF}
function Addr64ToAddr32(const Value: TJclAddr64): TJclAddr32;
begin
  if (Value shr 32) = 0 then
    Result := Value
  else
    raise EJclAddr64Exception.CreateResFmt(@RsCantConvertAddr64, [HexPrefix, Value]);
end;
function Addr32ToAddr64(const Value: TJclAddr32): TJclAddr64;
begin
  Result := Value;
end;
{$IFDEF OVERFLOWCHECKS_ON}
{$OVERFLOWCHECKS ON}
{$ENDIF OVERFLOWCHECKS_ON}
{$IFDEF SUPPORTS_GENERICS}
//DOM-IGNORE-BEGIN
//=== { TEquatable<T> } ======================================================
function TEquatable<T>.TestEquals(Other: T): Boolean;
begin
  if Other = nil then
    Result := False
  else
    Result := GetHashCode = Other.GetHashCode;
end;
function TEquatable<T>.TestEquals(A, B: T): Boolean;
begin
  if A = nil then
    Result := B = nil
  else
  if B = nil then
    Result := False
  else
    Result := A.GetHashCode = B.GetHashCode;
end;
function TEquatable<T>.GetHashCode2(Obj: T): Integer;
begin
  if Obj = nil then
    Result := 0
  else
    Result := Obj.GetHashCode;
end;
//DOM-IGNORE-END
{$ENDIF SUPPORTS_GENERICS}
procedure LoadAnsiReplacementCharacter;
{$IFDEF MSWINDOWS}
var
  CpInfo: TCpInfo;
begin
  CpInfo.MaxCharSize := 0;
  if GetCPInfo(CP_ACP, CpInfo) then
    AnsiReplacementCharacter := DWChar(Chr(CpInfo.DefaultChar[0]))
  else
    raise EJclInternalError.CreateRes(@RsEReplacementChar);
end;
{$ELSE ~MSWINDOWS}
begin
  AnsiReplacementCharacter := '?';
end;
{$ENDIF ~MSWINDOWS}
{$IFDEF FPC}
// FPC emits a lot of warning because the first parameter of its internal
// GetMem is a var parameter, which is not initialized before the call to GetMem
procedure GetMem(out P; Size: Longint);
begin
  Pointer(P) := nil;
  GetMem(Pointer(P), Size);
end;
{$ENDIF FPC}
initialization
  LoadAnsiReplacementCharacter;
  {$IFDEF UNITVERSIONING}
  RegisterUnitVersion(HInstance, UnitVersioning);
  {$ENDIF UNITVERSIONING}
finalization
  {$IFDEF UNITVERSIONING}
  UnregisterUnitVersion(HInstance);
  {$ENDIF UNITVERSIONING}
end.
