const { runFpTools } = require("./fptools");
const { createLocation, editorModifiedFiles } = require("./utils");

class CodeDefinition {
    async provideDefinition(document, position) {
        let response = await runFpTools({
            action: "codeDefinition",
            path: document.uri.fsPath,
            line: position.line + 1,
            column: position.character + 1,
            updates: await editorModifiedFiles()
        });
        if (!response.success) {
            return
        }
        return createLocation(
            response.data.path,
            response.data.line - 1,
            response.data.column - 1
        );
    };
};

module.exports = {
    CodeDefinition
};