"use strict"
define [
  "ng"
  "app"
  'utils'
  't!../views/issue/issue-all.html'
  't!../views/member/member-all.html'
  't!../views/commit/commit-all.html'
  't!../views/assets/assets-all.html'
  't!../views/project/project-all.html'
  't!../views/report/report-all.html'
  't!../views/global-all.html'
  't!../views/member/authority.html'
  't!../views/wiki/wiki-all.html'
  't!../views/team/team-all.html'
  't!../views/stream/stream-all.html'
  't!../views/gitlab/gitlab.html'
], (_ng, _app, _utils, _tmplIssue, _tmplMember,
    _tmplCommit, _tmplAssets, _tmplProject,
    _tmplReport, _tmplGlobal, _tmplAuthority,
    _tmplWiki, _tmplTeam, _tmplStream, _templGitlab) ->

  _app.config(['$routeProvider', '$locationProvider', '$stateProvider', '$urlRouterProvider',
  ($routeProvider, $locationProvider, $stateProvider, $urlRouterProvider) ->
    $locationProvider.html5Mode enabled: true, requireBase: false

    blankDetailsView =
      template: _utils.extractTemplate '#tmpl-global-blank-page', _tmplGlobal
      controller: ->

    streamView =
      template: _utils.extractTemplate '#tmpl-stream-list', _tmplStream
      controller: 'streamListController'

    #issue
    issueViews =
      'listPanel':
        template: _utils.extractTemplate('#tmpl-issue-list', _tmplIssue)
        controller: 'issueListController'
      'detailsPanel@project':
        templateUrl: '/views/issue/details.html'
        controller: 'issueDetailsController'
      'detailsPanel@myproject':
        templateUrl: '/views/issue/details.html'
        controller: 'issueDetailsController'
      'detailsPanel@myfollow':
        templateUrl: '/views/issue/details.html'
        controller: 'issueDetailsController'

    issueListOnly =
      'listPanel@project': issueViews.listPanel
      'listPanel@myproject': issueViews.listPanel
      'listPanel@myfollow': issueViews.listPanel
      'detailsPanel@project': blankDetailsView
      'detailsPanel@myproject': streamView
      'detailsPanel@myfollow': streamView

    documentListOnly =
      'listPanel@project':
        template: _utils.extractTemplate '#tmpl-document-list', _tmplIssue
        controller: 'documentListController'
      detailsPanel: blankDetailsView

    documentViews =
      listPanel: documentListOnly['listPanel@project']
      'detailsPanel@project': issueViews['detailsPanel@project']

    #测试相关
    testListOnly =
      'listPanel@project':
        template: _utils.extractTemplate '#tmpl-test-list', _tmplIssue
        controller: 'testListController'
      'detailsPanel': blankDetailsView

    testViews =
      listPanel: testListOnly['listPanel@project']
      'detailsPanel@project': issueViews['detailsPanel@project']

    #讨论
    discussionViews =
      listPanel:
        template: _utils.extractTemplate('#tmpl-discussion-list', _tmplIssue)
        controller: 'discussionListController'
      'detailsPanel@project':
        templateUrl: '/views/issue/details.html'
        controller: 'issueDetailsController'

    discussionListOnly =
      listPanel: discussionViews.listPanel
      detailsPanel: blankDetailsView


    weeklyReportListOnly =
      listPanel:
        template: _utils.extractTemplate('#tmpl-report-weekly-list', _tmplReport)
        controller: 'weeklyReportListController'
      detailsPanel: blankDetailsView

    weeklyReportViews =
      listPanel: weeklyReportListOnly.listPanel
      'detailsPanel@project':
        template: _utils.extractTemplate('#tmpl-report-weekly-details', _tmplReport)
        controller: 'reportWeeklyDetailsController'
      'detailsPanel@report':
        template: _utils.extractTemplate('#tmpl-report-weekly-details', _tmplReport)
        controller: 'reportWeeklyDetailsController'

    memberListOnly =
      'listPanel@project':
        template: _utils.extractTemplate('#tmpl-project-member-list', _tmplMember)
      detailsPanel: blankDetailsView

    commitListOnly =
      'listPanel@project':
        template: _utils.extractTemplate('#tmpl-commit-list', _tmplCommit)
        controller: 'commitListController'
      detailsPanel: blankDetailsView

    gitlabListOnly =
      'listPanel@project':
        template: _utils.extractTemplate('#tmpl-gitlab-details', _templGitlab)
        controller: 'gitlabController'
      detailsPanel: blankDetailsView

    assetsListOnly =
      listPanel:
        template: _utils.extractTemplate('#tmpl-assets-list', _tmplAssets)
        controller: 'assetsListController'
      detailsPanel: blankDetailsView

    assetsPreviewerViews =
      listPanel: assetsListOnly.listPanel
      'detailsPanel@project':
        template: _utils.extractTemplate('#tmpl-assets-details', _tmplAssets)
        controller: 'assetsDetailsController'

    #wiki相关
    wikiViews =
      'listPanel':
        template: _utils.extractTemplate '#tmpl-wiki-list', _tmplWiki
        controller: 'issueListController'
      'detailsPanel@wiki': issueViews['detailsPanel@project']

    wikiListOnly =
      'listPanel': wikiViews.listPanel
      'detailsPanel@wiki': blankDetailsView


    # 团队相关
    teamMemberListOnly =
      'listPanel':
        template: _utils.extractTemplate('#tmpl-team-member-list', _tmplTeam)
      'detailsPanel': blankDetailsView

    teamInviteListOnly =
      'listPanel':
        template: _utils.extractTemplate('#tmpl-team-invite-list', _tmplTeam)
      'detailsPanel': blankDetailsView


    

    $urlRouterProvider.otherwise('/myproject/all/issue/myself')

    $stateProvider
    .state('home',
      url: '/'
      templateUrl: '/views/home.html'
      controller: 'homeController'
    )

    #登录
    .state('login',
      url: '/login'
      template: _utils.extractTemplate '#tmpl-member-authority', _tmplAuthority
      controller: 'loginController'

    )

    #注册
    .state('invite',
      url: '/invite/:token'
      template: _utils.extractTemplate '#tmpl-member-authority', _tmplAuthority
      controller: 'loginController'

    )

    .state('project',
      abstract: true
      url: '/project/:project_id'
      template: _utils.extractTemplate '#tmpl-project-layout', _tmplProject
      controller: 'projectController'
    )

    #=====================================ISSUE相关=======================================
    #issue列表
    .state('project.issue',
      url: '/issue'
      views: issueListOnly
    ).state('project.issue.details',
      url: '/{issue_id:\\d+}'
      views: issueViews
    )

    .state('project.version',
      url: '/version/:version_id'
      abstract: true
    )

    #分类->issue
    .state('project.issue_category',
      url: '/category/:category_id/issue'
      views:
        listPanel: issueViews.listPanel
    ).state('project.issue_category.details',
      url: '/{issue_id:\\d+}'
      views: issueViews
    )

    #版本->分类->issue
    .state('project.version_category_issue',
      url: '/version/:version_id/category/:category_id/issue'
      views: issueListOnly
    ).state('project.version_category_issue.details',
      url: '/{issue_id:\\d+}'
      views: issueViews
    )

    #获取版本下的所有issue，但不考虑分类
    .state('project.version_issue',
      url: '/version/:version_id/issue'
      views: issueListOnly
    ).state('project.version_issue.details',
      url: '/{issue_id:\\d+}'
      views: issueViews
    )

    #用户自己的issue
    .state('project.my_issue',
      url: '/issue/{myself:myself}'
      views: issueListOnly
    ).state('project.my_issue.details',
      url: '/{issue_id:\\d+}'
      views: issueViews
    )

    #在指定版本下，用户自己的issue
    .state('project.version.my_issue',
      url: '/issue/{myself:myself}'
      views: issueListOnly
    ).state('project.version.my_issue.details',
      url: '/{issue_id:\\d+}'
      views: issueViews
    )

    #=====================================周报相关=======================================
    #周报
    .state('project.weekly_report',
      url: '/weekly-report'
      views: weeklyReportListOnly
    )

    .state('project.weekly_report.details',
      url: '/{start_time}~{end_time}'
      views: weeklyReportViews
    )

    .state('project.version_weekly_report',
      url: '/version/:version_id/weekly-report'
      views: weeklyReportListOnly
    )

    .state('project.version_weekly_report.details',
      url: '/{start_time}~{end_time}'
      views: weeklyReportViews
    )

#    #项目版本列表
#    .state('project.version',
#      url: '/version'
#      views: 'list-panel': {}
#    )


    #成员
    .state('project.member',
      url: '/member'
      views: memberListOnly
    ).state('project.version.member',
      url: '/member'
      views: memberListOnly
    )

    #commit
    .state('project.commit',
      url: '/commit'
      views: commitListOnly
    ).state('project.version.commit',
      url: '/commit'
      views: commitListOnly
    )

    #gitlab
    .state('project.gitlab',
      url: '/gitlab'
      views: gitlabListOnly
    ).state('project.version.gitlab',
      url: '/gitlab'
      views: gitlabListOnly
    )

    .state('project.version.commit.details',
      url: '/:commit_id?url'
      views:
        'detailsPanel@project':
          template: _utils.extractTemplate('#tmpl-commit-details', _tmplCommit)
          controller: 'commitDetailsController'
    )

    #====================================讨论相关=======================================
    #讨论
    .state('project.discussion',
      url: '/discussion'
      views: discussionListOnly
    ).state('project.discussion.details',
      url: '/{issue_id:\\d+}'
      data: articleOnly: true
      views: discussionViews
    )

    .state('project.version_discussion',
      url: '/version/:version_id/discussion'
      views: discussionListOnly
    ).state('project.version_discussion.details',
      url: '/{issue_id:\\d+}'
      data: articleOnly: true
      views: discussionViews
    )

    #====================================文档=======================================

    .state('project.document',
      url: '/document'
      views: documentListOnly
    ).state('project.version.document',
      url: '/document'
      views: documentListOnly
    ).state('project.version.document.details',
      url: '/:issue_id'
      data: articleOnly: true
      views: documentViews
    ).state('project.document.details',
      url: '/:issue_id'
      data: articleOnly: true
      views: documentViews
    )

    #====================================测试=======================================

    .state('project.test',
      url: '/test'
      views: testListOnly
    ).state('project.version.test',
      url: '/test'
      views: testListOnly
    ).state('project.version.test.details',
      url: '/:issue_id'
      views: testViews
    ).state('project.test.details',
      url: '/:issue_id'
      views: testViews
    )

    #素材
    .state('project.assets',
      url: '/assets'
      views: assetsListOnly
    ).state('project.version_assets',
      url: '/version/:version_id/assets'
      views: assetsListOnly
    ).state('project.version_assets.previewer'
      url: '/previewer/:asset_id'
      views: assetsPreviewerViews
    ).state('project.assets.previewer'
      url: '/previewer/:asset_id'
      views: assetsPreviewerViews
    )

    #wiki类，与project本质上来说，是同一个东西
    #====================================wiki=======================================
    .state('wiki',
      abstract: true
      url: '/wiki/:project_id'
      template: _utils.extractTemplate '#tmpl-wiki-layout', _tmplWiki
      #wiki与
      controller: 'projectController'
    )

    #空的列表
    .state('wiki.list',
      url: '/issue'
      data: wiki: true
      views: wikiListOnly
    )

    .state('wiki.list_category',
      url: '/category/:category_id/issue'
      data: wiki: true
      views: wikiListOnly
    )

    .state('wiki.list.details',
      url: '/{issue_id:\\d+}'
      data: wiki: true, articleOnly: true
      views: wikiViews
    )

    .state('wiki.list_category.details',
      url: '/{issue_id:\\d+}'
      data: wiki: true, articleOnly: true
      views: wikiViews
    )    

    #team类
    #====================================team=======================================
    .state('team',
      abstract: true
      url: '/team/:team_id'
      template: _utils.extractTemplate '#tmpl-team-layout', _tmplTeam
      controller: 'teamController'
    )

    .state('team.list',
      url: '/list'
      views: teamMemberListOnly
    )
    .state('team.invite',
      url: '/invite'
      views: teamInviteListOnly
    )


    #report类
    #====================================report=======================================
    .state('report',
      abstract: true
      url: '/report/:team_id'
      template: _utils.extractTemplate '#tmpl-report-layout', _tmplReport
      controller: 'reportController'
    )

    .state('report.list',
      url: '/weekly-report'
      views: weeklyReportListOnly
    )

    .state('report.list.details',
      url: '/{start_time}~{end_time}'
      views: weeklyReportViews
    )
 

     #myproject类
    #====================================myproject=======================================
    .state('myproject',
      abstract: true
      url: '/myproject'
      template: _utils.extractTemplate '#tmpl-my-project-layout', _tmplProject
      controller: 'myProjectController'
    )

    .state('myproject.list',
      url: '/:project_id'
    )

    .state('myproject.list.issue',
      url: '/issue/{myself:myself}'
      views: issueListOnly
    )

    .state('myproject.list.issue.details',
      url: '/{issue_id:\\d+}'
      views: issueViews
    )     

    #myfollow类
    #====================================myfollow=======================================
    .state('myfollow',
      abstract: true
      url: '/myfollow'
      template: _utils.extractTemplate '#tmpl-my-follow-layout', _tmplProject
      controller: 'myFollowController'
    )

    .state('myfollow.list',
      url: '/:project_id'
    )

    .state('myfollow.list.issue',
      url: '/issue/{follow:follow}'
      views: issueListOnly
    )

    .state('myfollow.list.issue.details',
      url: '/{issue_id:\\d+}'
      views: issueViews
    )

  ])