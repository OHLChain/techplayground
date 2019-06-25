unit constants;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;


const VERSION = '0.1';

const iniFile = 'oconfig.ini';
const INI_General = 'General';
const INI_Network = 'Network';
const INI_SWAMP = 'Swamp';

const BIND_Default_Address = '0.0.0.0';
const BIND_Default_Port = 16384;


const OPERATION_TYPE_BLOCKCHAIN_GENERAL_INFO = 1;
const OPERATION_TYPE_BLOCKCHAIN_SPECIFIC_BLOCK = 2;

const OPERATION_TYPE_NODE_DISCOVERY = 100;

const NODE_DISCOVERY_MAX_NODES = 10;



implementation

end.

