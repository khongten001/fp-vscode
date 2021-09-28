unit fptoolsprojectbuilding;

{$i fptools.inc}

interface

uses
  fpjson;

procedure ProjectBuilding(ARequest: TJSONData);

implementation

uses
  SysUtils,
  LazFileUtils,
  // fptools
  fptoolsutils;

procedure ProjectBuilding(ARequest: TJSONData);
var
  VDir: string;
  VSettings: TJSONData;
  VPlataform: string;
  VCommand: string;
  VCompiler: string;
  VIndex: integer;
  VSearchDirs: TJSONData;
  VIncludeDirs: TJSONData;
  VOutputDir: string;
  VCustomOptions: string;
  VProject: string;
begin
  try
    VDir := ARequest.Path('project.dir', '');
    if (not (DirectoryIsWritable(VDir))) then
    begin
      WriteStdout('Invalid project directory: "' + VDir + '"');
    end;
    VSettings := TJSONData.ParseFile(ARequest.Path('project.settings', ''));
    if (not (Assigned(VSettings))) then
    begin
      WriteStdout('Invalid project settings: "' +
        ARequest.Path('project.settings', '') + '"');
    end;
    VPlataform := VSettings.Path('plataform', '');
    VCommand := '';
    // Compiler
    if (VPlataform = 'webbrowser') or (VPlataform = 'node') then
    begin
      VCompiler := ARequest.Path('config.pas2js.executable', '');
      if (not (FileExistsUTF8(VCompiler))) then
      begin
        WriteStdout('Compiler Pas2JS no found: "' + VCompiler + '"');
      end;
    end
    else
    begin
      VCompiler := ARequest.Path('config.freepascal.executable', '');
      if (not (FileExistsUTF8(VCompiler))) then
      begin
        WriteStdout('Compiler Freepascal no found: "' + VCompiler + '"');
      end;
    end;
    VCommand += VCompiler;
    // Platform
    if (VPlataform = 'webbrowser') then
    begin
      VCommand += ' -Tbrowser';
    end
    else
    if (VPlataform = 'node') then
    begin
      VCommand += ' -Tnodejs';
    end;
    // Specifications
    if (VPlataform = 'webbrowser') or (VPlataform = 'node') then
    begin
      VCommand += ' -Pecmascript6';
    end;
    // FPC's Object Pascal compatibility mode
    VCommand += ' -MObjFPC';
    // Syntax options. Support operators like C (*=,+=,/= and -=)
    VCommand += ' -Sc';
    // Optimizations
    VCommand += ' -O1';
    // Write logo
    VCommand += ' -l';
    // Verbose [e = errros, w = warning, n = notes, h = hints, b = write full file names messages]
    VCommand += ' -vewnb';
    // Search dir
    VCommand += ' -Fu' + VDir;
    VSearchDirs := VSettings.Path('searchDir');
    if (Assigned(VSearchDirs)) then
    begin
      for VIndex := 0 to (VSearchDirs.Count - 1) do
      begin
        VCommand += ExpandPaths(VSearchDirs.Items[VIndex].AsString, VDir, ' -Fu');
      end;
    end;
    // Include dir
    VCommand += ' -Fi' + VDir;
    VIncludeDirs := VSettings.Path('includeDir');
    if (Assigned(VIncludeDirs)) then
    begin
      for VIndex := 0 to (VIncludeDirs.Count - 1) do
      begin
        VCommand += ExpandPaths(VIncludeDirs.Items[VIndex].AsString, VDir, ' -Fi');
      end;
    end;
    // Output dir
    VOutputDir := VSettings.Path('outputDir', '');
    if (VOutputDir <> '') then
    begin
      VCommand += ExpandPaths(VOutputDir, VDir, ' -FE');
    end;
    // Custom options
    VCustomOptions := VSettings.Path('customOptions', '');
    if (VCustomOptions <> '') then
    begin
      VCommand += ' ' + VCustomOptions;
    end;
    // Project
    VProject := VSettings.Path('project', '');
    if (VProject <> '') then
    begin
      VCommand += ExpandPaths(VProject, VDir, ' ');
    end;
    //Return
    WriteStdout(VCommand, True);
  finally
    FreeAndNil(VSettings);
  end;
end;

end.
