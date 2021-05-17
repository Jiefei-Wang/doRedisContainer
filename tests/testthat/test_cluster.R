context("Testing the container")
library(foreach)
library(BiocParallel)
doTest <- requireNamespace("ECSFargateProvider")&&
    !is.null(aws.ecx::aws_get_access_key_id())

testForeach <- function(){
    res <- foreach(i = 1:2) %dopar%{
        Sys.info()["user"]
    }
    expect_true(all(res=="root"))
}
environment(testForeach) <- globalenv()

testBiocParallel <- function(){
    res <- bplapply(1:2,function(x)Sys.info()["user"])
    expect_true(all(res=="root"))
}

if(doTest){
    provider <- ECSFargateProvider::ECSFargateProvider()
    provider$clusterName = "doRedisContainerUnitTest"

    ## r-base doRedis backend
    container <- RedisWorkerContainer(image = "r-base", backend = "doRedis")
    cluster <- makeDockerCluster(cloudProvider = provider,
                                 workerContainer = container,
                                 workerNumber = 1L)
    expect_error(cluster$startCluster(), NA)
    testForeach()
    cluster$stopCluster()

    ## Bioconductor doRedis backend
    container <- RedisWorkerContainer(image = "bioconductor", backend = "doRedis")
    cluster <- makeDockerCluster(cloudProvider = provider,
                                 workerContainer = container,
                                 workerNumber = 1L)
    expect_error(cluster$startCluster(), NA)
    testForeach()
    cluster$stopCluster()

    ## r-base RedisParam backend
    container <- RedisWorkerContainer(image = "r-base", backend = "RedisParam")
    cluster <- makeDockerCluster(cloudProvider = provider,
                                 workerContainer = container,
                                 workerNumber = 1L)
    expect_error(cluster$startCluster(), NA)
    testBiocParallel()
    cluster$stopCluster()

    ## Bioconductor RedisParam backend
    container <- RedisWorkerContainer(image = "bioconductor", backend = "RedisParam")
    cluster <- makeDockerCluster(cloudProvider = provider,
                                 workerContainer = container,
                                 workerNumber = 1L)
    expect_error(cluster$startCluster(), NA)
    testBiocParallel()
    cluster$stopCluster()
}

