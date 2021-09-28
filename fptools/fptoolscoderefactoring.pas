unit fptoolscoderefactoring;

{$i fptools.inc}

interface

uses
  fpjson;

procedure CodeRefactoringEmptyMethods(ARequest: TJSONData);
procedure CodeRefactoringUnusedUnits(ARequest: TJSONData);

implementation

uses
  Classes,
  SysUtils,
  CodeCache,
  CodeToolManager,
  CodeToolsStructs,
  // fptools
  fptoolsutils,
  fptoolscodecore;

procedure CodeRefactoringEmptyMethods(ARequest: TJSONData);
var
  VPath: string;
  VLine: integer;
  VColumn: integer;
  VCodeBuffer: TCodeBuffer;
  VListOfPCodeXYPosition: TFPList;
  VRemovedProcHeads: TStrings;
  VPascalClassSections: TPascalClassSections;
  VAll: boolean;
  VReturnData: TJSONObject;
begin
  CodetoolsLoad(ARequest);
  CodetoolsUpdate(ARequest);
  VPath := ARequest.Path('command.path', '');
  if (VPath = '') then
  begin
    WriteStdout('No code refactoring, invalid path');
  end;
  VLine := ARequest.Path('command.line', -1);
  if (VLine < 0) then
  begin
    WriteStdout('No code refactoring, invalid line');
  end;
  VColumn := ARequest.Path('command.column', -1);
  if (VColumn < 0) then
  begin
    WriteStdout('No code refactoring, invalid column');
  end;
  VCodeBuffer := CodeToolBoss.LoadFile(VPath, False, False);
  VListOfPCodeXYPosition := TFPList.Create;
  VRemovedProcHeads := nil;
  try
    VPascalClassSections := [pcsPublished, pcsPrivate, pcsProtected, pcsPublic];
    if (CodeToolBoss.FindEmptyMethods(VCodeBuffer, '', VColumn, VLine,
      VPascalClassSections, VListOfPCodeXYPosition, VAll)) and
      (CodeToolBoss.RemoveEmptyMethods(VCodeBuffer, '', VColumn,
      VLine, VPascalClassSections, VAll, [], VRemovedProcHeads)) then
    begin
      // Return
      VReturnData := TJSONObject.Create();
      VReturnData.Add('source', VCodeBuffer.Source);
      VReturnData.Add('modifield', VCodeBuffer.Modified);
      WriteStdout(VReturnData, True);
    end
    else
    begin
      // Return
      if (CodeToolBoss.ErrorMessage = '') then
      begin
        WriteStdout('No code refactoring');
      end
      else
      begin
        WriteStdout(CodeToolBoss.ErrorMessage);
      end;
    end;
  finally
    FreeAndNil(VRemovedProcHeads);
    CodeToolBoss.FreeListOfPCodeXYPosition(VListOfPCodeXYPosition);
  end;
end;

procedure CodeRefactoringUnusedUnits(ARequest: TJSONData);
var
  VPath: string;
  VCodeBuffer: TCodeBuffer;
  VUnits: TStrings;
  VIndex: integer;
  VResponse: TJSONObject;
begin
  CodetoolsLoad(ARequest);
  CodetoolsUpdate(ARequest);
  VPath := ARequest.Path('command.path', '');
  if (VPath = '') then
  begin
    WriteStdout('No code refactoring, invalid path');
  end;
  VCodeBuffer := CodeToolBoss.LoadFile(VPath, False, False);
  VUnits := TStringList.Create;
  try
    if (CodeToolBoss.FindUnusedUnits(VCodeBuffer, VUnits)) then
    begin
      for VIndex := 0 to VUnits.Count - 1 do
      begin
        if (VUnits.ValueFromIndex[VIndex] = '') then
        begin
          CodeToolBoss.RemoveUnitFromAllUsesSections(VCodeBuffer, VUnits.Names[VIndex]);
        end;
      end;
      // Return
      VResponse := TJSONObject.Create();
      VResponse.Add('source', VCodeBuffer.Source);
      VResponse.Add('modifield', VCodeBuffer.Modified);
      WriteStdout(VResponse, True);
    end
    else
    begin
      // Return
      if (CodeToolBoss.ErrorMessage = '') then
      begin
        WriteStdout('No code refactoring');
      end
      else
      begin
        WriteStdout(CodeToolBoss.ErrorMessage);
      end;
    end;
  finally
    FreeAndNil(VUnits);
  end;
end;

end.
