unit ONetCode;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, blcksock, nxnetwork, crt;


procedure testNetClient(port: String);
procedure testNetServer(port: String);

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
         //writeln('Gasit client #' + inttostr(ID));
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
  writeln(format('Client(%d)> [%s]',[ID,s]));
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
var ch: char;
begin
  try
    server:=TTCPServer.CreateTCPServer(port);
    ServerConnections := OServer.Create;

     server.onEvent:=@ServerConnections.ServerEvent;
     server.onData:=@ServerConnections.ServerData;

      server.Connect;

      writeln('Running the server. Press `q` to quit.');
      repeat
            sleep(100);
            ch := readKey();
      until (ch = 'q');

      server.Disconnect;

      server.Free;
      server := nil;

  finally
  end;
end;

 procedure testNetClient(port: String);
           var ch: char;
 begin
   try

 client:=TClient.CreateTCPClient('127.0.0.1',port);

 ClientConnections := OClient.Create;
 client.onEvent:=@ClientConnections.ClientEvent;
 client.onData:=@ClientConnections.ClientData;
 client.Connect;


 client.SendString('uuu');

 writeln('Running the client. Press `q` to quit.');
      repeat
            sleep(1000);
            if KeyPressed then begin
               ch := readKey();
                if (ch <> 'q') then begin
                  client.SendString(ch);
                end;
              end;


            client.SendString(TimeToStr(Now));
      until (ch = 'q');

 client.Disconnect;


 finally

 writeln('preparing for client free');

  while client.Connected do begin
    writeln ('waiting for d/c');
    sleep(100);
  end;

 client.Free;

 writeln('preparing for server free');

 client := nil;

 end;
 end;



end.

