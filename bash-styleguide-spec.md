# BASH STYLE GUIDE

```
## general recommendations 
## documentation&&commenting guidelines 
## headline that is parsable into a TOC
## variables 
## functions 
## conditions 
## arithmetic calculations 
## command substitution 
## linebreaking 
## includes 
## IDIOMS 
```





## general recommendations ##################################################################################
- formatting descriptions here often make use of regex syntax,keep that in mind
- ALWAYS use a syntax checker during development
    - for vim use syntastic, at least with shellcheck
        - `apt install vim-syntastic`
        - `apt install shellcheck`
    - possible are also `bashate` and `checkbashisms`
    - more info on these in vim after installing syntastic: `:h syntastic-checkers-sh`
- omit whitespace and empty lines whereever possible
    - it actually looks cleaner this way
    - and becomes easier readable over time
- split things semantically sensible to improve readability,always put `|`'s on as first element on new line
- when using constructs consisting of multiple keywords (conditionals,loops) usually put keywords on own lines
- indentation is four spaces, no exceptions
- linelength should be 115 chars,maximum



EXAMPLES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~bash
#keywords have to go on different lines
while (SOMETHING)
do
	WHATEVER
done

#############################################################################################################

#COMPARE THIS: shortcircuiting applied and good semantic variable handling (RIGHT)
local _currentdir=""  ## always null vars,and dont quote for-loop var in next line!
for _currentdir in ${dirs_to_cleanup}
do
    local _path="${_currentdir}"/"${_SOME_ID}"
    if [[ -d "${_path}" ]]
    then
        log_date "Cleaning up old files in ${_path}"
        rm "${_path}"/*||error_message
    else
        mkdir -p "${_path}"||error_message
    fi
done

#TO THAT: (WRONG)
for dir in ${dirs_to_cleanup}
do
  if [[ -d "${dir}/${SOME_ID}" ]]; then
    log_date "Cleaning up old files in ${dir}/${SOME_ID}"
    rm "${dir}/${SOME_ID}/"*
    if [[ "$?" -ne 0 ]]; then
      error_message
    fi
  else
    mkdir -p "${dir}/${SOME_SID}"
    if [[ "$?" -ne 0 ]]; then
      error_message
    fi
  fi
done
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~






## documentation&&commenting guidelines #####################################################################
- use `fixme` at the end of comments if something needs doing there and wasnt done yet
- use ` ... ` string in comments as placeholder if needed
    - delimited by spaces if there something leading up to/following by it
    - intended usecase it being some kind of wildcard placeholder instead of i.e. `WHATEVER_HAPPENS_HERE` et al.
- use CAPS with snakecase for describing pseudocode that has no reference to code functions/language keywords
    - `DESCRIBE_THINGS_THIS_WAY` instead of quoting/angle brackets/whatever  to save chars and improve readability
- at the end of the line comments: `...  ## YOUR_COMMENT` (separated by two spaces, double `##`, space)
- omit docstring-type documentation if documentation-needs can be satisfied through expressive var/function names
- otherwise:
    - if var documentation cannot be put on the end of the same line,the same approach as for functions applies
    - func documentation goes above the function and has to be a consecutive block
        - empty lines have to have a single `#` and not be completely empty
    - no empty line between comment block and function definition
    - these blocks usually have the format of `^\t*#TEXT_COMES_WITHOUT_A_SPACE`
        - indent as needed,ofc
        - that way,a TOC can be generated from comments having the format `^## after a space some kind of headline"
        - TOC / TOC generation will not be explained here for now fixme



EXAMPLES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~bash
some code  ## some comment
#another comment
## headline that is parsable into a TOC
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~






## variables ################################################################################################
- always use descriptive names,name length doesnt matter,if code becomes self-documenting,do  whereever possible
- are always prefixed by a single underscore for better readability
    - they are clearly distinguished from functions/executables
    - they are clearly distinguished from pseudocode in documentation
    - single underscores are only used for prefixing variables - renaming variable via search/replace works
    - only exception are `ENVIRONMENT_VARIABLES` (these dont get a leading underscore)
        - these are CAPS and can possibly have underscores in them
            - still these are used so rarely that they dont clash with `PSEUDO_CODE_DEFINITIONS_USED_ELSEWHERE`
- in functions always use local variables
    - all lowercase
    - no Pascal/Camel/snake-casing
    - at least defined/set to as empty string when not immediately defined with data
    - not immediately defined when command substitution output is used,but definition happens on the same line
    - otherwise always set them directly if possible
    - exception is when defining these outside of loops et al.,when they have to be cleared before their usage
- toplevel variables outside of functions
    - are nonlocal (no `local` keyword in front of them)
    - basically these should always by constants (use `readonly` keyword,not `declare -r` for making constants)
    - are written in CAPS,but also with `_`-prefix
    - are written snake-cased
- the letter-/snake-casing/`_`-prefixing definitions are to make clearly visible when 'dummy data' is used
    - this is to easier discern documentation parts where stuff is described via pseudocode
    - `THIS_IS_SOME_PSEUDOCODE_EXAMPLE_TO_BE_USED_WITHIN_DOCS`: CAPS,snake-case,no leading underscore
    - that way,clutches can be omitted while staying unanimous,but
        - not having to use more chars than absolutely needed
        - not having to use angle brackets,as they are reserved in bash
        - not having to use quotes as escaping these is just crap and needs to be avoided where/whenever possible
- there are two types of content: integers and strings
    - referencing these can made easily discernible by enclosing in double quotes
    - integers: omit quotes
    - strings: always use quotes
- though you better be careful with quoting in for loops,always rely on a syntax checker for that
- when constructing pathnames out of strings+variables, NEVER enclose `/`'es withing the variables
    - these have to be written expliclitly
    - through that convention you never forget them as easily otherwise
    - also dont quote two following variables with a `/` in between in the same pair of variables
        - DO: `"${_var1}"/"${_var2}"`
        - DONT: `"${_var1}/${_var2}"`
        - EXCEPTION: this is not just used for creation of a single pathname but part of a much larger string
            - sounds stupid, but that way you dodge having to descend down into indentation hell
    - always construct paths only once, dont repeat these `"${_var1}"/"${_var2}"` all over the place
        - instead construct once and save to a properly named variable which is then used afterwards
        - ALWAYS DO THIS. NO EXCEPTIONS. mangled paths are among the main sources scripts break/dont work.

- dereferencing variables is always done within braces
    - because this improves readability
    - and it makes it easier when deleting pre/suffixes or search/replacing in the variable's data
    - except for positional arguments
    - usually for running indexes (like `i`) too,but there also always use `${i}` as it improves readability
    - except when used within arithmetic expansion aka `$(( ... ))`
    - fixme



EXAMPLES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~bash
local _normalvar="some_string"  ## local vars are always prefixed by '_'
local _outputfromcommandsubstitution="";_outputfromcommandsubstitution="$(some_command_in_here)"

readonly _SOME_STRING_CONSTANT_TO_BE_USED_BY_DIFFERENT_FUNCTIONS="3.141592"
readonly _SOME_INTEGER_CONSTANT_WITHOUT_QUOTES_FOR_COMPARISON=1234124123413421
_GLOBAL_VAR_REFERENCING_STRINGS_OUTSIDE_OF_FUNCTIONS="${_SOME_STRING_CONSTANT_TO_BE_USED_BY_DIFFERENT_FUNCTIONS}"
_GLOBAL_VAR_REFERENCING_INTS_OUTSIDE_OF_FUNCTIONS=${_SOME_INTEGER_CONSTANT_WITHOUT_QUOTES_FOR_COMPARISON}
local _varreferencingstringsinfunctions="${_SOME_STRING_CONSTANT_TO_BE_USED_BY_DIFFERENT_FUNCTIONS}"
local _varreferencingintsinfunctions=${_SOME_INTEGER_CONSTANT_WITHOUT_QUOTES_FOR_COMPARISON}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~






## functions ################################################################################################
- use functions whereever it makes sense and is possible
- IF OUTSOURCING SOME CODE PART INTO A FUNCTION IMPROVES READABILITY, DO IT
- IF OUTSOURCING SOME CODE PART INTO A FUNCTION SELF-DOCUMENTS YOUR CODE, DO IT
- IF OUTSOURCING SOME CODE PART INTO A FUNCTION MODULARIZES YOUR CODE AND CAN BE REUSED, DO IT
- IF OUTSOURCING SOME CODE PART INTO A FUNCTION REMOVES REPETITION, DO IT
- IF OUTSOURCING SOME CODE PART INTO A FUNCTION LEADS TO THINGS ONLY BEING DEFINED IN ONE PLACE, DO IT
- there are absolutely no exceptions to these rules
    - sticking to these incrementally and inevitably leads to better and more readable code
    - any additional complexity pales in comparison to the gains you get from following these rules
- prefix helper functions (which are never intended to be used externally but only locally in same file) by `__`
    - double underscores are only used for prefixing helper functions - renaming these via search/replace works
- `local` variables can only be used within functions,and these should be put to use when/whereever possible
- `^_functionname() {\n ... \n}` format is mandatory (always lowercase,never snake-case)
    - start at first column with no spaces in between (except if defined within another function,ofc)
    - immeadiately follow up with the parentheses pair
    - space between opening brace is mandatory
        - so one can `grep` all function names from a source code file directly via `fgrep '() {' FILE`
    - dont use the `function` keyword,ever
- small functions can also be defined on a single line for brevity
    - always put a space after the opening brace
    - never put a space,but the semicolon instead,before the closing brace



EXAMPLES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~bash
__addtopath() {
    [[ -d "$1" ]]&&[[ ":${PATH}:" != *":$1:"* ]]&&PATH="$1${PATH:+:"${PATH}":}"
    PATH="$(echo "${PATH}"|sed 's/^:*//g;s/:*$//g')"
    export PATH
}

#############################################################################################################

mkcd() { if [[ $# -eq 0 ]];then pushd "$(mktemp -d)";else mkdir "$1"&&pushd "$1";fi;}

#############################################################################################################

alias cddp='__cdd "${_folder_docs_prv}"'
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~





## conditions ###############################################################################################
- always use the native bash builtin `[[` (even though `[` is so too, nowadays) if platform-independence isnt needed
- for simple conditionals dont use `if` but rather `[[ ... ]]&&DO_SOMETHING_ELSE` on a single line
    - but NEVER if you need `else` statements as `[[ ... ]]&&DO_SOMETHING||DO_ANOTHER_THING` is erroreous
        - if the `&&` statement executes and fail,the `||` clause will also run which is almost never whats intended
    - prefer negating the complete conditional statement over not-equal'ing its internal condition if possible
        - prefer i.e. `! [[ 0 -eq $1 ]]&& ...`
        - over i.e. `[[ 0 -ne $1 ]]|| ...`
        - as this improves comprehensibility
- `if ... then ... else ... fi` keywords are always written on the same indentation level and on their own line
    - this improves readability when scanning/scrolling over code
    - you dont forget semicolons before `then` all the time
- `if ... then ... elif ... then ... else ... fi` should be used sparingly fixme



EXAMPLES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~bash
[[ YOUR_TEST_CONDITION ]]  ## RIGHT
[ YOUR_TEST_CONDITION ]  ## WRONG

#############################################################################################################

#DO THIS:
#short-circuit short if-clauses so this:
if [[ SOME_CONDITION ]]
then 
	DO_SOMETHING
fi

#which becomes: (RIGHT)
[[ SOME_CONDITION ]]&&DO_SOMETHING



#BUT NEVER DO THIS:
#so this with an `else` clause:
if [[ SOME_CONDITION ]]
then 
	DO_SOMETHING
else
	DO_SOMETHING_ELSE_INSTEAD
fi

#becomes: (WRONG)
[[ SOME_CONDITION ]]&&DO_SOMETHING||OR_DO_SOMETHING_ELSE_INSTEAD  ## WRONG!!!
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~






## arithmetic calculations ##################################################################################
- no usage of `$[ ... ]` as its deprecated
- always use `$(( ... ))`
    - always do 1 space after opening and before closing parentheses for better readability
    - dont do spaces in there otherwise
    - no brace use for dereferencing variables
- never enclose arithmetic expansion or used variables in there  within any kind of quotes



EXAMPLES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~bash
local _a=1
local _b=2
$(( _a+_b ))
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~






## command substitution #####################################################################################
- never use ``` ` ... ` ```
    - these cannot be arbitrarily nested without fucking up eventually
    - exception is when being in the cli and not within scripts,if its one-off stuff. still try avoiding them
- always use `$( ... )` 
- always quote,if the resulting output is a string: `"$( ... )"`
- dont do space after/before the parentheses






## linebreaking #############################################################################################
- this sounds trivial,but isnt. good newline-hygiene improves readability by leaps and bounds
- try splitting content semantically,ofc
- put pipes as first char,indented,on their own line
    - do when the main command was done already even if it also contains pipes (remember: split semantically)
    - use this also for longer non-bash parts,i.e. for `awk` or passing data like for `curl`
- put matching parentheses on their own,on the same indentation level



EXAMPLES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~bash
zabbixproblems() {
    (\
        while read -r
        do
            if [[ -n "${REPLY}" ]]
            then
                echo\
                    "$(date +"%F %T" -d@"$(echo "${REPLY}"|awk '{print $1}')")"\
                    "$(echo "${REPLY}"|awk '{$1=""; print $0}')"\
                    |awk\
                        '{\
                            if ($3==2) $3="WARNING @";\
                            else if ($3==3) $3="AVERAGE @";\
                            else if ($3==4) $3="HIGH @";\
                            else if ($3==5) $3="DISASTER @";\
                            print\
                        }'
            fi
        done <<<\
            "$(\
                __zabbixproblemsraw\
                |jq -r '.clock+" "+.severity+" "+.name' \
                |sort -rnk1\
            )"\
        |column -s'@' -t\
    )\
    |tac
}

#############################################################################################################

__getzabbixapitoken() {
    curl -s -k -X POST -H "Content-Type:application/json"\
        --data\
            "{\
                \"jsonrpc\": \"2.0\",\
                \"method\":\"user.login\",\
                \"params\":\
                {\
                    \"user\":\"${USER}\",\
                    \"password\":\"${_PASS}\"\
                },\
                \"id\":1\
            }"\
            "${_ZABBIX_URL}"\
    |jq -r '.result'
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~






## includes #################################################################################################
- include files always via `.` and never by `source` keyword
- always do this in the first column (`^\.`)



EXAMPLE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~bash
. /path/to/include
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~






## IDIOMS ###################################################################################################
- fixme common bashisms will be put here
- i.e. iterating in a loop over lines instead of words when reading a file
