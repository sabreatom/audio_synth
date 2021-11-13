library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;    -- for the unsigned type

entity i2s_rx is
  generic (
    SAMPLE_WIDTH  : natural := 24
    );
  port (
    --I2S interface:
    sd_i            : in std_logic;
    ws_i            : in std_logic;
    sck_i           : in std_logic;

    --parallel interface:
    r_dout_o        : out std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
    l_dout_o        : out std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
    rdy_o           : out std_logic;

    --system:
    clk_i           : in std_logic;
    rst_i           : in std_logic;
    en_i            : in std_logic
    );
end entity i2s_rx;

architecture rtl of i2s_rx is

----------------------------------------
--Signals:
----------------------------------------

signal r_reg_wr_sig                 : std_logic;
signal r_reg_dout_sig               : std_logic_vector(SAMPLE_WIDTH - 1 downto 0);

signal l_reg_wr_sig                 : std_logic;
signal l_reg_dout_sig               : std_logic_vector(SAMPLE_WIDTH - 1 downto 0);

signal sck_prev_sig                 : std_logic;
signal sck_rising_edge_sig          : std_logic;

signal ws_sig                       : std_logic;

signal ws_prev_sig                  : std_logic;
signal ws_rising_edge_sig           : std_logic;

----------------------------------------

begin

----------------------------------------
--Right channel register:
----------------------------------------

r_reg: process(clk_i, rst_i, sd_i, r_reg_wr_sig, sck_rising_edge_sig)
begin
    if rising_edge(clk_i) then
        if (rst_i = '1') then
            r_reg_dout_sig <= (others => '0');
        else
            if ((r_reg_wr_sig = '1') and (sck_rising_edge_sig = '1')) then
                r_reg_dout_sig <= r_reg_dout_sig(SAMPLE_WIDTH - 2 downto 0) & sd_i;
            else
                r_reg_dout_sig <= r_reg_dout_sig;
            end if;
        end if;
    end if;
end process r_reg;

----------------------------------------
--Left channel register:
----------------------------------------

l_reg: process(clk_i, rst_i, sd_i, l_reg_wr_sig, sck_rising_edge_sig)
begin
    if rising_edge(clk_i) then
        if (rst_i = '1') then
            l_reg_dout_sig <= (others => '0');
        else
            if ((l_reg_wr_sig = '1') and (sck_rising_edge_sig = '1')) then
                l_reg_dout_sig <= l_reg_dout_sig(SAMPLE_WIDTH - 2 downto 0) & sd_i;
            else
                l_reg_dout_sig <= l_reg_dout_sig;
            end if;
        end if;
    end if;
end process l_reg;

----------------------------------------
--SCK rising edge detector:
----------------------------------------

sck_edge_det: process(clk_i, rst_i, sck_i, en_i)
begin
    if rising_edge(clk_i) then
        if (rst_i = '1') then
            sck_prev_sig <= '1';
        else
            if (en_i = '1') then
                sck_prev_sig <= sck_i;
            else
                sck_prev_sig <= sck_prev_sig;
            end if;
        end if;
    end if;
end process sck_edge_det;

sck_rising_edge_sig <= sck_i and (not sck_prev_sig);

----------------------------------------
--WS FF:
----------------------------------------

ws_ff: process(clk_i, rst_i, ws_i, sck_rising_edge_sig)
begin
    if rising_edge(clk_i) then
        if (rst_i = '1') then
            ws_sig <= '0';
        else
            if (sck_rising_edge_sig = '1') then
                ws_sig <= ws_i;
            else
                ws_sig <= ws_sig;
            end if;
        end if;
    end if;
end process ws_ff;

r_reg_wr_sig <= ws_sig;
l_reg_wr_sig <= not ws_sig;

----------------------------------------
--WS rising edge detector:
----------------------------------------

ws_edge_det: process(clk_i, rst_i, ws_i, sck_rising_edge_sig)
begin
    if rising_edge(clk_i) then
        if (rst_i = '1') then
            ws_prev_sig <= '1';
        else
            if (sck_rising_edge_sig = '1') then
                ws_prev_sig <= ws_i;
            else
                ws_prev_sig <= ws_prev_sig;
            end if;
        end if;
    end if;
end process ws_edge_det;

ws_rising_edge_sig <= ws_i and (not ws_prev_sig);

----------------------------------------
--RDY FF:
----------------------------------------

rdy_ff: process(clk_i, rst_i, sck_rising_edge_sig, ws_rising_edge_sig)
begin
    if rising_edge(clk_i) then
        if (rst_i = '1') then
            rdy_o <= '0';
        else
            if (sck_rising_edge_sig = '1') then
                rdy_o <= ws_rising_edge_sig;
            else
                rdy_o <= '0';
            end if;
        end if;
    end if;
end process rdy_ff;

----------------------------------------

end architecture rtl;