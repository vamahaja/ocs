import jenkins.model.*
def instance = Jenkins.getInstance()

// Change EXECUTORS before executing script
instance.setNumExecutors(${EXECUTORS})
