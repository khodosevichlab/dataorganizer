# dataorganizer

## Installation

```R
devtools::install("khodosevichlab/dataorganizer")
```

## Usage

### Basic structure

Package provides basic functionality for accessing your data.
By default, the package assume the following folder structure:

```
project
|- data_mapping.yml     # file with mapping of data folders (see below)
|
|- data/                # raw data, not changed once created. Examples: expression matrices, images for analysis.
|
|- metadata/            # data, relevant for the research, but not produced by it. It's much smaller than "data" 
|                       # and assumed to be stored in the git repo. Examples: list of gene markers or info about patients.
|
|- output/              # output of the project relevant by itself. Examples: cell annotation, paper figures.
|
|- cache/               # cache files, created to optimize long computations (mostly in .rds format).
...                     # the rest is assumed to be a normal R package and/or workflowr package
```

Though it's often desired not to store all data inside the package folder. To allow a user 
to specify the folder structure, `dataorganizer` uses `data_mapping.yml` file. There, paths
can be changed. **Note:** it's highly non-recommended to change paths to "metadata" and "output"
folders, as they are supposed to be a part of the project.

Example:

```yaml
folders:
  data: ~/data/Epilepsy/
  cache: ~/cache/Epilepsy
```

To access files in the folders one of the followint functions should be used:
- `DataPath(path)`
- `MetadataPath(path)`
- `OutputPath(path)`
- `CachePath(path)`

Example:

```R
DataPath("dir1", "file.mtx")
```
> [1] "/home/user/data/Epilepsy/dir1/file.mtx"

### Initialize project

To create the directories, run `CreateFolders` inside your project package

### Manual paths to datasets

It's often the case that some long paths are used more ofthen then the rest. Let's say,
we focus on the expression matrix from a single patient with path 
`"~/data/Epilepsy/patients/control/patient1/outs/count_matrix/cm.mtx"`. Using this path each 
time is annoying. To avoid this, the path can be saved in `data_mapping.yml`:

```yaml
folders:
  data: ~/data/Epilepsy/

datasets:
  c_p1_mtx: patients/control/patient1/outs/count_matrix/cm.mtx
  c_p2: patients/control/patient2/
```

Now we can run `DatasetPath` function:

```R
DatasetPath("c_p1_mtx")
```
    ##                                                                      c_p1_mtx
    ## "/home/user/data/Epilepsy/patients/control/patient1/outs/count_matrix/cm.mtx"

It can also be used for the folder paths:

```R
DatasetPath("c_p2", "outs/alignment.bam")
```
    ##                                                                     c_p2
    ## "/home/user/data/Epilepsy/patients/control/patient2//outs/alignment.bam"
