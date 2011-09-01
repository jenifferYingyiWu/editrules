#' Replace a variable by a value in a set of edits.
#'
#' @param E \code{\link{editmatrix}} or \code{\link{editarray}}
#' @param var \code{character} with name(s) of variable(s) to substitute
#' @param value vector with value(s) of variable(s)
#' @param ... arguments to be passed to or from other methods
#' @return \code{E}, with variables replaced by values
#' @export
substValue <- function(E, var, value, ...){ 
    UseMethod("substValue")
}


#' Reduce an editmatrix by substituting a variable
#'
#' Given a set of linear restrictions \eqn{E: {\bf Ax}\odot {\bf b}} with \eqn{\odot\in\{<,\leq,==\}},
#' and matrix \eqn{{\bf A}} with columns \eqn{{\bf a}_1,{\bf a}_2,\ldots,{\bf a}_n}.
#' Substituting variable \eqn{x_j} with a value \eqn{\tilde{\bf x}_j} means setting \eqn{{\bf a}_j=0}
#' and \eqn{{\bf b}={\bf a}_j\tilde{x}_j}.
#'
#' Note that the resulting \code{\link{editmatrix}} may be inconsistent because of inconsistencies in
#' \eqn{\tilde{\bf x}}.
#'
#' @method substValue editmatrix
#' @param remove \code{logical} should variable columns be removed from editmatrix?
#'
#' @rdname substValue 
#' @export
substValue.editmatrix <- function(E, var, value, remove=FALSE, ...){
    v <- match(var, getVars(E), nomatch=0)
    if (any(v==0)){
        warning("Parameter var (", var[v==0], ") is not a variable of editmatrix E")
    }
    v <- v[v != 0]
    ib <- ncol(E)
    E[,ib] <- E[ ,ib] - E[ ,v]%*%value
    
    if (remove)
        E <- E[,-v, drop=FALSE]
    else 
        E[,v] <- 0
        
    E[!isObviouslyRedundant.editmatrix(E),]    
}



#' Substitute a value in an editarray
#'
#' Multiple replacements is not yet implemented.
#'
#' @method substValue editarray
#'
#'
#' @rdname substValue
#' @export
substValue.editarray <- function(E, var, value, ...){
# TODO: make this work for multiple variables and values.
    J <- getInd(E)[[var]]
    sep=getSep(E)
    value <- paste(var,value,sep=sep)
    ival <- intersect(which(colnames(E) == value), J) 
    if ( length(ival) != 1 ) 
        stop(paste("Variable ", var,"not present in editarray or cannot take value",value))
    ii <- setdiff(J,ival)
    A <- getArr(E)
    A[,ii] <- FALSE
    I <- A[,ival]
    neweditarray(E=A[I,,drop=FALSE], ind=getInd(E), sep=sep, levels=getlevels(E))
}
