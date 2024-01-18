const core = require('@actions/core');
const exec = require('@actions/exec');

async function run() {
  try {
    // Get the inputs from the workflow file: action.yml
    const versionType = core.getInput('version-type');
    const src = __dirname;

    // Call the script
    // versionType: [marjor, minor, patch]
    await exec.exec(`${src}/git_update.sh -v ${versionType}`);
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();