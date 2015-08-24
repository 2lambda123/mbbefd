
fitDR <- function(x, dist, method="mle", form.arg=NULL, start=NULL, ...)
{
  if(any(x < 0 | x > 1))
    stop("Values outside [0,1] are not supported in fitDR.")
  method <- match.arg(method, c("mle", "mme", "qme", "mge"))
  dist <- match.arg(dist, c("oiunif", "oistpareto", "oibeta", "oigbeta", "mbbefd", "MBBEFD"))
  
  if(dist == "mbbefd")
  {
    initparmbbefd <- list(list(a=-1/2, b=2), list(a=2, b=1/2))
    require(alabama)
    
    if(method == "mle")
    {
      #wrap gradient -LL to match the call by fitdist
      grLL <- function(x, fix.arg, obs, ddistnam) -grLLfunc(obs=obs, theta=x, dist="mbbefd")
      
      #domain : (a,b) in (-1, 0) x (1, +Inf)
      alabama1 <- fitdist(x, distr="mbbefd", start=initparmbbefd[[1]], 
                        custom.optim= constrOptim.nl, hin=constrmbbefd, method="mle",
                        control.outer=list(trace= FALSE), gr=grLL)
      #domain : (a,b) in (0, +Inf) x (0, 1)
      alabama2 <- fitdist(x, distr="mbbefd", start=initparmbbefd[[2]], 
                        custom.optim= constrOptim.nl, hin=constrmbbefd, method="mle",
                        control.outer=list(trace= FALSE), gr=grLL)
      
      if(alabama1$loglik > alabama2$loglik)
        f1 <- alabama1
      else
        f1 <- alabama2  
      #computes Hessian of -LL at estimate values
      f1hess <- -heLLfunc(obs=x, theta=f1$estimate, dist="mbbefd")
      
      if(all(!is.na(f1hess)) && qr(f1hess)$rank == NCOL(f1hess)){
        f1$vcov <- solve(f1hess)
        f1$sd <- sqrt(diag(f1$vcov))
        f1$cor <- cov2cor(f1$vcov)
      }#otherwise it is already at NA from fitdist
      
      class(f1) <- c("DR", class(f1))
    }else
      stop("not yet implemented")
  }else if(dist == "MBBEFD")
  {
    stop("not yet implemented")
  }else if(dist == "oiunif")
  {
    if(is.null(start))
      start=list(p1=etl(x))
    
    #print(LLfunc(x, start$p1, dist))
    f1 <- fitdist(x, distr=dist, method=method, start=start,
                  lower=0, upper=1, ..., optim.method="Brent") #, control=list(trace=6, REPORT=1)
    
    #gof stat
    f1$loglik <- LLfunc(obs=x, theta=f1$estimate, dist=dist)
    npar <- length(f1$estimate)
    f1$aic <- -2*f1$loglik+2*npar
    f1$bic <- -2*f1$loglik+log(f1$n)*npar
    
    f1$vcov <- rbind(cbind(as.matrix(f1$vcov), rep(0, npar-1)), 
                     c(rep(0, npar-1), p1*(1-p1)))
    dimnames(f1$vcov) <- list(names(f1$estimate), names(f1$estimate))
    
    f1$sd <- sqrt(diag(f1$vcov))
    f1$cor <- cov2cor(f1$vcov)
    class(f1) <- c("DR", class(f1))
    
  }else if(dist %in% c("oistpareto", "oibeta", "oigbeta")) #one-inflated distr
  {
    p1 <- etl(x)
    xneq1 <- x[x != 1]
    distneq1 <- substr(dist, 3, nchar(dist))
    
    #print(dist)
    #print(distneq1)
    
    uplolist <- list(upper=Inf, lower=0)
    if(is.null(start))
    {
      if(distneq1 == "stpareto")
      {
        start <- list(a=1)               
      }else if(distneq1 == "beta")
      {
        n <- length(xneq1)
        m <- mean(xneq1)
        v <- (n - 1)/n*var(xneq1)
        aux <- m*(1-m)/v - 1
        start <- list(shape1=m*aux, shape2=(1-m)*aux)
        
      }else if(distneq1 == "gbeta")
      {
        start <- list(shape0=1, shape1=1, shape2=1)
      }else
        stop("wrong non-inflated distribution.")
    }else
    {
      if(distneq1 == "stpareto")
      {
        start <- start["a"]               
      }else if(distneq1 == "beta")
      {
        start <- start[c("shape1", "shape2")]
      }else if(distneq1 == "gbeta")
      {
        start <- start[c("shape0", "shape1", "shape2")]
      }else
        stop("wrong non-inflated distribution.")
    }
    #print(start)
      
    if(method == "mle")
    {
      f1 <- fitdist(xneq1, distr=distneq1, method="mle", start=start, 
                  lower=uplolist$lower, upper=uplolist$upper, ...)
      if(f1$convergence != 0)
      {
         stop("error in convergence when fitting data.")
      }else
      {
        f1$estimate <- c(f1$estimate, p1=p1) 
        f1$n <- length(x)
        f1$distname <- dist
        f1$data <- x
        
        #gof stat
        f1$loglik <- LLfunc(obs=x, theta=f1$estimate, dist=dist)
        npar <- length(f1$estimate)
        f1$aic <- -2*f1$loglik+2*npar
        f1$bic <- -2*f1$loglik+log(f1$n)*npar
        
        f1$vcov <- rbind(cbind(as.matrix(f1$vcov), rep(0, npar-1)), 
                         c(rep(0, npar-1), p1*(1-p1)))
        dimnames(f1$vcov) <- list(names(f1$estimate), names(f1$estimate))
        
        f1$sd <- sqrt(diag(f1$vcov))
        f1$cor <- cov2cor(f1$vcov)
        class(f1) <- c("DR", class(f1))
      } 
      
    }else
    {
      stop("not yet implemented.")
    }
    
  }else
    stop("Unknown distribution for destruction rate models.")
  
  f1
}

#likelihood function
LLfunc <- function(obs, theta, dist)
{
  dist <- match.arg(dist, c("oiunif", "oistpareto", "oibeta", "oigbeta", "mbbefd", "MBBEFD"))
  ddist <- paste0("d", dist)
  sum(log(do.call(ddist, c(list(obs), as.list(theta)) ) ) )
}

#gradient of the likelihood function
grLLfunc <- function(obs, theta, dist)
{
  dist <- match.arg(dist, c("mbbefd", "MBBEFD")) 
  if(dist == "mbbefd")
  {
    g1 <- function(x, theta)
    {
      a <- theta[1]; b <- theta[2]
      ifelse(x == 1, (b-1)/(a+1)/(a+b), (2*a+1)/(a*(a+1)) - 2/(a+b^x))
    }
    g2 <- function(x, theta)
    {
      a <- theta[1]; b <- theta[2]
      ifelse(x == 1, a/(b*(a+b)), -x/b+1/(b*log(b))+2*a*x/(b*(a+b^x)))
    }
    c(sum(sapply(obs, g1, theta=theta)), sum(sapply(obs, g2, theta=theta)))
  }else
  {
    stop("not yet implemented.")
  }
}

#Hessian of the likelihood function
heLLfunc <- function(obs, theta, dist)
{
  dist <- match.arg(dist, c("mbbefd", "MBBEFD")) 
  if(dist == "mbbefd")
  {
    h11 <- function(x, theta)
    {
      a <- theta[1]; b <- theta[2]
      ifelse(x == 1, 1/(a+b)^2-1/(a+1)^2, 2/(a+b^x)^2-1/a^2-1/(a+1)^2)
    }
    h21 <- function(x, theta)
    {
      a <- theta[1]; b <- theta[2]
      ifelse(x == 1, 1/(a+b)^2, 2*x*b^(x-1)/(a+b^x)^2)
    }
    h22 <- function(x, theta)
    {
      a <- theta[1]; b <- theta[2]
      ifelse(x == 1, 1/(a+b)^2-1/b^2, 
             x/b^2-(log(b)+1)/(b^2*log(b)^2)-2*a*x/(b^2*(a+b^x))-2*a*x^2*b^x/(b^2*(a+b^x)^2))
    }
    rbind(c(sum(sapply(obs, h11, theta=theta)), sum(sapply(obs, h21, theta=theta))),
    c(sum(sapply(obs, h21, theta=theta)), sum(sapply(obs, h22, theta=theta))))
  }else
  {
    stop("not yet implemented.")
  }
}

#constraint function for MBBEFD(a,b)
constrmbbefd <- function(x, fix.arg, obs, ddistnam)
{
  x[1]*(1-x[2]) #a*(1-b) >= 0
}

#constraint function for MBBEFD(g,b)
constrMBBEFD <- function(x, fix.arg, obs, ddistnam)
{
  c(x[1]-1, x[2]) #g >= 1, b > 0
}