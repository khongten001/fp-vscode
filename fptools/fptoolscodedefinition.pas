unit fptoolscodedefinition;

{$i fptools.inc}

interface

uses
  fpjson;

procedure CodeDefinition(ARequest: TJSONData);

implementation

uses
  CodeToolManager,
  CodeCache,
  // fptools
  fptoolsutils,
  fptoolscodecore;

procedure CodeDefinition(ARequest: TJSONData);
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
    WriteStdout('No definition, invalid path');
  end;
  VLine := ARequest.Path('command.line', -1);
  if (VLine < 0) then
  begin
    WriteStdout('No definition, invalid line');
  end;
  VColumn := ARequest.Path('command.column', -1);
  if (VColumn < 0) then
  begin
    WriteStdout('No definition, invalid column');
  end;
  VCodeBuffer := CodeToolBoss.LoadFile(VPath, False, False);
  if (CodeToolBoss.FindDeclaration(VCodeBuffer, VColumn, VLine,
    VOutCodeBuffer, VOutColumn, VOutLine, VOutTopLine, VOutBlockTopLine,
    VOutBlockBottomLine)) then
  begin
    // Return
    VResponse := TJSONObject.Create();
    VResponse.Add('path', VOutCodeBuffer.Filename);
    VResponse.Add('line', VOutLine);
    VResponse.Add('column', VOutColumn);
    WriteStdout(VResponse, True);
  end
  else
  begin
    // Return
    if (CodeToolBoss.ErrorMessage = '') then
    begin
      WriteStdout('No definition');
    end
    else
    begin
      WriteStdout(CodeToolBoss.ErrorMessage);
    end;
  end;
end;

end.
