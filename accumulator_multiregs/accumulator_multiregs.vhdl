library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accumulator_multiregs is
  generic(
    input_width : integer;
    data_width : integer;
    addr_width : integer;
    nr_regs : integer
  );
  port(
    i_val_acc   : std_logic; -- Signals whether accumulator is ready to receive new input data
    reset       : in std_logic; -- Reset signal
    clk         : in std_logic; -- Clock signal
    r_s         : in std_logic_vector(addr_width-1 downto 0); -- Register selector
    i_data      : in std_logic_vector(input_width-1 downto 0); -- Input data
    o_data      : out std_logic_vector(data_width-1 downto 0); -- Output data
    o_val_acc   : out std_logic -- Signal for completion of computations
  );
end accumulator_multiregs;

architecture rtl of accumulator_multiregs is
  signal first_dff        : std_logic_vector(input_width-1 downto 0) := (others => '0'); -- Buffer for the input data
  signal delay_val        : std_logic_vector(2 downto 0) := (others => '0'); -- Signal for pipeline progress
  -- signal o_acc            : std_logic_vector(31 downto 0) := (others => '0'); -- Accumulation registers
  -- type registers_delta is array (3 downto 0) of std_logic_vector(31 downto 0); -- Delta accumulation registers of size 32 bits (TODO: nr of regs and bit width should be generic)
  -- signal registers_d      : registers_delta := (others => (others => '0'));
  signal o_reg_acc        : std_logic_vector(data_width-1 downto 0) := (others => '0'); -- Buffer for the output data
  -- signal r_sel            : std_logic_vector(1 downto 0);

  -- Variables for regfile
  signal we3_am: std_logic;
  signal a1_am, a3_am: std_logic_vector(addr_width-1 downto 0);
  signal wd3_am, rd1_am: std_logic_vector(data_width-1 downto 0);
begin

  -- Generate register file
  inst_regfile : entity work.regfile(behavior)
    generic map(
      data_width => data_width,
      addr_width => addr_width,
      nr_regs => nr_regs
    )
    port map(
      clk => clk,
      we3 => we3_am,
      a1 => a1_am,
      a3 => a3_am,
      wd3 => wd3_am,
      rd1 => rd1_am
    );

  -- Load index into a1_am to select register for value retrieval
  process(clk) begin
    if rising_edge(clk) then
      if i_val_acc = '1' then
        a1_am <= r_s;
      end if;
    end if;
  end process;

  -- Load input into first_dff
  process(clk) begin
    if rising_edge(clk) then
        if reset = '1' then
          first_dff <= (others => '0');
        elsif i_val_acc = '1' then
          if delay_val(0) = '1' then
            first_dff <= i_data;
          end if;
        end if;
    end if;
  end process;

  -- Accumulate input value and value in register into o_reg_acc (accumulation register)
  process(first_dff) begin
    if reset = '1' then
      o_reg_acc <= (others => '0');
    else
      o_reg_acc <= std_logic_vector(unsigned(rd1_am) + unsigned(first_dff));
    end if;
    -- o_reg_acc(8 downto 0) <= std_logic_vector(unsigned(first_dff));
  end process;

  -- Store result of accumulation in register file at specified index
  process(clk) begin
    if rising_edge(clk) then
      if delay_val(1) = '1' then
        we3_am <= '1';
        a3_am <= a1_am;
        wd3_am <= o_reg_acc;
      end if;
    end if;
  end process;

  -- Determine delay through pipeline to set flag for finished computations
  process(clk) begin
    if rising_edge(clk) then
      if reset = '1' then
        delay_val <= (others => '0');
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
