#' Configure the doRedis worker container
#'
#' Configure the doRedis worker container
#'
#' @inheritParams DockerParallel::configWorkerContainerEnv
#' @return A `doRedisContainer` object
#' @export
setMethod("configWorkerContainerEnv", "doRedisContainer",
          function(container, cluster, workerNumber, verbose = FALSE){
              container <- callNextMethod()
              container$environment$backend <-
                  "doRedis"
              container
          }
)



#' Register the foreach doRedis backend
#'
#' Register the foreach doRedis backend. The registration will be done via
#' `doRedis::registerDoRedis`
#'
#' @inheritParams DockerParallel::registerParallelBackend
#' @param ... The additional parameter that will be passed to `doRedis::registerDoRedis`
#' @return No return value
#' @export
setMethod("registerParallelBackend", "doRedisContainer",
          function(container, cluster, verbose = FALSE, ...){
              queue <- .getJobQueueName(cluster)
              password <- .getServerPassword(cluster)
              serverPort <- .getServerPort(cluster)
              if(.getServerClientSameLAN(cluster)){
                  serverClientIP <- .getServerPrivateIp(cluster)
              }else{
                  serverClientIP <- .getServerPublicIp(cluster)
              }

              if(is.null(serverClientIP)){
                  stop("Fail to find the server Ip")
              }
              stopifnot(!is.null(serverPort))

              doRedis::registerDoRedis(queue=queue,
                                       host = serverClientIP,
                                       password = password,
                                       port = serverPort, ...)
              invisible(NULL)
          })


