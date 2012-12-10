global.localEnvironment = 'test' 
require('coffee-script')                        // switch to coffee-script
require (process.cwd() + '/config/application') // load the test environment

// load factories
var _i, _len;
var factoryFileNames = FS.readdirSync(rootPath.factories);
for (_i = 0, _len = factoryFileNames.length; _i < _len; _i++) {
  require(rootPath.factories + factoryFileNames[_i]);
}

