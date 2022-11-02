library ieee;
use ieee.std_logic_1164.all;

library work;
use work.pkg.all;

entity computing_column is
  port(
    clk           : in std_logic;
    rst           : in std_logic;
    xnor_inputs_1 : in std_logic_vector(xnor_gates_per_column-1 downto 0); -- First inputs
    xnor_inputs_2 : in std_logic_vector(xnor_gates_per_column-1 downto 0); -- Second inputs
    o_data_cc     : out std_logic_vector(31 downto 0) -- Output data
  );
end computing_column;

architecture rtl of computing_column is

signal clk_cc : std_logic; -- Clock signal

-- Signals for xnor array
signal in_cc_1 : std_logic_vector(xnor_gates_per_column-1 downto 0); -- Input 1 for xnor array
signal in_cc_2 : std_logic_vector(xnor_gates_per_column-1 downto 0); -- Input 2 for xnor array
signal o_data_xnor : std_logic_vector(xnor_gates_per_column-1 downto 0); -- Output of xnor array

-- Signals for popcount unit
signal o_data_popc : std_logic_vector(13 downto 0); -- Output of popcount unit
signal rst_popc, o_val_popc: std_logic := '0'; -- Reset and output signal
signal i_val_popc : std_logic := '1';

-- Signals for accumulator
signal rst_acc, o_val_acc: std_logic := '0'; -- Reset, input signal and output signal
signal i_val_acc : std_logic := '1';
signal i_data_acc : std_logic_vector(8 downto 0);
signal o_data_acc : std_logic_vector(31 downto 0); -- Output for accumulator

begin
  -- Instantiate xnor array
  inst_xnor_array : entity work.xnor_gate_array(rtl)
  port map(
    xnor_inputs_1 => in_cc_1,
    xnor_inputs_2 => in_cc_2,
    xnor_outputs => o_data_xnor
  );

  -- Instantiate popcount unit
  inst_popcount : entity work.popcount(rtl)
  port map(
    i_val => i_val_popc,
    clk => clk_cc,
    rst => rst_popc,
    stream_i => o_data_xnor,
    o_val => o_val_popc,
    stream_o => o_data_popc
  );

  -- Instantiate accumulator
  inst_accumulator : entity work.accumulator(rtl)
  port map(
    i_val_acc => i_val_acc,
    clk => clk_cc,
    reset => rst_acc,
    i_data => i_data_acc,
    o_data => o_data_acc,
    o_val_acc => o_val_acc
  );

  -- Transmit data from popcount unit to accumulator only when popcount output has finished computing
  process(clk) begin
    clk_cc <= clk;
    if rising_edge(clk) then
      in_cc_1 <= xnor_inputs_1;
      in_cc_2 <= xnor_inputs_2;
      if o_val_popc = '1' then
        i_data_acc <= o_data_popc(8 downto 0);
      end if;
      if o_val_acc = '1' then
        o_data_cc <= o_data_acc;
      end if;
    end if;
  end process;
end rtl;
