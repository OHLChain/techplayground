unit TOConfiguration;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, constants, inifiles;

Type TswampNode = record
   address: String;
   port: Integer;
   benchSpeed: Int64;
end;

Type TConfiguration = class
  var
     nodeSleepTime: Integer;
     NodeId: String;
     swamp: array of TswampNode;

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
begin
   self.nodeSleepTime := 10;

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

end;

Class Constructor  TConfiguration.Create;
begin

end;

Class Destructor TConfiguration.Destroy;
begin

end;

end.

