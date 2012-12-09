global.localEnvironment = 'test' 
require('coffee-script')                        // switch to coffee-script
require (process.cwd() + '/config/application') // load the test environment
