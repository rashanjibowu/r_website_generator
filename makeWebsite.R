
## set up environment
require(rmarkdown)
require(yaml)

## Specify a YAML file that contains the files to be converted into a website
## The order of the files specified in the YAML file impact the order of links
## presented in the footer navigation
## Input files cannot have an underscore in the filename
makeWebsite <- function (yml.file, theme = "cerulean", highlight = "zenburn", verbose = FALSE) {

    ## input must be a string
    stopifnot(!is.null(yml.file), is.character(yml.file))

    ## read yaml
    files <- yaml.load_file(yml.file)

    ## set up paths
    base_path <- paste0(getwd(), "/")

    ## include path
    include_directory <- "_includes"
    include_path <- paste0(base_path, include_directory, "/")
    before_body_include_path <- paste0(include_path, 'before_body.html')
    in_header_include_path <- paste0(include_path, 'in_header.html')

    ## generated includes path
    gen_includes_directory <- "_gen_includes"
    gen_includes_path <- paste0(base_path, gen_includes_directory, "/")
    if(!dir.exists(gen_includes_path))
        dir.create(gen_includes_path)

    ## libs path
    libs_directory <- "libs"
    libs_path <- paste0(base_path, libs_directory, "/")

    ## template path
    template_directory <- "_templates"
    template_path <- paste0(base_path, template_directory, "/")

    if(!dir.exists(template_path))
        dir.create(template_path)

    footer_template <- paste0(template_path, "/footer_template.html")

    for (i in 1:length(files)) {

        ## prepare the path to the input file
        ## Must read the .Rmd file
        input_path <- paste0(base_path, files[[i]]$filename)

        ## prepare the page-specific parameters
        ## This is used to generate the footers for each page
        params <- list()

        ## parse the parameters
        current_filename <- paste0(strsplit(files[[i]]$filename, ".Rmd"), ".html")
        params$current <- current_filename

        params$previous <- NULL
        if (i > 1) {
            previous_filename <- paste0(strsplit(files[[i-1]]$filename, ".Rmd"), ".html")
            params$previous <- previous_filename
            params$previous_desc <- files[[i-1]]$description
        }

        params$nxt <- NULL
        if (i < length(files)) {
            next_filename <- paste0(strsplit(files[[i+1]]$filename, ".Rmd"), ".html")
            params$nxt <- next_filename
            params$nxt_desc <- files[[i+1]]$description
        }

        ## create page-specific footer by merging parameters into template and writing to disk
        tmp_footer_include_path <- paste0(gen_includes_path, "include_", current_filename)
        pandoc_template(metadata = params,
                        template = footer_template,
                        output = tmp_footer_include_path)

        ## render HTML pages for each file
        ## use the rendered footer as an include
        rmarkdown::render(input_path,
                          output_format = html_document(
                              includes = includes(after_body = tmp_footer_include_path,
                                                  before_body = before_body_include_path,
                                                  in_header = in_header_include_path),
                              mathjax = NULL,
                              self_contained = FALSE,
                              theme = theme,
                              highlight = highlight,
                              lib_dir = "libs"),
                          output_options = output_options,
                          output_file =  current_filename,
                          output_dir = NULL,
                          runtime = "static",
                          clean = TRUE,
                          params = NULL,
                          quiet = !verbose)
        if(verbose)
            print(paste("We are making a website using", files[[i]]$filename))
    }

    if (verbose)
        print("Website complete! Check it out!")
}