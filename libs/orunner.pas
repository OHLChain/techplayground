unit ORunner;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, onetcode, toconfiguration, crt, IniFiles
  ;

Type TOInstance = class
   var
      InstanceID: String;
      dataDir: String;
      config: TConfiguration;
      Terminating: Boolean;
      ch: char;

      blockEngine: TONetCode;

   procedure run;
   procedure loop;
   procedure readConfiguration;

end;

implementation

procedure TOInstance.run;
begin

   self.Terminating:= False;
   self.readConfiguration;

   writeln('Node '''+self.config.NodeId +''' initiated.');

   blockEngine := TONetCode.Create;
   blockengine.runAsServer(self.config);

   self.loop;
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

  repeat

    sleep(self.config.nodeSleepTime);

    if KeyPressed then begin
       ch := readKey();
       if (ch = 'q') then self.Terminating:=True;
    end;

  until self.Terminating = True;
end;

end.

