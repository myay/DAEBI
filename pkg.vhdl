library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pkg is
  constant alpha                   : integer := 64; -- Number of neurons in weight matrix
  constant beta_gamma              : integer := 576; -- Number of weights in neurons
  constant delta                   : integer := 196; -- Number of columns in input matrix
  constant columns                 : integer := 64; -- Number columns in accelerator
  constant xnor_gates_per_column   : integer := 64; -- Number XNOR gates in each column
end pkg;
