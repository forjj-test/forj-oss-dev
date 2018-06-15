
multibranchPipelineJob('forj-oss-dev') {
  description('Folder for Project forj-oss-dev generated and maintained by Forjj. To update it use forjj update')
  branchSources {
      github {
          repoOwner('forjj-test')
          scanCredentialsId('github-user')
          repository('forj-oss-dev')
      }
  }
  orphanedItemStrategy {
      discardOldItems {
          numToKeep(20)
      }
  }
}
