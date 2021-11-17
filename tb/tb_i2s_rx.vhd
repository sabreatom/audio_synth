library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


entity tb_i2s_rx is
end tb_i2s_rx;

architecture tb of tb_i2s_rx is
    component i2s_rx
        generic (
            SAMPLE_WIDTH    : natural := 24
          );
        port (
            sd_i            : in std_logic;
            ws_i            : in std_logic;
            sck_i           : in std_logic;
            r_dout_o        : out std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
            l_dout_o        : out std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
            rdy_o           : out std_logic;
            clk_i           : in std_logic;
            rst_i           : in std_logic;
            en_i            : in std_logic
          );
    end component;

    constant SAMPLE_WIDTH       : natural := 24;
    constant CLK_PERIOD         : time    := 10 ns; --100MHz
    constant SCK_PERIOD         : time    := 10400 ns; --96kHz

    signal sd_i             : std_logic;
    signal ws_i             : std_logic;
    signal sck_i            : std_logic;
    signal r_dout_o         : std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
    signal l_dout_o         : std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
    signal rdy_o            : std_logic;
    signal clk_i            : std_logic;
    signal rst_i            : std_logic;
    signal en_i             : std_logic;

begin

  dut: i2s_rx
    generic map (
        SAMPLE_WIDTH => SAMPLE_WIDTH
    )
    port map (
            sd_i => sd_i,
            ws_i => ws_i,
            sck_i => sck_i,
            r_dout_o => r_dout_o,
            l_dout_o => l_dout_o,
            rdy_o => rdy_o,
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

  sck_gen: process
  begin
    clk_i <= '0';
    wait for SCK_PERIOD / 2;
    clk_i <= '1';
    wait for SCK_PERIOD / 2;
  end process sck_gen;

  stim: process
  begin
    rst_i <= '1';
    en_i <= '1';
    wait for CLK_PERIOD;

    wait for 100 ns;
    wait;
  end process stim;
end tb ;