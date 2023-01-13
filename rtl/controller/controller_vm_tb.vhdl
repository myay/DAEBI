library ieee;
use ieee.std_logic_1164.all;

library work;
use work.pkg.all;

entity controller_vm_tb is
end controller_vm_tb;

architecture test of controller_vm_tb is
  component controller_vm
	  generic(nr_xnor_gates        : integer;
			  nr_computing_columns : integer;
			  acc_data_width       : integer);
	  port(
        clk            : in std_logic; 								
        reset          : in std_logic; 	
		i_valid        : in std_logic;
		i_inputs       : in std_logic_vector( nr_xnor_gates-1 downto 0);
		i_weights      : in std_logic_vector( nr_xnor_gates-1 downto 0);
		o_addr_inputs  : out std_logic_vector(31 downto 0);
		o_addr_weights : out std_logic_vector(31 downto 0)
	  );
  end component;

signal rst_t: std_logic;
signal i_valid: std_logic;
signal input_w: std_logic_vector(63 downto 0);
signal input_i: std_logic_vector(63 downto 0);
signal output_addr_w: std_logic_vector(31 downto 0);
signal output_addr_i: std_logic_vector(31 downto 0);


signal clk_t: std_logic := '0';
constant clk_period : time := 2 ns;
shared variable i: integer := 0;
shared variable max_clock_cyles: integer := 200;

begin
  controller_vm_test: controller_vm
    generic map (nr_xnor_gates        => 64,
				 nr_computing_columns => 8,
				 acc_data_width       => 16)
    port map(
        clk            => clk_t,						
        reset          => rst_t,
		i_valid        => i_valid,
		i_inputs       => input_i,
		i_weights      => input_w,
		o_addr_inputs  => output_addr_i,
		o_addr_weights => output_addr_w
    );

  process begin
  
  -- input (cycle 0) to output (cycle 10) -> 10 cycles
  
  -- expected result: (accumulator : value) 0:5, 1:66, 2:3, 3:4, 4:64, 5:1, 6:2, 7:3
  
    -- reset
	input_w <= "1010101010101010101010101010101010101010101010101010101010101010";
    input_i <= "1010101010101010101010101010101010101010101010101010101010101010";
	rst_t <= '1';
	i_valid <= '0';
    wait for 2 ns;
	
    -- add 1
    input_w <= "0101010111010101010101010101010101010101010101010101010101010101";
    input_i <= "1010101010101010101010101010101010101010101010101010101010101010";
	rst_t <= '0';
	i_valid <= '1';
    wait for 2 ns;
	
	-- add 2
	input_w <= "0101010111010101010101010101010001010101010101010101010101010101";
    input_i <= "1010101010101010101010101010101010101010101010101010101010101010";
    wait for 2 ns;
	
	-- add 3
	input_w <= "0101010111010101010101010101010001010101010101010101010101010100";
    input_i <= "1010101010101010101010101010101010101010101010101010101010101010";
    wait for 2 ns;
	
	-- add 4
	input_w <= "0101010111010101010101010101010001010101010101010101010101010110";
    input_i <= "1010101010101010101010101010101010101010101010101010101010101010";
    wait for 2 ns;
	
	-- add 64
	input_w <= "1010101010101010101010101010101010101010101010101010101010101010";
    input_i <= "1010101010101010101010101010101010101010101010101010101010101010";
    wait for 2 ns;
	
	-- add 1
    input_w <= "0101010111010101010101010101010101010101010101010101010101010101";
    input_i <= "1010101010101010101010101010101010101010101010101010101010101010";
	rst_t <= '0';
	i_valid <= '1';
    wait for 2 ns;
	
	-- add 2
	input_w <= "0101010111010101010101010101010001010101010101010101010101010101";
    input_i <= "1010101010101010101010101010101010101010101010101010101010101010";
    wait for 2 ns;
	
	-- add 3
	input_w <= "0101010111010101010101010101010001010101010101010101010101010100";
    input_i <= "1010101010101010101010101010101010101010101010101010101010101010";
    wait for 2 ns;
	
	
	
	-- Start at 1 again
	
	
	-- add 4
	input_w <= "0101010111010101010101010101010001010101010101010101010101010110";
    input_i <= "1010101010101010101010101010101010101010101010101010101010101010";
    wait for 2 ns;
	
	-- add 64
	input_w <= "1010101010101010101010101010101010101010101010101010101010101010";
    input_i <= "1010101010101010101010101010101010101010101010101010101010101010";
    wait for 2 ns;
	
	i_valid <= '0';
	
	-- reset
	-- rst_t <= '1';
    -- wait for 2 ns;
	-- rst_t <= '0';
    -- wait for 2 ns;

	-- add 63
    -- input_w <= "1010101010101010101010101010101010101010101010101010101010101011";
    -- input_2 <= "1010101010101010101010101010101010101010101010101010101010101010";
    -- wait for 50 ns;
    wait;
  end process;

  -- Clock generation process
  clk_process: process
    begin
      while i<max_clock_cyles loop
        -- clk_t <= not clk_t after clk_period/2;
        clk_t <= '0';
        wait for clk_period/2;  -- Signal is '0'.
        clk_t <= '1';
        wait for clk_period/2;  -- Signal is '1'
        i := i+1;
      end loop;
      wait;
    end process;
end test;
