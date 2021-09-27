const { showListBox } = require("./utils");
const { project, runFpTools } = require("./fptools");

const projectLoading = async () => {
    project.settings = "";
    let response = await runFpTools({
        action: "projectSettings"
    });
    if (!response.success) {
        return
    };
    project.settings = await showListBox("Select a file...", response.data.sort());
};

module.exports = {
    projectLoading
};