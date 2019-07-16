unit ORunner;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, toconfiguration, crt,  TOClients, nxnetwork
  ;

Type TOInstance = class
   var
      InstanceID: String;
      dataDir: String;
      config: TConfiguration;
      Terminating: Boolean;
      ch: char;

      //blockEngine: TONetCode;
      clientsEngine: TOClientEngine;

      server: TServer;

   procedure ServerData(sender: TConnection; data: PByte; size,ID: integer);
   procedure ServerEvent(sender: TConnection; event: TConnectionEvent; ID: integer);
   procedure ServerWriteToClientString(sender: TConnection; ID: integer; message: String);
   procedure ClientData(sender: TConnection; data: PByte; size,ID: integer);
   procedure ClientEvent(sender: TConnection; event: TConnectionEvent; ID: integer);

   procedure run;
   procedure loop;
   procedure readConfiguration;
   procedure connectToSwampNodes(var c: TOClientEngine);
   procedure broadcastKnownNodes(s: String);

end;

implementation


procedure TOInstance.run;
var b: Boolean;
begin

   self.Terminating:= False;
   self.readConfiguration;

   writeln('Node '''+self.config.NodeId +''' initiated.');

   server:=TTCPServer.CreateTCPServer(inttostr(self.config.bindPort));
   server.Host:=self.config.bindAddress;
   server.onData:= @self.ServerData;

   server.onEvent:= @self.ServerEvent;

   b := server.Connect;

   if (b) then
     writeln('Server started ok.')
     else
       writeln('Server started with an error.');

   self.clientsEngine := TOClientEngine.Create;
   self.clientsEngine.s:=16383;;



   self.loop;

   self.clientsEngine.Free;
end;
procedure TOInstance.broadcastKnownNodes(s: String);
var i: integer;
 tmpClient: TOclient;
begin
   writeln('broadcasting...');
   //loop through clients and broadcast the known nodes
   for i:=0 to length(self.server.clients)-1 do begin

     writeln('bcd '+inttostr(i));
     self.server.clients[i].tcpSock.sendblock(s+#13#10);
   end;

   for tmpClient in self.clientsEngine.clients do begin
     if ((tmpClient<>nil) AND (tmpClient.tcpClient <> nil)) then
       if tmpClient.tcpClient.Connected then begin
         writeln(' YES ');
         tmpClient.tcpClient.SendString(' ** ' + s + ' ** '+#13#10);
       end else begin
         writeln(' NO ');
       end;
   end;


   //for i:=0 to length(self.clientsEngine.clients)-1 do begin
   //
   //  self.clientsEngine.clients[i].tcpClient.SendString(s+'++'+#13#10);
   //
   //    if self.clientsEngine.clients[i].tcpClient.Connected = True then begin
   //    writeln('conn client yes .');
   //       self.clientsEngine.clients[i].tcpClient.SendString(s+'**'+#13#10);
   //    end else begin
   //      writeln('no conn client');
   //    end;
   //end;
   //
   //

end;

procedure TOInstance.connectToSwampNodes(var c: TOClientEngine);
var swampNode: TSwampNode;
 cnt: Integer;
begin
   //writeln('QQQ: ' + inttostr(c.s));
    //writeln('Starting to connect to swamp nodes...');
    for swampNode in self.config.starSwampNodes do begin
        //writeln('SN host = ' + swampNode.address +':' + inttostr(swampNode.port));

         // try and see if we're already connected to this node
         if (not c.connectedTo(swampNode.address) ) then begin
         writeln('adding a new client...');
             cnt := length(c.clients);
             SetLength(c.clients,cnt +1);


             c.clients[cnt] := TOClient.create;
             c.clients[cnt].tcpClient := TClient.CreateTCPClient(swampNode.address, inttostr(swampnode.port));  // not yet connected
             c.clients[cnt].tcpClient.onData:= @self.ClientData;
             c.clients[cnt].tcpclient.onEvent:= @self.ClientEvent;

        end;
    end;

    //writeln('Initial swamp connection requests finished.');
end;

procedure TOInstance.readConfiguration;
begin

  // set the data directory
  if (self.InstanceID = 'default') then begin
     self.dataDir := 'Data';
   end else begin
     self.dataDir := self.InstanceID;
   end;

   self.dataDir:= 'Blockchain/'+self.dataDir;
   self.config := TConfiguration.Create;
   self.config.initDataDirectory(self.dataDir);

end;

procedure TOInstance.loop;
begin
  write('Press q to quit.' + chr(13)+chr(10));

  self.connectToSwampNodes(self.clientsEngine);

  self.clientsEngine.connectToNodes();

  repeat



    sleep(self.config.nodeSleepTime);

    if self.server.Connected = false then server.Connect;



    if KeyPressed then begin
       ch := readKey();
       if (ch = 'q') then self.Terminating:=True;

       write(ch);
       //if (ch = 't') then begin
            self.broadcastKnownNodes(ch+#13#10);
       //end;



    end;

    //self.broadcastKnownNodes();

  until self.Terminating = True;
end;



procedure TOInstance.ServerData(sender: TConnection; data: PByte; size,ID: integer);
var s: string;
begin
writeln('in server data');

 setlength(s,size);
 move(data[0],s[1],size);
 writeln(format('Client(%d)> [%s]'+ chr(13),[ID,s]));
 //writeln('clienti: ' + inttostr(length(sender.clients)));
 ServerWriteToClientString(sender, ID, 'wtffdsjkflsd');


 (sender as TConnection).clients[ID].tcpSock.SendString('raspuns de la server');
end;

procedure TOInstance.ServerWriteToClientString(sender: TConnection; ID: integer; message: String);
var
 NetClient: TServerSubThread;
begin
writeln('caut client...' + inttostr(ID));
    for NetClient in sender.clients do begin
      if (NetClient.ID = ID) then begin
        writeln('NSSS Gasit client #' + inttostr(ID));
        NetClient.tcpSock.SendBlock(message);
      end;
    end;

end;

procedure TOInstance.ServerEvent(sender: TConnection; event: TConnectionEvent; ID: integer);
begin
  writeln(inttostr(id));
  if event=ceError then begin
    writeln(format('Server error: <#%d Error(%d): %s>',
      [ID,sender.LastError,sender.LastErrorMsg]));
  end
  else
    writeln(format('Server: <#%d: %s>',
      [ID,sender.EventToStr(event)]));

end;

procedure TOInstance.ClientEvent(sender: TConnection; event: TConnectionEvent; ID: integer);
begin
  if sender=nil then exit;
  if event=ceError then
    //writeln(format('Client error: <Error(%d): %s>',[sender.LastError,sender.LastErrorMsg]))
  else  begin
    writeln(format('Client: <%s>',[sender.EventToStr(event)]));
    writeln('New client ip: ' + sender.Host +':'+sender.Port);
  if event = ceDisconnected then begin
     writeln('client was disconnected.');

  end;

  end;

end;

procedure TOInstance.ClientData(sender: TConnection; data: PByte; size,ID: integer);
var s: string;
begin
  setlength(s,size);
  move(data[0],s[1],size);
  writeln(format('From server> [%s]',[s]));
end;

end.

