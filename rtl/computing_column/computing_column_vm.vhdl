library ieee;
use ieee.std_logic_1164.all;

library work;
use work.pkg.all;

entity computing_column_vm is
  generic(nr_xnor_gates: integer;
		  acc_data_width: integer);
  port(
    clk           : in std_logic;
    rst           : in std_logic;
    xnor_inputs_1 : in std_logic_vector(nr_xnor_gates-1 downto 0); -- First inputs
    xnor_inputs_2 : in std_logic_vector(nr_xnor_gates-1 downto 0); -- Second inputs
    o_data_cc     : out std_logic_vector(acc_data_width-1 downto 0) -- Output data
  );
end computing_column_vm;

architecture rtl of computing_column_vm is

constant nr_popc_bits_o : integer := 7; -- nr of output bits of popcount unit, -> calculate using log2

signal clk_cc : std_logic; -- Clock signal

-- Signals for xnor array
signal in_cc_1 : std_logic_vector(nr_xnor_gates-1 downto 0) := (others => '0'); -- Input 1 for xnor array
signal in_cc_2 : std_logic_vector(nr_xnor_gates-1 downto 0) := (others => '0'); -- Input 2 for xnor array
signal o_data_xnor : std_logic_vector(nr_xnor_gates-1 downto 0) := (others => '0'); -- Output of xnor array

-- Signals for popcount unit
signal o_data_popc : std_logic_vector(nr_popc_bits_o-1 downto 0) := (others => '0'); -- Output of popcount unit
signal rst_popc, o_val_popc: std_logic := '0'; -- Reset and output signal
signal i_val_popc : std_logic := '1';

-- Signals for accumulator
signal rst_acc: std_logic := '0'; -- Reset
signal clk_acc: std_logic; -- Clock for accumulator
signal i_data_acc : std_logic_vector(nr_popc_bits_o-1 downto 0) := (others => '0');
signal o_data_acc : std_logic_vector(acc_data_width-1 downto 0) := (others => '0'); -- Output for accumulator
signal rst_pipe : std_logic_vector(8 downto 0) := (others => '0');

begin
  -- Instantiate xnor array
  inst_xnor_array : entity work.xnor_gate_array(rtl)
    generic map(nr_xnor_gates => nr_xnor_gates)
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
  inst_accumulator : entity work.accumulator_s(bhv)
    generic map(
      input_width => nr_popc_bits_o,
      data_width => acc_data_width
    )
    port map(
      clk => clk_cc,
      reset => rst_acc,
      i_data => i_data_acc,
      o_data => o_data_acc
    );

  -- store reset signal in pipeline to reach accumulator at the right timing
  process(clk) begin
	if rising_edge(clk) then
		rst_pipe <= rst_pipe(7 downto 0) & rst;
		rst_acc <= rst_pipe(8);
	end if;
  end process;
	
	
  process(clk) begin
    -- Update clock signal of cc
    clk_cc <= clk;
	-- Update clock signal of accumulator
	clk_acc <= clk and o_val_popc;
    if rising_edge(clk) then
      -- Assign inputs to input buffers
      in_cc_1 <= xnor_inputs_1;
      in_cc_2 <= xnor_inputs_2;
      -- Assign output of popcount value to input of accumulator
      if o_val_popc = '1' then
        i_data_acc <= o_data_popc;
      end if;
      -- Assign output of accumulator to output pins of cc
      -- if o_val_acc = '1' then
        o_data_cc <= o_data_acc;
      -- end if;
    end if;
  end process;
end rtl;
