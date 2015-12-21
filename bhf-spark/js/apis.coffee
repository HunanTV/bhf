define [], ->
  return [
    {
      "url": "mine",
      "methods": {
        "patch": false
      }
    },
    {
      "url": "session",
      "methods": {
        "put": false,
        "patch": false
      }
    },
    {
      "url": "project/:project_id/attachment/:filename",
      "methods": {}
    },
    {
      "url": "project",
      "methods": {}
    },
    #      {
    #        "url": "project/:project_id/status",
    #        "methods": {
    #          "post": false,
    #          "delete": false,
    #          "patch": false
    #        } 
    #      },
    {
      "url": "project/:project_id/category/:category_id",
      "methods": {}
    },
    {
      "url": "project/:project_id/version/:version_id",
      "methods": {}
    },
    {
      "url": "project/:project_id/webhook/:webhook_id",
      "methods": {}
    },
    {
      "url": "project/:project_id/deploy",
      "methods": {
        "get": false,
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "project/git",
      "methods": {
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "git/commit",
      "methods": {
        "get": false,
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "project/:project_id/owned-gits",
      "methods": {
        "get": true,
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "project/:project_id/gitlab/:id/fork",
      "methods": {
        "get": true,
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "commit/import",
      "methods": {
        "get": true,
        "post": false,
        "delete": true,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "project/:project_id/git/tags",
      "methods": {
        "post": false,
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "project/:project_id/member/:member_id",
      "methods": {}
    },
    {
      "url": "project/:project_id/git/commit",
      "methods": {
        "get": false,
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "project/:project_id/issue/:issue_id/commit",
      "methods": {
        "post": false,
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "project/:project_id/issue/:issue_id/split/:id",
      "methods": {
        "patch": false
      }
    },
    {
      "url": "project/:project_id/issue/:issue_id/follow/:id",
      "methods": {
        "patch": false,
        "put": false,
      }
    },
    {
      "url": "project/:project_id/follow",
      "methods": {
        "post": false,
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "project/:project_id/assets",
      "methods": {
        "patch": false,
        "put": false
      }
    },
    {
      "url": "project/:project_id/issue/:issue_id/assets/:id",
      "methods": {
        "patch": false,
        "put": false
      }
    },
    {
      "url": "project/:project_id/issue/:issue_id/commit",
      "methods": {
        "post": false,
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "project/:project_id/commit",
      "methods": {
        "post": false,
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "assets/:project_id/:zipfile/unwind",
      "methods": {
        "post": false,
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "project/:project_id/issue",
      "methods": {
        "delete": false,
        "patch": false
      }
    },
    {
      "url": "project/:project_id/report",
      "methods": {
        "post": false,
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "report/issue",
      "methods": {
        "post": false,
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "report",
      "methods": {
        "delete": false,
        "patch": false
      }
    },
    {
      "url": "project/:project_id/stat",
      "methods": {
        "post": false,
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "project/:project_id/report/weekly",
      "methods": {
        "post": false,
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "project/:project_id/issue/:issue_id/comment/:comment_id",
      "methods": {}
    },
    {
      "url": "project/:project_id/discussion",
      "methods": {
        "put": false,
        "post": false,
        "delete": false,
        "patch": false
      }
    },
    {
      "url": "project/:project_id/issue/:issue_id/status",
      "methods": {
        "get": false,
        "delete": false,
        "post": false,
        "patch": false
      }
    },
    {
      "url": "project/:project_id/issue/:issue_id/tag",
      "methods": {
        "get": false,
        "delete": false,
        "post": false,
        "patch": false
      }
    },
    {
      "url": "project/:project_id/issue/:issue_id/priority",
      "methods": {
        "get": false,
        "delete": false,
        "post": false
      }
    },
    {
      "url": "project/:project_id/favorite",
      "methods": {
        "get": false,
        "put": false
      }
    },
    {
      "url": "account/change-password",
      "methods": {
        "post": false,
        "delete": false,
        "get": false,
        "patch": false
      }
    },
    {
      "url": "account/reset-password",
      "methods": {
        "post": false,
        "delete": false,
        "put": false,
        "patch": false
      }
    },
    {
      "url": "account/weixin",
      "methods": {
        "delete": false,
        "get": false,
        "patch": false
      }
    },
    {
      "url": "member/role",
      "methods": {
        "post": false,
        "delete": false,
        "get": false,
        "patch": false
      }
    },
    {
      "url": "account/token",
      "methods": {
        "put": false,
        "delete": false,
        "get": false,
        "patch": false
      }
    },
    {
      "url": "member",
      "methods": {
        "put": false,
        "delete": false,
        "patch": false
      }
    },
    {
      "url": "member/mail",
      "methods": {
        "get": false,
        "put": false,
        "delete": false,
        "patch": false
      }
    },
    {
      "url": "account/profile",
      "methods": {
        "delete": false,
        "post": false,
        "patch": false
      }
    },
    {
      "url": "account/avatar/:member_id",
      "methods": {
        "put": false,
        "delete": false,
        "post": false,
        "patch": false
      }
    },
    {
      "url": "apis",
      "methods": {}
    },
    {
      "url": "project/:project_id/issue/:issue_id/log",
      "methods": {
        "post": false,
        "delete": false,
        "patch": false,
        "put": false
      }
    },
    {
      "url": "report/project/issue-finish",
      "methods": {
        "put": false,
        "post": false,
        "path": false,
        "delete": false,
        "patch": false
      }
    },
    {
      "url": "report/member/issue-finish",
      "methods": {
        "put": false,
        "post": false,
        "path": false,
        "delete": false,
        "patch": false
      }
    },
    {
      "url": "report/team/:team_id/issue-finish",
      "methods": {
        "put": false,
        "post": false,
        "path": false,
        "delete": false,
        "patch": false
      }
    },
    {
      "url": "report/weekly",
      "methods": {
        "put": false,
        "post": false,
        "path": false,
        "delete": false,
        "patch": false
      }
    },
    {
      "url": "report/:team_id/weekly",
      "methods": {
        "put": false,
        "post": false,
        "path": false,
        "delete": false,
        "patch": false
      }
    },
    {
      "url": "project/:project_id/member/invite",
      "methods": {}
    },

    {
      "url": "project/:project_id/assets/:asset_id/unwind",
      "methods": {
        "post": false,
        "delete": false,
        "patch": false,
        "put": false
      }
    },

    {
      "url": "message/:message_id",
      "methods": {
        "post": false,
        "delete": false,
        "patch": false
      }
    },

    {
      "url": "project/:project_id/issue/stat/test"
      "method": {
        "post": false,
        "delete": false,
        "patch": false
      }
    },
    {
      "url": "team/:team_id/member/:member_id"
      "method": {
        "patch": false
      }
    }
    {
      "url": "stream"
      "method": {
        "post": false
        "delete": false
        "put": false
        "patch": false
      }
    }
]