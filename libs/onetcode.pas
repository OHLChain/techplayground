unit ONetCode;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, nxnetwork, crt, TOConfiguration;


procedure testNetClient(port: String);
procedure testNetServer(port: String);


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


Type TONetCode = class
  var
    client: TClient;
    server: TServer;

    ServerConnections: OServer;
    ClientConnections: OClient;

  procedure runAsServer(config: TConfiguration);
  procedure disconnect;
end;


implementation

procedure TONetCode.disconnect;
begin
 if (Assigned(self.server)) then
    FreeAndNil(self.server);


end;

procedure TONetCode.runAsServer(config: TConfiguration);
begin

    self.server:=TTCPServer.CreateTCPServer(inttostr(config.bindPort));
    self.server.Host:=config.bindAddress;
    self.ServerConnections := OServer.Create;

    self.server.onEvent:=@self.ServerConnections.ServerEvent;
    self.server.onData:=@self.ServerConnections.ServerData;

    self.server.Connect;

    writeln('Waiting connections on ' + self.server.Host + ':' + inttostr(config.bindPort));

end;



 procedure OServer.ServerWriteToClientString(sender: TConnection; ID: integer; message: String);
 var
  Client: TServerSubThread;
 begin
 writeln('caut client...' + inttostr(ID));
     for Client in sender.clients do begin
       if (Client.ID = ID) then begin
         writeln('Gasit client #' + inttostr(ID));
         Client.tcpSock.SendBlock(message);
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
  writeln(format('Client(%d)> [%s]'+ chr(13),[ID,s]));
  //writeln('clienti: ' + inttostr(length(sender.clients)));
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

procedure testNetServer(port: String);
begin
  exit;
  try
    server:=TTCPServer.CreateTCPServer(port);
    ServerConnections := OServer.Create;

     server.onEvent:=@ServerConnections.ServerEvent;
     server.onData:=@ServerConnections.ServerData;

     server.Connect;

  finally
  end;
end;

 procedure testNetClient(port: String);
 begin

 client:=TClient.CreateTCPClient('127.0.0.1',port);

 ClientConnections := OClient.Create;
 client.onEvent:=@ClientConnections.ClientEvent;
 client.onData:=@ClientConnections.ClientData;
 client.Connect;


 end;


end.

