library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accumulator is
  generic(
    input_width: integer;
    data_width: integer
  );
  port(
    i_val_acc   : std_logic; -- Signals whether accumulator is ready to receive new input data
    reset       : in std_logic; -- Reset signal
    clk         : in std_logic; -- Clock signal
    i_data      : in std_logic_vector(input_width-1 downto 0); -- Input data
    o_data      : out std_logic_vector(data_width-1 downto 0); -- Output data
    o_val_acc   : out std_logic -- Signal for completion of computations
  );
end accumulator;

architecture rtl of accumulator is
  signal first_dff        : std_logic_vector(input_width-1 downto 0) := (others => '0'); -- Buffer for the input data
  signal delay_val        : std_logic_vector(2 downto 0) := (others => '0'); -- Singal for pipeline progress
  signal o_acc            : std_logic_vector(data_width-1 downto 0) := (others => '0'); -- Accumulation register
  signal o_reg_acc        : std_logic_vector(data_width-1 downto 0) := (others => '0'); -- Buffer for the output data
  signal token_add        : std_logic := '0';
begin

  -- Load input data into first_dff (input buffer)
  process(clk) begin
    if rising_edge(clk) then
      if reset = '1' then
        first_dff <= (others => '0');
      elsif i_val_acc = '1' then
        first_dff <= i_data;
      end if;
    end if;
  end process;

  -- Get token from input pin and set it to zero (consumed) one clock cycle later, so that no more additions are performed
  process(clk) begin
    if rising_edge(clk) then
      token_add <= i_val_acc;
      if delay_val(0) = '1' then
        token_add <= '0';
      end if;
    end if;
  end process;

  -- Accumulate input value in o_acc (accumulation register), only when in the second pipline stage and only when input token is available
  process(clk) begin
    if rising_edge(clk) then
      if delay_val(0) = '1' then
        if token_add = '1' then
          o_acc <= std_logic_vector(unsigned(o_reg_acc) + unsigned(first_dff));
        end if;
      end if;
    end if;
  end process;

  -- Copy current accumulation result to o_reg_acc (output register)
  process(clk) begin
    if rising_edge(clk) then
      if reset = '1' then
        o_reg_acc <= (others => '0');
      else
        if delay_val(1) = '1' then
          o_reg_acc <= o_acc;
        end if;
      end if;
    end if;
  end process;

  -- Determine delay through pipeline to set flag for finished computations
  process(clk) begin
    if rising_edge(clk) then
      if reset = '1' then
        delay_val <= (others => '0');
        o_val_acc <= '0';
      else
        delay_val <= delay_val(1 downto 0) & i_val_acc;
        if delay_val(2) = '1' then
          o_val_acc <= '1';
        else
          o_val_acc <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Send result of accumulation to output pins
  process(clk) begin
    if rising_edge(clk) then
      if reset = '1' then
        o_data <= (others => '0');
      else
        o_data <= o_reg_acc;
      end if;
    end if;
  end process;

end rtl;
