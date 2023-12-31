\name{mbbefd-distr}
\alias{mbbefd-distr}
\alias{mbbefd}
\alias{dmbbefd}
\alias{pmbbefd}
\alias{qmbbefd}
\alias{rmbbefd}
\alias{ecmbbefd}
\alias{mmbbefd}
\alias{tlmbbefd}

\alias{dmbbefd1}
\alias{dmbbefd2}


\alias{MBBEFD}
\alias{dMBBEFD}
\alias{pMBBEFD}
\alias{qMBBEFD}
\alias{rMBBEFD}
\alias{ecMBBEFD}
\alias{mMBBEFD}
\alias{tlMBBEFD}

\alias{dMBBEFD1}
\alias{dMBBEFD2}


\title{
The MBBEFD distribution (two parametrizations)
}
\description{
These functions perform probabilistic analysis as well 
as random sampling on the MBBEFD distribution:
the 1st parametrization MBBEFD(a,b) is implemented in <d,p,q,r>\code{mbbefd},
the 2nd parametrization MBBEFD(g,b) is implemented in <d,p,q,r>\code{MBBEFD}.
We also provide raw moments, exposure curve function and total loss.
}
\usage{

dmbbefd(x, a, b, log=FALSE)
pmbbefd(q, a, b, lower.tail = TRUE, log.p = FALSE)
qmbbefd(p, a, b, lower.tail = TRUE, log.p = FALSE)
rmbbefd(n, a, b)
ecmbbefd(x, a, b)
mmbbefd(order, a, b)
tlmbbefd(a, b)

dMBBEFD(x, g, b, log=FALSE)
pMBBEFD(q, g, b, lower.tail = TRUE, log.p = FALSE)
qMBBEFD(p, g, b, lower.tail = TRUE, log.p = FALSE)
rMBBEFD(n, g, b)
ecMBBEFD(x, g, b)
mMBBEFD(order, g, b)
tlMBBEFD(g, b)

}

\arguments{
\item{x, q}{
vector of quantiles.
}
\item{p}{
vector of probabilities.
}
\item{n}{
number of observations. If \code{length(n) > 1}, the length is take to be the number required.
}
\item{a, b, g}{
shape parameters. For \code{.mbbefd} functions, \code{g} is computed from \code{a}.
}
\item{order}{
order of the raw moment.
}
\item{log, log.p}{
logical; if \code{TRUE}, probabilities \code{p} are given as log(p).
}
\item{lower.tail}{
logical; if \code{TRUE} (default), probabilities are \eqn{P[X <= x]}, otherwise, \eqn{P[X> x]}.
}
  

}
\details{
it shall be remebered that \eqn{g=\frac{1}{p_1}=\frac{a+b}{\left(a+1\right)*b}}.
}
\value{
A numeric value or a vector.
}
\references{
BERNEGGER, STEFAN (1997). 
\emph{The Swiss Re Exposure Curves And The MBBEFD Distribution Class}, 
ASTIN Bulletin, 27(1), pp99-111, \doi{https://doi.org/10.2143/AST.27.1.563208}.
}
\author{
Giorgio Spedicato,
Dutang Christophe
}
\seealso{
\code{\link{swissRe}}, \code{\link{exposureCurve}}.
}
\examples{
#1st parametrization
#
aPar=0.2
bPar=0.04
rmbbefd(n=10,a=aPar,b=bPar) #for random generation
qmbbefd(p=0.7,a=aPar,b=bPar) #for quantiles
dmbbefd(x=0.5,a=aPar,b=bPar) #for density
pmbbefd(q=0.5,a=aPar,b=bPar) #for distribution function

#2nd parametrization
#
gPar=2
bPar=0.04
rMBBEFD(n=10,g=gPar,b=bPar) #for random generation
qMBBEFD(p=0.7,g=gPar,b=bPar) #for quantiles
dMBBEFD(x=0.5,g=gPar,b=bPar) #for density
pMBBEFD(q=0.5,g=gPar,b=bPar) #for distribution function


}

