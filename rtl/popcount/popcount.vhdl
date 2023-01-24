-- File is from here: https://github.com/TUD-MLA/bnna/blob/master/rtl/popcount.vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- TODO: generate this file automatically

entity popcount is
  port(
    i_val       : in std_logic; -- whether it is ready to compute
    clk         : in std_logic;
    rst         : in std_logic;
    stream_i    : in std_logic_vector(63 downto 0);	--input Vector
    o_val       : out std_logic; --Finish Signal
    stream_o    : out std_logic_vector(6 downto 0)	--output Result (how many ones in the input)
  );
end popcount;

architecture rtl of popcount is
  -- Buffer memory definitions for intermediate storage of partial sums
  type ram_type32 is array (31 downto 0) of std_logic_vector(1 downto 0); -- 32 arrays of 2 bits (buffer memory for results of 1st level additions)
  signal mem32_i      : ram_type32 := (others => (others => '0'));
  signal mem32_o      : ram_type32 := (others => (others => '0'));

  type ram_type16 is array (15 downto 0) of std_logic_vector(2 downto 0); -- 16 arrays of 3 bits (buffer memory for results of 2nd level additions)
  signal mem16_i      : ram_type16 := (others => (others => '0'));
  signal mem16_o      : ram_type16 := (others => (others => '0'));

  type ram_type8 is array (7 downto 0) of std_logic_vector(3 downto 0); -- 8 arrays of 4 bits (buffer memory for results of 3rd level additions)
  signal mem8_i       : ram_type8 := (others => (others => '0'));
  signal mem8_o       : ram_type8 := (others => (others => '0'));

  type ram_type4 is array (3 downto 0) of std_logic_vector(4 downto 0); -- 4 arrays of 5 bits (buffer memory for results of 4th level additions)
  signal mem4_i       : ram_type4 := (others => (others => '0'));
  signal mem4_o       : ram_type4 := (others => (others => '0'));

  type ram_type2 is array (1 downto 0) of std_logic_vector(5 downto 0); -- 2 arrays of 6 bits (buffer memory for results of 5th level additions)
  signal mem2_i       : ram_type2 := (others => (others => '0'));
  signal mem2_o       : ram_type2 := (others => (others => '0'));

  type ram_type1 is array (0 downto 0) of std_logic_vector(6 downto 0); -- 1 array of 7 bits (buffer memory for results of 6th level additions)

  signal mem1_i       : std_logic_vector(6 downto 0);
  signal mem1_o       : std_logic_vector(6 downto 0);

  signal dff_stream   : std_logic_vector(63 downto 0); -- Vector for inputs
  signal P           : std_logic_vector(6 downto 0):=(others => '0'); -- Vector for final result
  signal delay_val    : std_logic_vector(8 downto 0):= (others => '0'); --Delay signal

begin
  --Assign the input to the Signal
  process(clk)begin
    if rising_edge(clk) then
      if rst = '1' then
        dff_stream <= "1010101010101010101010101010101010101010101010101010101010101010";
      elsif ((i_val = '1') and ((stream_i(0) = '0') or (stream_i(0) = '1' ))) then
            dff_stream <= stream_i;
      end if;
    end if;
  end process;

  -- Generate 32 adders to add neighbouring bits of input and buffer the results (1st level additions)
  gen_add_1_2 : for i in 0 to 31 generate
    inst_adder_1_2:  entity work.adder(rtl)
      generic map(w_i => 1, w_o => 2)
      port map(
        a(0) => dff_stream(i*2),
        b(0) => dff_stream(i*2+1),
        y => mem32_i(i)
      );
    inst_dff_2 : entity work.register_dff(rtl)
    generic map(w => 2)
      port map(
        clk => clk,
        reset => rst,
        d => mem32_i(i),
        q => mem32_o(i)
      );
  end generate;

  -- Generate 16 adders to add neighbouring bits of input and buffer the results (2nd level additions)
  gen_add_2_3 : for i in 0 to 15 generate
    inst_adder_2_3 : entity work.adder(rtl)
      generic map(w_i => 2, w_o => 3)
      port map(
        a => mem32_o(i*2),
        b => mem32_o(i*2+1),
        y => mem16_i(i)
      );
    inst_dff_3 : entity work.register_dff(rtl)
      generic map(w => 3)
      port map(
        clk => clk,
        reset => rst,
        d => mem16_i(i),
        q => mem16_o(i)
      );
  end generate;

  -- Generate 8 adders to add neighbouring bits of input and buffer the results (3rd level additions)
  gen_add_3_4 : for i in 0 to 7 generate
    inst_adder_3_4 : entity work.adder(rtl)
      generic map(w_i => 3, w_o => 4)
      port map(
        a => mem16_o(i*2),
        b => mem16_o(i*2+1),
        y => mem8_i(i)
      );
    inst_dff_4 : entity work.register_dff(rtl)
      generic map(w => 4)
      port map(
        clk => clk,
        reset => rst,
        d => mem8_i(i),
        q => mem8_o(i)
      );
  end generate;

  -- Generate 4 adders to add neighbouring bits of input and buffer the results (4th level additions)
  gen_add_4_5 : for i in 0 to 3 generate
    inst_adder_4_5 : entity work.adder(rtl)
      generic map (w_i => 4, w_o => 5)
      port map(
        a => mem8_o(i*2),
        b => mem8_o(i*2+1),
        y => mem4_i(i)
      );
    inst_dff_5 : entity work.register_dff(rtl)
      generic map(w => 5)
      port map(
        clk => clk,
        reset => rst,
        d => mem4_i(i),
        q => mem4_o(i)
      );
  end generate;

  -- Generate 2 adders to add neighbouring bits of input and buffer the results (5th level additions)
  gen_add_5_6 : for i in 0 to 1 generate
    inst_adder_5_6 : entity work.adder(rtl)
      generic map(w_i => 5, w_o => 6)
      port map(
        a => mem4_o(i*2),
        b => mem4_o(i*2+1),
        y => mem2_i(i)
      );
    inst_dff_6 : entity work.register_dff(rtl)
      generic map(w => 6)
      port map(
        clk => clk,
        reset => rst,
        d => mem2_i(i),
        q => mem2_o(i)
      );
  end generate;

  -- Generate 1 adder to add neighbouring bits of input and buffer the results (6th level addition)
  inst_adder_6_7 : entity work.adder(rtl)
    generic map(w_i => 6, w_o => 7)
    port map(
      a => mem2_o(0),
      b => mem2_o(1),
      y => mem1_i
    );
  inst_dff_7 : entity work.register_dff(rtl)
    generic map(w => 7)
    port map(
      clk => clk,
      reset => rst,
      d => mem1_i,
      q => mem1_o
    );
-------------------------------------------
  process(mem1_o) begin
    P <= mem1_o;
  end process;

  --Calculate the Finish Signal with help of delay Signal
  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        delay_val <= (others => '0');
        o_val <= '0';
      else
        delay_val <= delay_val(7 downto 0) & i_val;
        if (delay_val(7) = '1') then
          o_val <= '1';
        else
          o_val <= '0';
        end if;
      end if;
    end if;
  end process;

  --Assign The results Vector to the Output
  process(clk)
    begin
      if rising_edge(clk) then
        if rst = '1'then
          stream_o <= (others => '0');
        elsif delay_val(7) = '1' then
          stream_o <= P;
        end if;
      end if;
  end process;

end rtl;
