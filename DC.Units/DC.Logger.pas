unit DC.Logger;

interface

uses
  System.SysUtils, System.IOUtils;

type
  TLogLevel = (llDebug, llInfo, llWarning, llError);

  TLogger = class
  private
    class procedure Log(const LogLevel: TLogLevel; const Msg: string);
    class function LogLevelToString(const LogLevel: TLogLevel): string;
  public
    class procedure Debug(const Msg: string);
    class procedure Info(const Msg: string);
    class procedure Warning(const Msg: string);
    class procedure Error(const Msg: string);
  end;

implementation

{ TLogger }

class procedure TLogger.Log(const LogLevel: TLogLevel; const Msg: string);
var
  LogFile: TextFile;
  LogFilePath, LogFileName: string;
begin
  LogFilePath := ExtractFilePath(ParamStr(0)) + 'log\';
  ForceDirectories(LogFilePath);

  LogFileName := LogFilePath + 'logfile_' + FormatDateTime('yyyy-mm-dd', Now) + '.log';
  AssignFile(LogFile, LogFileName);

  if FileExists(LogFileName) then
    Append(LogFile)
  else
    Rewrite(LogFile);

  try
     WriteLn(LogFile, '[' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + '] [' + LogLevelToString(LogLevel) + '] ' + Msg);
  finally
    CloseFile(LogFile);
  end;
end;

class function TLogger.LogLevelToString(const LogLevel: TLogLevel): string;
begin
  case LogLevel of
    llDebug: Result := 'DEBUG';
    llInfo: Result := 'INFO';
    llWarning: Result := 'WARNING';
    llError: Result := 'ERROR';
  else
    Result := 'UNKNOWN';
  end;
end;


class procedure TLogger.Debug(const Msg: string);
begin
  Log(llDebug, Msg);
end;

class procedure TLogger.Info(const Msg: string);
begin
  Log(llInfo, Msg);
end;

class procedure TLogger.Warning(const Msg: string);
begin
  Log(llWarning, Msg);
end;

class procedure TLogger.Error(const Msg: string);
begin
  Log(llError, Msg);
end;

end.

