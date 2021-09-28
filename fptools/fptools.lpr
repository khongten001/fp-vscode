program fptools;

{$mode objfpc}{$H+}

uses
  Classes,
  Sysutils,
  fpjson,
  // fptools
  fptoolsutils,
  fptoolscodecompletation, 
  fptoolscodedefinition,  
  fptoolscodeindentation,
  fptoolscoderefactoring,
  fptoolscodesuggestion,
  fptoolsprojectbuilding,
  fptoolsprojectcreation,
  fptoolsprojectsettings;

var
  VStdin: string;
  VVersion: string;
  VAction: string;
  VRequest: TJSONData;
begin
  try
    // Stdin
    Read(VStdin);
    VRequest := TJSONData.Parse(VStdin);
    if (Assigned(VRequest)) then
    begin
      VVersion := VRequest.Path('version', 'unknown');
      if (VVersion <> '1.0.9') then
      begin
        WriteStdout('Frontend does not match current requirements: Current version "' +
          VVersion + '"|| Required version "1.0.9"');
      end
      else
      begin
        // Action
        VAction := VRequest.Path('command.action', '');
        case VAction of     
          'codeCompletion': CodeCompletion(VRequest);
          'codeDefinition': CodeDefinition(VRequest);
          'codeIndentation': CodeIndentation(VRequest);  
          'codeRefactoringEmptyMethods': CodeRefactoringEmptyMethods(VRequest);    
          'codeRefactoringUnusedUnits': CodeRefactoringUnusedUnits(VRequest);
          'codeSuggestion': CodeSuggestion(VRequest);    
          'projectBuilding': ProjectBuilding(VRequest);
          'projectCreation': ProjectCreation(VRequest);  
          'projectSettings': ProjectSettings(VRequest);
          else
          begin
            WriteStdout('Unknown action: "' + VAction + '"');
          end;
        end;
      end;
    end
    else
    begin
      WriteStdout('Stdin must be of the JSON type');
    end;
  finally
    FreeAndNil(VRequest);
  end;

end.
