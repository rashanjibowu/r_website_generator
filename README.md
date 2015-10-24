## Welcome to R Website Generator

The R Website Generator enables R users to generate full websites from RMarkdown files using a yaml file.

## Usage

It's quite simple

### 1. Write your content

All of the features of RMarkdown and pandoc still work, so you can write your content the way you always have!

### 2. Create a YAML file

Below is an example.yaml file.

```{yaml}
- filename: file1.Rmd
  description: First file
  url: relative/path/to/file1.html
- filename: file2.Rmd
  description: Second file
  url: relative/path/to/file2.html
- filename: file3.Rmd
  description: Third file
  url: relative/path/to/file3.html
```

**Note:** Only the filenames are necessary. However, if you include the description and URLs, you'll have fully functional navigation in the footer! Plus, the order in which the filenames appear specifies the navigational flow.

### 3. Run `makeWebsite()`

```{r}
makeWebsite("example.yaml",[theme], [highlight], [verbose])
```
The first parameter is the yaml file that defines your website structure.

**theme**: The bootstrap theme to use when rendering your website
**highlight**: The syntax highlight library to use
**verbose**: Whether to display the interim steps in the process

### 4. Check out your new website!

Your website has been written to an `output/` directory.