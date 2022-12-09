library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accumulator_multiregs_s is
  generic(
    input_width: integer;
    data_width: integer;
    addr_width : integer;
    nr_regs : integer
  );
  port(
    i_val_acc : in std_logic;
    clk       : in std_logic;
    reset     : in std_logic;
    r_s       : in std_logic_vector(addr_width-1 downto 0);
    i_data    : in std_logic_vector(input_width-1 downto 0);
    o_data    : out std_logic_vector(data_width-1 downto 0);
    o_val_acc : out std_logic
  );
end accumulator_multiregs_s;

architecture bhv of accumulator_multiregs_s is
  signal tmp: std_logic_vector(data_width-1 downto 0) := (others => '0');
  signal delay_val: std_logic_vector(1 downto 0) := (others => '0');
  -- Variables for regfile
  signal we3_am, reset_am: std_logic;
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
      reset => reset_am,
      a1 => a1_am,
      a3 => a3_am,
      wd3 => wd3_am,
      rd1 => rd1_am
    );

  -- Load index into a1_am to select register for value retrieval (first clock cycle)
  process(clk) begin
    if rising_edge(clk) then
      if i_val_acc = '1' then
        a1_am <= r_s;
      end if;
    end if;
  end process;

  -- Perform the accumulation (second clock cycle)
  process (clk) begin
    if rising_edge(clk) then
      if reset = '1' then
        tmp <= (others => '0');
      else
        if delay_val(0) = '1' then
          tmp <= std_logic_vector(unsigned(rd1_am) + unsigned(i_data));
        end if;
      end if;
    end if;
  end process;

  -- Store result of accumulation in register file at specified index (third clock cycle) and send accumulation result to o_data
  process(clk) begin
    if rising_edge(clk) then
      if reset = '1' then
        we3_am <= '0';
        o_data <= (others => '0');
      else
        if delay_val(1) = '1' then
          we3_am <= '1';
          a3_am <= a1_am;
          wd3_am <= tmp;
          o_data <= tmp;
        else
          we3_am <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Determine delay through pipeline to set flag for finished computations
  process(clk) begin
    if rising_edge(clk) then
      if reset = '1' then
        delay_val <= (others => '0');
      else
        delay_val <= delay_val(0) & i_val_acc;
        if delay_val(1) = '1' then
          o_val_acc <= '1';
        else
          o_val_acc <= '0';
        end if;
      end if;
    end if;
  end process;
end bhv;
