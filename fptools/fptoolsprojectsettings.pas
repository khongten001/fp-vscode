unit fptoolsprojectsettings;

{$i fptools.inc}

interface

uses
  fpjson;

procedure ProjectSettings(ARequest: TJSONData);

implementation

uses
  SysUtils,
  LazFileUtils,
  // fptools
  fptoolsutils;

procedure ProjectSettings(ARequest: TJSONData);
var
  VSearch: TSearchRec;
  VDir: string;
  VList: TJSONArray;
begin
  VDir := ARequest.Path('project.dir', '');
  if (not (DirectoryIsWritable(VDir))) then
  begin
    WriteStdout('Invalid project directory: "' + VDir + '"');
  end;
  if (FindFirstUTF8(AppendPathDelim(VDir) + '*.lpr.json', faAnyFile, VSearch) = 0) then
  begin
    try
      VList := TJSONArray.Create;
      repeat
        VList.Add(AppendPathDelim(VDir) + VSearch.Name);
      until (FindNextUTF8(VSearch) <> 0);
      // Return
      WriteStdout(VList, True);
    finally
      FindCloseUTF8(VSearch);
    end;
  end
  else
  begin
    WriteStdout('No project settings found');
  end;
end;

end.
