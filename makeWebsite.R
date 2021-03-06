
## set up environment
library(rmarkdown)
library(yaml)

## Specify a YAML file that contains the files to be converted into a website
## The order of the files specified in the YAML file impact the order of links 
## presented in the footer navigation
makeWebsite <- function (yml.file, theme = "cerulean", highlight = "zenburn", verbose = FALSE) {

    ## input must be a string    
    stopifnot(!is.null(yml.file), is.character(yml.file))
    
    ## read yaml
    files <- yaml.load_file(yml.file)
    
    ## set up paths
    basePath <- paste0(getwd(), "/")
    
    ## output path
    output_directory <- "output"
    output_path <- paste0(basePath, output_directory, "/")
    
    if(!dir.exists(output_path)) 
        dir.create(output_path)
    
    ## include path
    include_directory <- "include"
    
    ## libs path
    libs_directory <- "libs"
    libs_path <- paste0(output_path, libs_directory, "/")
    
    ## template path
    template_directory <- "templates"
    template_path <- paste0(basePath, template_directory, "/")
    
    if(!dir.exists(template_path))
        dir.create(template_path)
    
    footer_template <- paste0(template_path, "/footer_template.html")
    
    ## create a list of output options
    output_options <- list()
    output_options$self_contained <- FALSE
    output_options$mathjax <- NULL
    
    for (i in 1:length(files)) {
        
        ## prepare the path to the input file
        input_path <- paste0(basePath, files[[i]]$filename)
        
        ## prepare the page-specific parameters
        ## This is used to generate the footers for each page
        params <- list()
        params$previous <- NULL
        if (i > 1) params$previous <- files[[i-1]]$filename
        
        params$current <- files[[i]]$filename
        
        params$nxt <- NULL
        if (i < length(files)) params$nxt <- files[[i+1]]$filename
        
        ## create page-specific footer by merging parameters into template and writing to disk
        tmp_include_file_base <- strsplit(files[[i]]$filename, ".Rmd")
        tmp_footer_path <- paste0(output_path, "include_", tmp_include_file_base, ".html")
        pandoc_template(metadata = params, 
                        template = footer_template, 
                        output = tmp_footer_path)
        
        ## render HTML pages for each file
        ## use the rendered footer as an include
        rmarkdown::render(input_path, 
                          output_format = html_document(
                              includes = includes(after_body = tmp_footer_path),
                              mathjax = NULL,
                              self_contained = FALSE,
                              theme = theme,
                              highlight = highlight,
                              lib_dir = libs_path),
                          output_options = output_options,
                          output_file =  NULL,
                          output_dir = output_path,
                          runtime = "static",
                          clean = TRUE,
                          params = NULL,
                          quiet = !verbose)
        
        print(paste("We are making a website using", files[[i]]$filename))    
    }
    
    print(paste0("Website complete! The files are here: ", output_path))
}