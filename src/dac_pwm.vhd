library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;    -- for the unsigned type

entity dac_pwm is
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
end entity dac_pwm;

architecture rtl of dac_pwm is

----------------------------------------
--Signals:
----------------------------------------

signal data_reg_dout_sig            : std_logic_vector(SAMPLE_WIDTH - 1 downto 0);

signal period_end_sig               : std_logic;

signal duty_reg_dout_sig            : std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
signal duty_comp_dout_sig           : std_logic;

signal period_counter_value_sig     : std_logic_vector(SAMPLE_WIDTH - 1 downto 0);

signal pwm_sig                      : std_logic;

signal sample_ff_dout_sig           : std_logic;

----------------------------------------

begin

----------------------------------------
--Data register:
----------------------------------------

data_reg: process(clk_i, rst_i, en_i, wr_i, din_i)
begin
    if rising_edge(clk_i) then
        if (rst_i = '1') then
            data_reg_dout_sig <= (others => '0');
        else
            if (en_i = '1') and (wr_i = '1') then
                data_reg_dout_sig <= din_i;
            else
                data_reg_dout_sig <= data_reg_dout_sig;
            end if;
        end if;
    end if;
end process data_reg;

----------------------------------------
--Duty cycle register:
----------------------------------------

duty_reg: process(clk_i, rst_i, en_i, period_end_sig, data_reg_dout_sig)
begin
    if rising_edge(clk_i) then
        if (rst_i = '1') then
            duty_reg_dout_sig <= (others => '0');
        else
            if (en_i = '1') and (period_end_sig = '1') then
                duty_reg_dout_sig <= data_reg_dout_sig;
            else
                duty_reg_dout_sig <= duty_reg_dout_sig;
            end if;
        end if;
    end if;
end process duty_reg;

----------------------------------------
--Duty cycle comparator:
----------------------------------------

duty_comp_dout_sig <=   '1' when unsigned(period_counter_value_sig) < unsigned(duty_reg_dout_sig) else
                        '0';

----------------------------------------
--PWM FF:
----------------------------------------

pwm_ff: process(clk_i, rst_i, en_i, duty_comp_dout_sig)
begin
    if rising_edge(clk_i) then
        if (rst_i = '1') then
            pwm_sig <= '0';
        else
            if (en_i = '1') then
                pwm_sig <= duty_comp_dout_sig;
            else
                pwm_sig <= pwm_sig;
            end if;
        end if;
    end if;
end process pwm_ff;

pwm_o <= pwm_sig;

----------------------------------------
--Period counter:
----------------------------------------

period_cntr: process(clk_i, rst_i, en_i, period_end_sig)
begin
    if rising_edge(clk_i) then
        if (rst_i = '1') then
            period_counter_value_sig <= (others => '0');
        else
            if (en_i = '1') then
                if (period_end_sig = '1') then
                    period_counter_value_sig <= (others => '0');
                else
                    period_counter_value_sig <= std_logic_vector(unsigned(period_counter_value_sig) + 1);
                end if;
            else
                period_counter_value_sig <= period_counter_value_sig;
            end if;
        end if;
    end if;
end process period_cntr;

----------------------------------------
--Period comparator:
----------------------------------------

period_end_sig <=   '1' when to_integer(unsigned(period_counter_value_sig)) >= COUNTER_PERIOD else
                    '0';

----------------------------------------
--Sample FF:
----------------------------------------

sample_ff: process(clk_i, rst_i, en_i, period_end_sig)
begin
    if rising_edge(clk_i) then
        if (rst_i = '1') then
            sample_ff_dout_sig <= '0';
        else
            if (en_i = '1') then
                sample_ff_dout_sig <= period_end_sig;
            else
                sample_ff_dout_sig <= sample_ff_dout_sig;
            end if;
        end if;
    end if;
end process sample_ff;

sample_o <= sample_ff_dout_sig;

----------------------------------------

end architecture rtl;