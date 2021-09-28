const vscode = require("vscode");
const { runFpTools } = require("./fptools");
const { editorModifiedFiles } = require("./utils");

const provideCompletionItems = async (document, position) => {
    let response = await runFpTools({
        action: "codeSuggestion",
        path: document.uri.fsPath,
        line: position.line + 1,
        column: position.character + 1,
        updates: await editorModifiedFiles()
    });
    if (response.success === true) {
        let suggestions = [];
        for (let item of response.data) { 
            let completionItem = {
                label: item.identifier,
                kind: item.kind,
                detail: item.detail 
            }
            suggestions.push(completionItem); 
        };
        return suggestions;
    } else {
        return [];
    }
}; 

module.exports = {
    provideCompletionItems
};