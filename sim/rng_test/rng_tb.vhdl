library ieee;
use ieee.std_logic_1164.all;
use IEEE.MATH_REAL.all;
USE ieee.numeric_std.ALL;
-- use ieee.math_real.uniform;
-- use ieee.math_real.floor;
-- use ieee.math_real.round;

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
signal rlv_val_8: std_logic_vector(7 downto 0);

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
    variable seed1, seed2 : integer := 999; -- Seeds for reproducable random numbers
    variable rand_real_val : real; -- For storing random real value
    variable rand_int_val : integer; -- For storing random integer value
    variable j: integer := 0;

    -- Function for generating random float
    impure function rand_real(min_val, max_val : real) return real is
      variable x : real; -- Returned random value in rng function
    begin
      uniform(seed1, seed2, x);
      return x * (max_val - min_val) + min_val;
    end function;

    -- Function for generating random integer
    impure function rand_int(min_val, max_val : real) return integer is
      variable x : real; -- Returned random value in rng function
    begin
      uniform(seed1, seed2, x);
      return integer(round(x * (max_val - min_val + 1.0) + (min_val) - 0.5));
    end function;

    -- Function for generating random std_logic_vector
    impure function rand_lv(len : integer) return std_logic_vector is
      variable x : real; -- Returned random value in rng function
      variable rlv_val : std_logic_vector(len - 1 downto 0); -- Returned random bit string of length len
    begin
      for i in rlv_val'range loop
        uniform(seed1, seed2, x);
        rlv_val(i) := '1' when x > 0.5 else '0';
      end loop;
      return rlv_val;
    end function;

    begin
      while j < max_clock_cyles loop
        j := j+1;
        report "The value of 'j' is " & integer'image(j);
        rand_real_val := rand_real(2.0,3.0);
        rand_int_val := rand_int(2.0,3.0);
        rlv_val_8 <= rand_lv(8);
        report "The value of 'rand_real_val' is " & real'image(rand_real_val);
        report "The value of 'rand_int_val' is " & integer'image(rand_int_val);
        report "The value of 'rlv_val_8' is " & integer'image(to_integer(unsigned(rlv_val_8)));
        wait for clk_period;
      end loop;
      wait;
    end process;
end test;
