#compdef make_parameters.py

_values "Defined parameter sets" $(grep -A1 "^@parameterset" make_parameters.py | sed -n 's/def \(.\+\)():/\1/p')
