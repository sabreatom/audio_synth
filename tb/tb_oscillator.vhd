library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


entity tb_oscillator is
end tb_oscillator;

architecture tb of tb_oscillator is
    component oscillator
        generic (
          CNTRL_WIDTH : natural := 8;
          DATA_WIDTH  : natural := 24
          );
        port (
          dout_o          : out std_logic_vector(DATA_WIDTH - 1 downto 0);
          freq_i          : in std_logic_vector(CNTRL_WIDTH - 1 downto 0);
          phase_i         : in std_logic_vector(CNTRL_WIDTH - 1 downto 0);
          waveform_sel_i  : in std_logic_vector(2 downto 0);
          clk_i           : in std_logic;
          rst_i           : in std_logic;
          en_i            : in std_logic
          );
    end component;

    constant CNTRL_WIDTH    : natural := 8;
    constant DATA_WIDTH     : natural := 24;
    constant CLK_PERIOD     : time    := 10 ns;

    signal dout_o           : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal freq_i           : std_logic_vector(CNTRL_WIDTH - 1 downto 0);
    signal phase_i          : std_logic_vector(CNTRL_WIDTH - 1 downto 0);
    signal waveform_sel_i   : std_logic_vector(2 downto 0);
    signal clk_i            : std_logic;
    signal rst_i            : std_logic;
    signal en_i             : std_logic;
begin
    -- connecting testbench signals with half_adder.vhd
  dut: oscillator
    generic map (
      CNTRL_WIDTH => CNTRL_WIDTH,
      DATA_WIDTH  => DATA_WIDTH
    )
    port map (
        dout_o => dout_o,
        freq_i => freq_i,
        phase_i => phase_i,
        waveform_sel_i => waveform_sel_i,
        clk_i => clk_i,
        rst_i => rst_i,
        en_i => en_i
    );

  clk_gen: process
  begin
    clk_i <= '0';
    wait for CLK_PERIOD / 2;
    clk_i <= '1';
    wait for CLK_PERIOD / 2;
  end process clk_gen;

  stim: process
  begin
    rst_i <= '1';
    en_i <= '1';
    wait for CLK_PERIOD;
    rst_i <= '0';
    freq_i <= std_logic_vector(to_unsigned(1, CNTRL_WIDTH));
    phase_i <= std_logic_vector(to_unsigned(0, CNTRL_WIDTH));
    waveform_sel_i <= "000";
    wait for 3000 ns;
    freq_i <= std_logic_vector(to_unsigned(10, CNTRL_WIDTH));
    wait for 100 ns;
    wait;
  end process stim;
end tb ;