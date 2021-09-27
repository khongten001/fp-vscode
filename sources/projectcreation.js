const { showInputBox, showListBox, editorOpenFile, showError } = require("./utils");
const { project, runFpTools } = require("./fptools");

const validName = (text) => {
    if (text === "" || text.indexOf(".") > -1) {
        return "Invalid name"
    }
    return null;
};

const projectCreation = async () => { 
    let template = await showListBox(
        "Select a template...",
        [
            "Application",
            "Application Node",
            "Application Web Browser",
            "Library"
        ]
    );
    if (!template) {
        return
    }
    let name = await showInputBox(
        "Enter a name...", "Project1",
        validName
    );
    if (!name) {
        return
    }
    let response = await runFpTools({
        action: "projectCreation",
        project: {
            name: name,
            template: template
        }
    });
    if (!response.success) {
        return showError(response.data)
    };
    // Loading 
    project.settings = response.data.settings;
    editorOpenFile(response.data.project); 
};

module.exports = {
    projectCreation
};