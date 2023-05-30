README.md: README.Rmd R/*
	@Rscript -e "devtools::load_all(); rmarkdown::render('README.Rmd')"
	@rm README.html
