% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/parallel_blast.R
\name{parallel_blast}
\alias{parallel_blast}
\title{Run BLAST Searches in Parallel}
\usage{
parallel_blast(
  btype = "blastn",
  dbase,
  qry,
  taxid = FALSE,
  report = TRUE,
  ncores = 2,
  numt = 1,
  ...
)
}
\arguments{
\item{btype}{A string indicating the BLAST search type (e.g., \code{"blastn"}). Default is \code{"blastn"}.}

\item{dbase}{The path to the BLAST database file to be used in the search.}

\item{qry}{A FASTA file containing the query sequences.}

\item{taxid}{Logical. If \code{TRUE}, assumes taxonomy IDs were added during database creation and appends them to results.
Default is \code{FALSE}.}

\item{report}{Logical. If \code{TRUE} (default), a report is generated and saved in the \verb{outputs/table/} directory.}

\item{ncores}{Integer. Number of cores to use for parallel processing. Default is \code{2}.}

\item{numt}{Integer. Passed to internal calls, typically corresponds to the number of threads for \code{blastn}. Default is \code{1}.}

\item{...}{Additional arguments passed to the internal BLAST wrapper function.}
}
\value{
A data frame with the combined BLAST search results from all cores.
}
\description{
This function performs BLAST searches in parallel using the \code{foreach} and \code{doParallel} packages.
It automatically splits the input query FASTA file into chunks, distributes them across the specified
number of cores, and then combines the results. If only one core is specified, it runs a regular search
using an internal wrapper.
}
\examples{
\dontrun{
# Run a parallel BLAST search with 4 cores
parallel_blast(
  btype = "blastn",
  dbase = "my_database",
  qry = "queries.fasta",
  taxid = TRUE,
  report = TRUE,
  ncores = 4,
  numt = 1
)
}

}
