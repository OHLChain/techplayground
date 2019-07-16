unit tech;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, nxNetwork, UNetProtocol, UTCPIP;

var
   server: TServer;

   ss: TNetTcpIpServer;

 Type TNetTech = class
      procedure ServerData(sender: TConnection; data: PByte; size,ID: integer);
      //procedure ServerEvent(sender: TConnection; event: TConnectionEvent; ID: integer);
      //procedure ServerWriteToClientString(sender: TConnection; ID: integer; message: String);

      procedure serverOnAfterConnect(Sender: Tobject);
 end;

 var  netTech : TNetTech;

procedure techTest();

implementation

procedure techTest();

begin

  ss:=TNetTcpIpServer.create;
  ss.Port:=18888;


  netTech:= TNetTech.Create;

  server := TTCPServer.CreateTCPServer('16384');
  server.Host:='127.0.0.1';



  server.onData:= @netTech.ServerData;

  server.MaxConnections:=100;

  server.Connect;

  if (not server.Connected) then begin
      writeln('waiting to connect...');
      repeat
        sleep(100);
        server.Connect;
      until server.Connected;
      writeln('Connected!');
  end;
end;

procedure TNetTech.ServerData(sender: TConnection; data: PByte; size,ID: integer);
begin
   writeln(inttostr(length(sender.clients) ) );
end;

procedure TNetTech.serverOnAfterConnect(Sender: Tobject);
begin
    writeln('something...');
end;

end.

