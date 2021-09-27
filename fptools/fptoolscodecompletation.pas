unit fptoolscodecompletation;

{$i fptools.inc}

interface

uses
  fpjson;

procedure CodeCompletion(ARequest: TJSONData);

implementation

uses
  CodeToolManager,
  CodeCache,
  // fptools
  fptoolsutils,
  fptoolscodecore;

procedure CodeCompletion(ARequest: TJSONData);
var
  VPath: string;
  VLine: integer;
  VColumn: integer;
  VCodeBuffer: TCodeBuffer;
  VOutCodeBuffer: TCodeBuffer;
  VOutColumn: integer;
  VOutLine: integer;
  VOutTopLine: integer;
  VOutBlockTopLine: integer;
  VOutBlockBottomLine: integer;
  VResponse: TJSONObject;
begin
  CodetoolsLoad(ARequest);
  CodetoolsUpdate(ARequest);
  VPath := ARequest.Path('command.path', '');
  if (VPath = '') then
  begin
    WriteStdout('No completion, invalid path');
  end;
  VLine := ARequest.Path('command.line', -1);
  if (VLine < 0) then
  begin
    WriteStdout('No completion, invalid line');
  end;
  VColumn := ARequest.Path('command.column', -1);
  if (VColumn < 0) then
  begin
    WriteStdout('No completion, invalid column');
  end;
  VCodeBuffer := CodeToolBoss.LoadFile(VPath, False, False);
  if (CodeToolBoss.CompleteCode(VCodeBuffer, VColumn, VLine, 0,
    VOutCodeBuffer, VOutColumn, VOutLine, VOutTopLine, VOutBlockTopLine,
    VOutBlockBottomLine, False)) then
  begin
    // Return
    VResponse := TJSONObject.Create();
    VResponse.Add('source', VCodeBuffer.Source);
    VResponse.Add('line', VOutLine);
    VResponse.Add('column', VOutColumn);
    WriteStdout(VResponse, True);
  end
  else
  begin
    // Return
    if (CodeToolBoss.ErrorMessage = '') then
    begin
      WriteStdout('No completion');
    end
    else
    begin
      WriteStdout(CodeToolBoss.ErrorMessage);
    end;
  end;
end;

end.
