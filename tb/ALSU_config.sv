package ALSU_config_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ALSU_config extends uvm_object;
        `uvm_object_utils(ALSU_config)

        virtual ALSU_if alsu_if;
        uvm_active_passive_enum is_active;

        function new (string name = "ALSU_config");
            super.new(name);
        endfunction
    endclass

endpackage