unit fptoolsutils;

{$i fptools.inc}

interface

uses
  Classes,
  SysUtils,
  fpjson,
  jsonscanner,
  jsonparser,
  LazFileUtils,
  LazUTF8Classes;

type

  { TJSONDataHelper }

  TJSONDataHelper = class helper for TJSONData
  public
    class function Parse(const ASource: TJSONStringType): TJSONData; static;
    class function ParseFile(const AFileName: TJSONStringType): TJSONData; static;
    function Path(const AName: TJSONStringType): TJSONData; overload;
    function Path(const AName: TJSONStringType;
      const ADefault: TJSONStringType): TJSONStringType; overload;
    function Path(const AName: TJSONStringType; const ADefault: integer): integer;
      overload;
    function Path(const AName: TJSONStringType; const ADefault: boolean): boolean;
      overload;
  end;

const
  LE = LineEnding;
                     
function Ternary(ACondition: boolean; AConsequence, Alternative: string): string;
function ExpandPaths(APaths, ABaseDir: string; AIncludeBefore: string = ''): string;
function ReadFile(AFileName: string): string;
function WriteFile(AFileName, AData: string; AAppend: boolean = False): boolean;
procedure WriteLog(AMessage: string);
procedure WriteStdout(AData: TJSONData; ASuccess: boolean = False); overload;
procedure WriteStdout(AData: string; ASuccess: boolean = False); overload;

implementation    

function Ternary(ACondition: boolean; AConsequence, Alternative: string): string;
begin
  if (ACondition) then
  begin
    Result := AConsequence;
  end
  else
  begin
    Result := Alternative;
  end;
end;

function ExpandPaths(APaths, ABaseDir: string; AIncludeBefore: string): string;
var
  VStartPos: integer;
  VEndPos: integer;
  VLength: integer;
begin
  Result := '';
  VLength := length(APaths);
  if (VLength > 0) then
  begin
    VStartPos := 1;
    while VStartPos <= VLength do
    begin
      while (VStartPos <= VLength) and (APaths[VStartPos] = ' ') do
      begin
        Inc(VStartPos);
      end;
      VEndPos := VStartPos;
      while (VEndPos <= VLength) and (APaths[VEndPos] <> ';') do
      begin
        Inc(VEndPos);
      end;
      if (VStartPos < VEndPos) then
      begin
        Result := Result + AIncludeBefore + PrepareCmdLineOption(
          ExpandFileNameUTF8(copy(APaths, VStartPos, VEndPos - VStartPos), ABaseDir));
      end;
      VStartPos := VEndPos + 1;
    end;
  end;
end;

function ReadFile(AFileName: string): string;
var
  VFileStream: TFileStreamUTF8;
  VLength: nativeint;
begin
  Result := '';
  if (FileExistsUTF8(AFileName)) then
  begin
    try
      VFileStream := TFileStreamUTF8.Create(AFileName, fmOpenRead or fmShareDenyWrite);
      try
        VLength := VFileStream.Size;
        if (VLength > 0) then
        begin
          SetLength(Result, VLength);
          VFileStream.Read(Pointer(Result)^, VLength);
        end;
      except
      end;
    finally
      FreeAndNil(VFileStream);
    end;
  end;
end;

function WriteFile(AFileName, AData: string; AAppend: boolean): boolean;
var
  VFileStream: TFileStreamUTF8;
begin
  try
    try
      if (FileExistsUTF8(AFileName)) then
      begin
        VFileStream := TFileStreamUTF8.Create(AFileName, fmOpenReadWrite or
          fmShareDenyNone);
        if (AAppend) then
        begin
          VFileStream.Seek(0, soFromEnd);
        end;
      end
      else
      begin
        VFileStream := TFileStream.Create(AFileName, fmCreate);
      end;
      if (AData <> '') then
      begin
        VFileStream.Write(Pointer(AData)^, Length(AData));
      end;
      Result := True;
    except
      Result := False;
    end;
  finally
    FreeAndNil(VFileStream);
  end;
end;

procedure WriteLog(AMessage: string);
begin
  WriteFile(AppendPathDelim(ExtractFilePath(ParamStr(0))) + 'ct.log',
    AMessage + LE, True);
end;

procedure WriteStdout(AData: TJSONData; ASuccess: boolean);
var
  VJSON: TJSONObject;
begin
  VJSON := TJSONObject.Create;
  try
    VJSON.Add('success', ASuccess);
    VJSON.Add('data', AData);
    // Stdout
    Write(VJSON.FormatJSON(AsCompressedJSON));
  finally
    FreeAndNil(VJSON);
    Halt;
  end;
end;

procedure WriteStdout(AData: string; ASuccess: boolean);
begin
  WriteStdout(TJSONString.Create(AData), ASuccess);
end;

{ TJSONDataHelper }

class function TJSONDataHelper.Parse(const ASource: TJSONStringType): TJSONData;
var
  VParser: TJSONParser;
begin
  Result := nil;
  VParser := TJSONParser.Create(ASource, [joUTF8]);
  try
    try
      Result := VParser.Parse;
    except
      FreeAndNil(Result);
    end;
  finally
    FreeAndNil(VParser);
  end;
end;

class function TJSONDataHelper.ParseFile(const AFileName: TJSONStringType): TJSONData;
begin
  Result := Parse(ReadFile(AFileName));
end;

function TJSONDataHelper.Path(const AName: TJSONStringType): TJSONData;
begin
  Result := FindPath(AName);
end;

function TJSONDataHelper.Path(const AName: TJSONStringType;
  const ADefault: TJSONStringType): TJSONStringType;
var
  VJSONData: TJSONData;
begin
  VJSONData := Path(AName);
  if (Assigned(VJSONData)) and (VJSONData.JSONType = jtString) then
  begin
    Result := VJSONData.AsString;
  end
  else
  begin
    Result := ADefault;
  end;
end;

function TJSONDataHelper.Path(const AName: TJSONStringType;
  const ADefault: integer): integer;
var
  VJSONData: TJSONData;
begin
  VJSONData := Path(AName);
  if (Assigned(VJSONData)) and (VJSONData.JSONType = jtNumber) then
  begin
    Result := VJSONData.AsInt64;
  end
  else
  begin
    Result := ADefault;
  end;
end;

function TJSONDataHelper.Path(const AName: TJSONStringType;
  const ADefault: boolean): boolean;
var
  VJSONData: TJSONData;
begin
  VJSONData := Path(AName);
  if (Assigned(VJSONData)) and (VJSONData.JSONType = jtBoolean) then
  begin
    Result := VJSONData.AsBoolean;
  end
  else
  begin
    Result := ADefault;
  end;
end;

end.
