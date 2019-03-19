##Pig Cheat Sheet
pig 
pig -x 		mapreduce mode 
pig -brief 	stop timestamps from being logged
pig.auto.local.enabled=true	which is an optimization that runs small jobs locally if the input is less than 100 MB 
pig.auto.local.input.maxbytes=		default 100,000,000 and no more than one reducer is being used.



-- max_temp.pig: Finds the maximum temperature by year
records = LOAD '/tmp/sample.txt'        --file must be loaded on HDFS
            AS (year:chararray, temperature:int, quality:int);  
            --define new relation 
filtered_records = FILTER records BY temperature != 9999 AND
                    quality IN (0, 1, 4, 5, 9);
                    --result
                    (1950,0,1)
                    (1950,22,1)
                    (1950,-11,1)
                    (1949,111,1)
                    (1949,78,1)
grouped_records = GROUP filtered_records BY year;       
                --result 
                (1949,{(1949,111,1),(1949,78,1)})
                (1950,{(1950,0,1),(1950,22,1),(1950,-11,1)})

grunt> DESCRIBE grouped_records;
grouped_records: {group: chararray,filtered_records: {year: chararray,
                    temperature: int,quality: int}}
max_temp = FOREACH grouped_records GENERATE group,
                        MAX(filtered_records.temperature);
DUMP max_temp;      --list all tuples 
                    (1949,111)
                    (1950,22)

describe records; 
--result: records: {year: chararray,temperature: int,quality: int}

/*
ILLUSTRATE operator
    Pig provides a tool for generating a reasonably complete
    and concise sample dataset. Here is the output from running ILLUSTRATE on our dataset
    (slightly reformatted to fit the page)
*/

grunt> ILLUSTRATE max_temp;
-------------------------------------------------------------------------------
| records | year:chararray | temperature:int | quality:int |
-------------------------------------------------------------------------------
| | 1949 | 78 | 1 |
| | 1949 | 111 | 1 |
| | 1949 | 9999 | 1 |
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
| filtered_records | year:chararray | temperature:int | quality:int |
-------------------------------------------------------------------------------
| | 1949 | 78 | 1 |
| | 1949 | 111 | 1 |
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
| grouped_records | group:chararray | filtered_records:bag{:tuple( |
year:chararray,temperature:int, |
quality:int)} |
-------------------------------------------------------------------------------
| | 1949 | {(1949, 78, 1), (1949, 111, 1)} |
-------------------------------------------------------------------------------
---------------------------------------------------
| max_temp | group:chararray | :int |
---------------------------------------------------
| | 1949 | 111 |
---------------------------------------------------



/*
* Description of my program spanning
* multiple lines.
*/
A = LOAD '/tmp/A';
B = LOAD '/tmp/B';
C = JOIN A BY $0, /* ignored */ B BY $1;
DUMP C;

-- Case Sensitivity 
-- Pig Latin has mixed rules on case sensitivity. Operators and commands are not case
-- sensitive (to make interactive use more forgiving); however, aliases and function names
-- are case sensitive


-- multiquery execution

-- Because DUMP is a diagnostic tool, it will always trigger execution. However, the STORE
-- command is different. In interactive mode, STORE acts like DUMP and will always trigger
-- execution (this includes the run command), but in batch mode it will not (this includes
-- the exec command). The reason for this is efficiency. In batch mode, Pig will parse the
-- whole script to see whether there are any optimizations that could be made to limit the
-- amount of data to be written to or read from disk. Consider the following simple
-- example
A = LOAD 'input/pig/multiquery/A';
B = FILTER A BY $1 == 'banana';
C = FILTER A BY $1 != 'banana';
STORE B INTO 'output/b';
STORE C INTO 'output/c';
-- Relations B and C are both derived from A, so to save reading A twice, Pig can run this
-- script as a single MapReduce job by reading A once and writing two output files from
-- the job, one for each of B and C. This feature is called multiquery execution.

-- In previous versions of Pig that did not have multiquery execution, each STORE statement
-- in a script run in batch mode triggered execution, resulting in a job for each STORE
-- statement. It is possible to restore the old behavior by disabling multiquery execution
-- with the -M or -no_multiquery option to pig



Loading and storing LOAD                Loads data from the filesystem or other storage into a relation
                    STORE               Saves a relation to the filesystem or other storage
                    DUMP (\d)           Prints a relation to the console
Filtering           FILTER              Removes unwanted rows from a relation
                    DISTINCT            Removes duplicate rows from a relation
                    FOREACH...GENERATE  Adds or removes fields to or from a relation
                    MAPREDUCE           Runs a MapReduce job using a relation as input
                    STREAM              Transforms a relation using an external program
                    SAMPLE              Selects a random sample of a relation
                    ASSERT              Ensures a condition is true for all rows in a relation; otherwise, fails
Grouping and joining JOIN               Joins two or more relations
                    COGROUP Groups the data in two or more relations
                    GROUP Groups the data in a single relation
                    CROSS Creates the cross product of two or more relations
                    CUBE Creates aggregations for all combinations of specified columns in a relation
Sorting             ORDER Sorts a relation by one or more fields
                    RANK Assign a rank to each tuple in a relation, optionally sorting by fields first
                    LIMIT Limits the size of a relation to a maximum number of tuples
Combining and splitting UNION Combines two or more relations into one
                    SPLIT Splits a relation into two or more relations
List of Operators
    DESCRIBE (\de) Prints a relation’s schema
    EXPLAIN (\e) Prints the logical and physical plans
    ILLUSTRATE (\i) Shows a sample execution of the logical plan, using a generated subset of the input


Table 16-3. Pig Latin macro and UDF statements
Statement Description
    REGISTER Registers a JAR file with the Pig runtime
    DEFINE Creates an alias for a macro, UDF, streaming script, or command specification
    IMPORT Imports macros defined in a separate file into a script


Table 16-4. Pig Latin commands
Hadoop filesystem   cat Prints the contents of one or more files
                    cd Changes the current directory
                    copyFromLocal Copies a local file or directory to a Hadoop filesystem
                    copyToLocal Copies a file or directory on a Hadoop filesystem to the local filesystem
                    cp Copies a file or directory to another directory
                    fs Accesses Hadoop’s filesystem shell
                    ls Lists files
                    mkdir Creates a new directory
                    mv Moves a file or directory to another directory
                    pwd Prints the path of the current working directory
                    rm Deletes a file or directory
                    rmf Forcibly deletes a file or directory (does not fail if the file or directory does not exist)
Hadoop MapReduce    kill Kills a MapReduce job
Utility             clear Clears the screen in Grunt
                    exec Runs a script in a new Grunt shell in batch mode
                    help Shows the available commands and options
                    history Prints the query statements run in the current Grunt session
                    quit (\q) Exits the interpreter
                    run Runs a script within the existing Grunt shell
                    set Sets Pig options and MapReduce job properties
                    sh Runs a shell command from within Grunt


grunt> set debug on

job.name option, which gives a Pig job a meaningful name, making it easier to pick out your
Pig MapReduce jobs when running on a shared Hadoop cluster

-- ##difference between using exec and run 
    -- There are two commands in Table 16-4 for running a Pig script, exec and run. The
    -- difference is that exec runs the script in batch mode in a new Grunt shell, so any aliases
    -- defined in the script are not accessible to the shell after the script has completed. On
    -- the other hand, when running a script with run, it is as if the contents of the script had
    -- been entered manually, so the command history of the invoking shell contains all the
    -- statements from the script. Multiquery execution, where Pig executes a batch of statements in one go is used only by exec, not run.


    ##Pig Cheat Sheet
pig 
pig -x 		mapreduce mode 
pig -brief 	stop timestamps from being logged
pig.auto.local.enabled=true	which is an optimization that runs small jobs locally if the input is less than 100 MB 
pig.auto.local.input.maxbytes=		default 100,000,000 and no more than one reducer is being used.



-- max_temp.pig: Finds the maximum temperature by year
records = LOAD 'input/ncdc/micro-tab/sample.txt'
AS (year:chararray, temperature:int, quality:int);
filtered_records = FILTER records BY temperature != 9999 AND
quality IN (0, 1, 4, 5, 9);
grouped_records = GROUP filtered_records BY year;
max_temp = FOREACH grouped_records GENERATE group,
MAX(filtered_records.temperature);
DUMP max_temp;