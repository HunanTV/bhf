module.exports = (grunt)->
  grunt.loadTasks './test/build_version'
  grunt.registerTask 'build-version', ['backup-mysql']