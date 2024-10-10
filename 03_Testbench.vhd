library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity testbench is
end entity;

architecture dataflow of testbench is
  component mips is
    port (
      clk: in std_logic;
      reset: in std_logic
    );
  end component;

  signal l_clk: std_logic := '0';
  signal l_reset: std_logic := '0';
begin

  mipsMain: mips port map(reset => l_reset, clk => l_clk);

  clkProc: process 
  begin
    for i in 0 to 60 loop
      l_clk <= not l_clk;
      wait for 500 ns;
    end loop;

    assert false report "Done Clock" severity note;
    wait;
  end process;

  mainProc: process 
    begin
      l_reset <= '1';
      wait for 1 us;
      l_reset <= '0';
    wait;
  end process;
  
end architecture;