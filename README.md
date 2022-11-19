# MELA: a Modestly Exhaustive dLx Architecture
```
                                             .:'
                                            __ :'__
                                         .'`  `-'  ``.
                                        :             :
                                        :             :
                                         :           :
                                          `.__.-.__.'

```

----

DLX ISA, RISC microprocessor, VHDL implementation


# Instruction Set Architecture
See [here](./doc/isa.md)

# Notes 
I don't like this folder strcuture but it was imposed on us to keep the project "tidier" and simpler to recognize the hierarchy from. 
To be honest the constraint is understandable but it's still aweful to look at and use.

# Vim Bindings
Make sure the vim `PWD` is the root of the project
```
# commpile the asm file open in the current buffer
:nnoremap <F4> :!./scripts/assembler/assembler.sh % ./src/000-common.core/003-IMEM_INIT_FILE.txt<cr>
# save all buffers and push to remote
:nnoremap <F5> :wa<cr>:! rsync -hh -a --info=stats1,progress2 --partial /home/simone/Documents/00.PoliTO/1.2-MicroElectronic-Systems/DLX/ ms_polito:~/dlx_simone<cr>
# compile on remote
:nnoremap <F6> :! ssh ms_polito "cd ./dlx_simone; ./scripts/build.sh"<cr>
```

[MicroEletronics PoliTO]
