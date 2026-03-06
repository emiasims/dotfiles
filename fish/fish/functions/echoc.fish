function echoc --wraps=echo -d "echo with color. -c [fcolor args] ..."
  # grab relevant echo flags, ignoring unknown for -c
  argparse --stop-nonopt --ignore-unknown n s e -- $argv

  while test -n "$argv"
    if test $argv[1] = "-c"
      # get flags for fcolor / set_color
      set ix 2
      while string match -q -r '^-' -- $argv[$ix]
        set ix (math $ix + 1)
      end

      set prefix (fcolor reset)(fcolor $argv[2..$ix])
      set -e argv[1..$ix]
    else
      set -a m "$prefix$argv[1]"
      set -e argv[1] prefix
    end
  end
  echo $_flag_n $_flag_s $_flag_e (fcolor reset)$m(fcolor reset)
end
