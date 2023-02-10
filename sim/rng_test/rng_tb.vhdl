library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.uniform;
use ieee.math_real.floor;

entity rng_tb is
end rng_tb;

architecture test of rng_tb is
  component xnor_gate
    port(
      xnor_in_1 : in std_logic; -- First input
      xnor_in_2 : in std_logic; -- Second input
      xnor_out  : out std_logic -- XNOR result
    );
  end component;

signal a, b, r: std_logic;

--- rng stuff
constant clk_period: time := 2 ns;
constant max_clock_cyles: integer := 40;

begin
  xnor_gate_test: xnor_gate port map(xnor_in_1 => a, xnor_in_2 => b, xnor_out => r);

  process begin
    a <= '0';
    b <= '0';
    wait for 10 ns;

    a <= '1';
    b <= '0';
    wait for 10 ns;

    a <= '0';
    b <= '1';
    wait for 10 ns;

    a <= '1';
    b <= '1';
    wait for 10 ns;

    wait;
  end process;

  rng_process: process
    variable seed1, seed2 : integer := 999;
    variable x : real;
    variable x_y : real;
    variable y : integer;
    variable j: integer := 0;

    function rand_real(min_val, max_val : real) return real is
      variable x : real;
      begin
        uniform(seed1, seed2, x);
        return x * (max_val - min_val) + min_val;
    end function;

    begin
      while j < max_clock_cyles loop
        j := j+1;
        report "The value of 'j' is " & integer'image(j);
        x_y := rand_real(2.0,3.0);
        report "The value of 'x_y' is " & real'image(x_y);
        wait for clk_period;
      end loop;
      wait;
    end process;
end test;
