const vscode = require("vscode");
const path = require("path");
const { getRootDir, isDarwin, isLinux, isWin, runCommand } = require("./utils");

const project = {
    settings: ""
}; 

const runFpTools = (command) => {
    return new Promise(async (resolve) => {
        try {
            // Bin
            let bin = "";
            if (isWin()) {
                bin = "../bin/win64/fptools.exe";
            } else if (isLinux()) {
                bin = "../bin/linux/fptools";
            } else if (isDarwin()) {
                bin = "../bin/darwin/fptools";
            };
            bin = path.resolve(__dirname, bin);
            // Stdin
            let stdin = {
                version: "1.0.9",
                config: { 
                    freepascal: vscode.workspace.getConfiguration("freepascal"),
                    pas2js: vscode.workspace.getConfiguration("pas2js")
                },
                project : {
                    dir: getRootDir(), 
                    settings: project.settings
                },
                command: command
            };
            // Run
            let stdout = await runCommand(bin, JSON.stringify(stdin))
            // Stdout
            resolve(JSON.parse(stdout));
        } catch (e) { 
            resolve("Internal error: " + e.message ?? e);
        }
    });
};

module.exports = {
    project,
    runFpTools
};