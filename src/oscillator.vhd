library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;    -- for the unsigned type

library work;
use work.waveform_lut_pkg.all;

entity oscillator is
  generic (
    CNTRL_WIDTH : natural := 8;
    DATA_WIDTH  : natural := 24
    );
  port (
    --datapath:
    din_i           : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    dout_o          : out std_logic_vector(DATA_WIDTH - 1 downto 0);

    --control:
    freq_i          : in std_logic_vector(CNTRL_WIDTH - 1 downto 0);
    phase_i         : in std_logic_vector(CNTRL_WIDTH - 1 downto 0);
    waveform_sel_i  : in std_logic_vector(2 downto 0);

    --system:
    clk_i           : in std_logic;
    rst_i           : in std_logic;
    en_i            : in std_logic
    );
end entity oscillator;

architecture rtl of oscillator is

----------------------------------------
--Signals:
----------------------------------------

signal freq_val_sig             : unsigned(CNTRL_WIDTH - 1 downto 0);
signal phase_cntr_val_sig       : unsigned(CNTRL_WIDTH - 1 downto 0);

signal phase_val_sig            : unsigned(CNTRL_WIDTH - 1 downto 0);

signal waveform_sel_sig         : std_logic_vector(2 downto 0);

signal waveform_out_sig         : unsigned(DATA_WIDTH - 1 downto 0);

----------------------------------------

begin

----------------------------------------
--Frequency register:
----------------------------------------

freq_reg: process(clk_i, rst_i, en_i, freq_i)
begin
    if rising_edge() then
        if (rst_i = '1') then
            freq_val_sig <= (others => '0');
        else
            if (en_i = '1') then
                freq_val_sig <= unsigned(freq_i);
            else
                freq_val_sig <= freq_val_sig;
            end if;
        end if;
    end if;
end process freq_reg;

----------------------------------------
--Phase register:
----------------------------------------

phase_reg: process(clk_i, rst_i, en_i, phase_i)
begin
    if rising_edge() then
        if (rst_i = '1') then
            phase_val_sig <= (others => '0');
        else
            if (en_i = '1') then
                phase_val_sig <= unsigned(phase_i);
            else
                phase_val_sig <= phase_val_sig;
            end if;
        end if;
    end if;
end process phase_reg;

----------------------------------------
--Phase counter:
----------------------------------------

phase_cntr: process(clk_i, rst_i, en_i, freq_val_sig):
begin
    if rising_edge() then
        if (rst_i = '1') then
            phase_cntr_val_sig <= (others => '0');
        else
            if (en_i = '1') then
                phase_cntr_val_sig <= phase_cntr_val_sig + freq_val_sig;
            else
                phase_cntr_val_sig <= phase_cntr_val_sig;
            end if;
        end if;
    end if;
end process phase_cntr;

----------------------------------------
--Waveform select register:
----------------------------------------

waveform_sel_reg: process(clk_i, rst_i, en_i, waveform_sel_i)
begin
    if rising_edge() then
        if (rst_i = '1') then
            waveform_sel_sig <= (others => '0');
        else
            if (en_i = '1') then
                waveform_sel_sig <= waveform_sel_i;
            else
                waveform_sel_sig <= waveform_sel_sig;
            end if;
        end if;
    end if;
end process waveform_sel_reg;

----------------------------------------
--Waveform output register:
----------------------------------------

waveform_out_reg: process(clk_i, rst_i, waveform_out_sig)
begin
    if rising_edge() then
        if (rst_i = '1') then
            dout_o <= (others => '0');
        else
            dout_o <= waveform_out_sig;
        end if;
    end if;
end process waveform_out_reg;

----------------------------------------
--Waveform lookup tables:
----------------------------------------

waveform_out_sig <= sine_lut(to_integer(unsinged(phase_cntr_val_sig)));

----------------------------------------

end architecture rtl;