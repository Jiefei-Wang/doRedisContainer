###########################
## container provider
###########################
#' The doRedis container object
#'
#' The doRedis container object, it is used by the DockerParallel package to create
#' the worker container
#'
#' @exportClass doRedisContainer
.doRedisContainer <- setRefClass(
    "doRedisContainer",
    contains = "RedisContainer"
)
