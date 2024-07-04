m80 =tshell
copy tshell.rel b1:;ne
b1:
gen osslave.sys a0:;kfc00
gen osmaster.sys a0:
change *;n
dcon
a100
di
hlt
.
g100
