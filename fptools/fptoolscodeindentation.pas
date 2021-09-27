unit fptoolscodeindentation;

{$i fptools.inc}

interface

uses
  fpjson;

procedure CodeIndentation(ARequest: TJSONData);

implementation

uses
  SysUtils,
  CodeToolManager,
  CodeCache,
  Converter,
  JcfSettings,
  // fptools
  fptoolsutils,
  fptoolscodecore;

procedure CodeIndentation(ARequest: TJSONData);
var
  VPath: string;
  VCodeBuffer: TCodeBuffer;
  VConverter: TConverter;
begin
  CodetoolsLoad(ARequest);
  CodetoolsUpdate(ARequest);
  VPath := ARequest.Path('command.path', '');
  if (VPath = '') then
  begin
    WriteStdout('No indentation, invalid path');
  end;
  VCodeBuffer := CodeToolBoss.LoadFile(VPath, False, False);
  if (Assigned(VCodeBuffer)) then
  begin
    FormattingSettings.ReadDefaults;
    VConverter := TConverter.Create;
    try
      VConverter.GuiMessages := False;
      VConverter.InputCode := VCodeBuffer.Source;
      VConverter.Convert;
      if (VConverter.ConvertError) then
      begin
        // Return
        WriteStdout(Format('%s(%d,%d): %s', [VPath, VConverter.ErrorLine,
          VConverter.ErrorColumn, VConverter.ErrorMessage]));
      end
      else
      begin
        // Return
        WriteStdout(VConverter.OutputCode, True);
      end;
    finally
      FreeAndNil(VConverter);
    end;
  end
  else
  begin
    // Return
    if (CodeToolBoss.ErrorMessage = '') then
    begin
      WriteStdout('No indentation');
    end
    else
    begin
      WriteStdout(CodeToolBoss.ErrorMessage);
    end;
  end;
end;

end.
