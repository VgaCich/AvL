unit avlSmtp;

interface

uses
  Windows, Messages, WinSock, Avl;

type
  TSmtp = class(TObject)
  private
    FSock: TSocket;
    FAddr: TSockAddr;
    FSubject: string;
    FFrom: string;
    FTo: String;
    FBody: String;
    FPort: Integer;
    FHost: String;
    FFromName: string;
    FOnDisconnect: TOnEvent;
    FOnConnect: TOnEvent;
    FOnSuccess: TOnEvent;
    FLocalProgram: string;
    FReplyTo: string;
    FDate: string;
    procedure SendText(Text: string);
    procedure ReceiveResponse(SuccessCode: integer);
  protected
    procedure HELO;
    procedure MAIL(from: string);
    procedure RCPT(to_: string);
    procedure DATA(body: string);
    procedure QUIT;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    procedure SendMail;

    property FromAddress: String read FFrom write FFrom;
    property FromName: string read FFromName write FFromName;
    property ToAddress: String read FTo write FTo;
//    property ToCarbonCopy: Tstringlist read FCc write SetLinesCc;
//    property ToBlindCarbonCopy: Tstringlist read FBcc write SetLinesBcc;
    property Body: String read FBody write FBody;
//    property Attachments: TstringList read FAttachments write SetLinesAttachments;
    property Subject: String read FSubject write FSubject;
    property LocalProgram: string read FLocalProgram write FLocalProgram;
    property Date: string read FDate write FDate;
    property ReplyTo: string read FReplyTo write FReplyTo;
    property Host: String read FHost write FHost;
    property Port: Integer read FPort write FPort;

    property OnConnect: TOnEvent read FOnConnect write FOnConnect;
    property OnDisconnect: TOnEvent read FOnDisconnect write FOnDisconnect;
    property OnSuccess: TOnEvent read FOnSuccess write FOnSuccess;
  end;

 E_SMTPSession = class (Exception);

implementation

{ TSMTP }

constructor TSMTP.Create;
var
  WSData: TWSAData;
begin
  WSAStartup(MakeWord(1,1), WSData);
  FPort := IPPORT_SMTP ;

  FLocalProgram := 'AvlSmtpClient';
end;

destructor TSMTP.Destroy;
begin
  WSACleanup;
end;

procedure TSMTP.SendText(Text: string);
begin
  OutputDebugString(PChar('>>'+Text));
  Text:=Text+#13#10;
  if send(FSock, pointer(Text)^, Length(Text), 0)<Length(Text) then
    raise E_SMTPSession.Create('Error while sending');
end;

procedure TSMTP.ReceiveResponse(SuccessCode: integer);
var
  ch: char;
  response, line: string;
begin
  response:='';
  repeat
   line:='';
   repeat
     recv(FSock, ch, 1, 0);
     line:=line+ch;
   until ch=#10;
   response:=response+line;
  until line[4]=' '; //Обрабатываем многострочный ответ
  OutputDebugString(PChar('<<'+response));
  if strtoint(copy(line, 1, 3))<>SuccessCode then
    raise E_SMTPSession.Create('Response: '+#13#10+response);
end;

procedure TSMTP.connect;
var
  HostEnt: PHOSTENT;
begin
  FAddr.sin_family:=AF_INET;
  FAddr.sin_port:=htons(FPort);
  HostEnt:=gethostbyname(PChar(FHost));
  if HostEnt=nil then raise E_SMTPSession.Create('Can''t Resolve '+FHost);
  FAddr.sin_addr:=PInAddr(HostEnt.h_addr^)^;
  //FAddr.sin_addr.S_addr:=inet_addr(PChar(Server)); если ip-address, а не hostname
  FSock:=socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if FSock<>INVALID_SOCKET then
   if winsock.connect(FSock, FAddr, SizeOf(FAddr))<>SOCKET_ERROR then
     ReceiveResponse(220)
   else
    begin
      raise E_SMTPSession.Create('Can''t connect: '+syserrormessage(WSAGetLastError))
    end
  else
   raise E_SMTPSession.Create('Can''t create socket');
     if Assigned(FOnConnect) then FOnConnect(Self);
end;

procedure TSMTP.Disconnect;
begin
  CloseSocket(FSock);
  if Assigned(FOnDisconnect) then FOnDisconnect(Self);
end;

procedure TSMTP.HELO;
//var
//  HostName: array[0..255] of char;
begin
//  GetHostName(HostName, Length(HostName));
//  SendText('HELO '+string(HostName));
  SendText('HELO ' +  FHost);
  ReceiveResponse(250);
end;

procedure TSMTP.MAIL(from: string);
begin
  SendText('MAIL FROM: <'+from+'>');
  ReceiveResponse(250);
end;

procedure TSMTP.RCPT(to_: string);
begin
  SendText('RCPT TO: <'+to_+'>');
  ReceiveResponse(250);
end;

procedure TSMTP.DATA(Body: String);
begin
  SendText('DATA');
  ReceiveResponse(354);
  SendText('Subject: ' + FSubject);
  if FFromName <> '' then SendText('From: ' + FFromName);
  SendText('To: ' + ToAddress);
  if FLocalProgram <> '' then SendText('X-Mailer: ' + FLocalProgram);
  if FReplyTo <> '' then SendText('Reply-To: ' + FReplyTo);
  if FDate <> '' then SendText('Date: ' + FDate);
  SendText('');
  SendText(Body);
  SendText(#13#10'.');
  ReceiveResponse(250);
  if Assigned(FOnSuccess) then FOnSuccess(Self);
end;

procedure TSMTP.QUIT;
begin
  SendText('QUIT');
  ReceiveResponse(221);
end;

procedure TSMTP.SendMail;
begin
  try
    HELO;
    MAIL(FFrom);
    RCPT(FTo);
    DATA(FBody);
  finally
    QUIT;
  end;
end;

end.
