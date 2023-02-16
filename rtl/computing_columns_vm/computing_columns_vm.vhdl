library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- library work;
-- use work.pkg.all;

package array_pack is
  type array_2d is array(integer range<>) of std_logic_vector;
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.array_pack.all;

entity computing_columns_vm is
  generic(
    nr_computing_columns : integer := 64; -- Number of computing columns used in this controller
    nr_xnor_gates : integer := 64; -- Number of XNOR gates used in each computing column
    acc_data_width : integer := 13; -- Width of the output of each computing column
    nr_popc_bits_o: integer := 7
  );
  port(
    clk : in std_logic;
    reset : in std_logic;
    xnor_inputs_1 : in array_2d(nr_computing_columns-1 downto 0)(nr_xnor_gates-1 downto 0); -- First inputs
    xnor_inputs_2 : in array_2d(nr_computing_columns-1 downto 0)(nr_xnor_gates-1 downto 0); -- Second inputs
    thresholds_in : in array_2d(nr_computing_columns-1 downto 0)(acc_data_width-1 downto 0);
    o_result : out array_2d(nr_computing_columns-1 downto 0)(acc_data_width-1 downto 0); -- Outputs
    less_results : out std_logic_vector(nr_computing_columns-1 downto 0);
    eq_results : out std_logic_vector(nr_computing_columns-1 downto 0)
  );
end computing_columns_vm;

architecture rtl of computing_columns_vm is
begin
  -- Create a certain number of computing columns for vm, number specified in nr_computing_columns
  cc_vm_gen: for i in 0 to nr_computing_columns-1 generate
    cc_inst: entity work.computing_column_vm(rtl)
      generic map(
        nr_xnor_gates => nr_xnor_gates,
        acc_data_width => acc_data_width,
        nr_popc_bits_o => nr_popc_bits_o
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
