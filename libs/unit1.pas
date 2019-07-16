unit Unit1;


{$mode objfpc}

interface
uses
  {$IFDEF UNIX}
 cthreads,
 {$ENDIF}
  Classes, Sysutils,  syncobjs, blcksock,synsock, crt;

type

 TThreadManager = class;

 { TManagedThread }

 TManagedThread = class(TThread)
 public
   constructor Create(waiting : Boolean);
   function    isDone()     : Boolean;
   function    isErroneus() : Boolean;

 protected
   done_,
   erroneous_ : Boolean;
end;

  { TTCPThread }

TTCPThread = class(TManagedThread)
    private
     fSock: TTCPBlockSocket;
     fIP: string;
     FPort: integer;
     FNumber: integer;
     lastCommunication: int64;
     procedure SetSocket(aSock: TSocket);
    protected
     procedure Execute; override;
    public
     constructor Create();
     destructor Destroy; override;
     procedure ProcessingData(procSock: TSocket;Data: string);
     Property Number: integer read Fnumber Write FNumber;
end;

 { TListenerThread }

 TListenerThread = class(TThread)
  private
    ListenerSocket: TTCPBlockSocket;
    FThreadManager: TThreadManager;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
end;

 { TThreadManager }

 TThreadManager = class(TObject)
	private
		FItemList: TThreadList;
		FAbort: Boolean;
		FThreadList: TList;
		FMaxThreadCount: Integer;
		procedure SetMaxThreadCount(Count: Integer);
	public
		constructor Create(MaxThreads: integer);
		destructor Destroy; override;
		procedure AddItem(Item: TTCPThread);
		function GetSuspendThread(aSock: TSocket): TTCPThread;
                procedure clearFinishedThreads;
		function GetActiveThreadCount: Integer;
		property MaxThreadCount: Integer read FMaxThreadCount write SetMaxThreadCount;
	end;

{ TThreadManager }

implementation

procedure TThreadManager.SetMaxThreadCount(Count: Integer);
begin
  FMaxThreadCount := Count;
end;

constructor TThreadManager.Create(MaxThreads: integer);
begin
  inherited Create;
	FItemList := TThreadList.Create;
	FThreadList := TList.Create;
        FMaxThreadCount := MaxThreads;
end;

destructor TThreadManager.Destroy;
var
	i: Integer;
begin
    FThreadList.Pack;
	for i := FThreadList.Count - 1 downto 0 do begin
    	TTCPThread(FThreadList[i]).Free;
	end;
    FThreadList.Capacity := FThreadList.Count;
	FThreadList.Free;
    FItemList.Clear;
	FItemList.Free;
	inherited;
end;

procedure TThreadManager.AddItem(Item: TTCPThread);
begin
  FItemList.Add(Pointer(Item));
end;

function TThreadManager.GetSuspendThread(aSock: TSocket): TTCPThread;
var
	i: Integer;
	TCPThread: TTCPThread;
begin
	Result := nil;
	if GetActiveThreadCount >= FMaxThreadCount then Exit;
	for i := 0 to FThreadList.Count - 1 do begin
		if TTCPThread(FThreadList[i]).Suspended then
                 begin
			TCPThread := TTCPThread(FThreadList[i]);

                        TCPThread.SetSocket(aSock);
                        TCPThread.Resume;
			Break;
		end;
	end;
	if (Result = nil) and (FMaxThreadCount > FThreadList.Count) then begin
		TCPThread := TTCPThread.Create;
		TCPThread.FreeOnTerminate := False;
                TCPThread.SetSocket(aSock);
		TCPThread.Number := FThreadList.Count;
		FThreadList.Add(TCPThread);
		Result := TCPThread;
	end;
end;

procedure TThreadManager.clearFinishedThreads;
var
        i: Integer;
begin
        for i := 0 to FThreadList.Count - 1 do begin

    if (TTCPThread(FThreadList[i]) <> nil) and TTCPThread(FThreadList[i]).isDone() then
       begin
               writeln('Terninating...');
         TTCPThread(FThreadList[i]).WaitFor;
         writeln(' [1] ');
         TTCPThread(FThreadList[i]).Free;
         writeln(' [2] ');
         FThreadList[i] := nil;
         writeln(' [3] ');
       end;

    end;

i := 0;
while i < FThreadList.Count do begin
  if FThreadList[ i ] = nil then
    FThreadList.Delete( i )
  else
    inc( i );
  end;

end;

function TThreadManager.GetActiveThreadCount: Integer;
var
	i: Integer;
begin
	Result := 0;
	for i := 0 to FThreadList.Count - 1 do begin
		if not TTCPThread(FThreadList[i]).Suspended then
			Inc(Result);
	end;
end;

{ TManagedThread }

constructor TManagedThread.Create(waiting : Boolean);
begin
 inherited Create(waiting);
 done_ := false;
 erroneous_ := false;
end;

function  TManagedThread.isDone()     : Boolean;
begin
 Result := done_;
end;


function  TManagedThread.isErroneus() : Boolean;
begin
 Result := erroneous_;
end;

{ TListenerThread }

procedure TListenerThread.Execute;
var
ClientSock: TSocket;
ClientThread: TTCPThread;
begin
   with ListenerSocket do
     begin
       CreateSocket;
        if LastError = 0 then
           WriteLn('Socket successfully initialized')
          else
           WriteLn('An error occurred while initializing the socket: '+GetErrorDescEx);
   Family := SF_IP4;
   setLinger(true,10000);
   bind('0.0.0.0', '5050');
    if LastError = 0 then
      WriteLn('Bind on 5050')
     else
      WriteLn('Bind error: '+GetErrorDescEx);
      listen;
      repeat
        if CanRead(100) then
         begin
           ClientSock := Accept;
            if LastError = 0
             then
              begin
              //TTCPThread.Create()
             ClientThread:=FThreadManager.GetSuspendThread(ClientSock);
             ClientThread.FreeOnTerminate:=True;
              WriteLn('We have '+ IntToStr(FThreadManager.GetActiveThreadCount)+#32+'client threads!');
              end
             else
              WriteLn('TCP thread creation error: '+GetErrorDescEx);
         end;
        FThreadManager.clearFinishedThreads;
      sleep(10);
     until false;
    end;
end;

constructor TListenerThread.Create;
begin
FreeOnTerminate := True;
ListenerSocket := TTCPBlockSocket.Create;
FThreadManager:=TThreadManager.Create(20000);
if ListenerSocket.LastError = 0
  then
     WriteLn('Listener has been created')
  else
      WriteLn('Listener creation error: '+ListenerSocket.GetErrorDescEx);
inherited Create(False);
end;

destructor TListenerThread.Destroy;
begin
 ListenerSocket.Free;
   if
     ListenerSocket.LastError = 0
       then
           WriteLn('Listener has been deleted')
          else
            WriteLn('Listener deleting error: '+ListenerSocket.GetErrorDescEx);
  inherited;
end;

{ TTCPThread }

procedure TTCPThread.SetSocket(aSock: TSocket);
begin
   fSock.Socket := aSock;
   fSock.GetSins;
end;

procedure TTCPThread.Execute;
var
  s: ansistring;
begin
  fIp:=fSock.GetRemoteSinIP;
  fPort:=fSock.GetRemoteSinPort;
  WriteLn(format('Accepted connection from %s:%d',[fIp,fPort]));
  while not isDone  do
   begin
    if fSock.WaitingData > 0 then
     begin
      s:=fSock.RecvPacket(2000);
      if fSock.LastError <> 0 then
       WriteLn(fSock.GetErrorDescEx);
       ProcessingData(fSock.Socket,S);
      end;
    sleep(10);
   end;
end;

constructor TTCPThread.Create();
begin
 FreeOnTerminate := True;
 fSock := TTCPBlockSocket.Create;
 inherited Create(false);
end;

destructor TTCPThread.Destroy;
begin
  WriteLn(format('Disconnect from %s:%d',[fIp,fPort]));
  fSock.Free;
  inherited;
end;

procedure TTCPThread.ProcessingData(procSock: TSocket; Data: string);

var i: integer;   b: byte;
  dataReal: string;
begin
  dataReal:='';
  for i:=0 to length(data) do begin
   b:= ord(data[i]);
   if ((b > 31) AND (b < 128)) then begin //keep only printable
      dataReal := dataReal + chr(b);
    write(' :#'+inttostr(ord(data[i])));
    end;

  end;

  writeln(' | ');
  writeln(inttostR(length(dataReal)) + 'bytes. ');
  if data <> '' then
   WriteLn(data+#32+'we get it from '+IntToStr(number)+' thread');

  if dataReal = 'quit' then  begin
   write(' >trying to quit< ');
     self.CurrentThread.Terminate;

  end;


end;
 var
   Server: TListenerThread;
begin
   //Server:=TListenerThread.Create;
   //repeat
   //      server.FThreadManager.clearFinishedThreads;
   //      sleep(10);
   //until KeyPressed;
   //
   //halt;
end.
