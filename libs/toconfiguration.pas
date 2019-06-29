unit TOConfiguration;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, constants, inifiles, strutils;

Type TSwampNode = record
   address: String;
   port: Integer;
   connectionId: Integer;
end;

Type TConfiguration = class
  var
     nodeSleepTime: Integer;
     NodeId: String;
     starSwampNodes: array of TswampNode;

  //node config
  bindAddress: String;
  bindPort: Integer;

  Class Constructor create;
  Class Destructor destroy;

  procedure initDataDirectory(dataDir: String);

end;

implementation

procedure TConfiguration.initDataDirectory(dataDir: String);
var ini: TINIFile;
  swampCount, swampPort, i, tmpI : Integer;
  tempNode,swampHost: String;
begin
   self.nodeSleepTime := 1000;

   if not DirectoryExists(dataDir) then
     begin
       writeln ('Creating data directory...');
       if not ForceDirectories(dataDir) then begin
         writeln('Can''t create the Data directory: ' + dataDir +'.');
         exit;
       end;
     end;

   ini := TINIFile.Create(dataDir + '/' + iniFile);

   self.NodeId:= ini.ReadString(INI_General,'NodeID','ONODE_'+timetostr(now));
   self.bindAddress:= ini.ReadString(INI_Network,'BindAddress',BIND_Default_Address);
   self.bindPort:= ini.ReadInteger(INI_Network,'BindPort',BIND_Default_Port);

   writeln('I am '+ self.NodeId);

   swampCount := ini.ReadInteger(INI_SWAMP,'NodeCount',0);
   SetLength(self.starSwampNodes,swampCount);

   for i:=1 to swampCount do begin
       tempNode := ini.ReadString(INI_SWAMP,'NODE_'+inttostr(i),'0.0.0.0:0');
       writeln('Reading starting swamp node '+inttostr(i)+': ' + tempNode);
       tmpI := pos(':',tempNode);

       swampHost := LeftStr(tempNode, tmpI-1);
       swampPort:= strtoint(RightStr(tempNode, Length(tempNode) - tmpI));

       writeln('New swamp node: ' + swampHost + ':'+inttostr(swampPort) );

       self.starSwampNodes[i-1].address:=swampHost;
       self.starSwampNodes[i-1].port:=swampPort;
   end;


   writeln('CNT SWAMP: ' + inttostr(Length(self.starSwampNodes) ));
end;

Class Constructor  TConfiguration.Create;
begin

end;

Class Destructor TConfiguration.Destroy;
begin

end;

begin

end.

