unit ONetCode;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, blcksock, nxNetwork;


procedure testNet();

//procedure ServerEvent(sender: TConnection; event: TConnectionEvent; ID: integer);
//procedure ClientEvent(sender: TConnection; event: TConnectionEvent; ID: integer);
//procedure ServerData(sender: TConnection; data: PByte; size,ID: integer);
//procedure ClientData(sender: TConnection; data: PByte; size,ID: integer);

Type OServer = class
   procedure ServerData(sender: TConnection; data: PByte; size,ID: integer);
   procedure ServerEvent(sender: TConnection; event: TConnectionEvent; ID: integer);
   procedure ServerWriteToClientString(sender: TConnection; ID: integer; message: String);
end;

  Type OClient = class
       procedure ClientData(sender: TConnection; data: PByte; size,ID: integer);
       procedure ClientEvent(sender: TConnection; event: TConnectionEvent; ID: integer);
  end;

var
client: TClient;
server: TServer;

ServerConnections: OServer;
ClientConnections: OClient;


implementation

 procedure OServer.ServerWriteToClientString(sender: TConnection; ID: integer; message: String);
 var
  Client: TServerSubThread;
 begin
 writeln('caut client...' + inttostr(ID));
     for Client in sender.clients do begin
       if (Client.ID = ID) then begin
         writeln('Gasit client #' + inttostr(ID));
         Client.tcpSock.SendBlock('OOOQPQPQ dsfdsf');
       end;
     end;

 end;

 procedure Oserver.ServerData(sender: TConnection; data: PByte; size,ID: integer);
var s: string;
begin
writeln('in server data');
  if server=nil then exit;
  setlength(s,size);
  move(data[0],s[1],size);
  writeln(format('xxa Client(%d)> [%s]',[ID,s]));
  writeln('clienti: ' + inttostr(length(sender.clients)));
  ServerWriteToClientString(sender, ID, 'wtffdsjkflsd');


  //(sender as TConnection).clients[ID].tcpSock.SendString('raspuns de la server');
end;

procedure OClient.ClientData(sender: TConnection; data: PByte; size,ID: integer);
var s: string;
begin
  if client=nil then exit;
  setlength(s,size);
  move(data[0],s[1],size);
  writeln(format('Server> [%s]',[s]));
end;

procedure OServer.ServerEvent(sender: TConnection; event: TConnectionEvent; ID: integer);
begin
  if server=nil then exit;
  writeln(inttostr(id));
  if event=ceError then
    writeln(format('ssee <#%d Error(%d): %s>',
      [ID,server.LastError,server.LastErrorMsg]))
  else
    writeln(format('dfd <#%d: %s>',
      [ID,server.EventToStr(event)]));


  //Timer1Timer(nil);
end;

procedure OClient.ClientEvent(sender: TConnection; event: TConnectionEvent; ID: integer);
begin
  if client=nil then exit;
  if event=ceError then
    writeln(format('cee <Error(%d): %s>',[client.LastError,client.LastErrorMsg]))
  else
    writeln(format('zzz <%s>',[client.EventToStr(event)]));

  if event = ceConnected then
    client.SendString('sdsdsd0000');
 // Timer1Timer(nil);
end;

 procedure testNet();



 begin


   try
 server:=TTCPServer.CreateTCPServer('16384');
 client:=TClient.CreateTCPClient('127.0.0.1','16384');

 ServerConnections := OServer.Create;
 ClientConnections := OClient.Create;

 server.onEvent:=@ServerConnections.ServerEvent;
 server.onData:=@ServerConnections.ServerData;

 client.onEvent:=@ClientConnections.ClientEvent;
 client.onData:=@ClientConnections.ClientData;

 server.Connect;
 client.Connect;

 sleep(1000);

 client.SendString('uuu');
 sleep(3000);

 client.Disconnect;
 server.Disconnect;

 finally

 writeln('preparing for client free');

  while client.Connected do begin
    writeln ('waiting for d/c');
    sleep(100);
  end;

 client.Free;

  writeln('preparing for server free');
 server.Free;

 client := nil; server := nil;

 end;
 end;



end.

