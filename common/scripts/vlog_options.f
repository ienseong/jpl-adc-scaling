# Require strict compliance with the LRM for module input ports
#
# Require all inputs be 4-state types unless explicitly declared as
# 'var'.  This setting will cause the compiler will fail with error if
# this requirement is not met.
-svinputport=net
