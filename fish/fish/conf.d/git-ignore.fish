# completions for the `git ignore` subcommand (scripts/bin/git-ignore).
# they live in conf.d because a completions/git.fish would shadow fish's own
# git completions rather than extend them.

function __git_ignore_args --description 'tokens after `git ignore`'
    set -l tokens (commandline -xpc)
    set -l i (contains -i -- ignore $tokens)
    or return 1
    set -e tokens[1..$i]
    set -q tokens[1]
    or return 1
    printf '%s\n' $tokens
end

# a lone -p, or a short cluster ending in p, swallows the next token
function __git_ignore_takes_arg
    string match -qr '^(-p|--path|-[a-z]*p)$' -- $argv[1]
end

function __git_ignore_verb
    set -l skip 0
    for t in (__git_ignore_args)
        if test $skip -eq 1
            set skip 0
            continue
        end
        if __git_ignore_takes_arg $t
            set skip 1
        else if not string match -q -- '-*' $t
            echo $t
            return 0
        end
    end
    return 1
end

function __git_ignore_needs_verb
    not __git_ignore_verb >/dev/null
end

function __git_ignore_verb_is
    contains -- (__git_ignore_verb) $argv
end

function __git_ignore_has_flag
    for t in (__git_ignore_args)
        contains -- $t $argv
        and return 0
    end
    return 1
end

# the scope flags already typed, so entry completion reads the same file the
# command would write
function __git_ignore_scope
    set -l tokens (__git_ignore_args)
    for i in (seq (count $tokens))
        set -l t $tokens[$i]
        switch $t
            case -g --global -l --local --root
                echo $t
                return
            case -p --path
                set -l n (math $i + 1)
                set -q tokens[$n]
                and printf '%s\n' $t $tokens[$n]
                return
            case '--path=*' '-p?*'
                echo $t
                return
        end
    end
end

function __git_ignore_filter --description 'drop comments and blank lines'
    for line in $argv
        set -l trimmed (string trim -- $line)
        test -z "$trimmed"
        and continue
        string match -q '#*' -- $trimmed
        and continue
        echo $line
    end
end

function __git_ignore_entries
    __git_ignore_filter (git ignore (__git_ignore_scope) show 2>/dev/null)
end

function __git_ignore_all_entries
    __git_ignore_filter (begin
        git ignore show
        git ignore -g show
        git ignore -l show
        git ignore --root show
    end 2>/dev/null | sort -u)
end

function __git_ignore_unignored
    git ls-files --others --exclude-standard --directory 2>/dev/null
end

set -l ignore '__fish_git_using_command ignore'

complete -c git -n __fish_git_needs_command -a ignore -d 'Edit and inspect ignore files'

complete -c git -f -n "$ignore" -n __git_ignore_needs_verb -a show -d 'Print the target ignore file'
complete -c git -f -n "$ignore" -n __git_ignore_needs_verb -a add -d 'Append entries to the target'
complete -c git -f -n "$ignore" -n __git_ignore_needs_verb -a rm -d 'Remove entries from the target'
complete -c git -f -n "$ignore" -n __git_ignore_needs_verb -a mv -d 'Move an entry into a scope'
complete -c git -f -n "$ignore" -n __git_ignore_needs_verb -a ls -d 'List ignored files in the tree'
complete -c git -f -n "$ignore" -n __git_ignore_needs_verb -a ls-files -d 'List ignored files in the tree'

complete -c git -f -n "$ignore" -s g -l global -d 'core.excludesFile'
complete -c git -f -n "$ignore" -s l -l local -d '.git/info/exclude'
complete -c git -f -n "$ignore" -l root -d 'the repo root .gitignore'
complete -c git -F -r -n "$ignore" -s p -l path -d 'ARG/.gitignore, or ARG itself'
complete -c git -f -n "$ignore" -s n -l dry-run -d 'Show what would change, write nothing'
complete -c git -f -n "$ignore" -n '__git_ignore_verb_is add rm' -s r -l resolve -d 'Treat args as globs, write matched paths'
complete -c git -f -n "$ignore" -n '__git_ignore_verb_is ls ls-files' -s a -l all -d 'Do not collapse directories'
complete -c git -f -n "$ignore" -n '__git_ignore_verb_is ls ls-files' -s v -l verbose -d 'Append the source:line for each path'

complete -c git -f -n "$ignore" -n '__git_ignore_verb_is add' -n 'not __git_ignore_has_flag -r --resolve' -a '(__git_ignore_unignored)' -d 'Not yet ignored'
complete -c git -F -n "$ignore" -n '__git_ignore_verb_is add' -n '__git_ignore_has_flag -r --resolve'
complete -c git -f -n "$ignore" -n '__git_ignore_verb_is rm' -n 'not __git_ignore_has_flag -r --resolve' -a '(__git_ignore_entries)' -d Entry
complete -c git -F -n "$ignore" -n '__git_ignore_verb_is rm' -n '__git_ignore_has_flag -r --resolve'
complete -c git -f -n "$ignore" -n '__git_ignore_verb_is mv' -a '(__git_ignore_all_entries)' -d Entry
complete -c git -F -n "$ignore" -n '__git_ignore_verb_is ls ls-files'
