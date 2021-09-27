const vscode = require("vscode");
const { runFpTools } = require("./fptools");
const { editorModifiedFiles } = require("./utils");

class CodeSuggestion {
    async provideCompletionItems(document, position) { 
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
                suggestions.push(new vscode.CompletionItem(item));
                // TODO: kind, detail...        
            }; 
            return suggestions;
        } else {
            return [];  
        }
    };
};

module.exports = {
    CodeSuggestion 
}; 