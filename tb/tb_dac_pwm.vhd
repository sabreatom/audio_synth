library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


entity tb_dac_pwm is
end tb_dac_pwm;

architecture tb of tb_dac_pwm is
    component dac_pwm
        generic (
            COUNTER_PERIOD  : natural := 4095 -- 2**12 -1
            SAMPLE_WIDTH    : natural := 12
        );
        port (
            --datapath:
            din_i           : in std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
            dout_o          : out std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
            wr_i            : in std_logic;
            sample_o        : out std_logic;
            pwm_o           : out std_logic;
        
            --system:
            clk_i           : in std_logic;
            rst_i           : in std_logic;
            en_i            : in std_logic
        );
    end component;

    constant CLK_PERIOD         : time    := 10 ns; --100MHz

    constant COUNTER_PERIOD     : natural := 1023
    constant SAMPLE_WIDTH       : natural := 12

    signal din_i                : std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
    signal dout_o               : std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
    signal wr_i                 : std_logic;
    signal sample_o             : std_logic;
    signal pwm_o                : std_logic;
    signal clk_i                : std_logic;
    signal rst_i                : std_logic;
    signal en_i                 : std_logic;

begin
    dut: dac_pwm
    generic map (
        COUNTER_PERIOD => COUNTER_PERIOD,
        SAMPLE_WIDTH => SAMPLE_WIDTH
    )
    port map (
        din_i => din_i,
        dout_o => dout_o,
        wr_i => wr_i,
        sample_o => sample_o,
        pwm_o => pwm_o,
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
        din_i <= std_logic_vector(to_unsigned(124, SAMPLE_WIDTH));
        wr_i <= '1';
        wait for CLK_PERIOD;
        wr_i <= '0';
        wait for 5 * COUNTER_PERIOD * CLK_PERIOD;
        wait;
    end process stim;
end tb ;