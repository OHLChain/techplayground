unit TConnectionManager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type TOconnectionManager = class

     const maxConnections = 1;

     private
      connections: Integer;

     public
      function newConnection: boolean;
      procedure disconnectConnection;

end;

  var ConnectionManager: TOconnectionManager;

implementation

procedure TOconnectionManager.disconnectConnection;
begin
   self.connections:=self.connections - 1;
   writeln('Connection disconnected. New connections count: '+inttostr(self.connections) +'. ');
end;

function TOconnectionManager.newConnection: boolean;
begin
   Result := True;
   self.connections:=self.connections+1;
   writeln('Connection count: ' + inttostr(self.connections));
   if (self.connections > self.maxConnections) then begin
      Result := False;
      writeln('Max connections reached! Not accepting new ones.');
   end;
end;

begin
     ConnectionManager := TOconnectionManager.Create;
end.

