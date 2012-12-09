{exec} = require 'child_process'

# may need to:
# ln -s coffee-script/lib/ lib


ReportFormat = 'spec'

task 'spec:server', 'Test server-side specs', (options)->
  exec "mocha -R #{ReportFormat} --require spec/spec-helper --colors spec/server/**/*-spec.coffee", (err, stdout, stderr) ->
  #   throw err if err
    console.log "Test server-side specs"
    console.log stdout
    console.log stderr
    console.log "----------------------------------------\n"

# task 'spec:client', 'Test client-side specs', (options)->
#   exec "mocha -R #{ReportFormat} --require spec/spec-helper --colors spec/client/*/*', (err, stdout, stderr) ->
#     throw err if err
#     sys.print "Test client-side specs\n" + stdout + stderr + "\n----------------------------------------\n"

# task 'spec:user', 'Test user-interaction specs (headless-browser)', (options)->
#     exec "mocha -R #{ReportFormat} --require spec/spec-helper --colors spec/user/*/*', (err, stdout, stderr) ->
#     throw err if err
#     sys.print "Test user-interaction specs (headless-browser)\n" + stdout + stderr + "\n----------------------------------------\n"

task 'spec', 'Run all client and server specs', (options)->
  invoke 'spec:server'
  # invoke 'spec:client'
  # invoke 'spec:user'

task 'test', 'test', (options)-> invoke 'spec'
