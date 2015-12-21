###
  Author: ec.huyinghuan@gmail.com
  Date: 2015.07.07
  Describe:
    gitlab与项目相关关系的增删改
###
"use strict"
define [
  '../ng-module'
  '../utils'
], (_module, _utils) ->

  _module.controllerModule.
  controller('gitlabController',
    ['$rootScope', '$scope', '$stateParams', 'API', 'NOTIFY'
      ($rootScope, $scope, $stateParams, API, NOTIFY)->
        projectAPI = API.project($stateParams.project_id)
        getData = (name)->
          projectAPI[name]().retrieve()

        #删除一条gitlab关联记录
        doDelGitMap = (id)->
          projectAPI.gitlab(id).delete().then((result)->
            NOTIFY.success("删除成功！")
            $scope.$broadcast("component:gitlab:reload")
          )
        #fork 一个gitlab仓库
        forkGit = (git_id)->
          projectAPI.gitlab(git_id).fork().retrieve().then(->
            NOTIFY.success("fork成功！")
            $scope.$broadcast("component:gitlab:reload")
          )

        #给项目添加关联一个已存在的gitlab地址
        addGitToProject = (gitlab_url)->
          projectAPI.gitlab().update({gitlab_url: gitlab_url}).then(->
            NOTIFY.success("添加成功！")
            $scope.$broadcast("component:gitlab:reload")
            $scope.$broadcast("component:gitlab_add_form:reset")
          )

        #创建一个新gitlab仓库并关联到项目
        createGitForProject = (gitlab_name)->
          projectAPI.gitlab().create({gitlab_name: gitlab_name}).then(->
            NOTIFY.success("创建项目成功")
            $scope.$broadcast("component:gitlab:reload")
            $scope.$broadcast("component:gitlab_create_form:reset")
          )

        doAction = (name, value)->
          switch name
            when "fork"
              forkGit value
            when "del"
              doDelGitMap value
            when "add"
              addGitToProject value
            when "create"
              createGitForProject value


        $scope.bean = {
          getData: getData
          doAction: doAction
        }
  ])