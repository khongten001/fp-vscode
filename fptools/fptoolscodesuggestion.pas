unit fptoolscodesuggestion;

{$i fptools.inc}

interface

uses
  fpjson;

procedure CodeSuggestion(ARequest: TJSONData);

implementation

uses
  CodeToolManager,
  CodeCache,
  IdentCompletionTool,
  // fptools
  fptoolsutils,
  fptoolscodecore;

procedure CodeSuggestion(ARequest: TJSONData);
var
  VPath: string;
  VLine: integer;
  VColumn: integer;
  VCodeBuffer: TCodeBuffer;
  VIdentifierList: TIdentifierList;
  VIdentifierListItem: TIdentifierListItem;
  VIndex: integer;
  VResponse: TJSONArray;
begin
  CodetoolsLoad(ARequest);
  CodetoolsUpdate(ARequest);
  VPath := ARequest.Path('command.path', '');
  if (VPath = '') then
  begin
    WriteStdout('No suggestions, invalid path');
  end;
  VLine := ARequest.Path('command.line', -1);
  if (VLine < 0) then
  begin
    WriteStdout('No suggestions, invalid line');
  end;
  VColumn := ARequest.Path('command.column', -1);
  if (VColumn < 0) then
  begin
    WriteStdout('No suggestions, invalid column');
  end;
  VCodeBuffer := CodeToolBoss.LoadFile(VPath, False, False);
  if (CodeToolBoss.GatherIdentifiers(VCodeBuffer, VColumn, VLine)) then
  begin
    // Return
    VResponse := TJSONArray.Create();
    VIdentifierList := CodeToolBoss.IdentifierList;
    for VIndex := 0 to (VIdentifierList.GetFilteredCount - 1) do
    begin
      VIdentifierListItem := VIdentifierList.FilteredItems[VIndex];
      VResponse.Add(VIdentifierListItem.Identifier);
      // TODO: kind, detail...
    end;
    WriteStdout(VResponse, True);
  end
  else
  begin
    // Return
    if (CodeToolBoss.ErrorMessage = '') then
    begin
      WriteStdout('No suggestions');
    end
    else
    begin
      WriteStdout(CodeToolBoss.ErrorMessage);
    end;
  end;
end;

end.
