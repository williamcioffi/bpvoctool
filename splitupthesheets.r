# split up the detection spreadsheet

a <- read.table('bp_det_onslo.csv', header = TRUE, sep = ',')
u_deploy <- unique(a$deploy)
n_deploy <- length(u_deploy)

for(i in 1:n_deploy) {
	curdep <- u_deploy[i]
	dese <- which(a$deploy == curdep)
	
	outfilename <- paste(curdep, '.csv', sep = '')
	out <- a[dese, 1:12]
	
	write.table(out, outfilename, row.names = FALSE, sep = ',')
}