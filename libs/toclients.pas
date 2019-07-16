unit TOClients;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, TOConfiguration, nxnetwork;

type TOClient = class
    lastTimeConnected: TDateTime;
    connected: boolean;
    data: TSwampNode;
    tcpClient: Tclient;
end;

Type TOClientEngine = class

   clients: array of TOClient;
   var s: integer;

   function connectedTo(address: String) : Boolean;
   procedure connectToNodes();
end;


implementation

procedure TOClientEngine.connectToNodes;
var i: integer;
begin
  writeln('Nr clienti: ' + inttostr(length(self.clients)));
   for i:=0 to length(self.clients)-1 do begin
     if not self.clients[i].tcpClient.Connected then begin
       //try to connect
       self.clients[i].tcpClient.Connect
        end else
           //self.clients[i].tcpClient.SendString(timetostr(now));
       end;
end;

function TOClientEngine.connectedTo(address: String): Boolean;
var client: TOClient;
begin
  Result := False;

  for client in self.clients do begin
    if (client.data.address = address) then begin
      Result := client.connected;
    end;
  end;


end;

end.

