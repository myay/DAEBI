library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package array_pack is
  type array_2d_data is array(0 to {{ m-1 }}) of std_logic_vector({{ n-1 }} downto 0);
  type array_2d_th is array(0 to {{ m-1 }}) of std_logic_vector({{ dw-1 }} downto 0);
  type array_2d_out is array(0 to {{ m-1 }}) of std_logic_vector({{ dw-1 }} downto 0);
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.array_pack.all;

entity computing_columns_vm_constrained is
  generic(
    nr_computing_columns : integer := {{ m }}; -- Number of computing columns used in this controller
    nr_xnor_gates : integer := {{ n }}; -- Number of XNOR gates used in each computing column
    acc_data_width : integer := {{ dw }}; -- Width of the output of each computing column
    nr_popc_bits_o: integer := {{ popc_o }}
  );
  port(
    clk : in std_logic;
    reset : in std_logic;
    xnor_inputs_1 : in array_2d_data; -- First inputs
    xnor_inputs_2 : in array_2d_data; -- Second inputs
    thresholds_in : in array_2d_th;
    o_result : out array_2d_out; -- Outputs
    less_results : out std_logic_vector({{ m-1 }} downto 0);
    eq_results : out std_logic_vector({{ m-1 }} downto 0)
  );
end computing_columns_vm_constrained;

architecture rtl of computing_columns_vm_constrained is
begin
  -- Create a certain number of computing columns for vm, number specified in nr_computing_columns
  cc_vm_gen: for i in 0 to {{ m-1 }} generate
    cc_inst: entity work.computing_column_vm(rtl)
      generic map(
        nr_xnor_gates => {{ n }},
        acc_data_width => {{ dw }},
        nr_popc_bits_o => {{ popc_o }}
      )
      port map(
        clk           => clk,
        rst           => reset,
        xnor_inputs_1 => xnor_inputs_1(i),
        xnor_inputs_2 => xnor_inputs_2(i),
        threshold_in  => thresholds_in(i),
        o_data_cc     => o_result(i),
        less_cc       => less_results(i),
        eq_cc         => eq_results(i)
      );
  end generate;
end rtl;
