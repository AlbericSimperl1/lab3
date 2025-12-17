
library IEEE; 

use IEEE.STD_LOGIC_1164.ALL; 

use IEEE.NUMERIC_STD.ALL; 

 

entity top is 

    Port (  
        -- std
        clk : in STD_LOGIC;
        -- wizard 
        vauxp6 : in STD_LOGIC; 
        vauxn6 : in STD_LOGIC;
        --  
        sw : in STD_LOGIC_VECTOR(1 downto 0); 
        btnC : in STD_LOGIC; 
        shown_digit : out STD_LOGIC_VECTOR(3 downto 0); 
        segments : out STD_LOGIC_VECTOR(6 downto 0); 
        led : out STD_LOGIC_VECTOR(15 downto 0) 
    ); 

end top; 

 

architecture Behavioral of top is 
    component xadc_wiz_0 
        port ( 
            di_in : in STD_LOGIC_VECTOR(15 downto 0); 
            daddr_in : in STD_LOGIC_VECTOR(6 downto 0); 
            den_in : in STD_LOGIC; 
            dwe_in : in STD_LOGIC; 
            drdy_out : out STD_LOGIC; 
            do_out : out STD_LOGIC_VECTOR(15 downto 0); 
            dclk_in : in STD_LOGIC; 
            reset_in : in STD_LOGIC; 
            vauxp6 : in STD_LOGIC; 
            vauxn6 : in STD_LOGIC; 
            busy_out : out STD_LOGIC; 
            channel_out : out STD_LOGIC_VECTOR(4 downto 0); 
            eoc_out : out STD_LOGIC; 
            eos_out : out STD_LOGIC; 
            alarm_out : out STD_LOGIC 
        ); 
    end component; 

     

    component values 
        Port (  
            value : in STD_LOGIC_VECTOR(11 downto 0); 
            mode : in STD_LOGIC_VECTOR(1 downto 0); 
            digit0 : out STD_LOGIC_VECTOR(3 downto 0); 
            digit1 : out STD_LOGIC_VECTOR(3 downto 0); 
            digit2 : out STD_LOGIC_VECTOR(3 downto 0); 
            digit3 : out STD_LOGIC_VECTOR(3 downto 0) 
        ); 
    end component; 

     

    component display 
        Port (  
            clk : in STD_LOGIC; 
            rst : in STD_LOGIC; 
            d0 : in STD_LOGIC_VECTOR(3 downto 0); 
            d1 : in STD_LOGIC_VECTOR(3 downto 0); 
            d2 : in STD_LOGIC_VECTOR(3 downto 0); 
            d3 : in STD_LOGIC_VECTOR(3 downto 0); 
            shown_digit : out STD_LOGIC_VECTOR(3 downto 0); 
            segments : out STD_LOGIC_VECTOR(6 downto 0) 
        ); 
    end component; 

     

    signal adc_data : STD_LOGIC_VECTOR(15 downto 0); 
    signal adc_value : STD_LOGIC_VECTOR(11 downto 0); 
    signal eoc : STD_LOGIC; 
    signal d0, d1, d2, d3 : STD_LOGIC_VECTOR(3 downto 0); 
    
begin 
    xadc_inst : xadc_wiz_0 
        port map ( 
            dclk_in => clk, 
            reset_in => btnC, 
            vauxp6 => vauxp6, 
            vauxn6 => vauxn6, 
            di_in => (others => '0'), 
            daddr_in => "0010110",
            den_in => eoc, 
            dwe_in => '0', 
            drdy_out => open, 
            do_out => adc_data, 
            eoc_out => eoc, 
            channel_out => open, 
            busy_out => open, 
            eos_out => open, 
            alarm_out => open 
        ); 

    adc_value <= adc_data(15 downto 4); 

    led <= adc_data; 

    values : values 
        port map ( 
            value => adc_value, 
            mode => sw(1 downto 0), 
            digit0 => d0,
            digit1 => d1, 
            digit2 => d2, 
            digit3 => d3 
        ); 
     
    -- Display driver 
    display : display 
        port map ( 
            clk => clk,
            reset => btnC, 
            d0 => d0, 
            d1 => d1, 
            d2 => d2, 
            d3 => d3, 
            shown_digit => shown_digit, 
            segments => segments 
        ); 
end Behavioral; 