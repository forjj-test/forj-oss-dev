
multibranchPipelineJob('forjj-examples') {
  description('Folder for Project forjj-examples generated and maintained by Forjj. To update it use forjj update')
  branchSources {
      github {
          repoOwner('forjj-test')
          scanCredentialsId('github-user')
          repository('forjj-examples')
      }
  }
  orphanedItemStrategy {
      discardOldItems {
          numToKeep(20)
      }
  }
}
