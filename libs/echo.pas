unit echo;

{$IFDEF FPC}
  {$mode delphi}
{$endif}

interface

uses
  Classes, blcksock, synsock, crt, sysutils, TConnectionManager;

Type Poc = class
     a: integer;
     procedure something(s:string);
end;


  type
  TTCPEchoThrd = class(TThread)
  private
    Sock:TTCPBlockSocket;
    CSock: TSocket;
    remoteIp: String;
    remotePort: Integer;
    TP: ^Poc;
    id: Integer;
  public
    Constructor Create (hsock:tSocket; id: integer);
    procedure Execute; override;
  end;


type
  TTCPEchoDaemon = class(TThread)
  private
    Sock:TTCPBlockSocket;
  public
    T: array of TTCPEchoThrd;
    isServer: Boolean;

    bindAddress: String;
    bindPort: Integer;

    remoteAddress: String;
    remotePort: Integer;

    Constructor Create;
    Destructor Destroy; override;
    procedure Execute; override;

  end;

  var P: Poc;

implementation

{ TEchoDaemon }

procedure POC.something(s:string);
begin
    writeln('INSIDE POC: ' + s);

end;

Constructor TTCPEchoDaemon.Create;
begin
  inherited create(false);
  sock:=TTCPBlockSocket.create;
  self.isServer:= True;
  FreeOnTerminate:=true;
end;

Destructor TTCPEchoDaemon.Destroy;
begin
  writeln('disconnecting');
  Sock.free;
end;

procedure TTCPEchoDaemon.Execute;
var
  ClientSock:TSocket;
  cnt: Integer;
begin

  with sock do
    begin
      CreateSocket;
      setLinger(true,10000);
      bind(self.bindAddress,inttostr(self.bindPort));
      listen;
      repeat
        if terminated then break;
        if canread(1000) then
          begin
            ClientSock:=accept;
            if lastError=0 then begin
              cnt := Length(self.T);
              SetLength(self.T, cnt +1);
              self.T[cnt] :=  TTCPEchoThrd.create(ClientSock, cnt);
            end;
          end;
      until false;
    end;
end;

{ TEchoThrd }

Constructor TTCPEchoThrd.Create(Hsock:TSocket; id: integer);
begin
  inherited create(false);
  Csock := Hsock;
  self.id := id;
  FreeOnTerminate:=true;

  writeln('New Connection.');
end;

procedure TTCPEchoThrd.Execute;
var
  s: string;
  rem: string;
begin
  sock:=TTCPBlockSocket.create;
  self.TP := @P;
  try
    Sock.socket:=CSock;
    sock.GetSins;
    self.remoteIp:=sock.GetRemoteSinIP;
    self.remotePort:=sock.GetRemoteSinPort;

    writeln('1');

    writeln('2');
    if ConnectionManager.newConnection=true then
      with sock do
        begin
          repeat
            if terminated then break;
            s := RecvPacket(10000);  //after how many seconds (without a NOP) will this Socket get destroyed?
            if lastError<>0 then break;
            SendString('fomr me ' + s);
            rem := GetRemoteSinIP + ':' + inttostr(GetRemoteSinPort);
            writeln('ID: '+inttostr(self.id) + ': '+rem+' > '+ inttostr(length(s))+ ' [ '+s+' ] '#13#10#13#10);
            TP.something(s);
            if s = 'quit'#13#10 then break;
            if lastError<>0 then break;
          until false;
        end;

    Sock.Destroy;

  finally
    ConnectionManager.disconnectConnection;
    Sock.Free;
  end;
end;

begin
  p:= POC.Create;
end.
