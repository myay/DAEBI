library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accumulator_multiregs is
  generic(
    input_width: integer := 7;
    data_width: integer := 13;
    addr_width : integer := 8; -- log2(nr_regs)
    nr_regs : integer := 196 -- VGG3 example
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
end accumulator_multiregs;

architecture bhv of accumulator_multiregs is
  signal tmp: std_logic_vector(data_width-1 downto 0) := (others => '0');
  signal delay_val: std_logic_vector(2 downto 0) := (others => '0');
  -- Variables for regfile
  signal we3_am, reset_am: std_logic;
  signal a1_am, a3_am: std_logic_vector(addr_width-1 downto 0);
  signal wd3_am, rd1_am: std_logic_vector(data_width-1 downto 0);
  -- signal token_add: std_logic := '0';
  -- Variables for pipeline registers
  signal reg_addr1, reg_addr2 : std_logic_vector(addr_width-1 downto 0);
  signal i_data1_ext, reg_data1, reg_data2 : std_logic_vector(data_width-1 downto 0);
  signal i_data0, i_data1: std_logic_vector(input_width-1 downto 0);
  
  
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
      a3 => reg_addr2,
      wd3 => reg_data2,
      rd1 => rd1_am
    );
	
	
  -- Generate pipeline register 0
  inst_reg_i_data0 : entity work.register_dff(rtl)
  generic map(w => input_width)
  port map(
    clk   => clk,
    reset => reset,
    d     => i_data,
    q     => i_data0
  );	

  -- Generate pipeline register 1
  inst_reg_i_data1 : entity work.register_dff(rtl)
  generic map(w => input_width)
  port map(
    clk   => clk,
    reset => reset,
    d     => i_data0,
    q     => i_data1
  );
  
  inst_reg_addr1 : entity work.register_dff(rtl)
  generic map(w => addr_width)
  port map(
    clk   => clk,
    reset => reset,
    d     => a1_am,
    q     => reg_addr1
  );
  
  -- Generate adder
  inst_adder : entity work.adder(rtl)
  generic map( w_i => data_width, w_o => data_width )
  port map(
    a => i_data1_ext,
    b => rd1_am,
    y => reg_data1
  );
  
  -- extend input to match data bits
  i_data1_ext <= (data_width-1 downto input_width => '0') & i_data1;
  
  -- Generate pipeline registers 2
  inst_reg_data : entity work.register_dff(rtl)
  generic map(w => data_width)
  port map(
    clk   => clk,
    reset => reset,
    d     => reg_data1,
    q     => reg_data2
  );
  
  inst_reg_addr2 : entity work.register_dff(rtl)
  generic map(w => addr_width)
  port map(
    clk   => clk,
    reset => reset,
    d     => reg_addr1,
    q     => reg_addr2
  );
  
  -- set we3 if input is valid
  we3_am <= delay_val(2);
  
  -- set output to reg_data2
  o_data <= reg_data2;
  
  

  -- Load index into a1_am to select register for value retrieval (first clock cycle)
  process(clk) begin
    if rising_edge(clk) then
      reset_am <= reset;
      if i_val_acc = '1' then
        a1_am <= r_s;
      end if;
    end if;
  end process;

  -- -- Get token from input pin and set it to zero (consumed) one clock cycle later, so that no more additions are performed
  -- process(clk) begin
  --   if rising_edge(clk) then
  --     token_add <= i_val_acc;
  --     if delay_val(1) = '1' then
  --       token_add <= '0';
  --     end if;
  --   end if;
  -- end process;

  -- Perform the accumulation (second clock cycle)
  -- process (clk) begin
    -- if rising_edge(clk) then
      -- if reset = '1' then
        -- tmp <= (others => '0');
      -- else
        -- --if ((delay_val(1) = '1') and (token_add = '1')) then
        -- if delay_val(0) = '1' then
          -- tmp <= std_logic_vector(unsigned(rd1_am) + unsigned(i_data));
        -- end if;
      -- end if;
    -- end if;
  -- end process;

  -- Store result of accumulation in register file at specified index (third clock cycle) and send accumulation result to o_data
  -- process(clk) begin
    -- if rising_edge(clk) then
      -- if reset = '1' then
        -- we3_am <= '0';
        -- o_data <= (others => '0');
      -- else
        -- if delay_val(1) = '1' then
          -- we3_am <= '1';
          -- a3_am <= a1_am;
          -- wd3_am <= tmp;
          -- o_data <= tmp;
        -- else
          -- we3_am <= '0';
        -- end if;
      -- end if;
    -- end if;
  -- end process;

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
end bhv;
