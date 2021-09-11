# CI/CD

The implementation of the CI/CD process was kept minimalistic, with the primary goal to illustrate key steps and moments.

It is inspired by trunk based development, but does not follow it religiously.

It, most importantly, tries to decouple the build from the deploy process, such that we are sure that the thing we test is the thing that we'll operate in production.

## Process description

Features are implemented in feature branches, which branch of from the `master` branch. 

When a pull request  is opened a **deployable artifact** is built.
This deployable artifact can then be used to deploy to multiple environments, such as dedicated environments for **integrated tests** as well as to do **performance testing** in a isolated setting. Having all infrastructure defined as code, works well to enable this.

Once automated testing has passed, the PR has been reviewed to a sufficient level, it is **merged into master**.

When merging to the trunk branch, there are two options to reduce the risk of introducing merge time inconsistencies.

1. Rely on github to force us to rebase all of the merge requests
2. Execute all the automatic checks against the trunk, now containing the merged code


The first option will be faster and in most cases probably safe enough. The build artifact can be then promoted up the environments and further validated before deploying to production, even further minimizing the risk of deploying a bug.

The second option is to be used in cases when the git provider can't enforce rebasing (ex. GitLab). Although it will be slower, the fact that it's automated means that it will not create any manual work for the development teams.


After merging to master, this pipeline **deploys** the built artifact to an environment called *staging*. It is an illustration of the continuous delivery principle.

Further propagation up the environment chain can be implemented by simply creating a job to manually trigger a deployment of the respective artifact to **production**.
The structure of the **terraform** that powers this is such that we only need to provide 2 input parameters, an artifact version and a target environment, making the deployment to additional environments relatively simple.
