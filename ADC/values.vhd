library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL; 
 
entity value_display_converter is 
    Port (  
        adc_value : in STD_LOGIC_VECTOR(11 downto 0); 
        display_mode : in STD_LOGIC_VECTOR(1 downto 0); 
        d0 : out STD_LOGIC_VECTOR(3 downto 0); 
        d1 : out STD_LOGIC_VECTOR(3 downto 0); 
        d2 : out STD_LOGIC_VECTOR(3 downto 0); 
        d3 : out STD_LOGIC_VECTOR(3 downto 0) 
    ); 
end value_display_converter; 


architecture Behavioral of value_display_converter is 

    function bin_to_bcd(bin_input : unsigned(11 downto 0)) return STD_LOGIC_VECTOR is 
        variable shift_register : unsigned(11 downto 0); 
        variable bcd_digits : unsigned(15 downto 0) := (others => '0'); 
    begin 
        shift_register := bin_input; 

        for bit_index in 0 to 11 loop 
            -- double dabble
            if bcd_digits(3 downto 0) > 4 then 
                bcd_digits(3 downto 0) := bcd_digits(3 downto 0) + 3; 
            end if; 

            if bcd_digits(7 downto 4) > 4 then 
                bcd_digits(7 downto 4) := bcd_digits(7 downto 4) + 3; 
            end if; 

            if bcd_digits(11 downto 8) > 4 then 
                bcd_digits(11 downto 8) := bcd_digits(11 downto 8) + 3; 
            end if; 

            if bcd_digits(15 downto 12) > 4 then 
                bcd_digits(15 downto 12) := bcd_digits(15 downto 12) + 3; 
            end if; 
             
            bcd_digits := bcd_digits(14 downto 0) & shift_register(11); 
            shift_register := shift_register(10 downto 0) & '0'; 
        end loop; 
         
        return std_logic_vector(bcd_digits); 
    end function;
    
begin 

    process(adc_value, display_mode) 
        variable value_unsigned : unsigned(11 downto 0); 
        variable decimal_bcd : STD_LOGIC_VECTOR(15 downto 0); 
        variable mV : unsigned(15 downto 0); 
        variable voltage_bcd : STD_LOGIC_VECTOR(15 downto 0); 
    begin 
        value_unsigned := unsigned(adc_value); 
         
        case display_mode is 
            when "00" =>  -- Decimaal mode (0-4095) 
                decimal_bcd := bin_to_bcd(value_unsigned); 
                d0 <= decimal_bcd(3 downto 0); 
                d1 <= decimal_bcd(7 downto 4); 
                d2 <= decimal_bcd(11 downto 8); 
                d3 <= decimal_bcd(15 downto 12); 
                 
            when "01" =>  -- Hexadecimaal mode (0xFFF) 
                d3 <= std_logic_vector(value_unsigned(11 downto 8));  -- MSB links 
                d2 <= std_logic_vector(value_unsigned(7 downto 4)); 
                d1 <= std_logic_vector(value_unsigned(3 downto 0));   -- LSB 
                d0 <= "0000";                                          -- Rechts leeg 
                 
            when "10" =>  -- Voltage mode (0.XXX V) 
                -- Voltage conversie: mV = adc_value * 1000 / 4096 
                mV := resize((value_unsigned * to_unsigned(125, 8)) srl 9, 16); 
           
                if mV > 999 then 
                    mV := to_unsigned(999, 16); 
                end if; 

                voltage_bcd := binary_to_bcd(mV(11 downto 0)); 
                 
                d0 <= voltage_bcd(3 downto 0);    -- a
                d1 <= voltage_bcd(7 downto 4);    -- b0 
                d2 <= voltage_bcd(11 downto 8);   -- c00
                d3 <= "0000";                     -- always 0,cba

            when others => 
                d0 <= "1111";
                d1 <= "1111"; 
                d2 <= "1111"; 
                d3 <= "1111"; 
        end case; 
    end process; 
    
end Behavioral;