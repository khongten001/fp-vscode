unit fptoolscodesuggestion;

{$i fptools.inc}

interface

uses
  fpjson;

procedure CodeSuggestion(ARequest: TJSONData);

implementation

uses
  Sysutils,
  CodeToolManager,
  CodeCache,
  CodeTree,
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
  VResponseItem: TJSONObject;
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
      VResponseItem := TJSONObject.Create();
      VResponseItem.Add('identifier', VIdentifierListItem.Identifier);
      case VIdentifierListItem.GetDesc of
        // unit    
        ctnUseUnit,
        ctnUseUnitClearName,
        ctnUseUnitNamespace,
        ctnUnit:
        begin
          VResponseItem.Add('kind', 10); 
          VResponseItem.Add('detail', 'Unit');
        end;
        // function/procedure/method
        ctnGlobalProperty,
        ctnProcedureType,
        ctnProcedure:
        begin
          VResponseItem.Add('kind', 2);  
          VResponseItem.Add('detail', 'Function/Procedure');
        end;
        // type
        ctnTypeType,
        ctnFileType,
        ctnPointerType,
        ctnClassOfType,
        ctnVariantType,
        ctnGenericType,
        ctnTypeDefinition,
        ctnVarDefinition:
        begin
          VResponseItem.Add('kind', 24);   
          VResponseItem.Add('detail', 'Type');
        end;
        // const
        ctnConstDefinition,
        ctnConstant:
        begin
          VResponseItem.Add('kind', 20);   
          VResponseItem.Add('detail', 'Const');
        end;
        // property
        ctnProperty:
        begin
          VResponseItem.Add('kind', 9);  
          VResponseItem.Add('detail', 'Property');
        end;
        // Enum
        ctnEnumIdentifier,
        ctnEnumerationType:
        begin
          VResponseItem.Add('kind', 19);
          VResponseItem.Add('detail', 'Enum');
        end;
        else
        begin
          VResponseItem.Add('kind', -1);  
          VResponseItem.Add('detail', IntToStr( VIdentifierListItem.GetDesc));
        end;
      end;
      VResponse.Add(VResponseItem);
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
