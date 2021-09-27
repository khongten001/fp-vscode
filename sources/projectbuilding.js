const { showError, runTask } = require("./utils");
const { project, runFpTools } = require("./fptools");

const projectBuilding = async () => { 
    if (!project.settings) {
        return showError("No project settings selected");
    };
    let response = await runFpTools({
        action: "projectBuilding"
    });
    if (!response.success) {
        return showError(response.data);
    };
    // Task
    runTask(response.data, "fp-vscode", ["$freepascal"]); 
};

module.exports = {
    projectBuilding
};
